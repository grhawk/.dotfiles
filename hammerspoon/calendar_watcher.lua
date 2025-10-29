-- ~/.hammerspoon/calendar_watcher.lua
-- Apple Calendar watcher for imminent meetings (+ calendar filtering)
-- Author: you :)

local M = {}
M.log = _G.log or { debug = function(_) end }

-- ========================= Config (edit via start{ ... }) =========================
M.config = {
  -- core behavior
  lookaheadMinutes       = 5,     -- alert for events starting within this many minutes
  pollSeconds            = 60,    -- how often to check calendars
  persistAlerts          = true,  -- remember alerts across reloads (prevents duplicates)
  openCalendarIfNoURL    = true,  -- action button opens Calendar when no URL is present

  -- calendar selection (use any, all, or none)
  onlyCalendarsByName    = {},    -- e.g., { "Work", "Team" }
  onlyCalendarsByUID     = {},    -- e.g., { "C1A23B45-...", "A9F8E7D6-..." }
  excludeCalendarsByName = {},    -- e.g., { "Birthdays", "Holidays" }
  excludeCalendarsByUID  = {},    -- e.g., { "FFFFFFFF-...." }
}
-- ==================================================================================

local _timer        = nil
local _alertedKey   = "calendar_watcher_alerted"
local _alerted      = hs.settings.get(_alertedKey) or {}

-- ---------- helpers ----------
local function ensureCalendarRunning(timeoutSec)
  hs.application.launchOrFocus("Calendar")
  local deadline = hs.timer.absoluteTime() + (timeoutSec or 2) * 1e9
  repeat
    local app = hs.appfinder.appFromName("Calendar")
    if app and app:isRunning() then return true end
    hs.timer.usleep(100000) -- 0.1s
  until hs.timer.absoluteTime() > deadline
  return false
end

local function asListQuoted(t)
  if not t or #t == 0 then return nil end
  local parts = {}
  for _, s in ipairs(t) do
    s = tostring(s):gsub('"','\\"')
    table.insert(parts, '"' .. s .. '"')
  end
  return "{" .. table.concat(parts, ", ") .. "}"
end

local function splitLines(str)
  local lines = {}
  for line in string.gmatch(str or "", "([^\r\n]+)") do table.insert(lines, line) end
  return lines
end

local function parseAppleScriptLines(lines)
  -- each line is: id||calendar||title||start||end||location||url
  local events = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" and line ~= "" then
      local parts, acc = {}, ""
      -- robust split on '||'
      for seg in line:gmatch("([^|]+)") do
        if acc == "" then
          acc = seg
        else
          acc = acc .. "|" .. seg
        end
        if acc:sub(-2) == "||" then
          table.insert(parts, acc:sub(1, -3))
          acc = ""
        end
      end
      if acc ~= "" then table.insert(parts, acc) end

      local evt = {
        id       = parts[1] or "",
        calendar = parts[2] or "",
        title    = parts[3] or "",
        start    = parts[4] or "",
        finish   = parts[5] or "",
        location = parts[6] or "",
        url      = parts[7] or ""
      }
      table.insert(events, evt)
    end
  end
  return events
end

local function notifyForEvent(evt)
  if not evt or evt.id == "" then return end
  if _alerted[evt.id] then return end

  local title = (evt.title ~= "" and evt.title) or "Calendar event"
  local informative = (evt.location ~= "" and ("Location: " .. evt.location))
                      or (evt.calendar ~= "" and ("Calendar: " .. evt.calendar))
                      or ""

  local note = hs.notify.new(function()
      if evt.url and evt.url ~= "" then
        hs.urlevent.openURL(evt.url)
      elseif M.config.openCalendarIfNoURL then
        hs.application.launchOrFocus("Calendar")
      end
    end, {
      title = "Meeting starting soon",
      subTitle = title,
      informativeText = informative,
      autoWithdraw = true,
      hasActionButton = true,
      actionButtonTitle = (evt.url and evt.url ~= "") and "Join" or "Open"
    })

  note:send()
  _alerted[evt.id] = true
  if M.config.persistAlerts then hs.settings.set(_alertedKey, _alerted) end
end

