Minetest mod: `adaptation_modpack`
==================================

This modpack can be used by other mods which wants to be adapted to more than one minetest game.
Main mod is `adaptation_lib`, which define adaptation API. See API.md for details.
Other mods primary add items to a database grouped by generic keys.

So, you can use provided API functions to easier finding aviable items, which you need to use by the key.

Example of get informations about carbon steel if aviable and normal steel if carbon steel is not aviable:

    metal_ingot = adaptation_lib.get_item({"ingot_carbon_steel", "ingot_steel"}) 

Source code:
-----------------------
Copyright (c) 2022 SFENCE
MIT - check LICENSE file

How to use:
-----------------------

Add `adaptation_lib` and other `adaptation_*` mods to your mod dependence list. Use `adaptation_lib` functions to translate keys to item data.

