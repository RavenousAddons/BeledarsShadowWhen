local ADDON_NAME, ns = ...
local L = ns.L

local CT = C_Timer

-- Load the Addon

function BeledarsShadowWhen_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Event Triggers

function BeledarsShadowWhen_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        ns:SetPlayerState()
        ns:SetDefaultOptions()
        ns:CreateSettingsPanel()
        if isInitialLogin then
            if not BSW_version then
                ns:PrettyPrint(L.Install:format(ns.color, ns.version))
            elseif BSW_version ~= ns.version then
                -- Version-specific messages go here...
            end
            BSW_version = ns.version
            if ns:OptionValue("alertOnLogin") then
                ns:TimerCheck()
            end
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

-- Addon Compartment Handling

AddonCompartmentFrame:RegisterAddon({
    text = ns.title,
    icon = ns.icon,
    registerForAnyClick = true,
    notCheckable = true,
    func = function(button, menuInputData, menu)
        local mouseButton = menuInputData.buttonName
        if mouseButton == "RightButton" then
            ns:OpenSettings()
            return
        end
        ns:TimerCheck(true)
    end,
    funcOnEnter = function(menuItem)
        local now = GetServerTime()
        -- Counts down from 10799 to 0
        local seconds = (GetQuestResetTime() + 3661) % 10800
        local startTime = ns:TimeFormat(now + seconds)
        local endTime = ns:TimeFormat(seconds < 9000 and (now + seconds + 1800) or (now + seconds - 9000))
        GameTooltip:SetOwner(menuItem)
        GameTooltip:SetText(ns.name .. "        v" .. ns.version)
        GameTooltip:AddLine(" ", 1, 1, 1, true)
        if seconds >= 9000 then
            -- Active now (10799 - 9000)
            GameTooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertPresent:format(ns:Duration(seconds - 9000), endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r", 1, 1, 1, true)
        else
            -- Upcoming (8999 - 0)
            GameTooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertFuture:format(ns:Duration(seconds), startTime, endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r", 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ", 1, 1, 1, true)
        GameTooltip:AddLine(L.AddonCompartmentTooltip1, 1, 1, 1, true)
        GameTooltip:AddLine(L.AddonCompartmentTooltip2, 1, 1, 1, true)
        GameTooltip:Show()
    end,
    funcOnLeave = function()
        GameTooltip:Hide()
    end,
})

-- Slash Command Handling

SlashCmdList["BELEDARSSHADOWWHEN"] = function(message)
    if message == "v" or message:match("ver") then
        -- Print the current addon version
        ns:PrettyPrint(L.Version:format(ns.version))
    elseif message == "c" or message:match("con") or message == "o" or message:match("opt") or message == "s" or message:match("sett") or message:match("togg") then
        -- Open settings window
        ns:OpenSettings()
    else
        -- Print the timer
        ns:TimerCheck(true)
    end
end
SLASH_BELEDARSSHADOWWHEN1 = "/" .. ns.command
