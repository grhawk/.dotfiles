-- usb_audio.lua
-- Helper to switch macOS audio input/output when a USB device is attached

local M = {}
M.log = _G.log or { debug = function(_) end }


--- Set the audio input and output to a specific device by name
-- @param deviceName string: the name of the audio device (as listed in Audio MIDI Setup)
function M.setAudioDevice(deviceName)
    local input = hs.audiodevice.findInputByName(deviceName)
    local output = hs.audiodevice.findOutputByName(deviceName)

    if input then
        if not input:setDefaultInputDevice() then
            M.log.error(string.format("Could not setup %s as input device!", deviceName))
        else
            M.log.info("Audio input set to: " .. deviceName)
        end
    else
        M.log.warn("Input device not found: " .. deviceName)
    end

    if output then
        if not output:setDefaultOutputDevice() then
            M.log.error(string.format("Could not setup %s as output device!", deviceName))
        else
            M.log.info("Audio output set to: " .. deviceName)
        end
    else
        M.log.warn("Output device not found: " .. deviceName)
    end
end

--- Returns a callback function you can pass to usb_events.onAttach()
-- @param deviceName string: audio device name
function M.audioAttachCallback(deviceName)
    return function(event)
        M.setAudioDevice(deviceName)
    end
end

--- Set the audio input and output to the MacBook default ones
function M.setAudioDeviceDefault()
    local input = "MacBook Pro Microphone"
    local output = "MacBook Pro Speakers"
    M.setAudioDevice(input)
    M.setAudioDevice(output)
end

return M
