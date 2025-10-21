# ⚙️ Hammerspoon USB Automations

This repo contains two small modules that work together to automate macOS behavior using **Hammerspoon** and **Karabiner-Elements**:

- `usb_events.lua` — listens for USB devices being attached or removed and triggers user-defined callbacks.
- `karabiner_profiles.lua` — switches Karabiner profiles from Hammerspoon via the CLI.

---

## Overview

These modules let you automate things like:

> “When I plug my ErgoDox, switch Karabiner to the *ErgoDox* profile; when I unplug it, switch back to *Default*.”

They are modular, reusable, and easy to extend.

---

## usb_events.lua

### Description

A generic USB watcher for Hammerspoon. Register callbacks for device attach/detach using simple pattern matching (by `productName`, `vendorName`, `vendorID`, etc.).

### API

- `usb_events.onAttach(pattern, callback)` — run `callback(event)` when matching device is attached.
- `usb_events.onDetach(pattern, callback)` — run `callback(event)` when matching device is detached.
- `usb_events.start()` — start the watcher.
- `usb_events.stop()` — stop the watcher.

### Event object

When a device is attached/removed Hammerspoon provides an event table like:

    {
        eventType   = "added" or "removed",
        productName = "ErgoDox EZ",
        vendorName  = "ZSA Technology Labs",
        productID   = 12345,
        vendorID    = 67890,
        locationID  = 987654321,
    }

Your callback receives that `event` table.

### Pattern matching

A pattern is a Lua table whose keys are fields from the event (e.g. `productName`, `vendorName`, `vendorID`). Values are matched as substrings using `string.find`. All keys present in the pattern must match.

Supported keys: `productName`, `vendorName`, `vendorID`, `productID`, `locationID`.

### Example

    local usb = require("usb_events")

    usb.onAttach({ productName = "ErgoDox" }, function(event)
        hs.alert.show("ErgoDox connected!")
    end)

    usb.onDetach({ productName = "ErgoDox" }, function(event)
        hs.alert.show("ErgoDox disconnected!")
    end)

    usb.start()

---

## karabiner_profiles.lua

### Description

Helper to switch Karabiner-Elements profiles from Hammerspoon via the CLI binary `karabiner_cli`.

### API

- `karabiner.selectProfile(profileName)` — switch Karabiner to `profileName` (shows macOS notification and logs).

### Example

    local karabiner = require("karabiner_profiles")
    karabiner.selectProfile("ErgoDox")

---

## Example integration

    local log = require("mylogger")
    local usb = require("usb_events")
    local karabiner = require("karabiner_profiles")

    usb.log = log
    karabiner.log = log

    -- ErgoDox keyboard
    usb.onAttach({ productName = "ErgoDox" }, function(event)
        karabiner.selectProfile("ErgoDox")
    end)

    usb.onDetach({ productName = "ErgoDox" }, function(event)
        karabiner.selectProfile("Default")
    end)

    -- Audio interface
    usb.onAttach({ vendorName = "Focusrite" }, function(event)
        karabiner.selectProfile("Audio")
    end)

    usb.onDetach({ vendorName = "Focusrite" }, function(event)
        karabiner.selectProfile("Default")
    end)

    usb.start()

---

## Notes

- Default path to `karabiner_cli` used by the helper:
  
      /Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli

  Verify with:

      mdfind karabiner_cli

- Both modules accept a `log` object with `.debug(msg)` for easy integration with your logger.
- You can register multiple callbacks for the same pattern — all will run.
- Hot-reload safe: restarting Hammerspoon restarts the watcher.

---

## Optional: Debug handler

If you want to inspect raw events while tuning patterns, add an any-event debug hook:

    usb.onAny(function(event)
        print(hs.inspect(event))
    end)

(If you want this helper added to the module I can include `onAny` in the code.)

---

## Files summary

- `usb_events.lua` — USB watcher + callback registration
- `karabiner_profiles.lua` — Karabiner CLI wrapper
- `init.lua` — example glue code

---

## License

MIT — feel free to copy, change, and integrate.
