local log = require("logger")

local M = {}

-- =========================
-- 🧠 Config
-- =========================
local debounceDelay = 0.1
local historyLimit = 5
local sizeTolerance = 1       -- for "almost equal" checks
local centerWindowRatio = 0.9 -- Are taken by the center and maximize function
-- =========================
-- 📝 State
-- =========================
local pendingFrames = {} -- [win:id()] = hs.geometry
local debounceTimer = nil
local lastTargetWin = nil

local history = {}         -- [win:id()] = {frame1, frame2, ...}
local maximizeRestore = {} -- [win:id()] = previousFrame
local centerRestore = {}   -- [win:id()] = previousFrame

-- =========================
-- 🧰 Helpers
-- =========================

local function almostEqual(a, b)
    return math.abs(a - b) <= sizeTolerance
end

local function saveToHistory(win)
    local id = win:id()
    if not history[id] then history[id] = {} end
    local frame = win:frame()

    -- Avoid duplicates if last entry is the same
    local h = history[id]
    local last = h[#h]
    if last and frame:equals(last) then return end

    table.insert(h, frame)
    if #h > historyLimit then
        table.remove(h, 1)
    end
end

local function popHistory(win)
    local id = win:id()
    if history[id] and #history[id] > 0 then
        return table.remove(history[id])
    end
    return nil
end

local function applyPendingFrame()
    if lastTargetWin and pendingFrames[lastTargetWin:id()] then
        local frame = pendingFrames[lastTargetWin:id()]
        frame.x = math.floor(frame.x + 0.5)
        frame.y = math.floor(frame.y + 0.5)
        frame.w = math.floor(frame.w + 0.5)
        frame.h = math.floor(frame.h + 0.5)

        lastTargetWin:setFrame(frame, 0)
    end
    debounceTimer = nil
end

local function debounceSetFrame(win, frame)
    lastTargetWin = win
    pendingFrames[win:id()] = frame

    if debounceTimer then
        debounceTimer:stop()
    end
    debounceTimer = hs.timer.doAfter(debounceDelay, applyPendingFrame)
end

local function getBaseFrame(win)
    -- Use pending frame if exists, otherwise actual frame
    local pf = pendingFrames[win:id()]
    if pf then
        return pf:copy()
    else
        return win:frame()
    end
end

-- =========================
-- 🧭 Cycle Functions
-- =========================

local function moveWindowHorizontal(win, direction)
    local screenFrame = win:screen():frame()
    local frame = getBaseFrame(win)
    maximizeRestore[win:id()] = nil
    centerRestore[win:id()] = nil

    log.debug(string.format(
        "Horizontal cycle called for window %d | direction=%s | x=%d w=%d",
        win:id(), direction, frame.x, frame.w
    ))

    if direction == "right" then
        if almostEqual(frame.x, screenFrame.x) and almostEqual(frame.w, screenFrame.w / 2) then
            -- Left half -> LEFT 75%
            frame.w = screenFrame.w * 0.75
            frame.x = screenFrame.x
        elseif almostEqual(frame.x, screenFrame.x) and almostEqual(frame.w, screenFrame.w * 0.75) then
            -- Left 75% -> Right half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x + screenFrame.w / 2
        elseif almostEqual(frame.x, screenFrame.x + screenFrame.w / 2) and almostEqual(frame.w, screenFrame.w / 2) then
            -- Right half -> Right quarter
            frame.w = screenFrame.w / 4
            frame.x = screenFrame.x + (screenFrame.w * 3 / 4)
        elseif almostEqual(frame.x, screenFrame.x + (screenFrame.w * 3 / 4)) and almostEqual(frame.w, screenFrame.w / 4) then
            -- Right quarter -> Right half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x + screenFrame.w / 2
        else
            -- Default: Left half -> Right half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x + screenFrame.w / 2
        end
    elseif direction == "left" then
        if almostEqual(frame.x, screenFrame.x + screenFrame.w / 2) and almostEqual(frame.w, screenFrame.w / 2) then
            -- Right half -> RIGHT 75%
            frame.w = screenFrame.w * 0.75
            frame.x = screenFrame.x + screenFrame.w - frame.w
        elseif almostEqual(frame.x, screenFrame.x + screenFrame.w - (screenFrame.w * 0.75)) and almostEqual(frame.w, screenFrame.w * 0.75) then
            -- Right 75% -> Left half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x
        elseif almostEqual(frame.x, screenFrame.x) and almostEqual(frame.w, screenFrame.w / 2) then
            -- Left half -> Left quarter
            frame.w = screenFrame.w / 4
            frame.x = screenFrame.x
        elseif almostEqual(frame.x, screenFrame.x) and almostEqual(frame.w, screenFrame.w / 4) then
            -- Left quarter -> Left half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x
        else
            -- Default: Right half -> Left half
            frame.w = screenFrame.w / 2
            frame.x = screenFrame.x
        end
    end

    debounceSetFrame(win, frame)
end

local function moveWindowVertical(win, direction)
    local screenFrame = win:screen():frame()
    local frame = getBaseFrame(win)
    maximizeRestore[win:id()] = nil
    centerRestore[win:id()] = nil

    log.debug(string.format(
        "Vertical cycle called for window %d | direction=%s | y=%d h=%d",
        win:id(), direction, frame.y, frame.h
    ))

    if direction == "down" then
        if almostEqual(frame.y, screenFrame.y) and almostEqual(frame.h, screenFrame.h / 2) then
            frame.h = screenFrame.h * 0.75
            frame.y = screenFrame.y
        elseif almostEqual(frame.y, screenFrame.y) and almostEqual(frame.h, screenFrame.h * 0.75) then
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y + screenFrame.h / 2
        elseif almostEqual(frame.y, screenFrame.y + screenFrame.h / 2) and almostEqual(frame.h, screenFrame.h / 2) then
            frame.h = screenFrame.h / 4
            frame.y = screenFrame.y + (screenFrame.h * 3 / 4)
        elseif almostEqual(frame.y, screenFrame.y + (screenFrame.h * 3 / 4)) and almostEqual(frame.h, screenFrame.h / 4) then
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y + screenFrame.h / 2
        else
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y + screenFrame.h / 2
        end
    elseif direction == "up" then
        if almostEqual(frame.y, screenFrame.y + screenFrame.h / 2) and almostEqual(frame.h, screenFrame.h / 2) then
            frame.h = screenFrame.h * 0.75
            frame.y = screenFrame.y + screenFrame.h - frame.h
        elseif almostEqual(frame.y, screenFrame.y + screenFrame.h - (screenFrame.h * 0.75)) and almostEqual(frame.h, screenFrame.h * 0.75) then
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y
        elseif almostEqual(frame.y, screenFrame.y) and almostEqual(frame.h, screenFrame.h / 2) then
            frame.h = screenFrame.h / 4
            frame.y = screenFrame.y
        elseif almostEqual(frame.y, screenFrame.y) and almostEqual(frame.h, screenFrame.h / 4) then
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y
        else
            frame.h = screenFrame.h / 2
            frame.y = screenFrame.y
        end
    end

    debounceSetFrame(win, frame)
end

-- =========================
-- 🖼 Center & Maximize
-- =========================

local function centerWindow(win)
    local id = win:id()
    maximizeRestore[id] = nil
    log.debug("id: %s", id)
    for k, v in pairs(centerRestore) do
        log.debug("k: %s, v: %s", k, v)
    end
    if centerRestore[id] then
        log.debug("restore from center window")
        debounceSetFrame(win, centerRestore[id])
        centerRestore[id] = nil
    else
        local screenFrame = win:screen():frame()
        local newFrame = getBaseFrame(win)
        centerRestore[id] = getBaseFrame(win)

        newFrame.w = screenFrame.w * centerWindowRatio
        newFrame.h = screenFrame.h * centerWindowRatio
        newFrame.x = screenFrame.x + (screenFrame.w - newFrame.w) / 2
        newFrame.y = screenFrame.y + (screenFrame.h - newFrame.h) / 2

        debounceSetFrame(win, newFrame)
    end
end

local function toggleMaximize(win)
    local id = win:id()
    centerRestore[id] = nil
    if maximizeRestore[id] then
        debounceSetFrame(win, maximizeRestore[id])
        maximizeRestore[id] = nil
    else
        maximizeRestore[id] = getBaseFrame(win)
        local screenFrame = win:screen():frame()
        debounceSetFrame(win, screenFrame)
    end
end

-- =========================
-- ↩ Undo
-- =========================

local function undo(win)
    local prev = popHistory(win)
    if prev then
        pendingFrames[win:id()] = nil -- clear pending
        win:setFrame(prev, 0)
    end
end

-- =========================
-- 🧭 Public API
-- =========================

function M.moveLeft()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); moveWindowHorizontal(win, "left")
    end
end

function M.moveRight()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); moveWindowHorizontal(win, "right")
    end
end

function M.moveUp()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); moveWindowVertical(win, "up")
    end
end

function M.moveDown()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); moveWindowVertical(win, "down")
    end
end

function M.center()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); centerWindow(win)
    end
end

function M.maximize()
    local win = hs.window.focusedWindow()
    if win then
        saveToHistory(win); toggleMaximize(win)
    end
end

function M.undo()
    local win = hs.window.focusedWindow()
    if win then undo(win) end
end

return M
