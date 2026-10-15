-- Apply leaf behavior after all mods have loaded
minetest.register_on_mods_loaded(function()

	for name, def in pairs(minetest.registered_nodes) do
		if not def.groups then
			goto continue
		end

		local g = def.groups
		local is_leaf =
			   g.leaves
			or name:find("leaves")
			or name:find("leaf")
			or name:find("twig")
			or name:find("bush")

		if is_leaf then
			minetest.override_item(name, {
				walkable = false,               -- sink through leaves
				climbable = true,               -- climb like a ladder
				liquid_viscosity = 3,           -- slow movement
				fall_damage_add_percent = -50,  -- reduce fall damage
			})
		end

		::continue::
	end

end)
