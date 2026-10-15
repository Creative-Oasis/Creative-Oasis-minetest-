-- PB&J Pup / Nyan Cat / MooGNU Mod (Luanti-safe, underground 15% spawn)

local def = core.get_modpath("default")
local mcl = core.get_modpath("mcl_core")
local snd = mcl and mcl_sounds.node_sound_glass_defaults() or default.node_sound_glass_defaults()

-- Helper function to register glowing fun nodes
local function register_fun_node(name, desc, tiles)
    core.register_node(name, {
        description = desc,
        tiles = tiles,
        paramtype = "light",
        light_source = 15,
        paramtype2 = "facedir",
        groups = {cracky = 2, handy = 1},
        is_ground_content = false,
        sounds = snd,
        _mcl_hardness = 1,
    })
end

-- Register nodes (all prefixed with pbj_pup)
register_fun_node("pbj_pup:pbj_pup", "PB&J Pup", {
    "pbj_pup_sides.png", "pbj_pup_jelly.png", "pbj_pup_sides.png",
    "pbj_pup_sides.png", "pbj_pup_back.png", "pbj_pup_front.png"
})

register_fun_node("pbj_pup:nyancat", "Nyan Cat", {
    "nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
    "nyancat_side.png", "nyancat_back.png", "nyancat_front.png"
})

register_fun_node("pbj_pup:moognu", "MooGNU", {
    "moognu_side.png", "moognu_side.png", "moognu_side.png",
    "moognu_side.png", "moognu_back.png", "moognu_front.png"
})

register_fun_node("pbj_pup:nyancat_rainbow", "Rainbow", {
    "nyancat_rainbow.png^[transformR90",
    "nyancat_rainbow.png^[transformR90",
    "nyancat_rainbow.png"
})

-- Fuel recipes
for _, node in ipairs({
    "pbj_pup:pbj_pup",
    "pbj_pup:nyancat",
    "pbj_pup:moognu",
    "pbj_pup:nyancat_rainbow"
}) do
    core.register_craft({
        type = "fuel",
        recipe = node,
        burntime = 10
    })
end

-- Helper function to place head + rainbow tail
local types = {"pbj_pup:pbj_pup", "pbj_pup:nyancat", "pbj_pup:moognu"}

local function place(pos, facedir, length)
    if facedir > 3 then facedir = 0 end
    local tailvec = core.facedir_to_dir(facedir)
    local p = {x = pos.x, y = pos.y, z = pos.z}
    local num = math.random(#types)
    core.swap_node(p, {name = types[num], param2 = facedir})

    for i = 1, length do
        p.x = p.x + tailvec.x
        p.z = p.z + tailvec.z
        core.swap_node(p, {name = "pbj_pup:nyancat_rainbow", param2 = facedir})
    end
end

-- Cave generation: underground spawn with 15% chance
if core.settings:get_bool("pbj_pup_generate") ~= false then
    local function spawn_in_cave(minp, maxp, seed)
        local pr = PseudoRandom(seed + 9324342)
        local tries = 1 -- attempts per chunk

        -- y-range underground
        local y_min = math.max(minp.y, -30000)
        local y_max = math.min(maxp.y, -25)

        if y_max < y_min then
            return -- skip invalid chunk
        end

        for i = 1, tries do
            local x = pr:next(minp.x, maxp.x)
            local y = pr:next(y_min, y_max)
            local z = pr:next(minp.z, maxp.z)
            local pos = {x=x, y=y, z=z}

            if core.get_node(pos).name == "air" then
                -- check if space is big enough
                local air_count = 0
                for dx=-1,1 do
                    for dy=-1,1 do
                        for dz=-1,1 do
                            if core.get_node({x=x+dx, y=y+dy, z=z+dz}).name == "air" then
                                air_count = air_count + 1
                            end
                        end
                    end
                end

                -- spawn with 15% chance
                if air_count >= 10 and pr:next(1,180) <= 15 then
                    local facedir = pr:next(0,3)
                    place(pos, facedir, pr:next(3,10))
                end
            end
        end
    end

    core.register_on_generated(spawn_in_cave)
end

-- Legacy aliases (old names -> pbj_pup)
core.register_alias("default:nyancat", "pbj_pup:nyancat")
core.register_alias("default:nyancat_rainbow", "pbj_pup:nyancat_rainbow")
core.register_alias("pbj_pup:pbj_pup_candies", "pbj_pup:nyancat_rainbow")

if def then default.make_nyancat = place end

print("[MOD] PB&J Pup / Nyan Cat / MooGNU loaded")
