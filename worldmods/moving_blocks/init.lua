--=========================================================
--  Items
--=========================================================


minetest.register_craftitem("moving_blocks:base_item", {
	description = "Base for moving blocks",
	inventory_image = "moving_blocks_base_item.png"
})

minetest.register_craft({
	output = "moving_blocks:base_item 25",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "group:wood", "default:steel_ingot"},
		{"", "default:steel_ingot",  ""}
	}
})

--=========================================================
--  Copies of block
--=========================================================

local function add_copy(n_mod,nom) --n_mod= "nom mod" nom = "nom_block"
  --local has_mod = minetest.get_modpath(n_mod)
  --if has_mod then
    local old_def = minetest.registered_nodes[n_mod..":"..nom]

    if not(old_def) then
	    return
	end
	
    local new_def = table.copy(old_def)

    --  modifier quelques propriétés
	new_def.description = nom.." (M)"

	--  compatibilité moving blocks
	new_def.groups = table.copy(old_def.groups or {})
	new_def.groups.moving_blocks = 1

	--  texture différente (optionnel)
	--new_def.tiles = {"super_steel.png"}

	--  enregistrer nouveau bloc
	minetest.register_node("moving_blocks:"..nom, new_def)
    --end
  
    minetest.register_craft({
	    type = "shapeless",
	    output = "moving_blocks:"..nom.." 1",
	    recipe = {n_mod..":"..nom, "moving_blocks:base_item"}
    })
end

--add_copy don't work with complex blocks

--add_copy("cannon73","cannon")
--add_copy("lrfurn","armchair")
--add_copy("homedecor","glass_table_small_round_with_wrought_iron_legs")
--add_copy("spacecannon","cannon_green")

--Wood

add_copy("default","wood")
add_copy("default","pine_wood")
add_copy("default","aspen_wood")
add_copy("default","acacia_wood")
add_copy("default","junglewood")

--Stone

add_copy("default","stonebrick")
add_copy("default","stone_block")
add_copy("default","stone")
add_copy("default","cobble")

-- metals

add_copy("default","steelblock")
add_copy("default","goldblock")
add_copy("default","bronzeblock")
add_copy("default","diamondblock")
add_copy("default","coalblock")

--truncs

add_copy("default","tree")
add_copy("default","pine_tree")
add_copy("default","aspen_tree")
add_copy("default","acacia_tree")
add_copy("default","jungle_tree")

--leaves

add_copy("default","leaves")
add_copy("default","pine_needles")
add_copy("default","aspen_leaves")
add_copy("default","acacia_leaves")
add_copy("default","jungleleaves")

-- other

add_copy("default","apple")
add_copy("vessels","drinking_glass")
add_copy("vessels","glass_bottle")






--=========================================================
--  glass blocks
--=========================================================

local function add_verre(nom, name) --nom=nom bloc  name=nom inv
	minetest.register_node("moving_blocks:"..nom, {
		description = "Moving block "..name,
		drawtype = "glasslike",
		tiles = {"moving_blocks_"..nom..".png"},

		paramtype = "light",
		sunlight_propagates = true,

		use_texture_alpha = "blend",

		groups = {cracky = 3, oddly_breakable_by_hand = 3, moving_blocks=1},
		sounds = default.node_sound_glass_defaults(),
	})
	end
	
add_verre("verre", "glass")
minetest.register_craft({
	    type = "shapeless",
	    output = "moving_blocks:verre",
	    recipe = {"default:glass", "moving_blocks:base_item"}
    })
	
add_verre("verre_noir", "black glass")
minetest.register_craft({
	    type = "shapeless",
	    output = "moving_blocks:verre_noir",
	    recipe = {"moving_blocks:verre", "dye:black"}
    })
	
add_verre("verre_cyan", "cyan glass")
minetest.register_craft({
	    type = "shapeless",
	    output = "moving_blocks:verre_cyan",
	    recipe = {"moving_blocks:verre", "dye:cyan"}
    })


