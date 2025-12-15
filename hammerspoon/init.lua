hs.loadSpoon("EmmyLua")
hs.console.clearConsole()
local log = require("logger")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
spoon.ReloadConfiguration:bindHotkeys({ reloadConfiguration = { { "cmd", "alt", "ctrl" }, "R", message = "Reloading config" } })

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "P", function()
    local laptopScreen = "Built-in Retina Display"
    local ghostty = hs.application.launchOrFocus("Ghostty")
    local safari = hs.application.launchOrFocus("Safari")
    local windowLayout = {
        { "Safari",  nil, laptopScreen, hs.geometry.rect(0, 0.5, 0.5, 0.5), nil, nil },
        { "Mail",    nil, laptopScreen, hs.layout.right50,                  nil, nil },
        { "Ghostty", nil, laptopScreen, nil,                                nil, hs.geometry.rect(0, 48, 4000, 48) },
    }
    hs.layout.apply(windowLayout)
end)

--k = hs.hotkey.modal.new('cmd-shift', 'd')
--function k:entered() hs.alert.show('Entered mode\nasdasd') end

--function k:exited() hs.alert 'Exited mode' end
--
--k:bind('', 'escape', function() k:exit() end)
--k:bind('', 'J', 'Pressed J', function() print 'let the record show that J was pressed' end)


local windowcycle = require("windowCycle")

-- Bind ⌘ + Shift + Ctrl + Alt + Space
hs.hotkey.bind({ "cmd", "shift", "ctrl", "alt" }, "space", windowcycle.maximize)

-- Bind ⌘ + ⌥ + ⌃ + ⇧ + Z
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "z", windowcycle.undo)

-- Bind ⌘ + Ctrl + Shift + ⌥ + X
hs.hotkey.bind({ "cmd", "ctrl", "shift", "alt" }, "x", windowcycle.center)

-- Bind to ctrl+alt+↑ and ctrl+alt+↓
hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "up", windowcycle.moveUp)
hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "down", windowcycle.moveDown)

-- Bind to ctrl+alt+←
hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "left", windowcycle.moveLeft)

-- Bind to ctrl+alt+→
hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "right", windowcycle.moveRight)


-----------------------------------------------------------------
-- Manage Karabiner profile depending on the attached keyboard --
-----------------------------------------------------------------
local usb_config = {
    { "show_events_on_screen", false }
}

Usb = require("usb_events") -- This is global to allow the usage of `hs.inspect(Usb.getLastEvent())` from the console.
local karabiner = require("karabiner_profiles")
local audio = require("usb_audio")
audio.log = log

Usb.log = log
karabiner.log = log
Usb.start()

-- Show events on screen
if usb_config["show_events_on_screen"] then
    Usb.onAny(function(e)
        hs.alert.show(string.format("%s: %s (%s)", e.eventType, e.productName or "?", e.vendorName or "?"))
    end)
end

-- Later, from the Hammerspoon console:
-- hs.inspect(Usb.getLastEvent())


--[[
Glorious Keyboard device:
{
  eventType = "added",
  productID = 25903,
  productName = "USB DEVICE",
  vendorID = 3141,
  vendorName = "SONiX"
}
]] --

Usb.onAttach({
    productID = 25903,
    productName = "USB DEVICE",
    vendorID = 3141,
    vendorName = "SONiX"
}, function(event)
    karabiner.selectProfile("Glorious")
end)

Usb.onDetach({
    productID = 25903,
    productName = "USB DEVICE",
    vendorID = 3141,
    vendorName = "SONiX"
}, function(event)
    karabiner.selectProfile("CTRL")
end)

--[[
Plantronics Calisto 3200
{
  eventType = "added",
  productID = 332,
  productName = "Plantronics Calisto 3200",
  vendorID = 1151,
  vendorName = "Plantronics"
}
]] --

Usb.onAttach({
    productID = 332,
    productName = "Plantronics Calisto 3200",
    vendorID = 1151,
    vendorName = "Plantronics"
}, function(event) audio.setAudioDevice("Plantronics Calisto 3200") end)

Usb.onDetach({
    productID = 332,
    productName = "Plantronics Calisto 3200",
    vendorID = 1151,
    vendorName = "Plantronics"
}, function(event) audio.setAudioDeviceDefault() end)



--local calwatch = require("calendar_watcher")
--
---- First time: discover your calendar names/UIDs in the console
---- calwatch.listCalendars()
--calwatch.log = log
--calwatch.start({
--  lookaheadMinutes = 10,
--  pollSeconds = 60,
--  persistAlerts = false,
--    openCalendarIfNoURL = true,
--    sticky = true,
--  soundName = "Submarine",
--
--  -- pick any combination you like:
--  onlyCalendarsByName    = { "Meteomatics" },
--  -- onlyCalendarsByUID  = { "C1A23B45-....", "A9F8E7D6-...." },
--  -- excludeCalendarsByName = { "Birthdays", "Holidays" },
--  -- excludeCalendarsByUID= { "FFFFFFFF-...." },
--})

-- --- CONFIG ----
local LOOKAHEAD_MIN = 10
local CAL_NAMES = { "Meteomatics" }  -- or {} for all visible calendars
-- ---------------

local function findIcalBuddy()
  local out = hs.execute("command -v icalBuddy 2>/dev/null", true) or ""
  out = out:gsub("%s+$","")
  return (out ~= "" and out) or nil
end

local function fmt(ts) return os.date("%Y-%m-%d %H:%M:%S", ts) end

-- Join as a single argument value (no quotes needed for hs.task)
local function csv(list)
  if not list or #list == 0 then return nil end
  return table.concat(list, ",")
end

local function testIcalBuddyDates()
  local ib = findIcalBuddy()
  if not ib then
    print("❌ icalBuddy not found in PATH. Try: brew install ical-buddy")
    return
  end

  local now = os.time()
  local startStr = fmt(now)
  local endStr   = fmt(now + LOOKAHEAD_MIN * 60)

  local args = {
    --"-nrd",                  -- no relative dates (your build)
    --"-nc",                   -- no calendar name prefixes
    --"-b", "",                -- no bullets
    --"-ps", "||",             -- property separator
    --"-tf", "%Y-%m-%d %H:%M:%S",
    --"-df", "%Y-%m-%d",
    --"-iep", "uid,title,datetime,location,url,notes",
  }

  --local include = csv(CAL_NAMES)
  --if include then table.insert(args, "-ic"); table.insert(args, include) end

  -- IMPORTANT: pass the command as TWO args:
  --table.insert(args, ('eventsFrom:"%s"'):format(startStr))
  --table.insert(args, ('to:"%s"'):format(endStr))

  table.insert(args, ('eventsToday'))

  print("➡️  Running icalBuddy with args:\n", hs.inspect(args))

  local stdout, stderr = {}, {}
  local t = hs.task.new(ib, function(ec, so, se)
      if so and #so > 0 then table.insert(stdout, so) end
      if se and #se > 0 then table.insert(stderr, se) end
      print("🔚 exit:", ec)
      print("STDOUT:\n" .. (table.concat(stdout)))
      if #stderr > 0 then print("STDERR:\n" .. table.concat(stderr)) end
    end,
    args
  )

  t:start()
  t:waitUntilExit()
end

-- Run it once:
testIcalBuddyDates()
