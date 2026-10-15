-- comod_areasbypass mod
-- Allows players with the 'comod_areasbypass' privilege to bypass Areas protections

-- Register the custom privilege
minetest.register_privilege("comod_areasbypass", {
	description = "Bypass Areas mod protections without giving full areas/admin privileges",
	give_to_singleplayer = false,
})

-- Save original canInteract function
local old_canInteract = areas.canInteract

-- Override canInteract to check our new priv
function areas:canInteract(pos, name)
	-- If the player has comod_areasbypass, allow bypass
	if minetest.check_player_privs(name, "comod_areasbypass") then
		return true
	end

	-- Otherwise, call the original Areas check
	return old_canInteract(self, pos, name)
end