--=========================================================
--  Simple blocks
--=========================================================

local function add_bloc(nom, lum, name) --nom=nom bloc  name=nom inv
    minetest.register_node("moving_blocks:"..nom, {
	description = "Moving block "..name,
	tiles = {"moving_blocks_"..nom..".png"},
	groups = {cracky=2, moving_blocks = 1},
	sounds = default.node_sound_metal_defaults(),
	light_source = lum, --1 à 14
    })
	end

add_bloc("fer",0,"iron")
minetest.register_craft({
	output = "moving_blocks:fer 4",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "moving_blocks:base_item", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot",  "default:steel_ingot"}
	}
})

add_bloc("ordi",4,"comuter")
minetest.register_craft({
	output = "moving_blocks:ordi",
	recipe = {
		{"", "default:glass", ""},
		{"moving_blocks:fer", "default:copper_ingot", "moving_blocks:fer"},
		{"", "default:copper_ingot",  ""}
	}
})

add_bloc("traits",0,"stripes")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:traits 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:yellow", "dye:black"}
})

add_bloc("fer_fonce",0,"dark iron")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:fer_fonce 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:black"}
})

add_bloc("blanc",0,"white")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:blanc 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:white"}
})

add_bloc("rouge",0,"red")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:rouge 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:red"}
})

add_bloc("orange",0,"orange")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:orange 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:orange"}
})

add_bloc("jaune",0,"yellow")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:jaune 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:yellow"}
})

add_bloc("vert",0,"green")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:vert 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:dark_green"}
})

add_bloc("bleu",0,"blue")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:bleu 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:blue"}
})

add_bloc("bleu_clair",0,"light blue")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:bleu_clair 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:cyan"}
})

add_bloc("violet",0,"purple")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:violet 4",
    recipe = {"moving_blocks:fer","moving_blocks:fer","moving_blocks:fer","moving_blocks:fer", "dye:violet"}
})

add_bloc("attention",0,"warning")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:attention 4",
    recipe = {"moving_blocks:fer", "dye:red"}
})

add_bloc("lampe_grande",14,"big light")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:lampe_grande",
    recipe = {"moving_blocks:lampe_petite", "moving_blocks:lampe_petite", "moving_blocks:lampe_petite", "moving_blocks:lampe_petite"}
})

add_bloc("lampe_petite",5,"small light")
minetest.register_craft({
	output = "moving_blocks:lampe_petite 4",
	recipe = {
		{"", "default:copper_ingot", ""},
		{"moving_blocks:fer", "default:copper_ingot", "moving_blocks:fer"},
		{"", "default:torch",  ""}
	}
})

add_bloc("attention_elec",7,"warning electricity")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:attention_elec",
    recipe = {"moving_blocks:rouge", "dye:yellow", "dye:black"}
})

add_bloc("attention_nuke",7,"warning nuclear")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:attention_nuke",
    recipe = {"moving_blocks:rouge", "dye:yellow", "dye:green"}
})

add_bloc("exit_bas",8,"exit bottom")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:exit_bas",
    recipe = {"moving_blocks:lampe_petite", "dye:white", "dye:green"}
})
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:exit_bas",
    recipe = {"moving_blocks:exit_haut"}
})

add_bloc("exit_droite",8,"exit right")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:exit_droite",
    recipe = {"moving_blocks:exit_bas"}
})

add_bloc("exit_gauche",8,"exit left")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:exit_gauche",
    recipe = {"moving_blocks:exit_droite"}
})

add_bloc("exit_haut",8,"exit top")
minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:exit_haut",
    recipe = {"moving_blocks:exit_gauche"}
})



--=========================================================
--  energy blocks
--=========================================================



moving_blocks = moving_blocks or {}





minetest.register_node("moving_blocks:cable", {
	description = "Moving block cable",
	tiles = {"moving_blocks_cable.png"},
	groups = {cracky=2, moving_blocks = 1},
	sounds = default.node_sound_metal_defaults(),
	--light_source = lum, --1 à 14
    })
	
