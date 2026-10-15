
minetest.after(0, function()
    -- Recipe: 1 steel block → 9 steel ingots
    minetest.register_craft({
        output = "default:steel_ingot 9",
        recipe = {
            {"default:steelblock"}
        }
    })
    
	minetest.register_craft({
		type = "cooking",
		output = "default:steel_ingot",
		recipe = "technic:wrought_iron_dust",
		cooktime = 9
	})

    minetest.register_craft({
		type = "cooking",
		output = "default:steel_ingot",
		recipe = "terumet:item_cryst_iron",
		cooktime = 8
	})
    -- Cobalt
	minetest.register_craft({
		output = "cobalto:LDCO 9",
		recipe = {
			{"cobalto:bloquecobalto"}
		}
	})

	-- Adamantite
	minetest.register_craft({
		output = "adamantita:LDAD 9",
		recipe = {
			{"adamantita:bloqueadamantita"}
		}
	})

	-- Titanium
	minetest.register_craft({
		output = "titanio:LDT 9",
		recipe = {
			{"titanio:bloquetitanio"}
		}
	})	

	-- Tugsten
	minetest.register_craft({
		output = "tugsteno:LDTO 9",
		recipe = {
			{"tugsteno:bloquetugsteno"}
		}
	})

	-- Clorofite
	minetest.register_craft({
		output = "clorofita:LDC 9",
		recipe = {
			{"clorofita:bloqueclorofita"}
		}
	})

	-- Abysmal
	minetest.register_craft({
		output = "abismal:LDA2 9",
		recipe = {
			{"abismal:bloqueabismal"}
		}
	})
        
        minetest.register_craft({
		output = "mobs:lava_orb 2",
		recipe = {
			{"bucket:bucket_lava","default:mese"}
		}
	})

        


end)




