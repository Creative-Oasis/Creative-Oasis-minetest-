Alien_Material adds new Alien Blocks! For all Alien Fans is the Mod well suited.

# Dependencies

### Depends

- default

### Optional Depends

- 3d_armor: Adding Alien Armor
- mobs: Adding Alien
- stamina: Adjusts the alien hearts to the correct height
- farming: Add a recipe for the Alien Bread
- stairs: Add Stairs for the Alien Bricks

# Alienbench

You are able to craft following things with Alienbench:

- Apple + Alien Ingot --> Alien Apple
- Bread + Alien Ingot --> Alien Bread (8x)

# Aliens

If you have activated [Mobs-Api](https://content.minetest.net/packages/TenPlus1/mobs/), Aliens exists. Aliens are strong entities. They drop Alienmese and Alienapples, so they are a faster source then searching it in mines. They are spawning below -4096. Alien like Alienblocks on y>=150 and y<=1000. They are spawning there in nights.

# License

### Code by Mooncarguy (MIT), TalkLounge:

- alienbench.lua
- alientable.lua

### Models by Zeg9 (CC BY-SA 3.0):

- models/alien.x

### Textures by Bambusmann (CC BY-SA 3.0):

- textures/alien.png
- textures/alien_apple.png
- textures/alien_axe.png
- textures/alien_bread.png
- textures/alien_brick_1.png
- textures/alien_brick_2.png
- textures/alien_diamond_block.png
- textures/alien_ingot.png
- textures/alien_ingot_bg.png
- textures/alien_mese.png
- textures/alien_mese_block.png
- textures/alien_mese_fragment.png
- textures/alien_multitool.png
- textures/alien_pickaxe.png
- textures/alien_post_light_side.png
- textures/alien_potion.png
- textures/alien_sand.png
- textures/alien_spade.png
- textures/alien_sword.png
- textures/armor_boots_alien.png
- textures/armor_boots_alien_preview.png
- textures/armor_chestplate_alien.png
- textures/armor_chestplate_alien_preview.png
- textures/armor_helmet_alien.png
- textures/armor_helmet_alien_preview.png
- textures/armor_inv_boots_alien.png
- textures/armor_inv_chestplate_alien.png
- textures/armor_inv_helmet_alien.png
- textures/armor_inv_leggings_alien.png
- textures/armor_inv_shield_alien.png
- textures/armor_leggings_alien.png
- textures/armor_leggings_alien_preview.png
- textures/armor_shield_alien.png
- textures/armor_shield_alien_preview.png

### Textures by debiankaios (CC BY-SA 3.0):

- textures/alienbench.png
- textures/alienbench_on.png
- textures/alienbench_side.png
- textures/alienbench_y.png
- textures/alien_block.png
- textures/alien_diamond_ore.png
- textures/alien_heart.png
- textures/alien_mese_ore.png

### Code License

Copyright (C) 2020-2024 debiankaios

#### Code

Licensed under the GNU GPL version 3 or later. See LICENSE.txt

#### Textures

CC BY-SA 3.0 See COPYING.txt at "License of media (textures, sounds and documentation)"

# Api

### Callbacks

`alien_material.register_on_player_alienhpchange(function(player, hp_change, reason), modifier)`

Same as minetest.register_on_player_hpchange(function(player, hp_change, reason), modifier) but for alienhp. You can't return a second argument stoping the execution right now.
