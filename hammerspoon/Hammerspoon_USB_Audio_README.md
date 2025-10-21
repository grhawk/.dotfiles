# 🎵 Hammerspoon USB Audio Helper

This module allows you to switch macOS audio input and output when a USB device is attached. It integrates with your `usb_events.lua` setup for automatic audio switching.

---

## 📦 Files

- `usb_audio.lua` — helper module with functions to set audio devices and generate attach callbacks.

---

## Usage

### 1. List available audio devices

Before using, find the exact name of your audio devices (as macOS recognizes them) using the Hammerspoon console:

```lua
-- List all output devices
for i, dev in ipairs(hs.audiodevice.allOutputDevices()) do
    print(i, dev:name())
end

-- List all input devices
for i, dev in ipairs(hs.audiodevice.allInputDevices()) do
    print(i, dev:name())
end
```

Example output:

```
1   MacBook Pro Speakers
2   Scarlett 2i2
3   BlackHole 2ch
```

Use the **exact name** for switching in your callback.

---

### 2. Set audio device manually

```lua
local audio = require("usb_audio")
audio.setAudioDevice("Scarlett 2i2")
```

This sets both **input and output** to the specified device. If the device is not found, a macOS alert will show.

---

### 3. Use as a callback with `usb_events.lua`

```lua
local usb = require("usb_events")
local audio = require("usb_audio")

-- Switch audio when Scarlett USB interface is attached
usb.onAttach({ productName = "Scarlett" }, audio.audioAttachCallback("Scarlett 2i2"))
usb.start()
```

- `productName` should match part of your USB device’s name (from the USB event).
- Only the devices you specify will trigger a switch.

---

### 🔧 API Reference

| Function | Description |
|----------|-------------|
| `setAudioDevice(deviceName)` | Switches macOS input and output to `deviceName` |
| `audioAttachCallback(deviceName)` | Returns a callback function suitable for `usb.onAttach()` |

---

### ✅ Tips

- Always check the device name exactly as macOS recognizes it (Hammerspoon console or Audio MIDI Setup).  
- This approach is safe: only switches audio when the USB device is attached.  
- You can combine multiple callbacks for different devices.

---

### License

MIT — free to use and modify.
