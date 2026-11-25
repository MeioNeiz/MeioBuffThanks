-- The message editor: one line per message. Save writes the shared list (MeioBuffThanksDB) or,
-- with "own lines" ticked, this character's (MeioBuffThanksCharDB); unticking drops them.
local _, ns = ...

local WIDTH, HEIGHT = 480, 344
local window, edit, own

local function Lines(text)
    local out = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        line = strtrim(line)
        if line ~= "" then out[#out + 1] = line end
    end
    return out
end
ns.Lines = Lines

local function Load(lines) edit:SetText(table.concat(lines, "\n")) end

local function Button(text, tip, onClick)
    local b = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    b:SetSize(90, 22)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(text)
        GameTooltip:AddLine(tip, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    return b
end

local function Create()
    window = CreateFrame("Frame", "MeioBuffThanksMessages", UIParent, "ButtonFrameTemplate")
    ButtonFrameTemplate_HidePortrait(window)
    if window.SetTitle then window:SetTitle("MeioBuffThanks messages") end
    window:SetSize(WIDTH, HEIGHT)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetToplevel(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", function(self) self:StartMoving() end)
    window:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    tinsert(UISpecialFrames, window:GetName())

    local hint = window:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 14, -30)
    hint:SetPoint("RIGHT", -14, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText("One message per line, picked at random. {name} is who buffed you, {spell} "
        .. "what they cast.")

    window.Inset:ClearAllPoints()
    own = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
    own:SetSize(24, 24)
    own:SetPoint("TOPLEFT", 10, -52)
    local ownText = own:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ownText:SetPoint("LEFT", own, "RIGHT", 2, 0)
    own.label = ownText
    own:SetScript("OnClick", function(self)
        -- the box keeps its text either way: ticking starts this character's list from it
        if not self:GetChecked() and MeioBuffThanksCharDB.messages then
            Load(ns.db.messages)
        end
    end)
    own:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(self.label:GetText())
        GameTooltip:AddLine("Ticked: these lines are used only on this character; your other "
            .. "characters keep the shared list. Unticked: this character uses the shared list "
            .. "(Save drops its own lines).", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    own:SetScript("OnLeave", GameTooltip_Hide)
    window.own = own

    window.Inset:SetPoint("TOPLEFT", 8, -80)
    window.Inset:SetPoint("BOTTOMRIGHT", -8, 34)

    local scroll = CreateFrame("ScrollFrame", nil, window.Inset, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(WIDTH - 56)
    edit:SetScript("OnEscapePressed", edit.ClearFocus)
    scroll:SetScrollChild(edit)
    scroll:SetScript("OnSizeChanged", function(_, w) edit:SetWidth(w) end)
    scroll:SetScript("OnMouseDown", function() edit:SetFocus() end)
    window.edit = edit

    local save = Button("Save", "Keep these lines.", function()
        local lines = Lines(edit:GetText())
        if own:GetChecked() then
            MeioBuffThanksCharDB.messages = lines
            ns.Say(("%d messages saved for %s only."):format(#lines, UnitName("player")))
        else
            MeioBuffThanksCharDB.messages = nil
            ns.db.messages = lines
            ns.Say(("%d shared messages saved."):format(#lines))
        end
        window:Hide()
    end)
    save:SetPoint("BOTTOMRIGHT", -10, 7)
    local test = Button("Test", "Show a random line from the box, filled in, in your chat. "
        .. "Sends nothing.", function() ns.Test(Lines(edit:GetText())) end)
    test:SetPoint("RIGHT", save, "LEFT", -6, 0)
    local defaults = Button("Defaults", "Put the starter lines back in the box (Save to keep "
        .. "them).", function() Load(ns.DEFAULT_MESSAGES) end)
    defaults:SetPoint("BOTTOMLEFT", 10, 7)

    window:SetScript("OnShow", function()
        own.label:SetText(("Own lines for %s"):format(UnitName("player") or "this character"))
        own:SetChecked(MeioBuffThanksCharDB.messages ~= nil)
        Load(ns.Messages())
    end)
    window:Hide()
end

function ns.OpenMessages()
    if not window then Create() end
    window:Show()
end
