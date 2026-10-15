--Adding groups
minetest.override_item("elepower_dynamics:battery", {
	groups = {battery = 1},
})

minetest.override_item("technic:battery", {
	groups = {battery = 1},
})

minetest.override_item("technic:coal_dust", {
	groups = {coal_dust = 1},
})

minetest.override_item("elepower_dynamics:coal_dust", {
	groups = {coal_dust = 1},
})

minetest.override_item("technic:cast_iron_ingot", {
	groups = {iron_ingot = 1},
})

minetest.override_item("elepower_dynamics:iron_ingot", {
	groups = {iron_ingot = 1},
})

minetest.override_item("technic:lead_dust", {
	groups = {lead_dust = 1},
})

minetest.override_item("elepower_dynamics:lead_dust", {
	groups = {lead_dust = 1},
})

minetest.override_item("technic:lead_ingot", {
	groups = {lead_ingot = 1},
})

minetest.override_item("elepower_dynamics:lead_ingot", {
	groups = {lead_ingot = 1},
})

minetest.override_item("technic:sawdust", {
	groups = {sawdust = 1},
})

minetest.override_item("elepower_dynamics:wood_dust", {
	groups = {sawdust = 1},
})

minetest.override_item("technic:sulfur_lump", {
	groups = {sulfur = 1},
})

minetest.override_item("technic:sulfur_dust", {
	groups = {sulfur = 1},
})

minetest.override_item("technic:zinc_dust", {
	groups = {zinc_dust = 1},
})

minetest.override_item("elepower_dynamics:zinc_dust", {
	groups = {zinc_dust = 1},
})

minetest.override_item("technic:zinc_ingot", {
	groups = {zinc_ingot = 1},
})

minetest.override_item("elepower_dynamics:zinc_ingot", {
	groups = {zinc_ingot = 1},
})

--Batteries
minetest.clear_craft({
	output = "elepower_dynamics:battery",
})

minetest.clear_craft({
	output = "technic:battery",
})

--Coal dust
minetest.clear_craft({
	type = "fuel",
	recipe = "technic:coal_dust",
	burntime = 50,
})

--iron lump
minetest.clear_craft({
	type   = "cooking",
	recipe = "default:iron_lump",
})

--Lead strip
minetest.clear_craft({
	output = "basic_materials:lead_strip",
})

--Sawdust
minetest.clear_craft({
	type = "fuel",
	recipe = "technic:sawdust",
	burntime = 6
})

--Wound coils
minetest.clear_craft({
	output = "elepower_dynamics:wound_copper_coil",
})

minetest.clear_craft({
	output = "elepower_dynamics:wound_silver_coil",
})

--[[Override function to clear the recipes for technic machines
(It may only work for the first recipe with that input name that
it finds, so we may need to add a better function that removes all the inputs instead.)]]
function clear_technic_recipe(recipe_type, recipe_input_name)
	minetest.after(0.1, function() --This has to be called with a delay for the table to load in.
	    technic.recipes[recipe_type]["recipes"][recipe_input_name] = nil
	end)
end

--[[This function accepts two parameters, the recipe type and
the name of the input of the recipe you want to clear
available recipe types:
    "grinding"
    "alloy"
    "extracting"
    "freezing"
    "separating" This one is for the centrifuge.
    "compressing"
    "cooking" This one is for the cooking recipes for the electric furnace but you should just be able to use the minetest.clear_craft to do it too.
The secound parameter is the name of the recipe you want to override. This is the item name of the item you
put into the machine i.e "default:silver_sandstone" which will clear the recipe that uses the silver sandstone as an input.
Example:
    clear_technic_recipe("grinding", "defualt:silver_sandstone") 
This will clear the grinding recipe that uses the "defualt:silver_sandstone" item as an input.
For alloy recipes this is different as you need to have the names of the inputs like this:
    clear_technic_recipe("alloy", "input1/input2")
Example:
    clear_technic_recipe("alloy", "technic:coal_dust/technic:raw_latex")
This will clear the alloy recipe with the inputs of technic:coal_dust and technic:raw_latex
]]

--[[New function that does what the above one does but for all inputs in the
given table name and not just the first one it finds.]]

--TO DO:This function needs to be tested.
function clear_technic_recipe_all_inputs(recipe_type, recipe_input_name)
    minetest.after(0.1, function()
        local recipe_table = technic.recipes[recipe_type]["recipes"]
        for key, recipe in pairs(recipe_table) do
            if recipe.input == recipe_input_name then
                recipe_table[key] = nil
            end
        end
    end)
end

--Ovverrides elepower machine recipes
function clear_elepower_recipe(craft_type, output_to_remove)
    minetest.after(0.5, function() --TO DO:Find out if this function will still work if we set it to run at 0.1 instead of 0.5 to prevent unwanted recipes from being used when a player first joins a world.
        local craft_table = elepm.craft[craft_type]
        local output_to_remove_itemstack = ItemStack(output_to_remove)
        for i = #craft_table, 1, -1 do
            -- Check if the output of the recipe at index i matches with output_to_remove
            local output_itemstack = ItemStack(craft_table[i].output)
            if output_itemstack:get_name() == output_to_remove_itemstack:get_name() and output_itemstack:get_count() == output_to_remove_itemstack:get_count() then
                -- Remove the recipe from the table
                table.remove(craft_table, i)
            end
        end
    end)
end



--[[
This function accepts two parameters, the recipe type and the output of the recipe you want to clear.
Recipe types:
    "compress"
    "grind" The grinding recipe for the depleted fuel rod will not work with this function because it has multiple outputs.
    "cooking" This one is for the cooking recipes for the electric furnace, but you should just be able to use the minetest.clear_craft to do it too.
    "can"
    "solder"
    "alloy"
The secound parameter is the output of the recipe that you want to use i.e
Example:
    clear_elepower_recipe("compress", "elepower_dynamics:zinc_plate 2")
This example function goes into the table compress and gets the first thing in the table with an index number of 1 and checks if it has
the specified output. If it does, it removes the item with that index number. If not, then it goes to the next item in the list and checks again.
This function doesn't clear recipes with multiple outputs because it only tests for one output.
]]

clear_elepower_recipe("compress", "default:desert_sandstone")

clear_elepower_recipe("grind", "default:desert_sand 4")

clear_elepower_recipe("grind", "default:gravel 4")

clear_elepower_recipe("compress", "default:sandstone")

clear_elepower_recipe("grind", "default:sand 4")

clear_elepower_recipe("compress", "default:silver_sandstone")

clear_elepower_recipe("grind", "default:silver_sand 4")