minetest.register_craft({
	output = "moving_blocks:cable 10",
	recipe = {
		{"", "default:copper_ingot", ""},
		{"moving_blocks:fer", "default:copper_ingot", "moving_blocks:fer"},
		{"", "default:copper_ingot",  ""}
	}
})


--  hydrogen blocks ====================================

dofile(minetest.get_modpath("moving_blocks") .. DIR_DELIM .. "hydrogen.lua")


--Fuel generator ====================================


minetest.register_lbm({
    name = "moving_blocks:generator_resume",
    nodenames = {"moving_blocks:generator"},
    run_at_every_load = true,

    action = function(pos)

        local meta = minetest.get_meta(pos)

        if meta:get_int("power") == 0 then
            return
        end

        local remaining = meta:get_float("fuel_end_time") - os.time()

        if remaining <= 0 then
            -- Le combustible est terminé pendant que le monde était fermé.
            -- On appelle directement la logique de fin de combustion.
            minetest.get_node_timer(pos):start(0.1)
        else
            -- On redémarre le timer avec le temps restant.
            minetest.get_node_timer(pos):start(remaining)
        end

    end
})



--moving_blocks = moving_blocks or {}

moving_blocks.GENERATOR_POWER = 200

minetest.register_node("moving_blocks:generator", {
    description = "Fuel Generator",
    tiles = {"moving_blocks_generator.png"},
    groups = {cracky = 2, moving_blocks = 1},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size("fuel", 1)
        meta:set_int("power", 0)
        meta:set_float("fuel_end_time", 0)

        meta:set_string("infotext", "Generator: OFF")
        meta:set_string("formspec",
            "size[8,4]" ..
            "label[0,0;Fuel Generator]" ..
            "list[current_name;fuel;3.5,1;1,1;]" ..
            "list[current_player;main;0,2.5;8,4;]" ..
            "listring[current_name;fuel]" ..
            "listring[current_player;main]"
        )
    end,
	
	
    can_dig = function(pos)
        local inv = minetest.get_meta(pos):get_inventory()
        return inv:is_empty("fuel")
    end,


    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local end_time = meta:get_float("fuel_end_time")

        if os.time() >= end_time then
            meta:set_int("power", 0)
			
			local inv = meta:get_inventory()
			local stack = inv:get_stack("fuel", 1)

			local fuel = minetest.get_craft_result({
				method = "fuel",
				width = 1,
				items = {stack}
			})

			if fuel.time > 0 then
				stack:take_item(1)
				inv:set_stack("fuel", 1, stack)
				
				meta:set_int("power", moving_blocks.GENERATOR_POWER)
				
				meta:set_string(
					"infotext",
					"Generator : "..moving_blocks.GENERATOR_POWER.." EU"
				)
				meta:set_float(
					"fuel_end_time",
					os.time() + fuel.time
				)

				return true

			end

			meta:set_string("infotext", "Generator : OFF")

			return false

        end

        return true

    end,


    on_rightclick = function(pos)

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        -- déjà en fonctionnement
        if meta:get_int("power") > 0 then
            return
        end

        local stack = inv:get_stack("fuel", 1)

        local fuel = minetest.get_craft_result({
            method = "fuel",
            width = 1,
            items = {stack}
        })

        if fuel.time <= 0 then
            return
        end

        stack:take_item(1)
        inv:set_stack("fuel", 1, stack)

        meta:set_int("power", moving_blocks.GENERATOR_POWER)

        meta:set_string(
            "infotext",
            "Generator: " ..
            moving_blocks.GENERATOR_POWER ..
            " EU "
        )

        local end_time = os.time() + fuel.time

        meta:set_float("fuel_end_time", end_time)

        minetest.get_node_timer(pos):start(1)

    end,
	
	
	allow_metadata_inventory_put = function(pos, listname, index, stack)

		if listname ~= "fuel" then
			return 0
		end

		return stack:get_count()

	end,
	
	
	on_metadata_inventory_put = function(pos)

		local meta = minetest.get_meta(pos)

		-- Si le générateur est déjà allumé, ne rien faire
		if meta:get_int("power") > 0 then
			return
		end

		local inv = meta:get_inventory()
		local stack = inv:get_stack("fuel", 1)

		local fuel = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {stack}
		})

		if fuel.time <= 0 then
			return
		end

		stack:take_item(1)
		inv:set_stack("fuel", 1, stack)

		meta:set_int("power", moving_blocks.GENERATOR_POWER)

		meta:set_string(
			"infotext",
			"Generator : "..moving_blocks.GENERATOR_POWER.." EU"
		)

		meta:set_float(
			"fuel_end_time",
			os.time() + fuel.time
		)

		minetest.get_node_timer(pos):start(1)

	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- item tenu par le joueur
		local item = puncher:get_wielded_item()
		local fuel_test = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {item}
		})

		-- pas un combustible
		if fuel_test.time <= 0 then
			return
		end

		local fuel_stack = inv:get_stack("fuel", 1)

		--  CAS 1 : déjà en production → on stocke seulement
		if meta:get_int("power") > 0 then

			local new_stack = ItemStack(item:get_name() .. " 1")
			local leftover = inv:add_item("fuel", new_stack)

			if leftover:is_empty() then
				item:take_item(1)
				puncher:set_wielded_item(item)
			end

		--  CAS 2 : pas en production → on démarre
		else

			item:take_item(1)
			puncher:set_wielded_item(item)

			meta:set_int("power", moving_blocks.GENERATOR_POWER)

			meta:set_string(
				"infotext",
				"Generator : " .. moving_blocks.GENERATOR_POWER .. " EU"
			)

			local fuel_test = minetest.get_craft_result({
				method = "fuel",
				width = 1,
				items = {ItemStack(item:get_name())}
			})

			meta:set_float(
				"fuel_end_time",
				os.time() + fuel_test.time
			)

			minetest.get_node_timer(pos):start(1)
		end

	end,
})



