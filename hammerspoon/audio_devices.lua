-- audio_devices.lua
local M = {}
M.log = _G.log or { debug = function(_) end }

local function setInput(deviceName)
    local input = hs.audiodevice.findInputByName(deviceName)
    if input then
        if not input:setDefaultInputDevice() then
            M.log.error(("Could not set %s as input device!"):format(deviceName))
        else
            M.log.info("Audio input set to: " .. deviceName)
        end
    else
        M.log.warn("Input device not found: " .. deviceName)
    end
end

local function setOutput(deviceName)
    local output = hs.audiodevice.findOutputByName(deviceName)
    if output then
        if not output:setDefaultOutputDevice() then
            M.log.error(("Could not set %s as output device!"):format(deviceName))
        else
            M.log.info("Audio output set to: " .. deviceName)
        end
    else
        M.log.warn("Output device not found: " .. deviceName)
    end
end

--- Set default input and/or output by name
function M.setDevices(opts)
    -- opts = { input = "foo", output = "bar" }
    if opts.input then setInput(opts.input) end
    if opts.output then setOutput(opts.output) end
end

--- Convenience: set to MacBook built-ins
function M.setMacBookDefaults()
    M.setDevices{
        input  = "MacBook Pro Microphone",
        output = "MacBook Pro Speakers",
    }
end

--- Returns the current default input and output audio devices
-- @return table: { input = "<device name>", output = "<device name>" }
function M.getCurrentDevices()
    local input  = hs.audiodevice.defaultInputDevice()
    local output = hs.audiodevice.defaultOutputDevice()

    return {
        input  = input and input:name() or nil,
        output = output and output:name() or nil,
    }
end

return M
