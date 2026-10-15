minetest.register_craftitem("junk_items:pebble", {
	description = "Pebble",
	inventory_image = "pebble.png"
})

minetest.register_craftitem("junk_items:broken_stick", {
	description = "Broken Stick",
	inventory_image = "broken_stick.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "fuel",
	recipe = "junk_items:broken_stick",
	burntime = 1,
})

minetest.register_craftitem("junk_items:fish_skeleton", {
	description = "Fish Skeleton",
	inventory_image = "fish_skeleton.png"
})

minetest.register_craftitem("junk_items:flint_shard", {
	description = "Flint Shard",
	inventory_image = "flint_shard.png"
})