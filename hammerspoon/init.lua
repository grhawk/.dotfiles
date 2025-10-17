
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
