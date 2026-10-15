minetest.register_craft({
	type = "cooking",
	output = "nanotech:carbonised_wool",
	recipe = "wool:white",
})

minetest.register_craft({
    output = 'nanotech:carbon_fibre',
	recipe = {
		{'nanotech:carbonised_wool', 'nanotech:carbonised_wool', 'nanotech:carbonised_wool'},
		{'nanotech:carbonised_wool', 'nanotech:drawplate', 'nanotech:carbonised_wool'},
		{'nanotech:carbonised_wool', 'nanotech:carbonised_wool', 'nanotech:carbonised_wool'},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_plate',
	recipe = {
		{'nanotech:carbon_fibre', 'nanotech:carbon_fibre', 'nanotech:carbon_fibre'},
		{'nanotech:carbon_fibre', 'nanotech:carbon_fibre', 'nanotech:carbon_fibre'},
		{'nanotech:carbon_fibre', 'nanotech:carbon_fibre', 'nanotech:carbon_fibre'},
	}
})
	
minetest.register_craft({
    output = 'nanotech:carbon_rod',
	recipe = {
		{'', 'nanotech:carbon_plate', ''},
		{'', 'nanotech:carbon_plate', ''},
		{'', 'nanotech:carbon_plate', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_pick',
	recipe = {
		{'nanotech:carbon_plate', 'nanotech:carbon_plate', 'nanotech:carbon_plate'},
		{'', 'nanotech:carbon_rod', ''},
		{'', 'nanotech:carbon_rod', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_axe',
	recipe = {
		{'nanotech:carbon_plate', 'nanotech:carbon_plate', ''},
		{'nanotech:carbon_plate', 'nanotech:carbon_rod', ''},
		{'', 'nanotech:carbon_rod', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_shovel',
	recipe = {
		{'', 'nanotech:carbon_plate', ''},
		{'', 'nanotech:carbon_rod', ''},
		{'', 'nanotech:carbon_rod', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_paxel',
	recipe = {
		{'nanotech:carbon_pick', 'nanotech:carbon_shovel', 'nanotech:carbon_axe'},
		{'', 'nanotech:carbon_rod', ''},
		{'', 'nanotech:carbon_rod', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_sword',
	recipe = {
		{'', 'nanotech:carbon_plate', ''},
		{'', 'nanotech:carbon_plate', ''},
		{'', 'nanotech:carbon_rod', ''},
	}
})

minetest.register_craft({
    output = 'nanotech:carbon_chest',
	recipe = {
		{'nanotech:carbon_plate', 'nanotech:carbon_plate', 'nanotech:carbon_plate'},
		{'nanotech:carbon_plate', 'default:chest', 'nanotech:carbon_plate'},
		{'nanotech:carbon_plate', 'nanotech:carbon_plate', 'nanotech:carbon_plate'},
	}
})

minetest.register_craft({
    output = 'nanotech:drawplate',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
	}
})
	
