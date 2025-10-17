------------------------------------------------------------
-- 📄 logger.lua — Console-style logger for Hammerspoon
------------------------------------------------------------
local M = {}

-- Format: 2025-10-17 08:57:22: -- [LEVEL] message
local function timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function makeLogger(level, color)
  return function(msg, ...)
    local formatted = string.format(msg, ...)
    local line = string.format("%s: -- [%s] %s\n", timestamp(), level, formatted)
    local styled = hs.styledtext.new(
      line,
      {
        font = { name = "Menlo", size = 12 },
        color = hs.drawing.color.asRGB(color)
      }
    )
    hs.console.printStyledtext(styled)
  end
end

M.info  = makeLogger("INFO",  {hex = "#00FF00"})
M.warn  = makeLogger("WARN",  {hex = "#FFA500"})
M.error = makeLogger("ERROR", {hex = "#FF3333"})
M.debug = makeLogger("DEBUG", {hex = "#00BFFF"})

-- Optional: enable/disable debug
M.enableDebug = true
local debugOrig = M.debug
M.debug = function(...)
  if M.enableDebug then
    debugOrig(...)
  end
end

return M
