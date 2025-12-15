-- audio_autoroute.lua
-- Generic auto-switching of macOS audio input/output based on available devices

local M = {}
M.log = _G.log or {
    debug = function(_) end,
    info  = function(_) end,
    warn  = function(_) end,
    error = function(_) end,
}

-- Your generic audio helper (the one with setDevices / etc.)
local audio = require("audio_devices")

-- A "route" is:
-- {
--   name     = "Friendly name for logs",
--   match    = "Device name substring or exact name",
--   input    = "Input device name (defaults to match)",
--   output   = "Output device name (defaults to match)",
--   priority = 100   -- higher wins
-- }
M.routes = {}

-- Fallback route used when none of the above match
M.fallback = nil

M._running          = false
M._lastAppliedRoute = nil

----------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------

--- Add a preferred audio route
-- @param opts table: { name, match, input?, output?, priority? }
function M.addRoute(opts)
    assert(opts.match, "route 'match' is required")

    local route = {
        name     = opts.name or opts.match,
        match    = opts.match,
        input    = opts.input or opts.match,
        output   = opts.output or opts.match,
        priority = opts.priority or 10,
    }

    table.insert(M.routes, route)
    M.log.info(("[audio_autoroute] Added route '%s' (match='%s', prio=%d)")
        :format(route.name, route.match, route.priority))
end

--- Set fallback devices
-- @param opts table: { name?, input, output }
function M.setFallback(opts)
    assert(opts.input and opts.output, "fallback needs input and output")

    M.fallback = {
        name   = opts.name or "fallback",
        input  = opts.input,
        output = opts.output,
    }

    M.log.info(("[audio_autoroute] Set fallback '%s' (in='%s', out='%s')")
        :format(M.fallback.name, M.fallback.input, M.fallback.output))
end

----------------------------------------------------------------------
-- Internal helpers
----------------------------------------------------------------------

-- Build a set of current audio device names (for outputs and inputs)
local function currentDeviceNames()
    local outputs = {}
    for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
        outputs[dev:name()] = true
    end

    local inputs = {}
    for _, dev in ipairs(hs.audiodevice.allInputDevices()) do
        inputs[dev:name()] = true
    end

    return inputs, outputs
end

local function stringMatches(haystack, needle)
    if haystack == nil or needle == nil then return false end
    -- do a case-insensitive substring match
    return string.find(string.lower(haystack), string.lower(needle), 1, true) ~= nil
end

local function pickBestRoute()
    local inputs, outputs = currentDeviceNames()

    local bestRoute = nil
    local bestPrio  = -math.huge

    for _, route in ipairs(M.routes) do
        -- Check if at least the output side is present; input is optional
        local outPresent = false
        for name, _ in pairs(outputs) do
            if stringMatches(name, route.match) then
                outPresent = true
                break
            end
        end

        if outPresent and route.priority > bestPrio then
            bestRoute = route
            bestPrio  = route.priority
        end
    end

    if bestRoute then
        return bestRoute
    end

    -- Nothing matched: use fallback if configured
    return M.fallback
end

local function applyRoute(route)
    if not route then
        M.log.debug("[audio_autoroute] No applicable route (and no fallback)")
        return
    end

    -- Avoid re-applying same route over and over
    if M._lastAppliedRoute
       and M._lastAppliedRoute.name   == route.name
       and M._lastAppliedRoute.input  == route.input
       and M._lastAppliedRoute.output == route.output
    then
        M.log.debug("[audio_autoroute] Route unchanged (" .. route.name .. ")")
        return
    end

    M.log.info(("[audio_autoroute] Applying route '%s' (in='%s', out='%s')")
        :format(route.name, route.input, route.output))

    audio.setDevices{
        input  = route.input,
        output = route.output,
    }

    M._lastAppliedRoute = route
end

local function handleAudioEvent(event)
    M.log.debug("[audio_autoroute] audio event: " .. tostring(event))
    local route = pickBestRoute()
    applyRoute(route)
end

----------------------------------------------------------------------
-- Public controls
----------------------------------------------------------------------

function M.start()
    if M._running then return end
    hs.audiodevice.watcher.setCallback(handleAudioEvent)
    hs.audiodevice.watcher.start()
    M._running = true
    M.log.info("[audio_autoroute] Started watcher")
    -- also apply immediately based on current devices
    handleAudioEvent("initial")
end

function M.stop()
    if not M._running then return end
    hs.audiodevice.watcher.stop()
    M._running = false
    M.log.info("[audio_autoroute] Stopped watcher")
end

return M
