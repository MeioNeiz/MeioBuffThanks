-- Options panel: Esc > Options > AddOns > MeioBuffThanks, or /buffthanks. Writes into MeioBuffThanksDB.
local _, ns = ...

local category, layout

local function Header(title, tip)
    if layout and CreateSettingsListSectionHeaderInitializer then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title, tip))
    end
end

local function Checkbox(key, name, tip, default)
    local setting = Settings.RegisterAddOnSetting(category, "MEIOBUFFTHANKS_" .. key:upper(), key,
        ns.db, Settings.VarType.Boolean, name, default)
    Settings.CreateCheckbox(category, setting, tip)
end

local function Slider(key, name, default, min, max, step, tip)
    local setting = Settings.RegisterAddOnSetting(category, "MEIOBUFFTHANKS_" .. key:upper(), key,
        ns.db, Settings.VarType.Number, name, default)
    local options = Settings.CreateSliderOptions(min, max, step)
    if MinimalSliderWithSteppersMixin then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(v) return ("%d min"):format(v) end)
    end
    Settings.CreateSlider(category, setting, options, tip)
end

local function Register()
    if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
    category, layout = Settings.RegisterVerticalLayoutCategory("MeioBuffThanks")

    Header("Thank players who buff you", "Long buffs another player casts on you: "
        .. "Fortitude, Mark of the Wild, Intellect, Kings... Not heals, shields or short buffs. "
        .. "Only someone the game can name: in your group, targeted, under the mouse or with "
        .. "a nameplate showing.")
    Checkbox("enabled", "Thank buffers", "Switch everything on or off. "
        .. "/buffthanks on||off", true)
    Checkbox("whisper", "Whisper a line", "Whisper them a random line from your messages. "
        .. "/buffthanks whisper on||off", true)
    Checkbox("emote", "/thank emote", "Do the /thank emote at them as well (or instead, with "
        .. "whispers off). /buffthanks emote on||off", false)
    Checkbox("group", "Thank your group", "Off: only players outside your "
        .. "group, so a party buffing each other isn't flooded with whispers. "
        .. "/buffthanks group on||off", false)
    Slider("minMinutes", "Buffs of at least", 5, 1, 30, 1, "Shorter buffs are ignored. "
        .. "5 minutes skips Battle Shout and short procs but keeps Blessings.")
    Slider("cooldown", "Thank again after", 15, 1, 60, 1, "A player who buffs you again "
        .. "within this time isn't thanked again.")

    if CreateSettingsButtonInitializer then
        layout:AddInitializer(CreateSettingsButtonInitializer("Messages", "Edit",
            function() ns.OpenMessages() end, "Edit your thank you lines (same as "
            .. "/buffthanks messages).", true))
        layout:AddInitializer(CreateSettingsButtonInitializer("Try it", "Test",
            function() ns.Test() end, "Show a random line, filled in, in your chat. Sends "
            .. "nothing (same as /buffthanks test).", true))
    end
    Settings.RegisterAddOnCategory(category)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    local ok, err = pcall(Register)
    if not ok then geterrorhandler()(err) end
end)

function ns.OpenSettings()
    if not category then return false end
    Settings.OpenToCategory(category:GetID())
    return true
end
