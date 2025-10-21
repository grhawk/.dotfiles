# 🪄 windowcycle.lua

A lightweight, snappy **window tiling and cycling module for Hammerspoon** — inspired by tiling window managers, but fully customizable.

---

## ✨ Features

- 🔄 **Cycle window positions** horizontally (left/right) and vertically (top/bottom):
    - Left / Right cycles through **50%**, **75%**, **25%** widths on each side
    - Top / Bottom cycles through **50%**, **75%**, **25%** heights
    - Cycles are **symmetric**:
      ```
      Right half → Left key → Right 75% → Left half → Left quarter → Left half …
      Left half  → Right key → Left 75%  → Right half → Right quarter → Right half …
      ```

- 🧠 **Debounced frame application**:
    - When you press keys quickly, the module only applies **one final move** after you stop.
    - This avoids expensive intermediate resizes (especially in Safari).

- 📝 **Undo stack** (per window):
    - Each movement stores up to **5 previous frames**.
    - `undo()` restores the previous frame, multiple times if repeated.

- 🖼 **Center** function:
    - Centers the window at 80 % of the screen size.

- 🖥 **Maximize / Restore toggle**:
    - First press = maximize, second press = restore previous frame.

- 🪵 Uses `log.debug` for internal debug logging (you provide the logger).

---

## 📦 Installation

1. Place `windowcycle.lua` in your Hammerspoon config directory:

   ```bash
   ~/.hammerspoon/windowcycle.lua
