--------------------------------------------------------------------------------
-- Bartender3 InlineAuras (c) 2014 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

if not Bartender3 then return end

local abs = abs
local pairs = pairs
local strsub = strsub
local tonumber = tonumber
local bar3 = Bartender3
local GetActionInfo = GetActionInfo
local GetSpellInfo = GetSpellInfo
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

local auras = {}

hooksecurefunc(Bartender3.Class.Button.prototype, "UpdateButton", function(self)
    if not HasAction(self.action) then return end
    local type, idx = GetActionInfo(self.action)
    if type ~= "spell" then return end
    local name, rank = GetSpellInfo(idx, "SPELLBOOK")
    local aura = auras[name]
    local br = self.frame.border

    if aura and abs(aura) == (tonumber(strsub(rank, 6, 6)) or 0) then
        br:SetVertexColor(aura < 0 and 1 or 0, aura > 0 and 1 or 0, 0, 1)
        br:Show()
    else
        br:Hide()
    end
end)

local Auras = CreateFrame("Frame", "Bar3_InlineAuras")

Auras:SetScript("OnEvent", function(self, event, unit)
    unit = unit or "target"
    if unit ~= "target" then return end
    for k in pairs(auras) do auras[k] = nil end

    for i = 1, 50 do
        local buff, rank = UnitBuff(unit, i)
        if not buff then break end
        auras[buff] = tonumber(strsub(rank, 6, 6) or 0)
    end

    for i = 1, 50 do
        local buff, rank = UnitDebuff(unit, i)
        if not buff then break end
        auras[buff] = -tonumber(strsub(rank, 6, 6) or 0)
    end

    bar3:RefreshBars()
end)

Auras:RegisterEvent("PLAYER_TARGET_CHANGED")
Auras:RegisterEvent("UNIT_AURA")
