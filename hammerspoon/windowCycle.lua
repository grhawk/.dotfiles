
local log = require("logger")

local M = {}

-- ============================================
-- 🕒 Debounce for smoother Safari behavior
-- ============================================
local debounceTimer = nil
local debounceDelay = 0.18
local pendingFrame = nil
local pendingWin = nil

local function applyPendingFrame()
    if pendingWin and pendingFrame then
        -- Round frame to integer pixels
        for k, v in pairs(pendingFrame) do
            pendingFrame[k] = math.floor(v + 0.5)
        end

        log.debug("Applying frame to %s → x:%d y:%d w:%d h:%d",
            pendingWin:application():name(),
            pendingFrame.x, pendingFrame.y, pendingFrame.w, pendingFrame.h
        )

        pendingWin:setFrame(pendingFrame, 0)
    end
    debounceTimer = nil
    pendingFrame = nil
    pendingWin = nil
end

local function debounceSetFrame(win, frame)
    pendingWin = win
    pendingFrame = frame
    if debounceTimer then debounceTimer:stop() end
    debounceTimer = hs.timer.doAfter(debounceDelay, applyPendingFrame)
end

local function getWorkingFrame(win)
    -- If we're in a debounce sequence, use pendingFrame instead of actual window frame
    if pendingWin == win and pendingFrame then
        return hs.geometry.copy(pendingFrame)
    else
        return win:frame()
    end
end

-- ============================================
-- 🧠 Utility: Almost Equal (tolerance = 1)
-- ============================================
local function almostEqual(a, b, tolerance)
    tolerance = tolerance or 1
    return math.abs(a - b) <= tolerance
end

local function frameAlmostEqual(f1, f2)
    return almostEqual(f1.x, f2.x)
       and almostEqual(f1.y, f2.y)
       and almostEqual(f1.w, f2.w)
       and almostEqual(f1.h, f2.h)
end

-- ============================================
-- 📐 Window positioning helpers
-- ============================================
local function cycleHorizontal(win, direction)
    local screenFrame = win:screen():frame()
    local current = getWorkingFrame(win)
    local newFrame = hs.geometry.copy(current)

    log.debug("cycleHorizontal dir=%s current x=%d y=%d w=%d h=%d",
        direction, current.x, current.y, current.w, current.h)

    local halfW = screenFrame.w / 2
    local threeQuartersW = screenFrame.w * 0.75
    local quarterW = screenFrame.w / 4

    local isRightHalf = almostEqual(current.x, screenFrame.x + halfW) and almostEqual(current.w, halfW)
    local isRight75   = almostEqual(current.x, screenFrame.x + screenFrame.w - threeQuartersW) and almostEqual(current.w, threeQuartersW)
    local isRight25   = almostEqual(current.x, screenFrame.x + screenFrame.w - quarterW) and almostEqual(current.w, quarterW)
    local isLeftHalf  = almostEqual(current.x, screenFrame.x) and almostEqual(current.w, halfW)
    local isLeft75    = almostEqual(current.x, screenFrame.x) and almostEqual(current.w, threeQuartersW)
    local isLeft25    = almostEqual(current.x, screenFrame.x) and almostEqual(current.w, quarterW)

    if direction == "right" then
        if isLeftHalf then
            newFrame.x = screenFrame.x
            newFrame.w = threeQuartersW
        elseif isLeft75 then
            newFrame.x = screenFrame.x + halfW
            newFrame.w = halfW
        elseif isRightHalf then
            newFrame.x = screenFrame.x + screenFrame.w - quarterW
            newFrame.w = quarterW
        elseif isRight25 then
            newFrame.x = screenFrame.x + halfW
            newFrame.w = halfW
        else
            newFrame.x = screenFrame.x + halfW
            newFrame.y = screenFrame.y
            newFrame.w = halfW
            newFrame.h = screenFrame.h
        end
    else -- left
        if isRightHalf then
            newFrame.x = screenFrame.x + screenFrame.w - threeQuartersW
            newFrame.w = threeQuartersW
        elseif isRight75 then
            newFrame.x = screenFrame.x
            newFrame.w = halfW
        elseif isLeftHalf then
            newFrame.x = screenFrame.x
            newFrame.w = quarterW
        elseif isLeft25 then
            newFrame.x = screenFrame.x
            newFrame.w = halfW
        else
            newFrame.x = screenFrame.x
            newFrame.y = screenFrame.y
            newFrame.w = halfW
            newFrame.h = screenFrame.h
        end
    end

    debounceSetFrame(win, newFrame)
end

local function cycleVertical(win, direction)
    local screenFrame = win:screen():frame()
    local current = getWorkingFrame(win)
    local newFrame = hs.geometry.copy(current)

    log.debug("cycleVertical dir=%s current x=%d y=%d w=%d h=%d",
        direction, current.x, current.y, current.w, current.h)

    local halfH = screenFrame.h / 2
    local threeQuartersH = screenFrame.h * 0.75
    local quarterH = screenFrame.h / 4

    local isTopHalf    = almostEqual(current.y, screenFrame.y) and almostEqual(current.h, halfH)
    local isTop75      = almostEqual(current.y, screenFrame.y) and almostEqual(current.h, threeQuartersH)
    local isTop25      = almostEqual(current.y, screenFrame.y) and almostEqual(current.h, quarterH)
    local isBottomHalf = almostEqual(current.y, screenFrame.y + halfH) and almostEqual(current.h, halfH)
    local isBottom75   = almostEqual(current.y, screenFrame.y + screenFrame.h - threeQuartersH) and almostEqual(current.h, threeQuartersH)
    local isBottom25   = almostEqual(current.y, screenFrame.y + screenFrame.h - quarterH) and almostEqual(current.h, quarterH)

    if direction == "down" then
        if isTopHalf then
            newFrame.y = screenFrame.y
            newFrame.h = threeQuartersH
        elseif isTop75 then
            newFrame.y = screenFrame.y + halfH
            newFrame.h = halfH
        elseif isBottomHalf then
            newFrame.y = screenFrame.y + screenFrame.h - quarterH
            newFrame.h = quarterH
        elseif isBottom25 then
            newFrame.y = screenFrame.y + halfH
            newFrame.h = halfH
        else
            newFrame.x = screenFrame.x
            newFrame.y = screenFrame.y + halfH
            newFrame.w = screenFrame.w
            newFrame.h = halfH
        end
    else -- up
        if isBottomHalf then
            newFrame.y = screenFrame.y + screenFrame.h - threeQuartersH
            newFrame.h = threeQuartersH
        elseif isBottom75 then
            newFrame.y = screenFrame.y
            newFrame.h = halfH
        elseif isTopHalf then
            newFrame.y = screenFrame.y
            newFrame.h = quarterH
        elseif isTop25 then
            newFrame.y = screenFrame.y
            newFrame.h = halfH
        else
            newFrame.x = screenFrame.x
            newFrame.y = screenFrame.y
            newFrame.w = screenFrame.w
            newFrame.h = halfH
        end
    end

    debounceSetFrame(win, newFrame)
end

-- ============================================
-- 🚀 Public API
-- ============================================

function M.moveLeft()  local w = hs.window.focusedWindow(); if w then cycleHorizontal(w, "left") end end
function M.moveRight() local w = hs.window.focusedWindow(); if w then cycleHorizontal(w, "right") end end
function M.moveUp()    local w = hs.window.focusedWindow(); if w then cycleVertical(w, "up") end end
function M.moveDown()  local w = hs.window.focusedWindow(); if w then cycleVertical(w, "down") end end

return M
