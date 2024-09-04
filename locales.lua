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
L.BeledarsShadow = "Beledar's Shadow"
L.BeledarsSpawn = "Beledar's Spawn"

-- English
L.Version = "%s is the current version." -- ns.version
L.Install = "Thanks for installing version |cff%1$s%2$s|r!" -- ns.color, ns.version
L.Update = "Thanks for updating to version |cff%1$s%2$s|r!" -- ns.color, ns.version
L.Help = "TODO"
L.AlertFuture = "starts in Hallowfall in %s from %s until %s."
L.AlertPresent = "has started in Hallowfall and will last %s until %s!"
L.AlertEnd = " has ended! 2h 30m until the next one."
L.DefeatCheck = "You %s defeated %s on %s today."
L.AddonCompartmentTooltip = "|cff" .. ns.color .. "Open Settings"
L.OptionsTitle1 = "When do you want to be alerted?"
L.OptionsTitle2 = "How do you want to be alerted?"
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
L.OptionsHowTooltip = "When important alerts go off, they will be accompanied by a %s, in addition to the chat box alert."
L.OptionsHow = {
    [1] = {
        key = "sound",
        name = "Sounds",
        tooltip = L.OptionsHowTooltip:format("Sound"),
    },
    [2] = {
        key = "raidwarning",
        name = "Raid Warnings",
        tooltip = L.OptionsHowTooltip:format("Raid Warning"),
    },
}

-- Check locale and apply appropriate changes below
local CURRENT_LOCALE = GetLocale()

-- German
if CURRENT_LOCALE == "deDE" then return end

-- Spanish
if CURRENT_LOCALE == "esES" then return end

-- Latin-American Spanish
if CURRENT_LOCALE == "esMX" then return end

-- French
if CURRENT_LOCALE == "frFR" then return end

-- Italian
if CURRENT_LOCALE == "itIT" then return end

-- Brazilian Portuguese
if CURRENT_LOCALE == "ptBR" then return end

-- Russian
if CURRENT_LOCALE == "ruRU" then return end

-- Korean
if CURRENT_LOCALE == "koKR" then return end

-- Simplified Chinese
if CURRENT_LOCALE == "zhCN" then return end

-- Traditional Chinese
if CURRENT_LOCALE == "zhTW" then return end

-- Swedish
if CURRENT_LOCALE == "svSE" then return end
