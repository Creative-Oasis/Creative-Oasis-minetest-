
local S = inspect_tool.translator

local inv_row_size = 8
if minetest.get_modpath("hades_core") then
  inv_row_size = 10
end

function inspect_tool.inspect_tool_use(itemstack, user, pointed_thing)
  if not user then
    return
  end
  local player_name = user:get_player_name()
  if player_name=="" then
    return
  end
  local def = itemstack:get_definition()
  if def._inspect_interval then
    local meta = itemstack:get_meta()
    local last_inspect = meta:get_int("last_inspect")
    local gametime = minetest.get_gametime()
    if (gametime-last_inspect)<def._inspect_interval then
      if def._inspect_wait_msg then
        minetest.chat_send_player(player_name, def._inspect_wait_msg)
      end
      return
    end
    meta:set_int("last_inspect", gametime)
  end
  
  def = nil
  local data = nil
  if pointed_thing.type == "node" then
    local node = minetest.get_node(pointed_thing.under)
    def = minetest.registered_nodes[node.name]
    data = pointed_thing.under
  elseif pointed_thing.type == "object" then
    def = pointed_thing.ref:get_luaentity()
    data = def
  else
    -- below in inventory
    local index = user:get_wield_index() + inv_row_size
    local inv = user:get_inventory()
    local itemstack = inv:get_stack("main", index)
    def = itemstack:get_definition()
    data = itemstack
  end
  if def then
    local msg = nil
    if def._inspect_msg_func then
      local level = minetest.get_item_group(itemstack:get_name(), "inspect_level")
      msg = def._inspect_msg_func(data, level)
    end
    if not msg and def._inspect_msg then
      msg = def._inspect_msg
    end
    if not msg and def.description then
      msg = def.description
    end
    if msg then
      minetest.chat_send_player(player_name, msg)
    end
  end
  return itemstack
end

function inspect_tool.item_namer_use(itemstack, user, pointed_thing)
  if not user then
    return
  end
  local player_name = user:get_player_name()
  if player_name=="" then
    return
  end
  local index = user:get_wield_index() + inv_row_size
  local inv = user:get_inventory()
  local itemstack = inv:get_stack("main", index)
  minetest.chat_send_player(player_name, S("Name of iten below used hand namer tool is \"@1\".", itemstack:get_name()))
end

