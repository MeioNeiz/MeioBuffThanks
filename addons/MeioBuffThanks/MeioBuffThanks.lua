-- MeioBuffThanks: another player's long buff on you (Fortitude, Mark of the Wild, Kings...) gets
-- a whisper and/or a /thank emote, with a random line from MeioBuffThanksDB.messages.
--
-- No combat log on Forever, so the caster comes from the aura's sourceUnit, which is only
-- set when the caster has a unit token (group, target, mouseover, a shown nameplate): a
-- stranger with none can't be named, so gets nothing. Aura fields can be secret in combat:
-- skipped then. No SAY: outside instances it needs a key press on modern clients.

local ADDON, ns = ...
local issecret = issecretvalue or function() return false end
local canaccess = canaccessvalue or function() return true end

-- seconds before thanking: gathers several buffs from one caster into one line, and a
-- random wait reads like a person typing (players mute instant, bot-like thanks)
local WAIT_MIN, WAIT_MAX = 2, 6
local RETRY, TRIES = 5, 6  -- chat lockdown (boss fights): wait up to 30 s, then drop it

ns.DEFAULT_MESSAGES = {
    "Thanks {name}!",
    "Thanks for the {spell}, {name}.",
    "Cheers {name}, much appreciated.",
    "Ty for the {spell}, {name}.",
    "Thanks {name}, that'll come in handy.",
    "Cheers for the {spell}, {name}.",
}

local DEFAULTS = { enabled = true, whisper = true, emote = false, group = false,
    minMinutes = 5, cooldown = 15 }

local db
local pending = {}
local lastLine

local function Say(msg) print("|cffb090ffMeioBuffThanks:|r " .. msg) end
ns.Say = Say

local function Readable(v) return v ~= nil and not issecret(v) and canaccess(v) end

-- a unit query that may answer a secret, or error on a stale token: nil unless plain
local function Ask(fn, ...)
    local ok, v = pcall(fn, ...)
    if ok and Readable(v) then return v end
end

local function Names(unit)
    local ok, name, realm = pcall(UnitName, unit)
    if not ok or name == nil or not canaccessvalue(name) then return end
    if name == "" or name == UNKNOWNOBJECT then return end
    if realm ~= nil and canaccessvalue(realm) and realm ~= "" then
        return name .. "-" .. realm, name
    end
    return name, name
end

local function Caster(a)
    if not Readable(a) or type(a) ~= "table" or not Readable(a.isHelpful) or not a.isHelpful then return end
    local d = a.duration
    if not Readable(d) or type(d) ~= "number" or d < db.minMinutes * 60 then return end
    local unit = a.sourceUnit
    if not Readable(unit) or type(unit) ~= "string" then return end
    if not Ask(UnitIsPlayer, unit) or Ask(UnitIsUnit, unit, "player") ~= false then return end
    if not db.group and (Ask(UnitInParty, unit) or Ask(UnitInRaid, unit)) then return end
    return unit
end

