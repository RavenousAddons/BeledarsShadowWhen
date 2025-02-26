local ADDON_NAME, ns = ...
local L = ns.L

local CT = C_Timer
local CQL = C_QuestLog

---
-- Local Functions
---

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
    if forced or (not QuestCompleted() and not MountCollected()) or ns:OptionValue(BSW_options, "alwaysAlert") then
        if raidWarningGate and ns:OptionValue(BSW_options, "raidwarning") then
            RaidNotice_AddMessage(RaidWarningFrame, "|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. message .. "|r", ChatTypeInfo["RAID_WARNING"])
        end
        if ns:OptionValue(BSW_options, "printText") then
            if not MountCollected() or ns:OptionValue(BSW_options, "alwaysTrackQuest") then
                local defeatString = "|cff" .. (QuestCompleted() and "ff4444has already defeated" or "44ff44has not defeated") .. "|r"
                message = message .. "|n" .. L.DefeatCheck:format(ns.data.characterNameFormatted, defeatString, "|cff" .. ns.color .. L.BeledarsSpawn .. "|r")
            end
            print("|cff" .. ns.color .. L.BeledarsShadow .. "|r " .. message)
        end
        if sound then
            ns:PlaySound(BSW_options, ns.data.sounds[sound])
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

--- Sets default options if they are not already set
function ns:SetOptionDefaults()
    BSW_options = BSW_options or {}
    for option, default in pairs(ns.data.defaults) do
        ns:SetOptionDefault(BSW_options, option, default)
    end
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
    ns:Toggle("timerActive", seconds - 1)

    -- Set End Alert (30 mins after start)
    if seconds > ns.data.durations.rollover then
        CT.After(seconds - ns.data.durations.rollover, function()
            if ns:OptionValue(BSW_options, "alertEnd") then
                ns:Toggle("recentlyOutput", ns.data.timeouts.short)
                TimerAlert(L.AlertEnd:format(ns:DurationFormat(BSW_options, ns.data.durations.rollover)), "finish", true)
            end
        end)
    end

    -- Set Pre-Defined Alerts (X mins before end)
    for option, minutes in pairs(ns.data.timers) do
        if seconds > (minutes * 60) then
            CT.After(seconds - (minutes * 60), function()
                if ns:OptionValue(BSW_options, option) then
                    ns:Toggle("recentlyOutput", ns.data.timeouts.short)
                    TimerAlert(L.AlertFuture:format(ns:DurationFormat(BSW_options, minutes * 60), startTime, endTime), "future", true)
                end
            end)
        end
    end

    -- Set Start Alert (at end)
    CT.After(seconds, function()
        ns:Toggle("recentlyOutput", ns.data.timeouts.short)
        if ns:OptionValue(BSW_options, "alertStart") then
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
    if forced and not ns:OptionValue(BSW_options, "alwaysAlert") and not ns.data.toggles.noAlertsWarningSeen and (QuestCompleted() or MountCollected()) then
        ns:Toggle("noAlertsWarningSeen", ns.data.timeouts.long)
        ns:PrettyPrint(L.AlwaysAlertDisabled:format(MountCollected() and L.AlwaysAlertDisabledCollected or L.AlwaysAlertDisabledDefeated))
    end

    if forced or not ns.data.toggles.recentlyOutput then
        ns:Toggle("recentlyOutput", ns.data.timeouts.short)
        if seconds >= ns.data.durations.rollover then
            -- Active now (>= ns.data.durations.rollover)
            TimerAlert(L.AlertPresent:format(ns:DurationFormat(BSW_options, seconds - ns.data.durations.rollover), endTime), "present", true, forced)
        else
            -- Upcoming (< ns.data.durations.rollover)
            TimerAlert(L.AlertFuture:format(ns:DurationFormat(BSW_options, seconds), startTime, endTime), "future", true, forced)
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
                    tooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertPresent:format(ns:DurationFormat(BSW_options, seconds - ns.data.durations.rollover), endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r")
                else
                    -- Upcoming (< ns.data.durations.rollover)
                    tooltip:AddLine("|cff" .. ns.color .. L.BeledarsShadow .. "|r |cffffffff" .. L.AlertFuture:format(ns:DurationFormat(BSW_options, seconds), startTime, endTime):gsub(L.Hallowfall .. " ", L.Hallowfall .. "|n") .. "|r")
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
