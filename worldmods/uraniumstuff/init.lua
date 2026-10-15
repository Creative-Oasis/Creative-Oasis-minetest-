local ingot_name = "technic:uranium0_ingot"
local stick_name = "default:stick"
local stone_name = "default:stone"
local stone_image = "default_stone.png"
local stone_sounds = nil

local MODNAME = minetest.get_current_modname()
local MODPATH = minetest.get_modpath(MODNAME)
local S = minetest.get_translator(MODNAME)

function get_setting(key, default)
	local value = minetest.settings:get("uraniumstuff." .. key)
	local num_value = tonumber(value)
	if value and not num_value then
		print("Invalid value for setting %s: %q. Using default %q.", key, value, default)
	end
	return num_value or default
end

local uses = get_setting("max_tool_uses", 400)
local full_punch_interval = get_setting("full_punch_interval", 0.3)
local damage_multiplier = get_setting("damage_multiplier", 1.5)
local radiation_damage = get_setting("radiation_damage", 5)
local allow_multitool = minetest.settings:get_bool("uraniumstuff.allow_multitool", true)
local allow_irradiating = minetest.settings:get_bool("uraniumstuff.allow_irradiating_mobs", true)
local allow_armor_damage = minetest.settings:get_bool("uraniumstuff.allow_armor_radiation", true)
local allow_tool_damage = minetest.settings:get_bool("uraniumstuff.allow_tool_radiation", true)
local leave_residue = minetest.settings:get_bool("uraniumstuff.leave_residue", true)

function round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

dofile(MODPATH .. "/goo.lua")

-- MineClone compatibility

if minetest.get_modpath("mcl_core") then
    stick_name = "mcl_core:stick"
    stone_name = "mcl_deepslate:deepslate"
    stone_image = "mcl_deepslate.png"
end

if minetest.get_modpath("mcl_sounds") then
    stone_sounds = mcl_sounds.node_sound_stone_defaults()
else
    stone_sounds = default.node_sound_stone_defaults()
end


-- Ore generation

if not minetest.get_modpath("technic") then
    ingot_name = "uraniumstuff:uranium_ingot"
    
    minetest.register_node("uraniumstuff:mineral_uranium", {
	    description = S("Uranium Ore"),
	    tiles = { stone_image .. "^uraniumstuff_mineral_uranium.png" },
	    is_ground_content = true,
	    groups = {cracky=3, radioactive=1},
	    sounds = stone_sounds,
	    drop = "uraniumstuff:uranium_lump",
        light_source = 5,
    })

    local ORE_MIN = -80
    local ORE_MAX = -300
    local ORE_SCARCITY = 8*8*8*8*8
    if minetest.get_modpath("mcl_core") then
        local ORE_MIN = -10
        local ORE_MAX = -64
        local ORE_SCARCITY = 8*8*8*8
    end

    minetest.register_ore({
	    ore_type = "scatter",
	    ore = "uraniumstuff:mineral_uranium",
	    wherein = stone_name,
	    clust_scarcity = ORE_SCARCITY,
	    clust_num_ores = 2,
	    clust_size = 3,
	    y_min = ORE_MIN,
	    y_max = ORE_MAX,
	    --noise_params = uranium_params,
	    --noise_threshold = uranium_threshold,
    })

    minetest.register_node("uraniumstuff:uranium_block", {
	    description = S("Uranium Block"),
	    tiles = { "uraniumstuff_uranium_block.png" },
	    is_ground_content = true,
	    groups = {cracky=1, level=2, radioactive=1},
	    sounds = stone_sounds,
        light_source = 5,
    })

    minetest.register_craftitem("uraniumstuff:uranium_lump", {
	    description = S("Uranium Lump"),
	    inventory_image = "uraniumstuff_uranium_lump.png",
        light_source = 5,
    })

    minetest.register_craftitem("uraniumstuff:uranium_ingot", {
	    description = S("Uranium Ingot"),
	    inventory_image = "uraniumstuff_uranium_ingot.png",
	    groups = {uranium_ingot=1},
        light_source = 5,
    })

    minetest.register_craft({
		output = "uraniumstuff:uranium_block",
		recipe = {
			{ingot_name, ingot_name, ingot_name},
			{ingot_name, ingot_name, ingot_name},
			{ingot_name, ingot_name, ingot_name},
		}
	})

	minetest.register_craft({
		output = ingot_name.." 9",
		recipe = {
			{"uraniumstuff:uranium_block"}
		}
	})

    minetest.register_craft({
	    type = 'cooking',
	    recipe = "uraniumstuff:uranium_lump",
	    output = "uraniumstuff:uranium_ingot",
    })