local function Join(list)
    if #list == 1 then return list[1] end
    return table.concat(list, ", ", 1, #list - 1) .. " and " .. list[#list]
end

function ns.Fill(line, name, spell)
    return (line:gsub("{(%a+)}", function(key)
        key = key:lower()
        if key == "name" then return name elseif key == "spell" then return spell end
    end))
end

-- this character's own lines if it has any, else the shared ones
function ns.Messages()
    local own = MeioBuffThanksCharDB.messages
    return own or db.messages
end

-- never the same line twice running
function ns.PickLine(lines)
    lines = lines or ns.Messages()
    if #lines <= 1 then return lines[1] end
    local i
    repeat i = math.random(#lines) until i ~= lastLine
    lastLine = i
    return lines[i]
end

local function Lockdown()
    local check = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    if not check then return false end
    local ok, v = pcall(check)
    return not ok or not Readable(v) or v and true or false
end

local function OnCooldown(full)
    local last = db.thanked[full]
    return last and time() - last < db.cooldown * 60
end

local function Flush(full)
    local p = pending[full]
    if not p or not db.enabled or OnCooldown(full) then
        pending[full] = nil
        return
    end
    if Lockdown() then
        p.tries = p.tries + 1
        if p.tries > TRIES then pending[full] = nil return end
        C_Timer.After(RETRY, function() Flush(full) end)
        return
    end
    pending[full] = nil
    db.thanked[full] = time()
    local line = db.whisper and ns.PickLine()
    if line then
        C_ChatInfo.SendChatMessage(ns.Fill(line, p.short, Join(p.spells)), "WHISPER", nil, full)
    end
    if db.emote then C_ChatInfo.PerformEmote("THANK", full) end
end

local function OnAura(info)
    if not db.enabled or not Readable(info) or type(info) ~= "table" then return end
    local full, added = info.isFullUpdate, info.addedAuras
    if issecret(full) or not canaccess(full) or full or not Readable(added) then return end
    for _, a in ipairs(added) do
        local unit = Caster(a)
        local full, short
        if unit then full, short = Names(unit) end
        if full and not OnCooldown(full) then
            local spell = Readable(a.name) and a.name or "buff"
            local p = pending[full]
            if not p then
                p = { short = short, spells = {}, tries = 0 }
                pending[full] = p
                local wait = WAIT_MIN + math.random() * (WAIT_MAX - WAIT_MIN)
                C_Timer.After(wait, function() Flush(full) end)
            end
            if not tContains(p.spells, spell) then table.insert(p.spells, spell) end
        end
    end
end

local function Prune()
    local now = time()
    for name, at in pairs(db.thanked) do
        if now - at > db.cooldown * 60 then db.thanked[name] = nil end
    end
end

local function Init()
    MeioBuffThanksDB = MeioBuffThanksDB or {}
    db = MeioBuffThanksDB
    for k, v in pairs(DEFAULTS) do if db[k] == nil then db[k] = v end end
    if type(db.messages) ~= "table" then db.messages = CopyTable(ns.DEFAULT_MESSAGES) end
    db.thanked = db.thanked or {}
    ns.db = db
    MeioBuffThanksCharDB = MeioBuffThanksCharDB or {}
    if type(MeioBuffThanksCharDB.messages) ~= "table" then MeioBuffThanksCharDB.messages = nil end
    Prune()
end

------------------------------------------------------------------------------- commands

local function OnOff(v) return v and "|cff40ff40on|r" or "|cffff4040off|r" end

local TOGGLES = {
    whisper = "Whisper a thank you line",
    emote = "/thank emote at them",
    group = "Also thank party and raid members",
}

local function Help()
    Say("thanks players who buff you. Settings: /buffthanks")
    print("  /buffthanks on||off: all of it (now " .. OnOff(db.enabled) .. ")")
    for _, key in ipairs({ "whisper", "emote", "group" }) do
        print(("  /buffthanks %s on||off: %s (now %s)"):format(key, TOGGLES[key], OnOff(db[key])))
    end
    print("  /buffthanks messages: edit your thank you lines (shared, or this character's own)")
    print("  /buffthanks test: show a random line, filled in, here (sends nothing)")
end

function ns.Test(lines)
    local line = ns.PickLine(lines)
    if not line then Say("no messages yet: /buffthanks messages") return end
    Say("would whisper: " .. ns.Fill(line, "Ancuta", "Power Word: Fortitude"))
end

SLASH_MEIOBUFFTHANKS1 = "/buffthanks"
SlashCmdList.MEIOBUFFTHANKS = function(msg)
    local cmd, arg = strtrim(msg or ""):lower():match("^(%S*)%s*(.-)$")
    if cmd == "" then
        if not ns.OpenSettings() then Help() end
    elseif cmd == "help" then
        Help()
    elseif cmd == "on" or cmd == "off" then
        db.enabled = cmd == "on"
        Say("thanking buffers " .. OnOff(db.enabled))
    elseif TOGGLES[cmd] and (arg == "on" or arg == "off") then
        db[cmd] = arg == "on"
        Say(TOGGLES[cmd] .. ": " .. OnOff(db[cmd]))
    elseif cmd == "messages" then
        ns.OpenMessages()
    elseif cmd == "test" then
        ns.Test()
    else
        Help()
    end
end

function MeioBuffThanks_OnAddonCompartmentClick()
    if not ns.OpenSettings() then Help() end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterUnitEvent("UNIT_AURA", "player")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then Init() end
    elseif db then
        OnAura(arg2)
    end
end)
