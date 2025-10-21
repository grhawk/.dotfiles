-- karabiner_profiles.lua
-- Helper to switch Karabiner profiles via CLI.

local M = {}
M.log = _G.log or { debug = function(_) end }

local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

function M.selectProfile(profileName)
  local cmd = string.format("%q --select-profile %q", KARABINER_CLI, profileName)
  M.log.debug("[karabiner_profiles] selecting profile: " .. profileName)
  local ok, out, _, rc = hs.execute(cmd)
  if ok then
    hs.notify.new({ title = "Karabiner", informativeText = "Profile switched to: " .. profileName }):send()
    M.log.debug("[karabiner_profiles] switched to " .. profileName)
  else
    hs.alert.show("❌ Failed to switch Karabiner profile (rc=" .. tostring(rc) .. ")")
    M.log.debug("[karabiner_profiles] error switching profile (rc=" .. tostring(rc) .. ")")
  end
end

return M
