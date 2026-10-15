futil.check_version({ year = 2022, month = 10, day = 24 })

inventory_ores = fmod.create()

inventory_ores.dofile("api")

if inventory_ores.has.unified_inventory then
	inventory_ores.dofile("unified_inventory")
end
