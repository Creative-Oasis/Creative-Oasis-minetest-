-- -- -- -- -- -- -- --
-- Normal Flameball with Protection
-- -- -- -- -- -- -- --

-- Helper function to safely set a node respecting protection
local function safe_set_node(pos, player, node_name)
    if player and not minetest.is_protected(pos, player:get_player_name()) then
        minetest.set_node(pos, {name=node_name})
    end
end

minetest.register_entity("even_mosword:flameball", {
    visual = "mesh",
    visual_size = {x=5, y=5},
    mesh = "mosword_ball.x",
    textures = {"default_lava.png"},
    velocity = 8,
    light_source = 2,

    owner = nil, -- store player who fired

    on_step = function(self, dtime)
        local pos = self.object:getpos()
        if minetest.get_node(pos).name ~= "air" then
            self:hit_node(pos)
            self.object:remove()
            return
        end
        pos.y = pos.y - 1
        for _,player in pairs(minetest.get_objects_inside_radius(pos, 1)) do
            if player:is_player() then
                self:hit_player(player)
                self.object:remove()
                return
            end
        end
    end,

    hit_player = function(self, player)
        local s = player:getpos()
        local p = player:get_look_dir()
        local vec = {x = s.x - p.x, y = s.y - p.y, z = s.z - p.z}
        player:punch(self.object, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = {fleshy = 4},
        }, vec)

        local pos = player:getpos()
        for dx = 0,1 do
            for dy = 0,1 do
                for dz = 0,1 do
                    local p = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                    local n = minetest.get_node(p).name
                    if n == "air" then
                        safe_set_node(p, self.owner, "fire:basic_flame")
                    end
                end
            end
        end
    end,

    hit_node = function(self, pos)
        for dx = -1,1 do
            for dy = -2,1 do
                for dz = -1,1 do
                    local p = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                    local n = minetest.get_node(p).name
                    if n == "air" then
                        safe_set_node(p, self.owner, "fire:basic_flame")
                    end
                end
            end
        end
    end,
})

-- Flame Sword Tool
minetest.register_tool("even_mosword:flame_sword", {
    description = "Flame Sword",
    inventory_image = "mosword_flame_sword.png",
    light_source = 2,

    on_use = function(itemstack, placer, pointed_thing)
        local dir = placer:get_look_dir()
        local playerpos = placer:getpos()
        local obj = minetest.add_entity(
            {x = playerpos.x + dir.x, y = playerpos.y + 2 + dir.y, z = playerpos.z + dir.z},
            "even_mosword:flameball"
        )
        if obj then
            obj:get_luaentity().owner = placer -- store player for protection
            local vec = {x = dir.x * 3, y = dir.y * 3, z = dir.z * 3}
            obj:setvelocity(vec)
        end
        return itemstack
    end,
})

-- Crafting recipe
--minetest.register_craft({
    --output = "even_mosword:flame_sword",
    --recipe = {
        --{'', 'bucket:bucket_lava', ''},
        --{'', 'bucket:bucket_lava', ''},
        --{'', 'default:obsidian_shard', ''},
    --}
--})
