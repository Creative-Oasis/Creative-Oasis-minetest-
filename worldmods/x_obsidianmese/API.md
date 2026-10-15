# [Mod] X Obsidianmese [x_obsidianmese] API

## Types

`PathNodeDef`

```lua
-- node what should get support for path, e.g. `mymod:dirt_with_grass`
[key: string] = {
    -- name of the node what will be used to construct new path node, e.g. `dirt_with_grass`
    name: string
    -- mod name registering this path node, e.g. `mymod`
    mod_origin: string
    -- description for the node definition
    descritption: string
    -- short description for the node definition, will use descirption if not defined
    short_descritption?: string
    -- node to drop when the path node is dug, will drop `default:dirt` if not defined
    drop?: string
    -- tile definition, see minetest lua api for more details
    tiles: table
}
```

## Class `x_obsidianmese`

### Other mods can register new path nodes for the shovel.

Method

`register_path_node(self: x_obsidianmese, defs: PathNodeDef[]): void`

example

```lua
 x_obsidianmese:register_path_node({
    ['mymod:dirt_with_grass'] = {
        name = 'dirt_with_grass',
        mod_origin = 'mymod',
        descritption = 'Dirt with Grass Path',
        drop = 'mymod:dirt',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(mymod_grass_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    }
})
```

