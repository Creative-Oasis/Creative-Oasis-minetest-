minetest.register_node("moving_blocks:hydrogen", {
    description = "Hydrogen \r(warning, explosive when are in tanks)",
    tiles = {"moving_blocks_hydrogen.png"},
	
    stack_max = 500,
	
	on_construct = function(pos)
        minetest.remove_node(pos)

        -- Nuage de gaz
        minetest.add_particlespawner({
            amount = 5,
            time = 0.5,

            minpos = vector.subtract(pos, 0.2),
            maxpos = vector.add(pos, 0.2),

            minvel = {x=-0.5,y=0.3,z=-0.5},
            maxvel = {x= 0.5,y=1.5,z= 0.5},

            minacc = {x=0,y=0,z=0},
            maxacc = {x=0,y=0.2,z=0},

            minexptime = 2,
            maxexptime = 4,

            minsize = 6,
            maxsize = 10,

            texture = "smoke_puff.png",
        })

        minetest.sound_play("fire_extinguish_flame", {
            pos = pos,
            gain = 0.4,
            max_hear_distance = 12,
        })

    end,
	
})

moving_blocks.HYDROGEN_CREATOR_POWER = 1000 -- EU/t

local function hydrogen_explode(pos,nb)
    -- 💥 explosion proportionnelle
	--local power = math.min(10, math.floor(nb / 80) + 1)
	local power = (nb/(0.75*3.14))^0.333 --formule sphère
	
	--minetest.chat_send_all(power)

	minetest.sound_play("tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 32
	})

	minetest.set_node(pos, {name = "air"})

	if minetest.get_modpath("tnt") then
		tnt.boom(pos, {
			radius = power,
			damage_radius = power,
		})
	end
end


local function hydrogen_check_fire_adjacent(pos, nb)

    if nb <= 0 then
        return
    end

    local dirs = {
        {x=1,y=0,z=0},
        {x=-1,y=0,z=0},
        {x=0,y=1,z=0},
        {x=0,y=-1,z=0},
        {x=0,y=0,z=1},
        {x=0,y=0,z=-1},
    }

    for _, dir in ipairs(dirs) do

        local p = vector.add(pos, dir)
        local node = minetest.get_node(p)

        -- 🔥 détection feu collé uniquement
        if node.name == "fire:basic_flame"
        or node.name == "fire:permanent_flame"
        or minetest.get_item_group(node.name, "fire") > 0 then

            hydrogen_explode(pos,nb)

			return true
        end
    end

    return false
end





