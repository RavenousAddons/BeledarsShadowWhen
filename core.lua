local ADDON_NAME, ns = ...
local L = ns.L

local CT = C_Timer

-- Load the Addon

function BeledarsShadowWhen_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
end

-- Event Triggers

function BeledarsShadowWhen_OnEvent(self, event, arg, ...)
    if event == "PLAYER_LOGIN" then
        ns:SetDefaultOptions()
        ns:CreateSettingsPanel()
        if not BSW_version then
            ns:PrettyPrint(L.Install:format(ns.color, ns.version))
        elseif BSW_version ~= ns.version then
            ns:PrettyPrint(L.Update:format(ns.color, ns.version))
            -- Version-specific messages go here...
            print("As a reminder, you can see the event timer at any time with this slash command:|n/bsw")
            print("You can also configure your alerts via the in-game Addon Options menu or with this slash command:|n/bsw config")
        end
        BSW_version = ns.version
        ns:TimerCheck()
    end
end

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
        GameTooltip:SetOwner(menuItem)
        GameTooltip:SetText(ns.name .. "        v" .. ns.version)
        GameTooltip:AddLine(" ", 1, 1, 1, true)
        GameTooltip:AddLine(L.AddonCompartmentTooltip1, 1, 1, 1, true)
        GameTooltip:AddLine(L.AddonCompartmentTooltip2, 1, 1, 1, true)
        GameTooltip:Show()
    end,
    funcOnLeave = function()
        GameTooltip:Hide()
    end,
})

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
