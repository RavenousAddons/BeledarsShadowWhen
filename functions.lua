local ADDON_NAME, ns = ...
local L = ns.L

local character = UnitName("player") .. "-" .. GetRealmName("player")

local CT = C_Timer
local CQL = C_QuestLog

---
-- Local Functions
---

--- Plays a sound if "sound" option in enabled
-- @param {number} id
local function PlaySound(id)
    if ns:GetOptionValue("sound") then
        PlaySoundFile(id)
    end
end

--- Toggles a feature with a specified timeout
-- @param {string} toggle
-- @param {number} timeout
local function Toggle(toggle, timeout)
    if not ns.data.toggles[toggle] then
        ns.data.toggles[toggle] = true
        CT.After(timeout, function()
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

--- Prints a message about the current timer
-- @param {string} message
-- @param {boolean} raidWarning
local function TimerPrint(message, raidWarningGate)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. L.BeledarsShadow .. "|r " .. message)
    if raidWarningGate and ns:GetOptionValue("raidwarning") then
        RaidNotice_AddMessage(RaidWarningFrame, L.BeledarsShadow .. " " .. message, ChatTypeInfo["RAID_WARNING"])
    end
    local defeatString = "|cff" .. (CQL.IsQuestFlaggedCompleted(ns.data.questID) and "ff4444have already" or "44ff44have not") .. "|r"
    local mountLearned = select(11, C_MountJournal.GetMountInfoByID(ns.data.mountID))
    if not mountLearned then
        DEFAULT_CHAT_FRAME:AddMessage(L.DefeatCheck:format(defeatString, "|cff" .. ns.color .. L.BeledarsSpawn .. "|r", character))
    end
end

local function SetTimers(seconds, startTime, endTime)
    -- Prevent duplicate timers
    Toggle("timerActive", seconds - 1)

    -- Set End Alert (30 mins after start)
    if seconds > 9000 then
        CT.After(seconds - 9000, function()
            if ns:GetOptionValue("alertEnd") then
                Toggle("recentlyOutput", ns.data.timeout)
                TimerPrint(L.AlertEnd, true)
                PlaySound(ns.data.sounds.future)
            end
        end)
    end

    -- Set Pre-Defined Alerts (X mins before end)
    for option, minutes in pairs(ns.data.timers) do
        if seconds >= (minutes * 60) then
            CT.After(seconds - (minutes * 60), function()
                if ns:GetOptionValue(option) then
                    Toggle("recentlyOutput", ns.data.timeout)
                    TimerPrint(L.AlertFuture:format(Duration(minutes * 60), startTime, endTime), true)
                    PlaySound(ns.data.sounds.future)
                end
            end)
        end
    end

    -- Set Start Alert (at end)
    CT.After(seconds, function()
        if ns:GetOptionValue("alertStart") then
            Toggle("recentlyOutput", ns.data.timeout)
            TimerPrint(L.AlertPresent:format(startTime, endTime), true)
            PlaySound(ns.data.sounds.present)
        end
        -- And restart timers
        CT.After(1, function()
            ns:TimerCheck()
        end)
    end)
end

---
-- Namespaced Functions
---

--- Returns an option from the options table
function ns:GetOptionValue(option)
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

    if forced or not ns.data.toggles.recentlyOutput then
        Toggle("recentlyOutput", ns.data.timeout)
        if seconds >= 9000 then
            -- Active now (10799 - 9000)
            TimerPrint(L.AlertPresent:format(Duration(seconds - 9000), endTime), true)
            PlaySound(ns.data.sounds.present)
        else
            -- Upcoming (8999 - 0)
            TimerPrint(L.AlertFuture:format(Duration(seconds), startTime, endTime), true)
            PlaySound(ns.data.sounds.future)
        end
    end

    -- Set alerts if timer isn't active
    if not ns.data.toggles.timerActive then
        SetTimers(seconds, startTime, endTime)
    end
end
