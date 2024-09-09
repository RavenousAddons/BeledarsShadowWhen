local ADDON_NAME, ns = ...
local L = ns.L

local _, className, _ = UnitClass("player")
local characterFormatted = "|cff" .. ns.data.classColors[className:lower()] .. UnitName("player") .. "-" .. GetRealmName("player") .. "|r"

local CT = C_Timer
local CQL = C_QuestLog

---
-- Local Functions
---

--- Plays a sound if "sound" option in enabled
-- @param {number} id
local function PlaySound(id)
    if ns:OptionValue("sound") then
        PlaySoundFile(id)
    end
end

--- Toggles a feature with a specified timeout
-- @param {string} toggle
-- @param {number} timeout
local function Toggle(toggle, timeout)
    if not ns.data.toggles[toggle] then
        ns.data.toggles[toggle] = true
        CT.After(math.max(timeout, 0), function()
            ns.data.toggles[toggle] = false
        end)
    end
end

-- Set default values for options which are not yet set.
-- @param {string} option
-- @param {any} default
local function RegisterDefaultOption(option, default)
    if BSW_options[ns.prefix .. option] == nil then
        if BSW_options[option] ~= nil then
            BSW_options[ns.prefix .. option] = BSW_options[option]
            BSW_options[option] = nil
        else
            BSW_options[ns.prefix .. option] = default
        end
    end
end

--- Formats a duration in seconds to a "Xh Xm XXs" string
-- @param {number} duration
-- @return {string}
local function Duration(duration)
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(math.fmod(duration, 3600) / 60)
    local seconds = math.fmod(duration, 60)
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    end
    if minutes > 0 then
        return string.format("%dm %02ds", minutes, seconds)
    end
    return string.format("%02d seconds", seconds)
end

local function MountCollected()
    return select(11, C_MountJournal.GetMountInfoByID(ns.data.mountID))
end

local function QuestCompleted()
    return CQL.IsQuestFlaggedCompleted(ns.data.questID)
end

--- Prints a message about the current timer
-- @param {string} message
-- @param {boolean} raidWarning
local function TimerAlert(message, sound, raidWarningGate, forced)
    if forced or (not QuestCompleted() and not MountCollected()) or ns:OptionValue("alwaysAlert") then
        if raidWarningGate and ns:OptionValue("raidwarning") then
            RaidNotice_AddMessage(RaidWarningFrame, L.BeledarsShadow .. " " .. message, ChatTypeInfo["RAID_WARNING"])
        end
        if not MountCollected() or ns:OptionValue("alwaysTrackQuest") then
            local defeatString = "|cff" .. (QuestCompleted() and "ff4444has already defeated" or "44ff44has not defeated") .. "|r"
            message = message .. "|n" .. L.DefeatCheck:format(characterFormatted, defeatString, "|cff" .. ns.color .. L.BeledarsSpawn .. "|r")
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. L.BeledarsShadow .. "|r " .. message)
        if sound then
            PlaySound(ns.data.sounds[sound])
        end
    end
end

local function SetTimers(seconds, startTime, endTime)
    -- Fix end/start discrepancy
    if seconds < 1 then
        seconds = 10800
    end
    -- Prevent duplicate timers
    Toggle("timerActive", seconds - 1)

    -- Set End Alert (30 mins after start)
    if seconds > 9000 then
        CT.After(seconds - 9000, function()
            if ns:OptionValue("alertEnd") then
                Toggle("recentlyOutput", ns.data.timeouts.short)
                TimerAlert(L.AlertEnd, "finish", true)
            end
        end)
    end

    -- Set Pre-Defined Alerts (X mins before end)
    for option, minutes in pairs(ns.data.timers) do
        if seconds > (minutes * 60) then
            CT.After(seconds - (minutes * 60), function()
                if ns:OptionValue(option) then
                    Toggle("recentlyOutput", ns.data.timeouts.short)
                    TimerAlert(L.AlertFuture:format(Duration(minutes * 60), startTime, endTime), "future", true)
                end
            end)
        end
    end

    -- Set Start Alert (at end)
    CT.After(seconds, function()
        Toggle("recentlyOutput", ns.data.timeouts.short)
        if ns:OptionValue("alertStart") then
            TimerAlert(L.AlertPresent:format(startTime, endTime), "present", true)
        end
        -- And restart timers
        CT.After(3, function()
            ns:TimerCheck()
        end)
    end)
end

---
-- Namespaced Functions
---

--- Returns an option from the options table
function ns:OptionValue(option)
    return BSW_options[ns.prefix .. option]
end

--- Sets default options if they are not already set
function ns:SetDefaultOptions()
    BSW_options = BSW_options or {}
    for option, default in pairs(ns.data.defaults) do
        RegisterDefaultOption(option, default)
    end
end

--- Prints a formatted message to the chat
-- @param {string} message
function ns:PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. "|r " .. message)
end

--- Opens the Addon settings menu and plays a sound
function ns:OpenSettings()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    Settings.OpenToCategory(ns.Settings:GetID())
end

--- Checks the timer's state
function ns:TimerCheck(forced)
    local now = GetServerTime()
    -- Counts down from 10799 to 0
    local seconds = (GetQuestResetTime() + 3660) % 10800
    local dateFormat = GetCVar("timeMgrUseMilitaryTime") == "1" and "%H:%M:%S" or "%I:%M:%S%p"
    local startTime = date(dateFormat, now + seconds)
    local endTime = date(dateFormat, seconds < 9000 and (now + seconds + 1800) or (now + seconds - 9000))

    if GetCVar("timeMgrUseMilitaryTime") == "0" then
        startTime = startTime:gsub("^0", ""):lower()
        endTime = endTime:gsub("^0", ""):lower()
    end

    -- Warn user about no alerts when TimerCheck is forced and appropriate
    -- conditions are met
    if forced and (QuestCompleted() or MountCollected()) and not ns:OptionValue("alwaysAlert") and not ns.data.toggles.noAlertsWarningSeen then
        Toggle("noAlertsWarningSeen", ns.data.timeouts.long)
        ns:PrettyPrint(L.AlwaysAlertDisabled:format(MountCollected() and L.AlwaysAlertDisabledCollected or L.AlwaysAlertDisabledDefeated))
    end

    if forced or not ns.data.toggles.recentlyOutput then
        Toggle("recentlyOutput", ns.data.timeouts.short)
        if seconds >= 9000 then
            -- Active now (10799 - 9000)
            TimerAlert(L.AlertPresent:format(Duration(seconds - 9000), endTime), "present", true, forced)
        else
            -- Upcoming (8999 - 0)
            TimerAlert(L.AlertFuture:format(Duration(seconds), startTime, endTime), "future", true, forced)
        end
    end

    -- Set alerts if timer isn't active
    if not ns.data.toggles.timerActive then
        SetTimers(seconds, startTime, endTime)
    end
end
