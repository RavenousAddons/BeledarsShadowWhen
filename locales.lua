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
L.Units = {
    hour = {
        s = "hour",
        p = "hours",
        a = "hr.",
        t = "h",
    },
    minute = {
        s = "minute",
        p = "minutes",
        a = "min.",
        t = "m",
    },
    second = {
        s = "second",
        p = "seconds",
        a = "sec.",
        t = "s",
    },
}
L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "Left-Click:|r Check Timer"
L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "Right-Click:|r Open Settings"
L.OptionsTitle1 = "When do you want to be alerted?"
L.OptionsWhenTooltip = "Sets up an alert %s the next " .. L.BeledarsShadow .. "." -- string
L.OptionsWhen = {
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
}
L.OptionsTitle2 = "How do you want to be alerted?"
L.OptionsHowTooltip = "When alerts go off, they will be accompanied by %s, in addition to the chat box alert."
L.OptionsHow = {
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
}
L.OptionsTitle3 = "Extra Options:"
L.OptionsExtra = {
    [1] = {
        key = "timeFormat",
        name = "Time Format",
        tooltip = "Choose a short or long time formatting.",
        fn = function()
            local container = Settings.CreateControlTextContainer()
            for i = 1, 3, 1 do
                container:Add(i, ns:DurationFormat(754, i))
            end
            return container:GetData()
        end,
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
}

-- Check locale and apply appropriate changes below
local CURRENT_LOCALE = GetLocale()

-- XXXX
-- if CURRENT_LOCALE == "xxXX" then return end