local ADDON_NAME, ns = ...
local L = ns.L

local CT = C_Timer
local CQL = C_QuestLog

local hour = L.Units.hour
local minute = L.Units.minute
local second = L.Units.second

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
        BSW_options[ns.prefix .. option] = default
    end
end

--- Check if the mount has been collected
local function MountCollected()
    return select(11, C_MountJournal.GetMountInfoByID(ns.data.mountID))
end

--- Check if the quest has been completed
local function QuestCompleted()
    return CQL.IsQuestFlaggedCompleted(ns.data.questID)
end

--- Prints a message about the current timer
-- @param {string} message
-- @param {boolean} raidWarning
local function TimerAlert(message, sound, raidWarningGate, forced)
    if forced or (not QuestCompleted() and not MountCollected()) or ns:OptionValue("alwaysAlert") then
        if raidWarningGate and ns:OptionValue("raidwarning") then
            RaidNotice_AddMessage(RaidWarningFrame, "|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. message .. "|r", ChatTypeInfo["RAID_WARNING"])
        end
        if ns:OptionValue("printText") then
            if not MountCollected() or ns:OptionValue("alwaysTrackQuest") then
                local defeatString = "|cff" .. (QuestCompleted() and "ff4444has already defeated" or "44ff44has not defeated") .. "|r"
                message = message .. "|n" .. L.DefeatCheck:format(ns.data.characterNameFormatted, defeatString, "|cff" .. ns.color .. L.BeledarsSpawn .. "|r")
            end
            print("|cff" .. ns.color .. L.BeledarsShadow .. "|r " .. message)
        end
        if sound then
            PlaySound(ns.data.sounds[sound])
        end
    end
end

---
-- Namespaced Functions
---

--- Set some data about the player
function ns:SetPlayerState()
    ns.data.characterName = UnitName("player") .. "-" .. GetNormalizedRealmName("player")
    local _, className, _ = UnitClass("player")
    ns.data.className = className
    ns.data.characterNameFormatted = "|cff" .. ns.data.classColors[ns.data.className:lower()] .. ns.data.characterName .. "|r"
end

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

--- Formats a duration in seconds to a "Xh Xm XXs" string
-- @param {number} duration
-- @param {number} timeFormat
-- @return {string}
function ns:DurationFormat(duration, timeFormat)
    timeFormat = timeFormat and timeFormat or ns:OptionValue("timeFormat")
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(math.fmod(duration, 3600) / 60)
    local seconds = math.fmod(duration, 60)
    local h, m, s
    if timeFormat == 3 then
        h = " " .. (hours > 1 and hour.p or hour.s)
        m = " " .. (minutes > 1 and minute.p or minute.s)
        s = " " .. (seconds > 1 and second.p or second.s)
    elseif timeFormat == 2 then
        h = " " .. hour.a
        m = " " .. minute.a
        s = " " .. second.a
    else
        h = hour.t
        m = minute.t
        s = second.t
    end
    if hours > 0 then
        if minutes > 0 then
            return string.format("%d" .. h .. (timeFormat ~= 2 and "," or "") .. " %d" .. m, hours, minutes)
        end
        return string.format("%d" .. h, hours)
    end
    if minutes > 0 then
        if seconds > 0 then
            return string.format("%d" .. m .. (timeFormat ~= 2 and "," or "") .. " %d" .. s, minutes, seconds)
        end
        return string.format("%d" .. m, minutes)
    end
    return string.format("%d" .. s, seconds)
end

--- Format a timestamp to a local time string
-- @param {number} timestamp
-- @return {string}
function ns:TimeFormat(timestamp, includeSeconds)
    local useMilitaryTime = GetCVar("timeMgrUseMilitaryTime") == "1"
    local timeFormat = useMilitaryTime and ("%H:%M" .. (includeSeconds and ":%S" or "")) or ("%I:%M" .. (includeSeconds and ":%S" or "") .. "%p")
    local time = date(timeFormat, timestamp)

    -- Remove starting zero from non-military time
    if not useMilitaryTime then
        time = time:gsub("^0", ""):lower()
    end

    return time
end

--- Get the seconds until the next event
function ns:GetSecondsUntilEvent()
    -- Counts down from 10799 to 0
    return (GetQuestResetTime() + ns.data.durations.offset) % ns.data.durations.frequency
end

--- Set the timers for the event
-- @param {number} seconds
-- @param {number} startTime
-- @param {number} endTime
function ns:SetTimers(seconds, startTime, endTime)
    -- Fix end/start discrepancy
    if seconds < 1 then
        seconds = ns.data.durations.frequency
    end
    -- Prevent duplicate timers
    Toggle("timerActive", seconds - 1)

    -- Set End Alert (30 mins after start)
    if seconds > ns.data.durations.rollover then
        CT.After(seconds - ns.data.durations.rollover, function()
            if ns:OptionValue("alertEnd") then
                Toggle("recentlyOutput", ns.data.timeouts.short)
                TimerAlert(L.AlertEnd:format(ns:DurationFormat(ns.data.durations.rollover)), "finish", true)
            end
        end)
    end

    -- Set Pre-Defined Alerts (X mins before end)
    for option, minutes in pairs(ns.data.timers) do
        if seconds > (minutes * 60) then
            CT.After(seconds - (minutes * 60), function()
                if ns:OptionValue(option) then
                    Toggle("recentlyOutput", ns.data.timeouts.short)
                    TimerAlert(L.AlertFuture:format(ns:DurationFormat(minutes * 60), startTime, endTime), "future", true)
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

--- Checks the timer's state
-- @param {boolean} forced
function ns:TimerCheck(forced)
    local now = GetServerTime()
    -- Counts down from 10799 to 0
    local seconds = ns:GetSecondsUntilEvent()
    local startTime = ns:TimeFormat(now + seconds)
    local endTime = ns:TimeFormat(seconds < ns.data.durations.rollover and (now + seconds + ns.data.durations.halfhour) or (now + seconds - ns.data.durations.rollover))

    -- Set Data Broker text
    ns:SetDataBrokerText()

    -- Warn user about no alerts when TimerCheck is forced and appropriate
    -- conditions are met
    if forced and not ns:OptionValue("alwaysAlert") and not ns.data.toggles.noAlertsWarningSeen and (QuestCompleted() or MountCollected()) then
        Toggle("noAlertsWarningSeen", ns.data.timeouts.long)
        ns:PrettyPrint(L.AlwaysAlertDisabled:format(MountCollected() and L.AlwaysAlertDisabledCollected or L.AlwaysAlertDisabledDefeated))
    end

    if forced or not ns.data.toggles.recentlyOutput then
        Toggle("recentlyOutput", ns.data.timeouts.short)
        if seconds >= ns.data.durations.rollover then
            -- Active now (>= ns.data.durations.rollover)
            TimerAlert(L.AlertPresent:format(ns:DurationFormat(seconds - ns.data.durations.rollover), endTime), "present", true, forced)
        else
            -- Upcoming (< ns.data.durations.rollover)
            TimerAlert(L.AlertFuture:format(ns:DurationFormat(seconds), startTime, endTime), "future", true, forced)
        end
    end

    -- Set alerts if timer isn't active
    if not ns.data.toggles.timerActive then
        ns:SetTimers(seconds, startTime, endTime)
    end
end

--- Build Data for Data Broker
function ns:BuildLibData()
    if LibStub then
        local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
        ns.DataSource = ldb:NewDataObject(ns.name, {
            id = ADDON_NAME,
            type = "data source",
            version = ns.version,
            label = L.BeledarsShadow,
            icon = "Interface\\Icons\\inv_shadowelementalmount_purple",
            notes = "Keep track of when Beledar's Shadow begins in Hallowfall and whether you have defeated Beledar's Spawn today.",
            OnClick = function(_, button)
                if button == "RightButton" then
                    ns:OpenSettings()
                else
                    ns:TimerCheck(true)
                end
            end,
            OnTooltipShow = function(tooltip)
                local now = GetServerTime()
                -- Counts down from 10799 to 0
                local seconds = ns:GetSecondsUntilEvent()
                local startTime = ns:TimeFormat(now + seconds)
                local endTime = ns:TimeFormat(seconds < ns.data.durations.rollover and (now + seconds + ns.data.durations.halfhour) or (now + seconds - ns.data.durations.rollover))
                tooltip:SetText(ns.name .. "        v" .. ns.version)
                tooltip:AddLine("|n")
                if seconds >= ns.data.durations.rollover then
                    -- Active now (>= ns.data.durations.rollover)
                    tooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertPresent:format(ns:DurationFormat(seconds - ns.data.durations.rollover), endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r")
                else
                    -- Upcoming (< ns.data.durations.rollover)
                    tooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertFuture:format(ns:DurationFormat(seconds), startTime, endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r")
                end
                tooltip:AddLine("|n")
                tooltip:AddLine("|cffffffff" .. L.AddonCompartmentTooltip1 .. "|r")
                tooltip:AddLine("|cffffffff" .. L.AddonCompartmentTooltip2 .. "|r")
            end,
        })
    end
end

--- Set text value for Data Broker
function ns:SetDataBrokerText()
    if ns.DataSource then
        local now = GetServerTime()
        local seconds = ns:GetSecondsUntilEvent()
        if seconds >= ns.data.durations.rollover then
            -- Active now (>= ns.data.durations.rollover)
            ns.DataSource.text = L.AlertPresentTime:format(ns:TimeFormat(now + seconds - ns.data.durations.rollover))
        else
            -- Upcoming (< ns.data.durations.rollover)
            ns.DataSource.text = L.AlertFutureTime:format(ns:TimeFormat(now + seconds))
        end
    end
end