minetest.register_craft({
	output = "moving_blocks:generator",
	recipe = {
		{"", "", ""},
		{"moving_blocks:fer", "default:furnace", "moving_blocks:fer"},
		{"", "default:copper_ingot",  ""}
	}
})



--=========================================================
--  conduit and chimney blocks
--=========================================================

minetest.register_node("moving_blocks:conduit", {
	description = "Moving block conduit",
	tiles = {"moving_blocks_conduit.png"},
	groups = {cracky=2, moving_blocks = 1},
	sounds = default.node_sound_metal_defaults(),
    })

minetest.register_craft({
	output = "moving_blocks:conduit 8",
	recipe = {
		{"moving_blocks:fer", "moving_blocks:fer", "moving_blocks:fer"},
		{"moving_blocks:fer", "", "moving_blocks:fer"},
		{"moving_blocks:fer", "moving_blocks:fer",  "moving_blocks:fer"}
	}
})


local function count_connected_generators(start_pos)

    local visited = {}
    local queue = {vector.new(start_pos)}

    local generators = 0
    local chimneys = 0

    local dirs = {
        {x=1,y=0,z=0},
        {x=-1,y=0,z=0},
        {x=0,y=1,z=0},
        {x=0,y=-1,z=0},
        {x=0,y=0,z=1},
        {x=0,y=0,z=-1},
    }

    while #queue > 0 do

        local pos = table.remove(queue, 1)
        local key = minetest.pos_to_string(pos)

        if not visited[key] then

            visited[key] = true

            local node = minetest.get_node(pos)

            if node.name == "moving_blocks:conduit" or node.name=="moving_blocks:chimney" then

                for _, dir in ipairs(dirs) do
                    table.insert(queue, vector.add(pos, dir))
                end
				
				if node.name == "moving_blocks:chimney" then
                    chimneys = chimneys + 1
				end

            elseif node.name == "moving_blocks:generator" then

                local power = minetest.get_meta(pos):get_int("power")

                if power > 0 then
                    generators = generators + 1
                end

            end
        end
    end

    if chimneys == 0 then
        return 0
    end

    return generators / chimneys

