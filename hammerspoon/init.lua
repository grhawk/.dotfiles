
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

-- Helper: compare two floating point numbers with tolerance
local function almostEqual(a, b, tolerance)
  tolerance = tolerance or 0.0001
  return math.abs(a - b) < tolerance
end

------------------------------------------------------------
-- 🪄 Center window at ~80% size (Cmd+Ctrl+Shift+Alt+X)
------------------------------------------------------------
local function centerWindow()
    local win = hs.window.focusedWindow()
    if not win then return end
    saveWindowFrame(win)

    local screen    = win:screen()
    local max       = screen:frame()

    local newWidth  = max.w * 0.9
    local newHeight = max.h * 0.9
    local newX      = max.x + (max.w - newWidth) / 2
    local newY      = max.y + (max.h - newHeight) / 2

    local f         = win:frame()
    f.x             = newX
    f.y             = newY
    f.w             = newWidth
    f.h             = newHeight
    win:setFrame(f, 0)
end

------------------------------------------------------------
-- 🪄 Toggle fullscreen window (Cmd+Shift+Ctrl+Alt+Space)
------------------------------------------------------------
local fullscreenHistory = {}  -- store previous frames per window

local function toggleFullscreenWindow()
  local win = hs.window.focusedWindow()
  if not win then return end
  local id = win:id()
  local screen = win:screen()
  local max = screen:frame()

  if fullscreenHistory[id] then
    -- Restore previous frame
    win:setFrame(fullscreenHistory[id])
    fullscreenHistory[id] = nil
  else
    -- Save current frame and go fullscreen
    fullscreenHistory[id] = win:frame()
    local f = win:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f, 0)
  end
end

-- Bind ⌘ + Shift + Ctrl + Alt + Space
hs.hotkey.bind({"cmd", "shift", "ctrl", "alt"}, "space", toggleFullscreenWindow)

-- Bind ⌘ + ⌥ + ⌃ + ⇧ + Z
-- hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "z", restoreWindowFrame)

-- Bind ⌘ + Ctrl + Shift + ⌥ + X
hs.hotkey.bind({"cmd", "ctrl", "shift", "alt"}, "x", centerWindow)

-- Bind to ctrl+alt+↑ and ctrl+alt+↓
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "up", windowcycle.moveUp)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "down", windowcycle.moveDown)

-- Bind to ctrl+alt+←
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "left", windowcycle.moveLeft)

-- Bind to ctrl+alt+→
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "right", windowcycle.moveRight)
