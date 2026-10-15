local ethereal_path_nodes = {
    {
        name = 'dry_dirt',
        descritption = 'Dried Dirt Path',
        drop = 'default:dry_dirt',
        tiles = {
            'x_obsidianmese_path_dry_dirt_base.png^(ethereal_dry_dirt.png^[mask:x_obsidianmese_path_overlay_2.png)',
            'x_obsidianmese_path_dry_dirt_base.png',
            'x_obsidianmese_dry_dirt_path_side.png'
        }
    },
    {
        name = 'cold_dirt',
        descritption = 'Cold Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_cold_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'bamboo_dirt',
        descritption = 'Bamboo Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_bamboo_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'gray_dirt',
        descritption = 'Gray Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_gray_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'fiery_dirt',
        descritption = 'Fiery Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_fiery_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'grove_dirt',
        descritption = 'Grove Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_grove_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'jungle_dirt',
        descritption = 'Jungle Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_jungle_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'crystal_dirt',
        descritption = 'Crystal Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_crystal_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'mushroom_dirt',
        descritption = 'Mushroom Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_mushroom_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    },
    {
        name = 'prairie_dirt',
        descritption = 'Prairie Dirt Path',
        tiles = {
            'x_obsidianmese_path_dirt_base.png^(ethereal_grass_prairie_top.png^[mask:x_obsidianmese_path_overlay.png)',
            'x_obsidianmese_path_dirt_base.png',
            'x_obsidianmese_dirt_path_side.png'
        }
    }
}

for i, def in ipairs(ethereal_path_nodes) do
    core.register_node('x_obsidianmese:path_ethereal_' .. def.name, {
        description = def.description,
        short_description = def.description,
        drawtype = 'nodebox',
        tiles = def.tiles,
        use_texture_alpha = 'clip',
        is_ground_content = false,
        paramtype = 'light',
        node_box = {
            type = 'fixed',
            fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
        },
        collision_box = {
            type = 'fixed',
            fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
        },
        selection_box = {
            type = 'fixed',
            fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
        },
        drop = def.drop or 'default:dirt',
        groups = { no_silktouch = 1, crumbly = 3, not_in_creative_inventory = 1 },
        sounds = default.node_sound_dirt_defaults()
    })
end