end



local function start_chimney(pos)

    local node = minetest.get_node_or_nil(pos)
    if not node or node.name ~= "moving_blocks:chimney" then
        return
    end

    local meta = minetest.get_meta(pos)

    local id = tostring(minetest.get_us_time()) .. "_" .. math.random(1000)
    meta:set_string("chimney_id", id)

    local function loop(my_id)

        local node2 = minetest.get_node_or_nil(pos)
        if not node2 or node2.name ~= "moving_blocks:chimney" then
            return
        end

        local meta2 = minetest.get_meta(pos)

        if meta2:get_string("chimney_id") ~= my_id then
            return
        end

        local generators = count_connected_generators(pos)

        if generators > 0 then
            minetest.add_particlespawner({
                amount = generators * 5,
                time = 1,
                minpos = vector.add(pos, {x=-0.2,y=0.5,z=-0.2}),
                maxpos = vector.add(pos, {x=0.2,y=0.8,z=0.2}),
                minvel = {x=-0.2,y=1,z=-0.2},
                maxvel = {x=0.2,y=2,z=0.2},
                minacc = {x=0,y=0.2,z=0},
                maxacc = {x=0,y=0.5,z=0},
                minexptime = 1,
                maxexptime = 3,
                minsize = 4,
                maxsize = 8,
                texture = "smoke_puff.png",
            })
        end

        minetest.after(1, function()
            loop(my_id)
        end)
    end

    minetest.after(1, function()
        loop(id)
    end)
end







minetest.register_lbm({
    name = "moving_blocks:chimney_init",
    nodenames = {"moving_blocks:chimney"},
    run_at_every_load = true,
    action = function(pos)
        minetest.after(0, function()
            start_chimney(pos)
        end)
    end
})



minetest.register_node("moving_blocks:chimney", {
    description = "Moving block Chimney",
    tiles = {
        "moving_blocks_chimney.png"
    },
    groups = {
        cracky = 1,
        moving_blocks = 1
    },
	
    on_construct = function(pos)
        start_chimney(pos)
    end,

    on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("chimney_id", "")
    end,
	
})

minetest.register_craft({
    type = "shapeless",
    output = "moving_blocks:chimney",
    recipe = {"moving_blocks:conduit"}
})

--=========================================================
--  pusher blocks
--=========================================================

