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
  sticky                 = true,
  soundName              = "Submarine",

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
  local app = hs.application.find("Calendar")
  if not app then
    -- Launch Calendar in background without bringing it forward
    hs.task.new("/usr/bin/open", nil, {"-gj", "-a", "Calendar"}):start()
  elseif not app:isRunning() then
    app:launch()
  end

  -- wait up to timeoutSec seconds for it to become responsive
  local deadline = hs.timer.absoluteTime() + (timeoutSec or 2) * 1e9
  repeat
    app = hs.application.find("Calendar")
    if app and app:isRunning() then return true end
    hs.timer.usleep(100000)
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

-- Robust split of exactly 7 fields separated by "||"
local function splitFields(line)
  local parts, start = {}, 1
  for i = 1, 6 do
    local s, e = string.find(line, "%|%|", start)
    if not s then
      -- not enough delimiters; bail out
      table.insert(parts, string.sub(line, start))
      break
    end
    table.insert(parts, string.sub(line, start, s - 1))
    start = e + 1
  end
  if #parts < 7 then
    table.insert(parts, string.sub(line, start))
  end
  -- normalize whitespace and "missing value"
  for k, v in ipairs(parts) do
    v = (v or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if v == "missing value" then v = "" end
    parts[k] = v
  end
  return parts
end

-- Drop-in replacement
local function parseAppleScriptLines(lines)
  local events = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" and line ~= "" then
      local p = splitFields(line)
      if #p >= 7 then
        events[#events + 1] = {
          id       = p[1],
          calendar = p[2],
          title    = p[3],
          start    = p[4],
          finish   = p[5],
          location = p[6],
          url      = p[7],
        }
      else
        hs.printf("[calendar_watcher] parse warning: got %d fields: %s", #p, line)
      end
    end
  end
  return events
end


-- Drop-in replacement for notifyForEvent (shows event title prominently)
-- Final improved notifyForEvent: title headline, smart browser routing, dedupe, sound, sticky
local function notifyForEvent(evt)
  M.log.debug(string.format("notifyForEvent: %s", hs.inspect(evt)))
  if not evt or (evt.id or "") == "" then return end

  -- de-dupe by id + start time
  local dupKey = (evt.id or "") .. "::" .. (evt.start or "")
  if _alerted[dupKey] then return end

  local eventTitle = (evt.title and evt.title ~= "" and evt.title) or "Untitled event"

  -- Build multi-line info text
  local info = {}
  if evt.calendar and evt.calendar ~= "" then table.insert(info, "Calendar: " .. evt.calendar) end
  if evt.location and evt.location ~= "" then table.insert(info, "Location: " .. evt.location) end
  if (evt.start and evt.start ~= "") or (evt.finish and evt.finish ~= "") then
    local when = string.format("Time: %s%s%s",
      evt.start or "",
      (evt.start and evt.start ~= "" and evt.finish and evt.finish ~= "") and " → " or "",
      evt.finish or "")
    table.insert(info, when)
  end
  local informative = table.concat(info, "\n")

  local note = hs.notify.new(function(n)
      local act = n:activationType()
      if act == hs.notify.activationTypes.actionButtonClicked
         or act == hs.notify.activationTypes.contentsClicked then
        if evt.url and evt.url ~= "" then
          local url = evt.url
          -- Detect Google Meet (supports meet.google.com and also calendar.google.com links)
          if url:match("https://meet%.google%.com/") or url:match("https://calendar%.google%.com/") then
            local chrome = hs.application.find("Google Chrome")
            if not chrome then hs.application.launchOrFocus("Google Chrome") end
            hs.osascript.applescript(string.format(
              'tell application "Google Chrome" to open location "%s"', url))
          else
            -- Safari or default browser for other URLs
            local safari = hs.application.find("Safari")
            if not safari then hs.application.launchOrFocus("Safari") end
            hs.osascript.applescript(string.format(
              'tell application "Safari" to open location "%s"', url))
          end
        elseif M.config.openCalendarIfNoURL then
          hs.application.launchOrFocus("Calendar")
        end
      end
    end, {
      title = eventTitle,               -- Event title as main headline
      subTitle = "Starting soon",
      informativeText = informative,
      autoWithdraw = not M.config.sticky,
      hasActionButton = true,
      actionButtonTitle = (evt.url and evt.url ~= "") and "Join" or "Open",
    })

  if M.config.soundName then note:soundName(M.config.soundName) end


  note:send()

  _alerted[dupKey] = true
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
