function x_obsidianmese.place_path_ethereal(node, pos)
    if node.name == 'ethereal:dry_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_dry_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_dry_dirt' })
    elseif node.name == 'ethereal:cold_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_cold_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_cold_dirt' })
    elseif node.name == 'ethereal:bamboo_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_bamboo_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_bamboo_dirt' })
    elseif node.name == 'ethereal:gray_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_gray_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_gray_dirt' })
    elseif node.name == 'ethereal:fiery_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_fiery_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_fiery_dirt' })
    elseif node.name == 'ethereal:grove_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_grove_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_grove_dirt' })
    elseif node.name == 'ethereal:jungle_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_jungle_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_jungle_dirt' })
    elseif node.name == 'ethereal:crystal_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_crystal_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_crystal_dirt' })
    elseif node.name == 'ethereal:mushroom_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_mushroom_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_mushroom_dirt' })
    elseif node.name == 'ethereal:prairie_dirt'
        and node.name ~= 'x_obsidianmese:path_ethereal_prairie_dirt'
    then
        core.set_node(pos, { name = 'x_obsidianmese:path_ethereal_prairie_dirt' })
    end
end
