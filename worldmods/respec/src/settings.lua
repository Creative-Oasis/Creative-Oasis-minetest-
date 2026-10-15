
respec.settings = {}
local default = false

local debugOverrides = {}
function respec.settings.debug(playerName)
  if not playerName then playerName = "singleplayer" end
  local val = debugOverrides[playerName] == true
  if default then return not val else return val end
end

function respec.settings.set_debug_for(playerName, debugTF)
  if default then debugTF = not debugTF end
  if debugTF then debugOverrides[playerName] = true
  else debugOverrides[playerName] = nil end
end