minetest.register_node("moving_blocks:hydrogen_creator", {
    description = "Hydrogen Creator",
    tiles = {"moving_blocks_hydrogen_creator.png"},
    --groups = {cracky = 2, technic_machine = 1},
	groups = {cracky = 2},
	
	--connects_to = {
    --    "group:technic_machine",
    --    --"moving_blocks:conduit",
    --},

    on_construct = function(pos)

        local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("hydrogen", 1)

		meta:set_int("hydrogen_count", 0)

		meta:set_string("formspec",
			"size[8,4]" ..
			"label[0,0;Hydrogen Creator]" ..
			"list[current_name;hydrogen;3.5,1;1,1;]" ..
			"list[current_player;main;0,2.5;8,4;]" ..
			"listring[current_name;hydrogen]" ..
			"listring[current_player;main]"
		)

        minetest.get_node_timer(pos):start(1)
    end,
	
	allow_metadata_inventory_put = function(pos, listname, index, stack)

		--if stack:get_name() ~= "moving_blocks:hydrogen" then
		--	return 0
		--end

		--return stack:get_count()
		
		return 0

	end,
	
	

    on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("hydrogen", 1)

		hydrogen_check_fire_adjacent(pos, stack:get_count())

		if minetest.get_modpath("technic") then
			return true
		end

		local dirs = {
			{x=1,y=0,z=0},{x=-1,y=0,z=0},
			{x=0,y=1,z=0},{x=0,y=-1,z=0},
			{x=0,y=0,z=1},{x=0,y=0,z=-1},
		}

		local touching_water = false

		for _, d in ipairs(dirs) do
			local node = minetest.get_node(vector.add(pos, d))

			if node.name == "default:water_source"
			or node.name == "default:water_flowing" then
				touching_water = true
				break
			end
		end

		local light = minetest.get_node_light(pos) or 0

		if touching_water and light >= -1 then
			--if count < 500 then
			--	count = count + 1
			--	meta:set_int("hydrogen_count", count)
			--end
			local inv = meta:get_inventory()
			local stack = inv:get_stack("hydrogen", 1)

            if stack:get_count() < 500 then
                inv:add_item("hydrogen", ItemStack("moving_blocks:hydrogen"))
            end
		end

		--meta:set_string("infotext",
		--	"Hydrogen Creator : " .. count
		--)
		
		meta:set_string(
                "infotext",
                "Hydrogen Creator\n"..
                stack:get_count().." H₂"
            )

		return true
	end,

    on_rightclick = function(pos, node, clicker)
		minetest.show_formspec(
            clicker:get_player_name(),
            "moving_blocks:hydrogen_creator",
            minetest.get_meta(pos):get_string("formspec")
        )
	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- item tenu par le joueur
		local item = puncher:get_wielded_item()
		
		--item du réservoir
		local fuel_stack = inv:get_stack("hydrogen", 1)
		
		local current = fuel_stack:get_count() --nombre d'hydrogène dans le réservoir
		local player_count = item:get_count()  --nombre d'hydrogène du joueur
		

		
		if item:get_name() == "" then -- si item vide
		    --vider le réservoir
			local stack = inv:get_stack("hydrogen", 1)
            local leftover = puncher:get_inventory():add_item("main", stack)

            inv:set_stack("hydrogen", 1, leftover)
			
			
		elseif  item:get_name()~="moving_blocks:hydrogen" then --si c'est autre que hydrogen
		    -- rien faire
			return
			
		else -- si c'est hydrogène
		    --remplir le réservoir
			local nb=500-current
			
			if nb>player_count then
				nb=player_count
			end

			local new_stack = ItemStack(item:get_name() .. " "..nb)
			local leftover = inv:add_item("hydrogen", new_stack)

			if leftover:is_empty() then
				item:take_item(nb)
				puncher:set_wielded_item(item)
			end
		end

	end,

    on_destruct = function(pos)
        minetest.get_node_timer(pos):stop()
    end,
	
	on_blast = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local nb = inv:get_stack("hydrogen", 1):get_count()

		hydrogen_explode(pos,nb)
		
	end,
	
	
	
	technic_run = function(pos, node)

        local meta = minetest.get_meta(pos)

        -------------------------------------------------
        -- Vérifie l'eau
        -------------------------------------------------

        local near_water = false

        local dirs = {
            {x=1,y=0,z=0},
            {x=-1,y=0,z=0},
            {x=0,y=1,z=0},
            {x=0,y=-1,z=0},
            {x=0,y=0,z=1},
            {x=0,y=0,z=-1},
        }

        for _, dir in ipairs(dirs) do

            local n = minetest.get_node(vector.add(pos, dir))

            if n.name == "default:water_source"
            or n.name == "default:water_flowing" then

                near_water = true
                break

            end

        end

        -------------------------------------------------
        -- Énergie MV reçue
        -------------------------------------------------

        local eu = meta:get_int("MV_EU_input")
		
		local eu_demand = meta:get_int("MV_EU_demand")

        --if eu_demand <= 0 then
        --    meta:set_string(
        --        "infotext",
        --        "Hydrogen Creator: erreur"
        --    )
		--	return
        --end

        if eu >= moving_blocks.HYDROGEN_CREATOR_POWER and near_water then

            meta:set_int(
                "MV_EU_demand",
                moving_blocks.HYDROGEN_CREATOR_POWER
            )

            --local hydrogen = meta:get_int("hydrogen_count")

            --if hydrogen < 500 then
            --    hydrogen = hydrogen + 1
            --    meta:set_int("hydrogen_count", hydrogen)
            --end
			local inv = meta:get_inventory()
			local stack = inv:get_stack("hydrogen", 1)

            if stack:get_count() < 500 then
                inv:add_item("hydrogen", ItemStack("moving_blocks:hydrogen"))
            end

            --meta:set_string(
            --    "infotext",
            --    "Hydrogen Creator\n"..
            --    hydrogen.." H₂"
            --)
			
			meta:set_string(
                "infotext",
                "Hydrogen Creator\n"..
                stack:get_count().." H₂"
            )

        else

            meta:set_int("MV_EU_demand", moving_blocks.HYDROGEN_CREATOR_POWER)

            local inv = meta:get_inventory()
			local stack = inv:get_stack("hydrogen", 1)

            meta:set_string(
                "infotext",
                "Hydrogen Creator\nOFF\n"..
                stack:get_count().." H₂"
            )

        end

    end,

})


