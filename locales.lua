local _, ns = ...
local L = {}
ns.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

-- Global
L.Enabled = _G.VIDEO_OPTIONS_ENABLED
L.Disabled = _G.VIDEO_OPTIONS_DISABLED

-- English
L.BeledarsShadow = "Beledar's Shadow"
L.BeledarsSpawn = "Beledar's Spawn"
L.Hallowfall = "Hallowfall"
L.Version = "%s is the current version." -- ns.version
L.Install = "Thanks for installing version |cff%1$s%2$s|r!" -- ns.color, ns.version
L.AlertFuture = "starts in " .. L.Hallowfall .. " in |cffffff00%s|r from |cffffff00%s|r until |cffffff00%s|r."
L.AlertFutureTime = "starts at %s"
L.AlertPresent = "has started in " .. L.Hallowfall .. " and will last |cffffff00%s|r until |cffffff00%s|r!"
L.AlertPresentTime = "ends at %s"
L.AlertEnd = "has ended! |cffffff00%s|r until the next event."
L.DefeatCheck = "%s %s %s today."
L.AlwaysAlertDisabled = "Alerts are disabled when you have %s. You can change this setting (\"Always Display Alerts\") in the Addon's options."
L.AlwaysAlertDisabledCollected = "collected the " .. L.BeledarsSpawn .. " mount"
L.AlwaysAlertDisabledDefeated = "already defeated " .. L.BeledarsSpawn .. " today"
L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "Left-Click:|r Check Timer"
L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "Right-Click:|r Open Settings"

L.OptionsWhenTooltip = "Sets up an alert %s the next " .. L.BeledarsShadow .. "." -- string
L.OptionsHowTooltip = "When alerts go off, they will be accompanied by %s, in addition to the chat box alert."
L.Settings = {
    [1] = {
        title = "When do you want to be alerted?",
        options = {
            [1] = {
                key = "alertStart",
                name = "Start of " .. L.BeledarsShadow,
                tooltip = L.OptionsWhenTooltip:format("for the start of"),
            },
            [2] = {
                key = "alertEnd",
                name = "End of " .. L.BeledarsShadow,
                tooltip = L.OptionsWhenTooltip:format("for the end of"),
            },
            [3] = {
                key = "alert1Minute",
                name = "1 minute before",
                tooltip = L.OptionsWhenTooltip:format("1 minute before"),
            },
            [4] = {
                key = "alert5Minutes",
                name = "5 minutes before",
                tooltip = L.OptionsWhenTooltip:format("5 minutes before"),
            },
            [5] = {
                key = "alert10Minutes",
                name = "10 minutes before",
                tooltip = L.OptionsWhenTooltip:format("10 minutes before"),
            },
            [6] = {
                key = "alert30Minutes",
                name = "30 minutes before",
                tooltip = L.OptionsWhenTooltip:format("30 minutes before"),
            },
        },
    },
    [2] = {
        title = "How do you want to be alerted?",
        options = {
            [1] = {
                key = "printText",
                name = "Chat Messages",
                tooltip = L.OptionsHowTooltip:format("chat message"),
            },
            [2] = {
                key = "sound",
                name = "Sounds",
                tooltip = L.OptionsHowTooltip:format("sound"),
            },
            [3] = {
                key = "raidwarning",
                name = "Raid Warnings",
                tooltip = L.OptionsHowTooltip:format("Raid Warning"),
            },
        },
    },
    [3] = {
        title = "Extra Options:",
        options = {
            [1] = {
                key = "timeFormat",
                name = "Time Format",
                tooltip = "Choose a short or long time formatting.",
                choices = {
                    [1] = ns:DurationFormat(nil, 754, 1),
                    [2] = ns:DurationFormat(nil, 754, 2),
                    [3] = ns:DurationFormat(nil, 754, 3),
                },
            },
            [2] = {
                key = "alertOnLogin",
                name = "Alert on login",
                tooltip = "Fires an alert when you log in.",
            },
            [2] = {
                key = "alwaysAlert",
                name = "Always Display Alerts",
                tooltip = "Always display alerts, even if you have already defeated Beledar's Spawn today or collected the mount.",
            },
            [3] = {
                key = "alwaysTrackQuest",
                name = "Always Include Rare Status",
                tooltip = "Always display whether your character has killed Beledar's Spawn yet today, even if you have already collected the mount.",
            },
        },
    },
}

-- Check locale and apply appropriate changes below
local CURRENT_LOCALE = GetLocale()

-- XXXX
-- if CURRENT_LOCALE == "xxXX" then return end