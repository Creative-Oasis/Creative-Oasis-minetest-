
local S = inspect_tool.translator

minetest.register_tool("inspect_tool:hand_glass", {
    description = S("Inspect Hand Glass"),
    inventory_image = "inspect_tool_hand_glass.png",
    groups = {inspect_level = 1},
    
    on_use = inspect_tool.inspect_tool_use,
  })

minetest.register_tool("inspect_tool:hand_computer", {
    description = S("Inspect Hand Computer"),
    inventory_image = "inspect_tool_hand_computer.png",
    groups = {inspect_level = 2},
    
    _inspect_interval = 5,
    _inspect_wait_msg = S("Recharging..."),
    
    on_use = inspect_tool.inspect_tool_use,
  })

minetest.register_tool("inspect_tool:hand_laser", {
    description = S("Inspect Hand Laser"),
    inventory_image = "inspect_tool_hand_laser.png",
    groups = {inspect_level = 3},
    
    _inspect_interval = 15,
    _inspect_wait_msg = S("Recharging..."),
    
    on_use = inspect_tool.inspect_tool_use,
  })

minetest.register_tool("inspect_tool:hand_item_namer", {
    description = S("Hand Item Namer"),
    _tt_help = "Use to get name of item below in inventory.",
    inventory_image = "inspect_tool_hand_item_namer.png",
    
    on_use = inspect_tool.item_namer_use,
  })

