-- The message editor: one line per message, saved into MeioBuffThanksDB.messages on Save.
local _, ns = ...

local WIDTH, HEIGHT = 480, 320
local window, edit

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
    window.Inset:SetPoint("TOPLEFT", 8, -58)
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
        ns.db.messages = Lines(edit:GetText())
        ns.Say(("%d messages saved."):format(#ns.db.messages))
        window:Hide()
    end)
    save:SetPoint("BOTTOMRIGHT", -10, 7)
    local test = Button("Test", "Show a random line from the box, filled in, in your chat. "
        .. "Sends nothing.", function() ns.Test(Lines(edit:GetText())) end)
    test:SetPoint("RIGHT", save, "LEFT", -6, 0)
    local defaults = Button("Defaults", "Put the starter lines back in the box (Save to keep "
        .. "them).", function() Load(ns.DEFAULT_MESSAGES) end)
    defaults:SetPoint("BOTTOMLEFT", 10, 7)

    window:SetScript("OnShow", function() Load(ns.db.messages) end)
    window:Hide()
end

function ns.OpenMessages()
    if not window then Create() end
    window:Show()
end
