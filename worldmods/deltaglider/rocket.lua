local S = deltaglider.translator

-- Configuration
local rocket_cooldown = 0   -- seconds between rockets
local rocket_boost = 6      -- fixed speed boost per rocket

-- Register rocket item
minetest.register_craftitem("deltaglider:rocket", {
	description = S("Rocket (Use while gliding to boost delta glider speed.)"),
	inventory_image = "deltaglider_rocket.png",
	on_use = function(itemstack, player)
		local attach = player:get_attach()
		if not attach then
			return itemstack
		end

		local luaent = attach:get_luaentity()
		if not luaent or luaent.name ~= "deltaglider:hangglider" then
			return itemstack
		end

		-- Initialize rocket cooldown timer if missing
		luaent.rocket_timer = luaent.rocket_timer or rocket_cooldown

		-- Check cooldown
		if luaent.rocket_timer < rocket_cooldown then
			return itemstack
		end

		-- Apply fixed boost
		luaent.speed = luaent.speed + rocket_boost

		-- Reset cooldown timer
		luaent.rocket_timer = 0

		-- Add particles
		minetest.add_particlespawner({
			amount = 200,
			time = 2,
			minpos = { x = -0.05, y = -0.05, z = -0.05 },
			maxpos = { x = 0.05, y = 0.05, z = 0.05 },
			minexptime = 1,
			maxexptime = 2,
			attached = attach,
			texture = "deltaglider_rocket_particle.png",
		})

		-- Consume one rocket
		itemstack:take_item()
		return itemstack
	end
})

-- Globalstep to increase cooldown timers
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local attach = player:get_attach()
		if attach and attach:get_luaentity() and attach:get_luaentity().name == "deltaglider:hangglider" then
			local luaent = attach:get_luaentity()
			luaent.rocket_timer = (luaent.rocket_timer or rocket_cooldown) + dtime
		end
	end
end)

-- Manual mod compatibility for crafting
local gunpowder = nil
if core.get_modpath("mcl_mobitems") then    -- Mineclonia/Voxelibre or similar
	gunpowder = "mcl_mobitems:gunpowder" 
elseif core.get_modpath("default") then     -- default
	gunpowder = "tnt:gunpowder"
else
	gunpowder = xcompat.materials.coal_lump -- Backup solution
end

-- Crafting recipe
minetest.register_craft({
	output = "deltaglider:rocket 33",
	recipe = {
		{ "group:wood", gunpowder, "group:wood" },
		{ "group:wood", gunpowder, "group:wood" },
		{ "group:wood", gunpowder, "group:wood" },
	}
})
