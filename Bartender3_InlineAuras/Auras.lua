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

local buffs = {}
local debuffs = {}

-- Target (de)buff to player spell map
local aliases = {
    ["Fire Vulnerability"] = "Scorch"
}

-- Spells that ignore rank check
local ignore_rank = {
    ["Scorch"] = true
}

hooksecurefunc(Bartender3.Class.Button.prototype, "UpdateButton", function(self)
    if not HasAction(self.action) then return end
    local type, idx, name, rank = GetActionInfo(self.action)

    if type == "spell" then
        name, rank = GetSpellInfo(idx, "SPELLBOOK")
    elseif type == "macro" then
        name, rank = GetMacroSpell(idx)
    else
        return
    end

    local buff = buffs[name]
    local debuff = debuffs[name]
    local br = self.frame.border

    if buff and (ignore_rank[name] or buff == rank)
    or debuff and (ignore_rank[name] or debuff == rank) then
        if not br:IsShown() then
            br:SetVertexColor(debuff and 1 or 0, buff and 1 or 0, 0, 1)
            br:Show()
        end
    else
        if br:IsShown() then br:Hide() end
    end
end)

local Auras = CreateFrame("Frame", "Bar3_InlineAuras")

Auras:SetScript("OnEvent", function(self, event, unit)
    unit = unit or "target"
    if unit ~= "target" then return end

    for k in pairs(buffs)   do buffs[k] = nil   end
    for k in pairs(debuffs) do debuffs[k] = nil end

    for i = 1, 50 do
        local buff, rank = UnitBuff(unit, i)
        if not buff then break end
        buffs[aliases[buff] or buff] = rank
    end

    for i = 1, 50 do
        local buff, rank = UnitDebuff(unit, i)
        if not buff then break end
        debuffs[aliases[buff] or buff] = rank
    end

    for _, btn in pairs(bar3.actionbuttons) do
        if btn.state == "used" then
            btn.object:UpdateButton(true)
        end
    end
end)

Auras:RegisterEvent("PLAYER_TARGET_CHANGED")
Auras:RegisterEvent("UNIT_AURA")