local function move_structure(start_pos, direction)

    local visited = {}
    local structure = {}
    local queue = {vector.new(start_pos)}
	
	dist=1

    local dirs = {
        {x= 1*dist,y= 0,z= 0},
        {x=-1*dist,y= 0,z= 0},
        {x= 0,y= 1*dist,z= 0},
        {x= 0,y=-1*dist,z= 0},
        {x= 0,y= 0,z= 1*dist},
        {x= 0,y= 0,z=-1*dist},
    }

    while #queue > 0 do

        local pos = table.remove(queue, 1)
        local key = minetest.pos_to_string(pos)

        if not visited[key] then

            visited[key] = true

            local node = minetest.get_node(pos)

            if minetest.get_item_group(node.name, "moving_blocks") > 0 then

                local timer = minetest.get_node_timer(pos)

				table.insert(structure, {
					pos = vector.new(pos),
					node = table.copy(node),
					meta = minetest.get_meta(pos):to_table(),
					timer_timeout = timer:get_timeout(),
					timer_elapsed = timer:get_elapsed(),
				})

                for _, dir in ipairs(dirs) do
                    table.insert(queue, vector.add(pos, dir))
                end

            end
        end
    end
	
	
	
	
	local entities_to_move = {}
    local players_to_move = {}
    local entity_ids = {}

	for _, block in ipairs(structure) do

		local objs = minetest.get_objects_inside_radius(block.pos, 1)

		for _, obj in ipairs(objs) do

        local id = tostring(obj)

        if not entity_ids[id] then

            entity_ids[id] = true

            if obj:is_player() then
                table.insert(players_to_move, obj)
            else
                table.insert(entities_to_move, obj)
            end
        end
    end

    end




    for _, block in ipairs(structure) do

        local target = vector.add(block.pos, direction)
        local target_node = minetest.get_node(target)

        if minetest.get_item_group(target_node.name, "moving_blocks") == 0
        and (target_node.name ~= "air" and target_node.name ~= "default:water_source" and target_node.name ~= "default:water_flowing") then
            return false
        end

    end

    for _, block in ipairs(structure) do

		minetest.get_node_timer(block.pos):stop()

		-- Bloc situé derrière celui qui se déplace
		local behind_pos = vector.subtract(block.pos, direction)
		local behind_node = minetest.get_node(behind_pos)

		if behind_node.name == "default:water_source" then

			-- Remet de l'eau à la place du bloc déplacé
			minetest.set_node(block.pos, {name = behind_node.name})

		else

			-- Sinon, on laisse de l'air
			minetest.remove_node(block.pos)

		end
	end
	

    for _, block in ipairs(structure) do

        local target = vector.add(block.pos, direction)

        minetest.set_node(target, block.node)
		
		if block.node.name=="moving_blocks:hydrogen_generator" then

            local meta = minetest.get_meta(target)
			meta:from_table(block.meta)
			
			local inv = meta:get_inventory()
			local stack = inv:get_stack("hydrogen", 1)

			stack:take_item(1)
			inv:set_stack("hydrogen", 1, stack)
			
			if stack:is_empty() then
				meta:set_int("power", 0)
				meta:set_string("infotext", "Hydrogen Generator : OFF")
			end
		
		else
		    
			local meta = minetest.get_meta(target)
            meta:from_table(block.meta)
		
		end
		
		if block.node.name == "moving_blocks:generator" then

			local end_time = tonumber(block.meta.fields.fuel_end_time) or 0

			if end_time > 0 then
				local remaining = math.max(
					block.timer_timeout - block.timer_elapsed,
					0
				)

				block.meta.fields.fuel_end_time =
					tostring(os.time() + remaining)
			end
		end
		
		if block.node.name == "moving_blocks:chimney" then

			minetest.get_meta(target):set_string("chimney_id", "")

			minetest.after(0.1, function()
				start_chimney(target)
			end)
		 
        end

		if block.timer_timeout > 0 then

			local remaining =
				math.max(
					block.timer_timeout - block.timer_elapsed,
					0.1
				)
			minetest.get_node_timer(target):start(remaining)

		end

    end
	
	
	for _, obj in ipairs(entities_to_move) do

        if obj and obj:get_pos() then
            obj:set_pos(vector.add(obj:get_pos(), direction))
        end

    end
	
	minetest.after(0, function()

		for _, player in ipairs(players_to_move) do

			if player and player:get_pos() then

				local pos = player:get_pos()

				player:set_pos(vector.add(pos, direction))

				-- remet la vitesse à zéro pour éviter les effets de collision
				player:add_velocity({x=0, y=0, z=0})

			end

		end

	end)
	
	
	minetest.sound_play("moving_blocks_truck", {
		pos = start_pos,
	    gain = 1.0,
	})

    return true

end




moving_blocks.MOVE_ENERGY_PER_BLOCK = 1

local function count_structure_blocks(start_pos)

    local visited = {}
    local queue = {vector.new(start_pos)}
    local count = 0

    local dirs = {
        {x=1,y=0,z=0},
        {x=-1,y=0,z=0},
        {x=0,y=1,z=0},
        {x=0,y=-1,z=0},
        {x=0,y=0,z=1},
        {x=0,y=0,z=-1},
    }

    while #queue > 0 do

        local pos = table.remove(queue, 1)
        local key = minetest.pos_to_string(pos)

        if not visited[key] then

            visited[key] = true

            local node = minetest.get_node(pos)

            if minetest.get_item_group(node.name, "moving_blocks") > 0 then

                count = count + 1

                for _, dir in ipairs(dirs) do
                    table.insert(queue, vector.add(pos, dir))
                end

            end
        end
    end

    return count

