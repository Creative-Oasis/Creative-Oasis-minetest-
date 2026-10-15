
local S = power_generators.translator
  
-- node box {x=0, y=0, z=0}
local node_box = {
  type = "fixed",
  fixed = {
    {-0.5,-0.5,-0.5,-0.375,0.1875,-0.375},
    {0.375,-0.5,-0.5,0.5,0.1875,-0.375},
    {-0.375,-0.4375,-0.5,0.375,-0.3125,-0.375},
    {-0.375,0.0625,-0.5,0.375,0.1875,-0.3125},
    {-0.375,-0.3125,-0.4375,0.375,0.0625,0.4375},
    {-0.4375,0.1875,-0.4375,0.4375,0.25,0.4375},
    {-0.5,-0.4375,-0.375,-0.375,-0.3125,0.5},
    {0.375,-0.4375,-0.375,0.5,-0.3125,0.5},
    {-0.375,-0.375,-0.375,0.375,-0.3125,0.5},
    {-0.4375,-0.3125,-0.375,-0.375,0.1875,0.5},
    {0.375,-0.3125,-0.375,0.4375,0.1875,0.5},
    {-0.5,0.0625,-0.375,-0.4375,0.1875,0.5},
    {0.4375,0.0625,-0.375,0.5,0.1875,0.5},
    {-0.375,0.25,-0.375,0.375,0.3125,0.375},
    {-0.3125,-0.4375,-0.3125,0.3125,-0.375,0.3125},
    {-0.375,0.0625,-0.3125,0.375,0.125,0.5},
    {-0.375,0.125,-0.3125,-0.0625,0.1875,0.5},
    {0.0,0.125,-0.3125,0.375,0.1875,0.5},
    {-0.3125,0.3125,-0.3125,0.3125,0.375,0.3125},
    {-0.125,0.375,-0.3125,0.125,0.5,-0.0625},
    {-0.0625,0.125,-0.25,0.0,0.1875,0.5},
    {-0.0625,-0.5,0.125,0.0625,-0.4375,0.1875},
    {-0.125,-0.5,0.1875,-0.0625,-0.4375,0.3125},
    {0.0625,-0.5,0.1875,0.125,-0.4375,0.3125},
    {-0.0625,-0.5,0.3125,0.0625,-0.375,0.375},
    {-0.5,-0.5,0.375,-0.375,-0.4375,0.5},
    {0.375,-0.5,0.375,0.5,-0.4375,0.5},
    {-0.375,-0.4375,0.375,0.375,-0.375,0.5},
    {-0.5,-0.3125,0.375,-0.4375,0.0625,0.5},
    {0.4375,-0.3125,0.375,0.5,0.0625,0.5},
  },
}

--local function update_info(pos, node, meta)
local function update_info(_, node, meta)
  local def = minetest.registered_nodes[node.name]
  local fuel = meta:get_int("fuel")
  local fuel_percent = math.floor((fuel/def._fuel_capacity)*100)
  
  local fill = "image[1,1;1,5;appliances_consumption_progress_bar.png]";
  if fuel_percent then
    fill = "image[1,1;1,5;appliances_consumption_progress_bar.png^[lowpart:" ..
            (fuel_percent) ..
            ":appliances_consumption_progress_bar_full.png]";
  end
  local formspec =  "formspec_version[3]" .. "size[2.75,8.5]" ..
                    "background[-1.25,-1.25;5,10;appliances_appliance_formspec.png]" ..
                    fill;
  local infotext = "Fill "..fuel_percent.."%"
  meta:set_string("infotext", infotext)
  meta:set_string("formspec", formspec)
end
    
local add_fuel = function(meta, puncher, fuel_capacity)
  -- add fuel if posible
  local wield_item = puncher:get_wielded_item()
  local idef = wield_item:get_definition()
  if idef._fuel_amount then
    local fuel = meta:get_float("fuel")
    
    if (fuel+idef._fuel_amount)<=fuel_capacity then
      local energy = meta:get_float("energy")
      energy = energy*fuel + idef._fuel_energy*idef._fuel_amount
      fuel = fuel+idef._fuel_amount
      energy = energy/fuel
      meta:set_float("fuel", fuel)
      meta:set_float("energy", energy)
      wield_item:take_item()
      puncher:set_wielded_item(wield_item)
      if idef._fuel_empty then
        local inv = puncher:get_inventory()
        inv:add_item("main", ItemStack(idef._fuel_empty))
      end
    end
  end
end

local node_sounds = nil
if minetest.get_modpath("default") then
  node_sounds = default.node_sound_metal_defaults()
end
if minetest.get_modpath("hades_sounds") then
  node_sounds = hades_sounds.node_sound_metal_defaults()
end
if minetest.get_modpath("sounds") then
  node_sounds = sounds.node_metal()
end

minetest.register_node("power_generators:fuel_tank", {
    description = S("Fuel Tank"),
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "mesh",
    mesh = "power_generators_ce_fuel_tank.obj",
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_ce_pipes.png",
        "power_generators_fuel_tank_cover.png",
    },
    collision_box = node_box,
    selection_box = node_box,
    sounds = node_sounds,
    groups = {cracky = 2},
    
    _fuel_capacity = 256,
    --_take_fuel = function(pos, node, meta, amount)
    _take_fuel = function(pos, _, meta, amount)
      local fuel = meta:get_float("fuel")
      if amount > fuel then
        amount = fuel
      end
      fuel = fuel-amount
      meta:set_float("fuel", fuel)
      update_info(pos, {name="power_generators:fuel_tank"}, meta)
      return amount
    end,
    
    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      update_info(pos, {name="power_generators:fuel_tank"}, meta)
    end,
    --on_punch = function(pos, node, puncher)
    on_punch = function(pos, _, puncher)
      local meta = minetest.get_meta(pos)
      add_fuel(meta, puncher, 256)
      update_info(pos, {name="power_generators:fuel_tank"}, meta)
    end,
  })

appliances.add_item_help("power_generators:fuel_tank", S("Fill it with liquid fuel by punching."))

