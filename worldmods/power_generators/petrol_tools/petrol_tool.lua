
-- register tool powered by combustion engine

local S = power_generators.translator

local players = {}

local next_line_offset = 8
if minetest.get_modpath("hades_core") then
  next_line_offset = 10
end

local function tool_refuel(self, itemstack, placer, new_name)
  local player_name = placer:get_player_name()
  local inv = placer:get_inventory()
  local index = placer:get_wield_index()+next_line_offset
  local tankstack = inv:get_stack("main", index)
  if (tankstack:get_count()<=0) then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("No fuel under in inventory/"))
    end
    return nil
  end
  local tank_def = tankstack:get_definition()
  if (not tank_def) or (not tank_def._fuel_amount) then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("No fuel under in inventory."))
    end
    return nil
  end
  local meta = itemstack:get_meta()
  local fuel = meta:get_int(self.meta_energy)
  local fuel_capacity = self.max_stored_energy - fuel
  local fuel_amount = tank_def._fuel_amount*10000
  if (fuel_amount>fuel_capacity) then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("Unused fuel tank capacity is too small."))
    end
    return nil
  end
  meta:set_int(self.meta_energy, fuel+fuel_amount)
  self:update_wear(itemstack, meta)
  tankstack:take_item(1)
  local emptystack = ItemStack(tank_def._fuel_empty or "")
  if tankstack:get_count()==0 then
    inv:set_stack("main", index, emptystack)
  else
    emptystack = inv:add_item("main", emptystack)
    if emptystack:get_count()>0 then
      minetest.add_item(placer:get_pos(), emptystack)
    end
  end
  return itemstack
end

local function tool_poweron(self, itemstack, placer, new_name)
  local meta = itemstack:get_meta()
  if (meta:get_int(self.meta_energy)<=0) then
    local player_name = placer:get_player_name()
    if player_name~="" then
      minetest.chat_send_player(player_name, S("Fuel tank is empty!"))
    end
    return itemstack
  end
  local player_name = placer:get_player_name()
  if (player_name~="") and (players[player_name]) then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("Another power tool is running already!"))
    end
    return itemstack
  end
  if self.delay_poweron then
    self:set_delay(itemstack, meta, self.delay_poweron)
  end
  appliances.swap_stack(itemstack, new_name)
  if self.sounds and self.sounds.poweron then
    local sound_param = table.copy(self.sounds.poweron.sound_param)
    sound_param.object = placer
    sound_param.loop = false
    minetest.sound_play(self.sounds.poweron.sound, sound_param)
  end
  if player_name~="" then
    if self.sounds and self.sounds.running then
      if self.sounds.running.sound_param.loop then
        local sound_param = table.copy(self.sounds.running.sound_param)
        sound_param.object = placer
        minetest.after(sound_param.delay, function(sound, sound_param, player_name)
            if players[player_name] then
              players[player_name].sound = minetest.sound_play(sound, sound_param)
            end
          end, self.sounds.running.sound, sound_param, player_name)
      end
    end
    players[player_name] = {
        formspec = placer:get_inventory_formspec(),
      }
    placer:set_inventory_formspec("")
  end
  return itemstack
end
local function tool_poweroff(self, itemstack, placer, new_name)
  appliances.swap_stack(itemstack, new_name)
  if self.sounds and self.sounds.poweroff then
    local sound_param = table.copy(self.sounds.poweroff.sound_param)
    sound_param.object = placer
    sound_param.loop = false
    minetest.sound_play(self.sounds.poweroff.sound, sound_param)
  end
  local player_name = placer:get_player_name()
  if player_name~="" then
    if players[player_name] then
      placer:set_inventory_formspec(players[player_name].formspec)
      if players[player_name].sound then
        minetest.sound_stop(players[player_name].sound)
      end
    end
    players[player_name] = nil
  end
  return itemstack
end

local function tool_break(self, itemstack, user)
  appliances.swap_stack(itemstack, self.tool_name_break)
  if self.sounds and self.sounds.onbreak then
    local sound_param = table.copy(self.sounds.onbreak.sound_param)
    sound_param.object = placer
    sound_param.loop = false
    minetest.sound_play(self.sounds.onbreak.sound, sound_param)
  end
  local player_name = user:get_player_name()
  if player_name~="" then
    if players[player_name] then
      user:set_inventory_formspec(players[player_name].formspec)
      if players[player_name].sound then
        minetest.sound_stop(players[player_name].sound)
      end
    end
    players[player_name] = nil
  end
  self:tool_drop_on_break(itemstack, user)
  return itemstack
end

local function tool_drop_on_break(self, itemstack, user)
  if self.drops_on_break then
    local dir = user:get_look_dir()
    dir.y = 0.5
    local pos = vector.add(user:get_pos(), dir)
    for _,drop_data in pairs(self.drops_on_break) do
      local item = minetest.add_item(pos, drop_data.item)
      if item then
        dir.y = drop_data.y or 0
        local rads = (appliances.random:next()/2147483648)*(drop_data.rads or math.pi/2)
        local item_dir = vector.rotate_around_axis(dir, vector.new(0,1,0), rads)
        item:set_velocity(vector.multiply(dir, drop_data.speed or 1))
      end
    end
  end
end

local function power_tool_step(self, itemstack, user)
  local meta = itemstack:get_meta()
  if (not self:use_energy(itemstack, meta, self.energy_per_step)) then
    tool_poweroff(self, itemstack, user, self.tool_name_off)
  else
    if self.sounds and self.sounds.running then
      if not self.sounds.running.sound_param.loop then
        local sound_param = table.copy(self.sounds.running.sound_param)
        sound_param.object = user
        minetest.sound_play(self.sounds.running.sound, sound_param, true)
      end
    end
  end
  return itemstack