end



local function get_network_power(start_pos)

    local visited = {}
    local queue = {vector.new(start_pos)}

    local total_power = 0

    local dirs = {
        {x=1,y=0,z=0},
        {x=-1,y=0,z=0},
        {x=0,y=1,z=0},
        {x=0,y=-1,z=0},
        {x=0,y=0,z=1},
        {x=0,y=0,z=-1},
    }

    while #queue > 0 do

        local pos = table.remove(queue, 1)
        local key = minetest.pos_to_string(pos)

        if not visited[key] then

            visited[key] = true

            local node = minetest.get_node(pos)

            if node.name == "moving_blocks:cable" or node.name == "moving_blocks:pusher_x1" or node.name == "moving_blocks:pusher_x10" or node.name == "moving_blocks:pusher_x50" then

                for _, dir in ipairs(dirs) do
                    table.insert(queue, vector.add(pos, dir))
                end

            elseif node.name == "moving_blocks:generator" or node.name == "moving_blocks:hydrogen_generator" then

                local meta = minetest.get_meta(pos)

                total_power =
                    total_power +
                    meta:get_int("power")

            end
        end
    end

    return total_power

end


function register_pusher(count)

minetest.register_node("moving_blocks:pusher_x"..count, {
    description = "Pusher x"..count,
    tiles = {"moving_blocks_pusher"..count..".png"},
    groups = {cracky = 1, moving_blocks = 1},

    paramtype = "light",
    paramtype2 = "facedir",
	
	on_rightclick = function(pos, node, clicker)

    local structure_size =
        count_structure_blocks(pos)

    local required_energy =
        structure_size *
        moving_blocks.MOVE_ENERGY_PER_BLOCK

    local available_energy =
        get_network_power(pos)

    if available_energy < required_energy then
	  if available_energy==0 then
	    minetest.chat_send_player(
            clicker:get_player_name(),
            "Not enough power (" ..
            available_energy ..
            "/" ..
            required_energy ..
            " EU) (the generators must be connected to the pusher and active)"
        )
		
      else

        minetest.chat_send_player(
            clicker:get_player_name(),
            "Not enough power (" ..
            available_energy ..
            "/" ..
            required_energy ..
            " EU)"
        )
      end

        return

    end

    local dir = minetest.facedir_to_dir(node.param2)
    local current_pos = vector.new(pos)

    local i = 0
    local max = count -- nombre d'executions

    local function step()

        if i >= max then
            return
        end

        if not move_structure(current_pos, dir) then
            return
        end

        current_pos = vector.add(current_pos, dir)

        i = i + 1

        minetest.after(0.1, step)

    end

    minetest.after(0.1, step)

    end,
})
end

register_pusher(1)

minetest.register_craft({
	output = "moving_blocks:pusher_x1",
	recipe = {
		{"", "moving_blocks:fer", ""},
		{"moving_blocks:fer", "moving_blocks:ordi", "moving_blocks:fer"},
		{"", "moving_blocks:fer",  ""}
	}
})

register_pusher(10)

minetest.register_craft({
	output = "moving_blocks:pusher_x10",
	recipe = {
		{"", "moving_blocks:fer", ""},
		{"moving_blocks:fer", "moving_blocks:pusher_x1", "moving_blocks:fer"},
		{"", "moving_blocks:fer",  ""}
	}
})

register_pusher(50)

minetest.register_craft({
	output = "moving_blocks:pusher_x50",
	recipe = {
		{"", "moving_blocks:fer", ""},
		{"moving_blocks:fer", "moving_blocks:pusher_x10", "moving_blocks:fer"},
		{"", "moving_blocks:fer",  ""}
	}
})



--=========================================================
--  rotator block
--=========================================================