end


-- Tool Registration

if minetest.get_modpath("toolranks") then
    uses = 200
end


-- Pickaxe

minetest.register_tool("uraniumstuff:uranium_pick", {
	description = S("Uranium Pickaxe"),
	inventory_image = "uraniumstuff_uranium_pick.png",
    light_source = 5,
	tool_capabilities = {
		full_punch_interval = full_punch_interval,
		max_drop_level = 3,
		groupcaps = {
			cracky = {times = {[1] = 2.25, [2] = 0.55, [3] = 0.35}, uses = uses, maxlevel = 3},
		},
		damage_groups = {fleshy = 6*damage_multiplier, radioactive = radiation_damage},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_craft({
    output = "uraniumstuff:uranium_pick",
    recipe = {
        {ingot_name, ingot_name, ingot_name},
        {"", stick_name, ""},
        {"", stick_name, ""}
    }
})


-- Shovel

minetest.register_tool("uraniumstuff:uranium_shovel", {
    description = S("Uranium Shovel"),
    inventory_image = "uraniumstuff_uranium_shovel.png",
    light_source = 5,
    wield_image = "uraniumstuff_uranium_shovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = full_punch_interval,
		max_drop_level = 3,
		groupcaps = {
			crumbly = {times = {[1] = 0.70, [2] = 0.35, [3] = 0.20}, uses = uses, maxlevel = 3},
		},
		damage_groups = {fleshy = 5*damage_multiplier, radioactive = radiation_damage},
        radioactive = 1,
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

minetest.register_craft({
    output = "uraniumstuff:uranium_shovel",
    recipe = {
        {ingot_name},
        {stick_name},
        {stick_name}
    }
})


-- Axe

minetest.register_tool("uraniumstuff:uranium_axe", {
    description = S("Uranium Axe"),
    inventory_image = "uraniumstuff_uranium_axe.png",
    light_source = 5,
	tool_capabilities = {
		full_punch_interval = full_punch_interval,
		max_drop_level = 3,
		groupcaps = {
			choppy = {times = {[1] = 1.75, [2] = 0.45, [3] = 0.45}, uses = uses, maxlevel = 3},
			fleshy = {times = {[2] = 0.95, [3] = 0.30}, uses = uses, maxlevel = 2},
		},
		damage_groups = {fleshy = 8*damage_multiplier, radioactive = radiation_damage},
        radioactive = 1,
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_craft({
    output = "uraniumstuff:uranium_axe",
    recipe = {
        {ingot_name, ingot_name, ""},
        {ingot_name, stick_name, ""},
        {"", stick_name, ""}
    }
})


-- Sword

minetest.register_tool("uraniumstuff:uranium_sword", {
    description = S("Uranium Sword"),
    inventory_image = "uraniumstuff_uranium_sword.png",
    light_source = 5,
	tool_capabilities = {
		full_punch_interval = full_punch_interval,
		max_drop_level = 3,
		groupcaps = {
			fleshy = {times = {[2] = 0.65, [3] = 0.25}, uses = uses, maxlevel = 2},
			snappy = {times = {[1] = 1.70, [2] = 0.70, [3] = 0.25}, uses = uses, maxlevel = 3},
			choppy = {times = {[3] = 0.65}, uses = uses, maxlevel = 0},
		},
		damage_groups = {fleshy = 10*damage_multiplier, radioactive = radiation_damage},
        radioactive = 1,
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_craft({
    output = "uraniumstuff:uranium_sword",
    recipe = {
        {ingot_name},
        {ingot_name},
        {stick_name}
    }
})


-- Hoe

minetest.register_tool("uraniumstuff:uranium_hoe", {
    description = S("Uranium Hoe"),
    inventory_image = "uraniumstuff_uranium_hoe.png",
    light_source = 5,
	tool_capabilities = {
		full_punch_interval = full_punch_interval,
		max_drop_level = 3,
		max_uses = uses,
        damage_groups = {radioactive = radiation_damage},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {hoe = 1}
})

minetest.register_craft({
    output = "uraniumstuff:uranium_hoe",
    recipe = {
        {ingot_name, ingot_name, ""},
        {ingot_name, "", ""},
        {stick_name, "", ""}
    }
})



-- Multitool

--if allow_multitool then

   -- minetest.register_tool("uraniumstuff:uranium_multitool", {
      --  description = S("Uranium Multitool"),
      --  inventory_image = "uraniumstuff_uranium_multitool.png",
      --  light_source = 5,
      --  tool_capabilities = {
         --   full_punch_interval = full_punch_interval,
          --  max_drop_level = 3,
          --  groupcaps = {
             --   cracky = {times = {[1] = 2.25, [2] = 0.55, [3] = 0.35}, uses = uses, maxlevel = 3},
             --   crumbly = {times = {[1] = 0.70, [2] = 0.35, [3] = 0.20}, uses = uses, maxlevel = 3},
             --   choppy = {times = {[1] = 1.75, [2] = 0.45, [3] = 0.45}, uses = uses, maxlevel = 3},
              --  fleshy = {times = {[2] = 0.65, [3] = 0.25}, uses = uses, maxlevel = 2},
            --    snappy = {times = {[1] = 1.70, [2] = 0.70, [3] = 0.25}, uses = uses, maxlevel = 3},
          --  },
           -- damage_groups = {fleshy = 10*damage_multiplier, radioactive = radiation_damage},
        --},
        --sound = {breaks = "default_tool_breaks"},
      --  groups = {sword = 1, axe = 1, shovel = 1, pickaxe = 1},
       -- range = 8.0,
   -- })

   -- minetest.register_craft({
      --  output = "uraniumstuff:uranium_multitool",
       -- recipe = {
        --    {"", "uraniumstuff:uranium_shovel", ""},
           -- {"uraniumstuff:uranium_axe", "uraniumstuff:uranium_pick", "uraniumstuff:uranium_sword"},
       -- }
   -- })
    
--end

-- Gems

if allow_armor_damage or allow_tool_damage then

    minetest.register_craftitem("uraniumstuff:uranium_gem", {
        description = S("Uranium Gem"),
        inventory_image = "uraniumstuff_uranium_gem.png",
        light_source = 5,
    })

    minetest.register_craft({
        output = "uraniumstuff:uranium_gem",
        recipe = {
            {"", ingot_name, ""},
            {ingot_name, ingot_name, ingot_name},
            {"", ingot_name, ""},
        }
    })

    minetest.register_craftitem("uraniumstuff:uranium_protection_gem", {
        description = S("Uranium Protection Gem"),
        inventory_image = "uraniumstuff_uranium_protection_gem.png",
        light_source = 5,
    })

    local iron_ingot = "default:steel_ingot"
    local crystal_name = "default:mese_crystal"
    if minetest.get_modpath("mcl_core") then
        iron_ingot = "mcl_core:iron_ingot"
        crystal_name = "mcl_core:emerald"
    end

    minetest.register_craft({
        output = "uraniumstuff:uranium_protection_gem",
        recipe = {
            {iron_ingot, crystal_name, iron_ingot},
            {crystal_name, "uraniumstuff:uranium_gem", crystal_name},
            {iron_ingot, crystal_name, iron_ingot},
        }
    })

end


-- Toolranks Integration

if minetest.get_modpath("toolranks") then
	minetest.override_item("uraniumstuff:uranium_sword", {
		description = toolranks.create_description(S("Uranium Sword"), 0, 1),
		original_description = S("Uranium Sword"),
		after_use = toolranks.new_afteruse
	})

	minetest.override_item("uraniumstuff:uranium_pick", {
		description = toolranks.create_description(S("Uranium Pickaxe"), 0, 1),
		original_description = S("Uranium Pickaxe"),
		after_use = toolranks.new_afteruse
	})

	minetest.override_item("uraniumstuff:uranium_axe", {
		description = toolranks.create_description(S("Uranium Axe"), 0, 1),
		original_description = S("Uranium Axe"),
		after_use = toolranks.new_afteruse
	})

	minetest.override_item("uraniumstuff:uranium_shovel", {
		description = toolranks.create_description(S("Uranium Shovel"), 0, 1),
		original_description = S("Uranium Shovel"),
		after_use = toolranks.new_afteruse
	})
    
    if allow_multitool then
        minetest.override_item("uraniumstuff:uranium_multitool", {
            description = toolranks.create_description(S("Uranium Multitool"), 0, 1),
            original_description = S("Uranium Multitool"),
            after_use = toolranks.new_afteruse
        })
    end
end


-- Armor

if minetest.get_modpath("3d_armor") then
	armor.materials.uranium = ingot_name
	armor.config.material_uranium = true

	armor:register_armor("uraniumstuff:helmet_uranium", {
		description = S("Uranium Helmet"),
		inventory_image = "uraniumstuff_inv_uranium_helmet.png",
		light_source = 5,
		groups = {armor_head=1, armor_heal=12, armor_use=200, armor_fire=3},
		armor_groups = {fleshy=20, radiation=10},
		damage_groups = {cracky=2, snappy=1, level=3},
		wear = 0,
	})
	minetest.register_alias("uraniumstuff:uranium_helmet", "uraniumstuff:helmet_uranium")
	minetest.override_item("uraniumstuff:uranium_helmet", {light_source = 5})

	armor:register_armor("uraniumstuff:chestplate_uranium", {
		description = S("Uranium Chestplate"),
		inventory_image = "uraniumstuff_inv_uranium_chestplate.png",
		light_source = 5,
		groups = {armor_torso=1, armor_heal=12, armor_use=200, armor_fire=3},
		armor_groups = {fleshy=25, radiation=10},
		damage_groups = {cracky=2, snappy=1, level=3},
		wear = 0,
	})
	minetest.register_alias("uraniumstuff:uranium_chestplate", "uraniumstuff:chestplate_uranium")
	minetest.override_item("uraniumstuff:uranium_chestplate", {light_source = 5})

	armor:register_armor("uraniumstuff:leggings_uranium", {
		description = S("Uranium Leggings"),
		inventory_image = "uraniumstuff_inv_uranium_leggings.png",
		light_source = 5,
		groups = {armor_legs=1, armor_heal=12, armor_use=200, armor_fire=3},
		armor_groups = {fleshy=25, radiation=10},
		damage_groups = {cracky=2, snappy=1, level=3},
		wear = 0,
	})
	minetest.register_alias("uraniumstuff:uranium_leggings", "uraniumstuff:leggings_uranium")
	minetest.override_item("uraniumstuff:uranium_leggings", {light_source = 5})

	armor:register_armor("uraniumstuff:boots_uranium", {
		description = S("Uranium Boots"),
		inventory_image = "uraniumstuff_inv_uranium_boots.png",
		light_source = 5,
		groups = {armor_feet=1, armor_heal=12, armor_use=200, armor_fire=3, physics_jump=0.5, physics_speed = 1},
		armor_groups = {fleshy=20, radiation=10},
		damage_groups = {cracky=2, snappy=1, level=3},
		wear = 0,
	})
	minetest.register_alias("uraniumstuff:uranium_boots", "uraniumstuff:boots_uranium")
	minetest.override_item("uraniumstuff:uranium_boots", {light_source = 5})

	if minetest.get_modpath("shields") then
		armor:register_armor("uraniumstuff:shield_uranium", {
			description = S("Uranium Shield"),
			inventory_image = "uraniumstuff_inv_uranium_shield.png",
			light_source = 5, 
			groups = {armor_shield=1, armor_heal=12, armor_use=200, armor_fire=3},
			armor_groups = {fleshy=25, radiation=10},
			damage_groups = {cracky=2, snappy=1, level=3},
			wear = 0,
		})
	    minetest.register_alias("uraniumstuff:uranium_shield", "uraniumstuff:shield_uranium")
	end

end

if minetest.get_modpath("3d_armor") or minetest.get_modpath("mcl_armor") then
	minetest.register_craft({
		output = "uraniumstuff:uranium_helmet",
		recipe = {
			{ingot_name, ingot_name, ingot_name},
			{ingot_name, "", ingot_name},
			{"", "", ""},
		}
	})

	minetest.register_craft({
		output = "uraniumstuff:uranium_chestplate",
		recipe = {
			{ingot_name, "", ingot_name},
			{ingot_name, ingot_name, ingot_name},
			{ingot_name, ingot_name, ingot_name},
		}
	})

	minetest.register_craft({
		output = "uraniumstuff:uranium_leggings",
		recipe = {
			{ingot_name, ingot_name, ingot_name},
			{ingot_name, "", ingot_name},
			{ingot_name, "", ingot_name},
		}
	})

	minetest.register_craft({
		output = "uraniumstuff:uranium_boots",
		recipe = {
			{ingot_name, "", ingot_name},
			{ingot_name, "", ingot_name},
		}
	})

	if not minetest.get_modpath("mcl_armor") then
		minetest.register_craft({
			output = "uraniumstuff:uranium_shield",
			recipe = {
				{ingot_name, ingot_name, ingot_name},
				{ingot_name, ingot_name, ingot_name},
				{"", ingot_name, ""},
			}
		})
	end
end


-- Armor/Tool Player Damage

if allow_tool_damage or (allow_armor_damage and minetest.get_modpath("3d_armor")) then
    
    local function has_item(player_name, item_name)
        local inventory = minetest.get_inventory({type="player", name=player_name})
        local main_list = inventory:get_list("main")
        for _, stack in ipairs(main_list) do
            if stack:get_name() == item_name then
                return true
            end
        end
        return false
    end

    local function alter_health(player, change)
        if player == nil then return end
        local hp_max = player:get_properties().hp_max
        local current_health = player:get_hp()
        local new_health = current_health + change

        if new_health > hp_max then new_health = hp_max end
        if new_health < 0 then new_health = 0 end

        player:set_hp(new_health)
    end

    local function has_radioactive_tool(player)
        local wield = player:get_wielded_item()
        if wield then
            local tool_cap = wield:get_tool_capabilities()
            if tool_cap and tool_cap.damage_groups and tool_cap.damage_groups.radioactive then
                return true
            end
        end
        return false
    end

    local function pattern_count(base, pattern)
        return select(2, string.gsub(base, pattern, ""))
    end

    local function get_radioactive_armor_count(player)
        local inv_3d = player:get_meta():get_string("3d_armor_inventory")
        if not inv_3d then return 0 end
        return pattern_count(inv_3d, "uraniumstuff:")
    end

    local function damage_players()
        local players = minetest.get_connected_players()
        for _, player in ipairs(players) do
            local damage = 0
            if allow_armor_damage then
                damage = damage + get_radioactive_armor_count(player)
            end
            if allow_tool_damage and has_radioactive_tool(player) then
                damage = damage + 1
            end
            if damage > 0 then
                local player_name = player:get_player_name()
                local has_gem = has_item(player_name, "uraniumstuff:uranium_protection_gem")
                if not has_gem then
                    alter_health(player, damage*-1)
                end
            end
        end
        minetest.after(5, damage_players)
    end
    damage_players()

end


-- Irradiating entities

if allow_irradiating then

    local function register_entity_on_punch(callback)
        for name, entity in pairs(minetest.registered_entities) do
            local orig = entity.on_punch
            entity.on_punch = function(punched, puncher, time_from_last_punch, tool_capabilities, direction, damage)
                callback(punched, puncher, time_from_last_punch, tool_capabilities, direction, damage)
                if orig then
                    orig(punched, puncher, time_from_last_punch, tool_capabilities, direction, damage)
                end
            end
        end
    end

    function string_split(inputstr, sep)
       if sep == nil then
          sep = "%s"
       end
       local t={}
       for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
       end
       return t
    end

    local function set_entity_texture(entity, textures)
        local prop = entity.object:get_properties()
        prop.textures = textures
        prop.glow = 10
        prop.use_texture_alpha = true
        entity.object:set_properties(prop)
    end

    local new_texture = "uraniumstuff_goo.png"
    local entity_goo_textures = {
        new_texture, new_texture, new_texture, new_texture, new_texture, 
        new_texture, new_texture, new_texture, new_texture, new_texture, 
        new_texture, new_texture, new_texture, new_texture, new_texture,
        new_texture, new_texture, new_texture, new_texture, new_texture, 
        new_texture, new_texture, new_texture, new_texture, new_texture, 
        new_texture, new_texture, new_texture, new_texture, new_texture,
    }

    local function liquify_entity(entity)
        if not (entity and entity.object) then return nil end
        local pos = entity.object:get_pos()
        if not pos then return nil end
        entity.state = "stand"
        set_entity_texture(entity, entity_goo_textures)
        local r_pos = {x = round(pos.x), y = round(pos.y), z = round(pos.z)}
        local low_pos_1 = {x = r_pos.x, y = r_pos.y - 1, z = r_pos.z}
        local low_pos_2 = {x = r_pos.x, y = r_pos.y - 2, z = r_pos.z}
        local low_node = minetest.get_node(low_pos_2)
        minetest.set_node(r_pos, {name = "uraniumstuff:goo_source"})
        minetest.after(3, function()
            minetest.set_node(r_pos, {name = "uraniumstuff:goo_flowing"})
            if leave_residue and low_node.name ~= "air" then
                minetest.set_node(low_pos_1, {name = "uraniumstuff:goo_source"})
            end
        end)
    end

    local function irradiate_entity(entity, damage, time)
        local function radiation_damage(entity, damage, time)
            entity.health = entity.health - damage
            if entity.health <= 0 then
                liquify_entity(entity)
                entity.health = 0 
            else
                minetest.after(time, radiation_damage, entity, damage, time)          
            end
        end
        if entity.health and entity.health > 0 and not entity.irradiated then
            entity.irradiated = true
            local prop = entity.object:get_properties()
            local transparent = false
            for i, texture in ipairs(prop.textures) do
                local tspl = string_split(texture, "%^")
                local t_length = #(tspl)
                if t_length > 1 then 
                    transparent = true
                    prop.textures[i] = texture .. "^uraniumstuff_irradiated_full.png"
                else
                    prop.textures[i] = texture .. "^uraniumstuff_irradiated.png"
                end
            end
            prop.glow = 10
            if not transparent then prop.use_texture_alpha = true end
            entity.object:set_properties(prop)
            minetest.after(time, radiation_damage, entity, damage, time)
        end
    end

    register_entity_on_punch(function(punched, puncher, time_from_last_punch, tool_capabilities, direction, damage)
        if tool_capabilities and tool_capabilities.damage_groups then
            local rad_damage = tool_capabilities.damage_groups.radioactive
            if rad_damage and rad_damage > 0 then
                irradiate_entity(punched, rad_damage, 1)
            end
        end
    end)

end