minetest.register_craft({
	output = "moving_blocks:hydrogen_creator",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:copper_ingot", "moving_blocks:fer", "default:copper_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

if minetest.get_modpath("technic") then
	technic.register_machine(
		"MV",
		"moving_blocks:hydrogen_creator",
		technic.receiver
	)
end





minetest.register_node("moving_blocks:hydrogen_tank", {
    description = "Hydrogen Tank",
    tiles = {"moving_blocks_hydrogen_tank.png"},
    groups = {cracky = 2, moving_blocks = 1},

    on_construct = function(pos)

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size("hydrogen", 1)

        meta:set_string("formspec",
            "size[8,8]" ..
            "label[0,0;Hydrogen Tank]" ..
            "list[current_name;hydrogen;3.5,1;1,1;]" ..
            "list[current_player;main;0,3;8,4;]" ..
            "listring[current_name;hydrogen]" ..
            "listring[current_player;main]"
        )

        meta:set_string("infotext", "Hydrogen Tank")
		
		minetest.get_node_timer(pos):start(1)
    end,
	
	on_destruct = function(pos)
        minetest.get_node_timer(pos):stop()
    end,

    can_dig = function(pos)

        local inv = minetest.get_meta(pos):get_inventory()
        return inv:is_empty("hydrogen")

    end,
	
	on_blast = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local nb = inv:get_stack("hydrogen", 1):get_count()

		hydrogen_explode(pos,nb)
		
	end,

    allow_metadata_inventory_put = function(pos, listname, index, stack)

        if listname ~= "hydrogen" then
            return 0
        end

        if stack:get_name() ~= "moving_blocks:hydrogen" then
            return 0
        end

        return stack:get_count()

    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack)

        return stack:get_count()

    end,
	
	on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("hydrogen", 1)

		hydrogen_check_fire_adjacent(pos, stack:get_count())

		return true
	
	
	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- item tenu par le joueur
		local item = puncher:get_wielded_item()
		
		--item du réservoir
		local fuel_stack = inv:get_stack("hydrogen", 1)
		
		local current = fuel_stack:get_count() --nombre d'hydrogène dans le réservoir
		local player_count = item:get_count()  --nombre d'hydrogène du joueur
		

		
		if item:get_name() == "" then -- si item vide
		    --vider le réservoir
			local stack = inv:get_stack("hydrogen", 1)
            local leftover = puncher:get_inventory():add_item("main", stack)

            inv:set_stack("hydrogen", 1, leftover)
			
			
		elseif  item:get_name()~="moving_blocks:hydrogen" then --si c'est autre que hydrogen
		    -- rien faire
			return
			
		else -- si c'est hydrogène
		    --remplir le réservoir
			local nb=500-current
			
			if nb>player_count then
				nb=player_count
			end

			local new_stack = ItemStack(item:get_name() .. " "..nb)
			local leftover = inv:add_item("hydrogen", new_stack)

			if leftover:is_empty() then
				item:take_item(nb)
				puncher:set_wielded_item(item)
			end
		end

	end,
	
	
})

minetest.register_craft({
	output = "moving_blocks:hydrogen_tank 8",
	recipe = {
		{"moving_blocks:fer", "moving_blocks:fer", "moving_blocks:fer"},
		{"moving_blocks:fer", "dye:white", "moving_blocks:fer"},
		{"moving_blocks:fer", "moving_blocks:fer",  "moving_blocks:fer"}
	}
})


local function hydrogen_update_power(pos)

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack("hydrogen", 1)

    if stack:is_empty() then
        meta:set_int("power", 0)
        meta:set_string("infotext", "Hydrogen Generator : OFF")
    else
        meta:set_int("power", moving_blocks.HYDROGEN_GENERATOR_POWER)

        meta:set_string(
            "infotext",
            "Hydrogen Generator\nPower: " ..
            moving_blocks.HYDROGEN_GENERATOR_POWER ..
            "\nFuel: " .. stack:get_count()
        )
    end
end


moving_blocks.HYDROGEN_GENERATOR_POWER=400


minetest.register_node("moving_blocks:hydrogen_generator", {
    description = "Hydrogen Generator",
    tiles = {"moving_blocks_hydrogen_generator.png"},
    groups = {cracky = 2, moving_blocks = 1},
	
	
	on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("hydrogen", 1)

		hydrogen_check_fire_adjacent(pos, stack:get_count())

		return true
	end,

    on_construct = function(pos)
	
	    minetest.get_node_timer(pos):start(1)
	
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size("hydrogen", 1)
        meta:set_int("power", 0)
        --meta:set_float("fuel_end_time", 0)

        meta:set_string("infotext", "Generator: OFF")
        meta:set_string("formspec",
            "size[8,4]" ..
            "label[0,0;Hydrogen Generator]" ..
            "list[current_name;hydrogen;3.5,1;1,1;]" ..
            "list[current_player;main;0,2.5;8,4;]" ..
            "listring[current_name;hydrogen]" ..
            "listring[current_player;main]"
        )
		
		meta:set_string("infotext", "Hydrogen Generator : OFF")
		
		--local meta = minetest.get_meta(pos)
		--local inv = meta:get_inventory()

		--inv:set_size("hydrogen", 1)

		local stack = inv:get_stack("hydrogen", 1)

		if not stack:is_empty() then

			stack:take_item(1)
			inv:set_stack("hydrogen", 1, stack)

		end

		if stack:is_empty() then

			meta:set_int("power", 0)
			meta:set_string("infotext", "Hydrogen Generator : OFF")

		else

			meta:set_int("power", moving_blocks.HYDROGEN_GENERATOR_POWER)

			meta:set_string(
				"infotext",
				"Hydrogen Generator\nPower : "..moving_blocks.HYDROGEN_GENERATOR_POWER..
				"\nFuel : "..stack:get_count()
			)

		end
    end,
	
	on_destruct = function(pos)
        minetest.get_node_timer(pos):stop()
    end,
	
    can_dig = function(pos)
        local inv = minetest.get_meta(pos):get_inventory()
        return inv:is_empty("hydrogen")
    end,
	
	on_blast = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local nb = inv:get_stack("hydrogen", 1):get_count()

		hydrogen_explode(pos,nb)
		
	end,


    on_rightclick = function(pos)

        minetest.show_formspec(
            "",
            "moving_blocks:hydrogen_generator",
            minetest.get_meta(pos):get_string("formspec")
        )

    end,
	
	
	allow_metadata_inventory_put = function(pos, listname, index, stack)

		if listname ~= "hydrogen" then
			return 0
		end

		return stack:get_count()

	end,
	
	
	on_metadata_inventory_put = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local stack = inv:get_stack("hydrogen", 1)

		if stack:is_empty() then
			meta:set_int("power", 0)
			meta:set_string("infotext", "Hydrogen Generator : OFF")
		else
			meta:set_int("power", moving_blocks.HYDROGEN_GENERATOR_POWER)
			meta:set_string(
    		    "infotext",
		    	"Generator : "..moving_blocks.HYDROGEN_GENERATOR_POWER.." EU"
		        )
		end
	end,
	
	on_metadata_inventory_take = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local stack = inv:get_stack("hydrogen", 1)

		if stack:is_empty() then
			meta:set_int("power", 0)
			meta:set_string("infotext", "Hydrogen Generator : OFF")
		else
			meta:set_int("power", moving_blocks.HYDROGEN_GENERATOR_POWER)
			meta:set_string(
    		    "infotext",
		    	"Generator : "..moving_blocks.HYDROGEN_GENERATOR_POWER.." EU"
		        )
		end
	end,
	
	
	on_punch = function(pos, node, puncher, pointed_thing)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- item tenu par le joueur
		local item = puncher:get_wielded_item()
		
		--item du réservoir
		local fuel_stack = inv:get_stack("hydrogen", 1)
		
		local current = fuel_stack:get_count() --nombre d'hydrogène dans le réservoir
		local player_count = item:get_count()  --nombre d'hydrogène du joueur
		

		
		if item:get_name() == "" then -- si item vide
		    --vider le réservoir
			local stack = inv:get_stack("hydrogen", 1)
            local leftover = puncher:get_inventory():add_item("main", stack)

            inv:set_stack("hydrogen", 1, leftover)
			
			
		elseif  item:get_name()~="moving_blocks:hydrogen" then --si c'est autre que hydrogen
		    -- rien faire
			return
			
		else -- si c'est hydrogène
		    --remplir le réservoir
			local nb=500-current
			
			if nb>player_count then
				nb=player_count
			end

			local new_stack = ItemStack(item:get_name() .. " "..nb)
			local leftover = inv:add_item("hydrogen", new_stack)

			if leftover:is_empty() then
				item:take_item(nb)
				puncher:set_wielded_item(item)
			end
		end
		
		
		
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local stack = inv:get_stack("hydrogen", 1)

		if stack:is_empty() then
			meta:set_int("power", 0)
			meta:set_string("infotext", "Hydrogen Generator : OFF")
		else
			meta:set_int("power", moving_blocks.HYDROGEN_GENERATOR_POWER)
			meta:set_string(
    		    "infotext",
		    	"Generator : "..moving_blocks.HYDROGEN_GENERATOR_POWER.." EU"
		        )
		end

	end,
})


minetest.register_craft({
	output = "moving_blocks:hydrogen_generator",
	recipe = {
		{"moving_blocks:fer", "moving_blocks:fer", "moving_blocks:fer"},
		{"moving_blocks:fer", "moving_blocks:generator", "moving_blocks:fer"},
		{"moving_blocks:fer", "moving_blocks:fer",  "moving_blocks:fer"}
	}
})