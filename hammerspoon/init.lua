
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


-- Helper: compare two floating point numbers with tolerance
local function almostEqual(a, b, tolerance)
  tolerance = tolerance or 0.0001
  return math.abs(a - b) < tolerance
end

------------------------------------------------------------
-- 🪄 Window History (Undo last action)
------------------------------------------------------------
local windowHistory = {}

-- Save the current frame of the focused window before changing it
local function saveWindowFrame(win)
  if not win then return end
  local id = win:id()
  if id then
    windowHistory[id] = win:frame()
  end
end

-- Restore the last saved frame of the focused window
local function restoreWindowFrame()
  local win = hs.window.focusedWindow()
  if not win then return end
  local id = win:id()
  local lastFrame = windowHistory[id]
  if lastFrame then
    win:setFrame(lastFrame)
    windowHistory[id] = nil -- clear after undo to avoid toggling infinitely
  else
    hs.alert.show("No previous state for this window")
  end
end


-- Cycle positions: 50% right, 25% right
local function moveWindowRightCycle()
    local win = hs.window.focusedWindow()
    if not win then return end
    saveWindowFrame(win)

    local screen = win:screen()
    local f = win:frame()
    local max = screen:frame()

    -- Current width fraction (e.g., 0.5 if window takes half the screen)
    local currentFraction = f.w / max.w

    if almostEqual(f.x, max.x + max.w * 0.5) and almostEqual(currentFraction, 0.5) then
        -- Case 1: window is already at right half → go to right quarter
        f.x = max.x + max.w * 0.75
        f.w = max.w * 0.25
        win:setFrame(f)
    elseif almostEqual(f.x, max.x + max.w * 0.75) and almostEqual(currentFraction, 0.25) then
        -- Case 2: window is already at right quarter → cycle back to right half
        f.x = max.x + max.w * 0.5
        f.w = max.w * 0.5
        win:setFrame(f)
    else
        -- Default: snap to right half
        f.x = max.x + max.w * 0.5
        f.y = max.y
        f.w = max.w * 0.5
        f.h = max.h
        win:setFrame(f)
    end
end

-- Cycle positions: 50% left, 25% left
local function moveWindowLeftCycle()
  local win = hs.window.focusedWindow()
  if not win then return end
  saveWindowFrame(win)

  local screen = win:screen()
  local f = win:frame()
  local max = screen:frame()

  -- Current width fraction (e.g., 0.5 if window takes half the screen)
  local currentFraction = f.w / max.w

  if almostEqual(f.x, max.x) and almostEqual(currentFraction, 0.5) then
    -- Case 1: window is already at left half → go to left quarter
    f.x = max.x
    f.w = max.w * 0.25
    win:setFrame(f)
  elseif almostEqual(f.x, max.x) and almostEqual(currentFraction, 0.25) then
    -- Case 2: window is already at left quarter → cycle back to left half
    f.x = max.x
    f.w = max.w * 0.5
    win:setFrame(f)
  else
    -- Default: snap to left half
    f.x = max.x
    f.y = max.y
    f.w = max.w * 0.5
    f.h = max.h
    win:setFrame(f)
  end
end

-- Cycle positions: top half (50%) ↔ top quarter (25%)
local function moveWindowTopCycle()
  local win = hs.window.focusedWindow()
  if not win then return end
  saveWindowFrame(win)

  local screen = win:screen()
  local f = win:frame()
  local max = screen:frame()

  local currentFraction = f.h / max.h

  if almostEqual(f.y, max.y) and almostEqual(currentFraction, 0.5) then
    -- Case 1: top half → top quarter
    f.y = max.y
    f.h = max.h * 0.25
    f.x = max.x
    f.w = max.w
    win:setFrame(f)
  elseif almostEqual(f.y, max.y) and almostEqual(currentFraction, 0.25) then
    -- Case 2: top quarter → top half
    f.y = max.y
    f.h = max.h * 0.5
    f.x = max.x
    f.w = max.w
    win:setFrame(f)
  else
    -- Default: snap to top half
    f.y = max.y
    f.x = max.x
    f.w = max.w
    f.h = max.h * 0.5
    win:setFrame(f)
  end
end

-- Cycle positions: bottom half (50%) ↔ bottom quarter (25%)
local function moveWindowBottomCycle()
  local win = hs.window.focusedWindow()
  if not win then return end
  saveWindowFrame(win)

  local screen = win:screen()
  local f = win:frame()
  local max = screen:frame()

  local currentFraction = f.h / max.h

  log.debug("moveWindowBottomCycle: f.y: %.1f, max.y: %.1f, max.h: %.1f, window_position: %.1f, almost_equal_position: %s, currentFraction: %.8f", f.y, max.y, max.h, max.y + max.h * 0.5, almostEqual(f.y, max.y + max.h * 0.5, 1), currentFraction)

  if almostEqual(f.y, max.y + max.h * 0.5, 1) and almostEqual(currentFraction, 0.5, 0.1) then
    -- Case 1: bottom half → bottom quarter
    log.debug("Entering bottom quarter")
    f.y = max.y + max.h * 0.75
    f.h = max.h * 0.25
    f.x = max.x
    f.w = max.w
    win:setFrame(f)
  elseif almostEqual(f.y, max.y + max.h * 0.75) and almostEqual(currentFraction, 0.25) then
    -- Case 2: bottom quarter → bottom half
    log.debug("Entering bottom half")

    f.y = max.y + max.h * 0.5
    f.h = max.h * 0.5
    f.x = max.x
    f.w = max.w
    win:setFrame(f)
  else
    -- Default: snap to bottom half
    f.y = max.y + max.h * 0.5
    f.x = max.x
    f.w = max.w
    f.h = max.h * 0.5
    win:setFrame(f)
  end
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
    win:setFrame(f)
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
    win:setFrame(f)
  end
end

-- Bind ⌘ + Shift + Ctrl + Alt + Space
hs.hotkey.bind({"cmd", "shift", "ctrl", "alt"}, "space", toggleFullscreenWindow)



-- Bind ⌘ + ⌥ + ⌃ + ⇧ + Z
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "z", restoreWindowFrame)


-- Bind ⌘ + Ctrl + Shift + ⌥ + X
hs.hotkey.bind({"cmd", "ctrl", "shift", "alt"}, "x", centerWindow)
-- Bind to ctrl+alt+↑ and ctrl+alt+↓
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "up", moveWindowTopCycle)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "down", moveWindowBottomCycle)


-- Bind to ctrl+alt+←
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "left", moveWindowLeftCycle)


-- Bind to ctrl+alt+→
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "right", moveWindowRightCycle)
