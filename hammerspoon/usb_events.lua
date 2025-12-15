-- usb_events.lua
-- Generic USB event listener for Hammerspoon
-- Allows registering callbacks for device attach/detach events based on pattern matching
-- and provides helpers to inspect the most recent USB event.

local M = {}
M._callbacks = {
    attach = {},
    detach = {},
    any = {}
}
M._lastEvent = nil
M.log = _G.log or { debug = function(_) end }

-- Match an event against a user-provided pattern
local function matchPattern(event, pattern)
    M.log.debug(string.format("Event: %s -- Patter: %s", hs.inspect(event), hs.inspect(pattern)))
    for k, v in pairs(pattern) do
        if not tostring(event[k] or ""):match(v) then
            M.log.info(string.format("Match device %s", k))
            return false
        end
    end
    return true
end

-- Dispatch an event to matching callbacks
local function dispatch(event, list)
    for _, item in ipairs(list) do
        if matchPattern(event, item.pattern) then
            hs.timer.doAfter(2.5, function() item.callback(event) end)
        end
    end
end

-- Unified USB callback
local function usbCallback(event)
    M._lastEvent = hs.fnutils.copy(event)
    if event.eventType == "added" then
        dispatch(event, M._callbacks.attach)
    elseif event.eventType == "removed" then
        dispatch(event, M._callbacks.detach)
    end

    -- Notify "any" watchers
    dispatch(event, M._callbacks.any)
end

-- Start watching
function M.start()
    if not M._watcher then
        M._watcher = hs.usb.watcher.new(usbCallback)
        M._watcher:start()
        M.log.info("[usb_events] Started USB watcher")
    end
end

-- Stop watching
function M.stop()
    if M._watcher then
        M._watcher:stop()
        M._watcher = nil
        M.log.info("[usb_events] Stopped USB watcher")
    end
end

-- Register callbacks
function M.onAttach(pattern, callback)
    table.insert(M._callbacks.attach, { pattern = pattern or {}, callback = callback })
end

function M.onDetach(pattern, callback)
    table.insert(M._callbacks.detach, { pattern = pattern or {}, callback = callback })
end

function M.onAny(callback)
    table.insert(M._callbacks.any, { pattern = {}, callback = callback })
end

--- 🔍 Get the last USB event that occurred
--- Returns a table like:
--- {
---   eventType = "added" or "removed",
---   productName = "Some Device",
---   vendorName = "Vendor Inc.",
---   vendorID = 1234,
---   productID = 5678,
---   locationID = 87654321
--- }
function M.getLastEvent()
    if M._lastEvent then
        print(string.format(
            "[usb_events] Last event: %s — %s (%s)",
            M._lastEvent.eventType,
            M._lastEvent.productName or "Unknown Product",
            M._lastEvent.vendorName or "Unknown Vendor"
        ))
        return M._lastEvent
    else
        print("[usb_events] No USB events recorded yet.")
        return nil
    end
end

return M
