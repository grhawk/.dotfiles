-- calendar_meet_alert_multi_final.lua
-- Alerts 30, 10, 1 minute before events
-- Events with links → clickable notification to open in Chrome
-- Events without links → normal notification

local M = {}

-- === Configuration ===
M.calendarNames = { "Meteomatics" }        -- calendars to monitor
M.checkInterval = 30                             -- seconds
M.alertOffsets = {30*60, 10*60, 90}             -- seconds before event
M.browserScheme = "googlechrome"                -- browser scheme for meetings

-- Internal storage to track which alerts have fired per event
-- { [eventID] = { [offset] = true, ... } }
M._alertedEvents = {}

-- Detect Zoom/Meet/Teams links in notes or location
local function findMeetLink(event)
    if not event then return nil end
    local textFields = { event.location, event.notes }
    for _, text in ipairs(textFields) do
        if text then
            local link = string.match(text, "(https?://[%w%p]+)")
            if link and (link:match("zoom.us") or link:match("meet.google.com") or link:match("teams.microsoft.com")) then
                return link
            end
        end
    end
    return nil
end

-- Send a clickable notification
local function notifyWithLink(event, link, minutesBefore)
    local title = string.format("Meeting in %d min: %s", minutesBefore, event.title)
    local message = "Starts at " .. os.date("%H:%M", event:startDate():time()) .. "\nClick to open meeting"

    local notification = hs.notify.new(function(n)
        hs.urlevent.openURL(M.browserScheme .. "://" .. link:gsub("^https?://", ""))
    end, title, message)

    notification:send()
end

-- Send a normal notification
local function notifyNormal(event, minutesBefore)
    local title = string.format("Event in %d min: %s", minutesBefore, event.title)
    local message = "Starts at " .. os.date("%H:%M", event:startDate():time())
    hs.notify.new(nil, title, message):send()
end

-- Check upcoming events and send notifications
local function checkEvents()
    local now = hs.timer.secondsSinceEpoch()
    local calendars = hs.calendar.calendars()

    for _, cal in ipairs(calendars) do
        if hs.fnutils.contains(M.calendarNames, cal:title()) then
            -- Look ahead to the max offset
            local maxOffset = math.max(table.unpack(M.alertOffsets))
            local events = cal:eventsInRange(os.date("*t", now), os.date("*t", now + maxOffset + 10))

            for _, ev in ipairs(events) do
                local evID = ev:id()
                if not M._alertedEvents[evID] then
                    M._alertedEvents[evID] = {}
                end

                local link = findMeetLink(ev)

                for _, offset in ipairs(M.alertOffsets) do
                    local alertTime = ev:startDate():time() - offset
                    if now >= alertTime and not M._alertedEvents[evID][offset] then
                        M._alertedEvents[evID][offset] = true
                        if link then
                            notifyWithLink(ev, link, math.floor(offset/60))
                        else
                            notifyNormal(ev, math.floor(offset/60))
                        end
                    end
                end
            end
        end
    end
end

-- === Start/Stop API ===
function M.start()
    if not M._timer then
        M._timer = hs.timer.doEvery(M.checkInterval, checkEvents)
        hs.alert.show("📅 Multi-time Meeting Alert started")
    end
end

function M.stop()
    if M._timer then
        M._timer:stop()
        M._timer = nil
        hs.alert.show("🛑 Multi-time Meeting Alert stopped")
    end
end

return M