local function rotate_param2(node, times)

    local ndef = minetest.registered_nodes[node.name]
    if not ndef then
        return node.param2 or 0
    end

    local paramtype2 = ndef.paramtype2

    --  CASE 1: facedir
    if paramtype2 == "facedir" or paramtype2 == "colorfacedir" then

        local dir = minetest.facedir_to_dir(node.param2 or 0)

        for i = 1, times do
            dir = {x = -dir.z, y = dir.y, z = dir.x}
        end

        return minetest.dir_to_facedir(dir, true)

    end

    --  CASE 2: wallmounted
    if paramtype2 == "wallmounted" then

        local dir = minetest.wallmounted_to_dir(node.param2 or 0)

        for i = 1, times do
            dir = {x = -dir.z, y = dir.y, z = dir.x}
        end

        return minetest.dir_to_wallmounted(dir)

    end

    if paramtype2 == "none" then
		return node.param2 or 0
	end
	
	

end



local function rotate_vector_y(pos, center, times)

    local p = vector.subtract(pos, center)

    for i = 1, times do
        p = {x = -p.z, y = p.y, z = p.x}
    end

    return vector.add(center, p)

end


local function rotate_structure(center, times)

    local visited = {}
    local structure = {}

    local dirs = {
        {x=1,y=0,z=0},{x=-1,y=0,z=0},
        {x=0,y=0,z=1},{x=0,y=0,z=-1},
        {x=0,y=1,z=0},{x=0,y=-1,z=0},
    }

    local queue = {vector.new(center)}

    --  scan
    while #queue > 0 do

        local pos = table.remove(queue, 1)
        local key = minetest.pos_to_string(pos)

        if not visited[key] then

            visited[key] = true

            local node = minetest.get_node(pos)

            if minetest.get_item_group(node.name, "moving_blocks") > 0 then

                table.insert(structure, {
                    pos = vector.new(pos),
                    node = table.copy(node),
                    meta = minetest.get_meta(pos):to_table(),
                })

                for _, d in ipairs(dirs) do
                    table.insert(queue, vector.add(pos, d))
                end

            end
        end
    end

    --  entités
    local entities = {}
    local seen = {}

    for _, b in ipairs(structure) do

        for _, obj in ipairs(minetest.get_objects_inside_radius(b.pos, 1)) do

            if not obj:is_player() and not seen[obj] then
                seen[obj] = true
                table.insert(entities, obj)
            end

        end

    end

    --  remove
    for _, b in ipairs(structure) do
        minetest.remove_node(b.pos)
    end

    --  place rotated nodes + param2 rotation
    for _, b in ipairs(structure) do

        local new_pos = rotate_vector_y(b.pos, center, times)

        local new_node = table.copy(b.node)

        new_node.param2 = rotate_param2(b.node, times)

        minetest.set_node(new_pos, new_node)

        local meta = minetest.get_meta(new_pos)
        meta:from_table(b.meta)

    end

    --  entités
    for _, obj in ipairs(entities) do

        if obj:get_pos() then

            local new_pos = rotate_vector_y(obj:get_pos(), center, times)
            obj:set_pos(new_pos)

        end

    end

end


minetest.register_node("moving_blocks:rotator", {

    description = "Moving block rotator",
    tiles = {"moving_blocks_rotator.png"},

    groups = {cracky = 1, moving_blocks = 1},

    paramtype = "light",
    paramtype2 = "facedir",

    on_rightclick = function(pos, node, clicker)

        local dir = minetest.facedir_to_dir(node.param2)

        -- centre = bloc + direction (ajustable)
        local center = pos

        -- 90° rotation (1 = 90°, 2 = 180°, etc.)
        local times = 1

        rotate_structure(center, times)

    end
})

minetest.register_craft({
	output = "moving_blocks:rotator",
	recipe = {
		{"", "", ""},
		{"moving_blocks:pusher_x1", "moving_blocks:fer", "moving_blocks:pusher_x1"},
		{"", "",  ""}
	}
})