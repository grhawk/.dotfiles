
hs.loadSpoon("EmmyLua")
hs.console.clearConsole()
local log = require("logger")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
spoon.ReloadConfiguration:bindHotkeys({reloadConfiguration={{"cmd", "alt", "ctrl"}, "R", message="Reloading config"}})

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "P", function()
    local laptopScreen = "Built-in Retina Display"
    local ghostty = hs.application.launchOrFocus("Ghostty")
    local safari = hs.application.launchOrFocus("Safari")
    local windowLayout = {
        {"Safari",  nil,          laptopScreen, hs.geometry.rect(0, 0.5, 0.5, 0.5),    nil, nil},
        {"Mail",    nil,          laptopScreen, hs.layout.right50,   nil, nil},
        {"Ghostty", nil, laptopScreen, nil, nil, hs.geometry.rect(0, 48, 4000, 48)},
    }
    hs.layout.apply(windowLayout)
end)

k = hs.hotkey.modal.new('cmd-shift', 'd')
function k:entered() hs.alert.show('Entered mode\nasdasd') end
function k:exited()  hs.alert'Exited mode'  end
k:bind('', 'escape', function() k:exit() end)
k:bind('', 'J', 'Pressed J', function() print 'let the record show that J was pressed' end)


local windowcycle = require("windowCycle")

-- Bind ⌘ + Shift + Ctrl + Alt + Space
hs.hotkey.bind({"cmd", "shift", "ctrl", "alt"}, "space", windowcycle.maximize)

-- Bind ⌘ + ⌥ + ⌃ + ⇧ + Z
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "z", windowcycle.undo)

-- Bind ⌘ + Ctrl + Shift + ⌥ + X
hs.hotkey.bind({"cmd", "ctrl", "shift", "alt"}, "x", windowcycle.center)

-- Bind to ctrl+alt+↑ and ctrl+alt+↓
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "up", windowcycle.moveUp)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "down", windowcycle.moveDown)

-- Bind to ctrl+alt+←
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "left", windowcycle.moveLeft)

-- Bind to ctrl+alt+→
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "right", windowcycle.moveRight)


-----------------------------------------------------------------
-- Manage Karabiner profile depending on the attached keyboard --
-----------------------------------------------------------------
local usb_config = {
{"show_events_on_screen", false}
}

Usb = require("usb_events") -- This is global to allow the usage of `hs.inspect(Usb.getLastEvent())` from the console.
local karabiner = require("karabiner_profiles")
local audio = require("usb_audio")

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
]]--

Usb.onAttach({
               productID = 25903,
               productName = "USB DEVICE",
               vendorID = 3141,
               vendorName = "SONiX"
             }, function(event) karabiner.selectProfile("Glorious")
end)

Usb.onDetach({
               productID = 25903,
               productName = "USB DEVICE",
               vendorID = 3141,
               vendorName = "SONiX"
             }, function(event) karabiner.selectProfile("CTRL")
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