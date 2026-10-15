local modname = minetest.get_current_modname()

local pvp_hud = {}
local FORMNAME = modname .. ":pvp"

-- =========================================================
-- PvP state
-- =========================================================

local function is_pvp_enabled(player)
    if not player or not player:is_player() then
        return true
    end

    local meta = player:get_meta()

    -- New players have PvP enabled by default.
    if meta:get_string("comod_pvp_enabled") == "" then
        meta:set_string("comod_pvp_enabled", "true")
        return true
    end

    return meta:get_string("comod_pvp_enabled") == "true"
end


local function set_pvp_enabled(player, enabled)
    if not player or not player:is_player() then
        return
    end

    player:get_meta():set_string(
        "comod_pvp_enabled",
        enabled and "true" or "false"
    )

    update_pvp_hud(player)
end


-- =========================================================
-- PvP HUD
-- =========================================================

function update_pvp_hud(player)
    if not player or not player:is_player() then
        return
    end

    local name = player:get_player_name()
    local enabled = is_pvp_enabled(player)

    local text
    local color

    if enabled then
        text = "PvP ENABLED"
        color = 0x55FF55
    else
        text = "PvP DISABLED"
        color = 0xFF5555
    end

    if not pvp_hud[name] then
        pvp_hud[name] = player:hud_add({
            hud_elem_type = "text",

            -- Top-right area, but moved far enough left
            -- so the whole text stays on screen.
            position = {
                x = 0.65,
                y = 0
            },

            offset = {
                x = 0,
                y = 20
            },

            -- Left aligned
            alignment = {
                x = 0,
                y = 0
            },

            text = text,

            number = color,

            size = {
                x = 1.0,
                y = 1.0
            },

            style = 1,

            z_index = 100
        })
    else
        player:hud_change(
            pvp_hud[name],
            "text",
            text
        )

        player:hud_change(
            pvp_hud[name],
            "number",
            color
        )

        player:hud_change(
            pvp_hud[name],
            "position",
            {
                x = 0.65,
                y = 0
            }
        )

        player:hud_change(
            pvp_hud[name],
            "offset",
            {
                x = 0,
                y = 20
            }
        )

        player:hud_change(
            pvp_hud[name],
            "alignment",
            {
                x = 0,
                y = 0
            }
        )

        player:hud_change(
            pvp_hud[name],
            "size",
            {
                x = 1.0,
                y = 1.0
            }
        )
    end
end


-- =========================================================
-- PvP GUI
-- =========================================================

local function show_pvp_formspec(player)
    if not player or not player:is_player() then
        return
    end

    local enabled = is_pvp_enabled(player)

    local status_text
    local status_color

    if enabled then
        status_text = "PvP is currently ENABLED"
        status_color = "#55FF55"
    else
        status_text = "PvP is currently DISABLED"
        status_color = "#FF5555"
    end

    local formspec =
        "formspec_version[6]" ..
        "size[8,4.8]" ..

        -- Title
        "hypertext[0.5,0.35;7,0.7;title;" ..
            "<center><b>PvP Settings</b></center>" ..
        "]" ..

        -- Current status
        "hypertext[0.5,1.15;7,0.7;status;" ..
            "<center><b>" ..
            minetest.formspec_escape(status_text) ..
            "</b></center>" ..
        "]" ..

        -- Description
        "hypertext[0.5,1.9;7,1.2;description;" ..
            "<center>" ..
            "PvP allows players to damage each other.<br>" ..
            "Turn PvP off if you do not want other players to damage you." ..
            "</center>" ..
        "]" ..

        -- Toggle button
        "button[2,3.25;4,0.75;toggle_pvp;" ..
            (enabled and "Disable PvP" or "Enable PvP") ..
        "]" ..

        -- Close
        "button_exit[2,4.15;4,0.5;close;Close]"

    minetest.show_formspec(
        player:get_player_name(),
        FORMNAME,
        formspec
    )
end


-- =========================================================
-- PvP warning
-- =========================================================

local function show_pvp_warning(player)
    if not player or not player:is_player() then
        return
    end

    local formspec =
        "formspec_version[6]" ..
        "size[8,3.8]" ..

        "hypertext[0.5,0.45;7,2.0;warning;" ..
            "<center>" ..
            "<b>Their PvP mode is disabled!</b><br>" ..
            "You cannot hit them.<br>" ..
            "They need to enable PvP." ..
            "</center>" ..
        "]" ..

        "button_exit[2,3.0;4,0.5;close;Close]"

    minetest.show_formspec(
        player:get_player_name(),
        FORMNAME .. "_warning",
        formspec
    )
end


-- =========================================================
-- Chat command
-- =========================================================

minetest.register_chatcommand("toggle_pvp", {
    description = "Open the PvP settings",

    func = function(name)
        local player = minetest.get_player_by_name(name)

        if not player then
            return false, "Player not found."
        end

        show_pvp_formspec(player)

        return true
    end
})


-- Short command
minetest.register_chatcommand("pvp", {
    description = "Open the PvP settings",

    func = function(name)
        local player = minetest.get_player_by_name(name)

        if not player then
            return false, "Player not found."
        end

        show_pvp_formspec(player)

        return true
    end
})


-- =========================================================
-- GUI buttons
-- =========================================================

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then
        return
    end

    if fields.toggle_pvp then
        local enabled = is_pvp_enabled(player)

        set_pvp_enabled(player, not enabled)

        -- Reopen with the new status
        show_pvp_formspec(player)
    end
end)


-- =========================================================
-- Prevent PvP damage when disabled
-- =========================================================

minetest.register_on_punchplayer(function(
    player,
    hitter,
    time_from_last_punch,
    tool_capabilities,
    dir,
    damage
)
    if not player or not player:is_player() then
        return
    end

    if not hitter or not hitter:is_player() then
        return
    end

    -- Attacker has PvP disabled
    if not is_pvp_enabled(hitter) then
        return true
    end

    -- Target has PvP disabled
    if not is_pvp_enabled(player) then
        show_pvp_warning(hitter)
        return true
    end

    -- Both players have PvP enabled
    return
end)


-- =========================================================
-- Player joined
-- =========================================================

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()

    if meta:get_string("comod_pvp_enabled") == "" then
        meta:set_string("comod_pvp_enabled", "true")
    end

    minetest.after(0.2, function()
        if player and player:is_player() then
            update_pvp_hud(player)
        end
    end)
end)


-- =========================================================
-- Player leaves
-- =========================================================

minetest.register_on_leaveplayer(function(player)
    if not player then
        return
    end

    local name = player:get_player_name()

    if pvp_hud[name] then
        pvp_hud[name] = nil
    end
end)