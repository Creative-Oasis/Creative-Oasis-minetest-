minetest.register_node("comod_spikes:steel_spike", {
	description = "Steel Spikes",
	damage_per_second = 8,
    drawtype = "firelike",
	groups = {cracky=2},
	walkable = false,
	buildable_to = true,
    tiles = {"spikes_steel_spike.png"},
})

minetest.register_node("comod_spikes:wood_spike", {
	description = "Wood Spikes",
	damage_per_second = 5,
    drawtype = "firelike",
	groups = {choppy=3,flammable=3},
	walkable = false,
	buildable_to = true,
    tiles = {"spikes_wood_spike.png"},
})

minetest.register_node("comod_spikes:titanium_spike", {
	description = "Titanium Spikes",
	damage_per_second = 10,
    drawtype = "firelike",
	groups = {cracky=2},
	walkable = false,
	buildable_to = true,
    tiles = {"spikes_titanium_spike.png"},
})
