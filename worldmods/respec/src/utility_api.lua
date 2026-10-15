
----------------------------------------------------------------
-- Inventory Location utility methods
----------------------------------------------------------------
respec.inv = {}

--[[
 If both param1 and param2 are present:
 `param1` is taken to mean the Player's name,
 `param2` to be the list's name

 If only `param1` is present: `param1` is taken as the List's name, and the player
 is assumed to be "current_player"
]]
function respec.inv.player(param1, param2)
  local playerName = "current_player"
  local listName = param1
  if type(param2) == "string" then
    playerName = param1 ; listName = param2
  end
  return { playerName, listName }
end

--[[
 If both param1 and param2 are present, 
 `param1` must be a vector in the {x=x, y=y, z=z} format,
 `param2` must be a string of the list's name

 If only `param1` is present, `param1` is taken as the list's name,
 and the node's position will be autofilled.

 The single-paramter version can only be used when using show_on_node_rightclick()
]]

function respec.inv.node(param1, param2)
  local nodePos = -1
  local listName = param1
  if param2 then
    nodePos = "nodemeta:"..param1.x..","..param1.y..","..param1.z
    listName = param2
  end
  return { nodePos, listName }
end

function respec.inv.detached(invName, listName)
  local inv = "detached:"..invName
  return { inv, listName }
end
