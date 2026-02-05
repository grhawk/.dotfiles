local M = {}

local CHECK_INTERVAL_SECONDS = 20
local SLEEP_THROTTLE_SECONDS = 300

local screensaver_active = false
local quiet_hours_enabled = false
local last_sleep_attempt = 0
local timers = {}
local watcher = nil
M.log = _G.log or {
    debug = function(_) end,
    info  = function(_) end,
    warn  = function(_) end,
    error = function(_) end,
}

local function parse_time_string(time_str)
    local hour, min = time_str:match("^(%d%d?):(%d%d)$")
    if not hour or not min then
        error("invalid time format, expected HH:MM")
    end
    return tonumber(hour), tonumber(min)
end

local function minutes_from(hour, min)
    return hour * 60 + min
end

local function screensaver_is_active()
    local props = hs.caffeinate.sessionProperties()
    log.debug(("Caffeinate properties: "):format(hs.inspect(props)))
    log.debug(hs.inspect(hs.caffeinate.sessionProperties()))
    if props and props.CGSSessionScreenIsLocked ~= nil then
        return props.CGSSessionScreenIsLocked
    end
    return screensaver_active
end

local function maybe_sleep(reason)
    log.debug("maybe_sleep")
    log.debug(("is screensaver active: %s"):format(screensaver_is_active()))
    if not quiet_hours_enabled or not screensaver_is_active() then
        return
    end
    local now = hs.timer.secondsSinceEpoch()
    log.debug(("now: %s - last_sleep_attempt: %s").format(now, last_sleep_attempt))
    if now - last_sleep_attempt < SLEEP_THROTTLE_SECONDS then
        return
    end
    last_sleep_attempt = now
    log.info("Quiet hours: sleeping due to screensaver (" .. reason .. ")")
    hs.caffeinate.systemSleep()
end

local function schedule_daily(time_str, handler)
    local function schedule_next()
        return hs.timer.doAt(time_str, function()
            handler()
            schedule_next()
        end)
    end
    return schedule_next()
end

function M.start(start_time, end_time)
    local start_hour, start_min = parse_time_string(start_time)
    local end_hour, end_min = parse_time_string(end_time)
    local start_minutes = minutes_from(start_hour, start_min)
    local end_minutes = minutes_from(end_hour, end_min)

    local function is_quiet_hours()
        local now = os.date("*t")
        local minutes = minutes_from(now.hour, now.min)
        return (minutes >= start_minutes) or (minutes < end_minutes)
    end

    local function set_quiet_hours_enabled(enabled, reason)
        quiet_hours_enabled = enabled
        if enabled then
            maybe_sleep(reason or "quiet hours start")
        end
    end

    quiet_hours_enabled = is_quiet_hours()

    watcher = hs.caffeinate.watcher.new(function(event)
        if event == hs.caffeinate.watcher.screensaverDidStart then
            screensaver_active = true
            maybe_sleep("screensaver started")
        elseif event == hs.caffeinate.watcher.screensaverDidStop
            or event == hs.caffeinate.watcher.screensaverWillStop then
            screensaver_active = false
        end
    end)
    watcher:start()

    timers.start = schedule_daily(start_time, function()
        set_quiet_hours_enabled(true, "quiet hours start")
    end)
    timers["end"] = schedule_daily(end_time, function()
        set_quiet_hours_enabled(false, "quiet hours end")
    end)
    timers.periodic = hs.timer.doEvery(CHECK_INTERVAL_SECONDS, function()
        maybe_sleep("periodic check")
    end)

    maybe_sleep("startup")
end

return M
