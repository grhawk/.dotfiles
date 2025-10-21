-- usb_events.lua
-- Generic USB event watcher with callback registration.

local M = {}
local watcher = nil
M.log = _G.log or { debug = function(_) end }

-- Registered callbacks
M._callbacks = {
  added = {},
  removed = {}
}

-- Helper to check if an event matches a pattern
local function matches(event, pattern)
  for key, value in pairs(pattern) do
    local field = event[key]
    if not field or not tostring(field):find(value) then
      return false
    end
  end
  return true
end

-- Core event handler
local function usbEvent(event)
  local etype = event.eventType
  local callbacks = M._callbacks[etype]
  if not callbacks then return end

  for _, entry in ipairs(callbacks) do
    if matches(event, entry.pattern) then
      M.log.debug(string.format("[usb_events] %s: matched %s", etype, hs.inspect(entry.pattern)))
      entry.fn(event)
    end
  end
end

-- Register a callback
local function register(eventType, pattern, fn)
  table.insert(M._callbacks[eventType], { pattern = pattern, fn = fn })
  M.log.debug(string.format("[usb_events] registered %s handler for %s", eventType, hs.inspect(pattern)))
end

function M.onAttach(pattern, fn)
  register("added", pattern, fn)
end

function M.onDetach(pattern, fn)
  register("removed", pattern, fn)
end

function M.start()
  if watcher then watcher:stop() end
  watcher = hs.usb.watcher.new(usbEvent)
  watcher:start()
  hs.alert.show("🔌 usb_events started")
  M.log.debug("[usb_events] watcher started")
end

function M.stop()
  if watcher then
    watcher:stop()
    watcher = nil
    hs.alert.show("🛑 usb_events stopped")
    M.log.debug("[usb_events] watcher stopped")
  end
end

return M
