# comod_anim

Updated for Luanti 5.17 + Minetest Game.

- Sneak pose no longer leans the torso backward; torso stays nearly neutral and legs bend.
- Head keeps vertical look tracking and adds left/right yaw wave, slight roll, and a small bob while moving.
- Sprint uses a forward lean and faster limb swing.
- Walk and stand use the stock MTG player_api animation ranges.
- Sneak camera lowers smoothly; FOV is not changed.

Install by replacing the old `comod_anim` folder with this one and restarting the world/server.

This mod uses MTG's existing `character.b3d` and Lua bone overrides; it does not include baked new B3D animation tracks. The standard MTG bone names are assumed. Other mods that override the same bones or head may conflict.