end

function power_generators.register_power_tool(tool_name, tool_def, off_def, on_def)
  tool_def.tool_name = tool_name.."_on"
  tool_def.no_energy_msg = S("No fuel! Please, refuel!")
  tool_def.energy_per_step = tool_def.energy_per_step or 10
  
  local tool_name_off = tool_name.."_off"
  tool_def.tool_name_off = tool_name_off
  
  local power_tool = appliances.tool:new(tool_def)
  
  power_tool:battery_data_register(
    {
      ["power_generators_combustion_power_battery"] = {
        },
    })
  
  power_tool.tool_refuel = power_tool.tool_refuel or tool_refuel
  power_tool.tool_poweron = power_tool.tool_poweron or tool_poweron
  power_tool.tool_poweroff = power_tool.tool_poweroff or tool_poweroff
  power_tool.tool_break = power_tool.tool_break or tool_break
  power_tool.tool_drop_on_break = power_tool.tool_drop_on_break or tool_drop_on_break
  
  function power_tool:cb_on_place(itemstack, placer, pointed_thing)
      self:tool_poweroff(itemstack, placer, tool_name_off)
      return itemstack
    end
  function power_tool:cb_on_secondary_use(itemstack, placer, pointed_thing)
      self:tool_poweroff(itemstack, placer, tool_name_off)
      return itemstack
    end
  function power_tool:cb_on_drop(itemstack, placer, pointed_thing)
      self:tool_poweroff(itemstack, placer, tool_name_off)
      return minetest.item_drop(itemstack, placer, pointed_thing)
    end
  function power_tool:cb_on_break(itemstack, _meta, placer, _pointed_thing)
      self:tool_break(itemstack, placer)
      return itemstack
    end
  
  power_tool.cb_on_power_step = power_tool.cb_on_power_step or power_tool_step
  
  on_def.on_power_step = function(itemstack, user)
      return power_tool:cb_on_power_step(itemstack, user)
    end
  
  on_def.groups = on_def.groups or {}
  on_def.groups.not_in_creative_inventory = 1
  on_def.groups.power_tool_running = 1
  on_def._power_tool = power_tool
  
  power_tool:register_tool(on_def)
  
  off_def.on_use = function(itemstack, placer, pointed_thing)
      power_tool.tool_refuel(itemstack:get_definition(), itemstack, placer)
      return itemstack
    end
  off_def.on_place = function(itemstack, placer, pointed_thing)
      power_tool.tool_poweron(itemstack:get_definition(), itemstack, placer, power_tool.tool_name)
      return itemstack
    end
  off_def.on_secondary_use = function(itemstack, placer, pointed_thing)
      power_tool.tool_poweron(itemstack:get_definition(), itemstack, placer, power_tool.tool_name)
      return itemstack
    end
  off_def.update_wear = power_tool.update_wear
  off_def.get_energy = power_tool.get_energy
  off_def.meta_energy = power_tool.meta_energy
  off_def.max_stored_energy = power_tool.max_stored_energy
  off_def.set_delay = power_tool.set_delay
  off_def.meta_delay = power_tool.meta_delay
  
  off_def.description = off_def.description or power_tool.tool_description
  minetest.register_tool(tool_name_off, off_def)
  if power_tool.tool_help then
    appliances.add_item_help(tool_name_off, power_tool.tool_help)
  end
  
  return power_tool
end

local time_diff = 0

minetest.register_globalstep(function(dtime)
    time_diff = time_diff + dtime
    if time_diff>1 then
      local connected_players = minetest.get_connected_players()
      for _,player in pairs(connected_players) do
        local player_name = player:get_player_name()
        if players[player_name] then
          local inv = player:get_inventory()
          for index=1,next_line_offset do
            local itemstack = inv:get_stack("main", index)
            if itemstack:get_count()==1 then
              -- only count 1 is allowed for tools
              local def = itemstack:get_definition()
              if def.groups and def.groups.power_tool_running then
                itemstack = def.on_power_step(itemstack, player)
                inv:set_stack("main", index, itemstack)
                local formspec = player:get_inventory_formspec()
                if formspec~="" then
                  -- fix inventory disable
                  if players[player_name] then
                    players[player_name].formspec = formspec
                    player:set_inventory_formspec("")
                  end
                end
                -- only one running power tool in inventory
                break
              end
            end
          end
        end
      end
      time_diff = 0
    end
  end)

minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    for index=1,next_line_offset do
      local itemstack = inv:get_stack("main", index)
      if itemstack:get_count()==1 then
        -- only count 1 is allowed for tools
        local def = itemstack:get_definition()
        if def.groups and def.groups.power_tool_running then
          local power_tool = def._power_tool
          local sound
          if power_tool.sounds and power_tool.sounds.running then
            if power_tool.sounds.running.sound_param.loop then
              local sound_param = table.copy(power_tool.sounds.running.sound_param)
              sound_param.object = player
              sound = minetest.sound_play(power_tool.sounds.running.sound, sound_param)
            end
          end
          players[player:get_player_name()] = {
              formspec = player:get_inventory_formspec(),
              sound = sound,
            }
          player:set_inventory_formspec("")
          return
        end
      end
    end
  end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    if players[player_name] then
      if players[player_name].sound then
        minetest.sound_stop(players[player_name].sound)
      end
      players[player_name] = nil
    end
  end)

minetest.register_allow_player_inventory_action(function(player, action, inv, inv_info)
    local player_name = player:get_player_name()
    if players[players] then
      if action=="put" then
        return inv_info.stack:get_count()
      end
      return 0
    else
      if action=="move" then
        return inv_info.count
      else
        return inv_info.stack:get_count()
      end
    end
  end)

