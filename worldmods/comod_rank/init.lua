-- =========================
-- Privilege
-- =========================
minetest.register_privilege("comod_trusted", {
    description = "Trusted player status",
    give_to_singleplayer = false,
})

local DEFAULT_RANK  = "Player"
local DEFAULT_COLOR = "#ADFF2F"

-- =========================
-- Rank reader (Idle-safe)
-- =========================
local function get_staffrank(name)
    local player = minetest.get_player_by_name(name)
    if not player then
        return DEFAULT_RANK, DEFAULT_COLOR
    end

    local meta = player:get_meta()
    local rank  = meta:get_string("staffranks:rank_prefix")
    local color = meta:get_string("staffranks:rank_color")

    -- Ignore AFK Idle rank
    if rank == "Idle" then
        local r = meta:get_string("staffranks:afk_original_rank")
        local c = meta:get_string("staffranks:afk_original_color")
        if r ~= "" then
            rank  = r
            color = c
        end
    end

    if rank == "" or rank == "None" then
        rank  = DEFAULT_RANK
        color = DEFAULT_COLOR
    end

    return rank, color
end

-- =========================
-- Status
-- =========================
local function get_status(name)
    local privs = minetest.get_player_privs(name)
    return privs.comod_trusted and "Trusted" or "Regular"
end

-- =========================
-- Stats helpers
-- =========================
local function get_stats(name)
    local player = minetest.get_player_by_name(name)
    if not player then
        return 0, 0
    end
    local meta = player:get_meta()
    return meta:get_int("kills"), meta:get_int("deaths")
end

local function get_kd(k, d)
    if d == 0 then
        return string.format("%.1f", k)
    end
    return string.format("%.1f", k / d)
end

-- =========================
-- PvP kill counter ONLY
-- =========================
minetest.register_on_dieplayer(function(victim, reason)
    if not reason or reason.type ~= "punch" then return end
    if not reason.object or not reason.object:is_player() then return end

    local killer = reason.object
    if killer:get_player_name() == victim:get_player_name() then return end

    local vmeta = victim:get_meta()
    local kmeta = killer:get_meta()

    vmeta:set_int("deaths", vmeta:get_int("deaths") + 1)
    kmeta:set_int("kills",  kmeta:get_int("kills")  + 1)
end)

-- =========================
-- Rank display
-- =========================
local function show_rank(viewer, target)
    -- If no target given, show self
    if target == "" or not target then
        target = viewer
    end

    if not minetest.player_exists(target) then
        minetest.chat_send_player(viewer, "Player does not exist.")
        return
    end

    local rank, rank_color = get_staffrank(target)
    local status = get_status(target)
    local kills, deaths = get_stats(target)
    local kd = get_kd(kills, deaths)

    minetest.chat_send_player(viewer,
        minetest.colorize("pink", "----" .. target .. "----"))
    minetest.chat_send_player(viewer,
        minetest.colorize("grey", ">Rank: ") ..
        minetest.colorize(rank_color, rank))
    minetest.chat_send_player(viewer,
        minetest.colorize("grey", ">Status: " .. status))
    minetest.chat_send_player(viewer,
        minetest.colorize("grey", ">Players killed: " .. kills))
    minetest.chat_send_player(viewer,
        minetest.colorize("grey", ">Be murdered: " .. deaths))
    minetest.chat_send_player(viewer,
        minetest.colorize("grey", ">K/D rate: " .. kd))
end


-- =========================
-- Commands
-- =========================
minetest.register_chatcommand("rank", {
    params = "<name>",
    description = "Show player rank and PvP stats",
    func = function(name, param)
        show_rank(name, param)
    end,
})

minetest.register_chatcommand("r", {
    params = "<name>",
    description = "Alias for /rank",
    func = function(name, param)
        show_rank(name, param)
    end,
})