-- ---------- core fetch ----------
local function buildCalendarCondition()
  local incNames = asListQuoted(M.config.onlyCalendarsByName)
  local incUIDs  = asListQuoted(M.config.onlyCalendarsByUID)
  local excNames = asListQuoted(M.config.excludeCalendarsByName)
  local excUIDs  = asListQuoted(M.config.excludeCalendarsByUID)

  local incCond
  if incNames or incUIDs then
    local namePart = incNames and ("(name of cal is in " .. incNames .. ")") or "false"
    local uidPart  = incUIDs  and ("(uid of cal is in "   .. incUIDs  .. ")") or "false"
    incCond = "(" .. namePart .. " or " .. uidPart .. ")"
  else
    incCond = "true"
  end

  local excCond
  if excNames or excUIDs then
    local namePart = excNames and ("(name of cal is in " .. excNames .. ")") or "false"
    local uidPart  = excUIDs  and ("(uid of cal is in "   .. excUIDs  .. ")") or "false"
    excCond = "(" .. namePart .. " or " .. uidPart .. ")"
  else
    excCond = "false"
  end

  return incCond .. " and not " .. excCond
end

local function fetchUpcomingEvents(lookaheadMinutes)
  ensureCalendarRunning(2)

  local cond = buildCalendarCondition()

  local as = ([[
    with timeout of 30 seconds
      tell application id "com.apple.iCal"
        set lookahead to %d
        set nowDate to (current date)
        set futureDate to nowDate + (lookahead * minutes)
        set outLines to {}
        repeat with cal in calendars
          if %s then
            set calName to name of cal
            try
              set evts to every event of cal whose start date ≥ nowDate and start date ≤ futureDate
              repeat with e in evts
                set theID to uid of e
                set theTitle to summary of e
                set sDate to start date of e
                set eDate to end date of e
                set theLoc to location of e
                set theURL to ""
                try
                  set theURL to url of e
                end try
                copy (theID & "||" & calName & "||" & theTitle & "||" & sDate & "||" & eDate & "||" & theLoc & "||" & theURL) to end of outLines
              end repeat
            end try
          end if
        end repeat
        return outLines
      end tell
    end timeout
  ]]):format(lookaheadMinutes, cond)

  -- primary path: hs.osascript
  local ok, res, err = hs.osascript.applescript(as)
  if ok and type(res) == "table" then return parseAppleScriptLines(res) end

  -- quick retry for transient -1712 / timeout
  local es = tostring(err or ""):lower()
  if es:match("timeout") or es:match("%-1712") then
    hs.timer.usleep(300000) -- 0.3s
    ok, res, err = hs.osascript.applescript(as)
    if ok and type(res) == "table" then return parseAppleScriptLines(res) end
  end

  hs.printf("[calendar_watcher] AppleScript error: %s", tostring(err))
  return {}
end

-- ---------- timer tick ----------
local function tick()
  local events = fetchUpcomingEvents(M.config.lookaheadMinutes)
  for _, evt in ipairs(events) do notifyForEvent(evt) end
end

-- ---------- public API ----------
function M.start(opts)
  if opts and type(opts) == "table" then
    for k, v in pairs(opts) do
      if M.config[k] ~= nil then M.config[k] = v end
    end
  end
  if _timer then _timer:stop() end
  _timer = hs.timer.doEvery(M.config.pollSeconds, tick)
  tick()
  hs.printf("[calendar_watcher] started: lookahead=%dm, poll=%ds", M.config.lookaheadMinutes, M.config.pollSeconds)
end

function M.stop()
  if _timer then _timer:stop(); _timer = nil end
  hs.printf("[calendar_watcher] stopped")
end

-- convenience: list all calendars (UID || Name) in console
function M.listCalendars()
  local ok, res, err = hs.osascript.applescript([[
    tell application id "com.apple.iCal"
      set out to {}
      repeat with cal in calendars
        copy (uid of cal & " || " & name of cal) to end of out
      end repeat
      return out
    end tell
  ]])
  if not ok then
    hs.printf("[calendar_watcher] listCalendars error: %s", tostring(err))
    return {}
  end
  print(hs.inspect(res))
  return res
end

return M
