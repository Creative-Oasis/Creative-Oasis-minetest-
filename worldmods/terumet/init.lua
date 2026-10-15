--[[ Terumet v3.3
Mod for Minetest (https://www.minetest.net/)
Creates ores, alloys, tools, and heat-powered machines.
Updated to fix pickaxe digging issues.
]]--

terumet = {}
terumet.version = {major=3, minor=3, patch=0}
terumet.mod_name = minetest.get_current_modname()

-- load global functions
dofile(minetest.get_modpath(terumet.mod_name) .. '/global.lua')(terumet)

-- legacy check
terumet.legacy = minetest.get_version().string:find('0.4')
if terumet.legacy then
    minetest.log('[terumet] MTv0.4.* detected - in legacy mode!')
end

local FMT = string.format

-- helper functions
function terumet.blast_chance(pct, id)
    return function(pos)
        if terumet.chance(pct) then
            minetest.remove_node(pos)
            return {id}
        else
            return nil
        end
    end
end

function terumet.format_time(t)
    return string.format('%.1f s', t or 0)
end

function terumet.create_lit_node_groups(unlit_groups)
    local new_groups = {not_in_creative_inventory=1}
    for k,v in pairs(unlit_groups) do new_groups[k] = v end
    return new_groups
end

function terumet.description(name, xinfo)
    if xinfo then
        return string.format("%s\n%s", name, minetest.colorize(terumet.options.misc.TIP_COLOR, xinfo))
    else
        return name
    end
end

function terumet.crystal_tex(color)
    return string.format('%s^[multiply:%s', terumet.tex('item_cryst'), color)
end

function terumet.tex_trans(id, rot)
    return terumet.tex(id) .. '^[transform' .. rot
end

local HEAR_DIST = 12
terumet.squishy_node_sounds = {
    footstep = {name='terumet_squish_step', max_hear_distance=HEAR_DIST},
    dig = {name='terumet_squish_dig', max_hear_distance=HEAR_DIST},
    dug = {name='terumet_squish_dug', max_hear_distance=HEAR_DIST},
    place = {name='terumet_squish_place', max_hear_distance=HEAR_DIST},
}

-- load modules
terumet.do_lua_file('settings')
terumet.do_lua_file('interop/terumet_api')
terumet.do_lua_file('options')
terumet.do_lua_file('machine/generic/machine')
terumet.do_lua_file('material/raw')
terumet.do_lua_file('material/reg_alloy')
terumet.do_lua_file('material/upgrade')
terumet.do_lua_file('material/entropy')

-- item info chat command
if terumet.options.misc.ITEM_INFO_CHATCOMMAND then
    minetest.register_chatcommand('item_info', {
        params = '',
        description = 'Get a complete description of the ItemStack in your hand',
        privs = {debug=true},
        func = function(name)
            local player = minetest.get_player_by_name(name)
            if player then
                local witem = player:get_wielded_item()
                if witem:is_empty() then
                    return true, "You're not holding anything."
                else
                    local def = witem:get_definition()
                    local wear = witem:get_wear()
                    local wear_pct = FMT('%.1f%%', wear / 65535 * 100.0)
                    if def then
                        local grpsText = ''
                        for grp,gval in pairs(def.groups) do
                            local grpt = FMT('%s=%s', grp, gval)
                            if #grpsText > 0 then
                                grpsText = grpsText..', '..grpt
                            else
                                grpsText = grpt
                            end
                        end
                        return true, FMT('%s "%s" #%s/%s w:%s (%s) gs:%s',
                            minetest.colorize('#ff0', witem:get_name()),
                            def.description,
                            witem:get_count(),
                            minetest.colorize('#0ff', def.stack_max),
                            minetest.colorize('#f0f', wear),
                            minetest.colorize('#f0f', wear_pct),
                            minetest.colorize('#aaa', grpsText)
                        )
                    else
                        return true, FMT('*NO DEF* %s #%s w:%s (%s)',
                            minetest.colorize('#ff0', witem:get_name()),
                            witem:get_count(),
                            minetest.colorize('#f0f', wear),
                            minetest.colorize('#f0f', wear_pct)
                        )
                    end
                end
            else
                return false, "You aren't a player somehow, sorry?!"
            end
        end
    })
end

-- register alloys
terumet.reg_alloy('Terucopper', 'tcop', 1, 20)
terumet.reg_alloy('Terutin', 'ttin', 1, 15)
terumet.reg_alloy('Terusteel', 'tste', 2, 40)
terumet.reg_alloy('Terugold', 'tgol', 3, 80)
terumet.reg_alloy('Coreglass', 'cgls', 4, 120)
terumet.reg_alloy('Teruchalcum', 'tcha', 2, 60)

-- more materials
terumet.do_lua_file('material/ceramic')
terumet.do_lua_file('material/thermese')
terumet.do_lua_file('material/coil')
terumet.do_lua_file('material/crushed')
terumet.do_lua_file('material/pwood')
terumet.do_lua_file('material/tglass')
terumet.do_lua_file('material/rebar')
terumet.do_lua_file('material/misc')
terumet.do_lua_file('material/crystallized')
terumet.do_lua_file('material/battery')

local id = terumet.id

-- raw terumetal repair material
terumet.register_repair_material(id('ingot_raw'), 10)

-- tools
terumet.do_lua_file('tool/reg_tools')
local sword_opts = terumet.options.tools.sword_damage

-- Fixed pickaxes (maxlevel increased for stone/ores)
terumet.reg_tools('Pure Terumetal', 'raw', id('ingot_raw'), {2.0, 1.2, 0.8}, 10, 3, sword_opts.TERUMETAL, 10)
terumet.reg_tools('Terucopper', 'tcop', id('ingot_tcop'), {3.2, 1.4, 0.8}, 40, 3, sword_opts.COPPER_ALLOY, 20)
terumet.reg_tools('Terusteel', 'tste', id('ingot_tste'), {2.9, 1.3, 0.7}, 50, 3, sword_opts.IRON_ALLOY, 40)
terumet.reg_tools('Terugold', 'tgol', id('ingot_tgol'), {2.7, 1.2, 0.63}, 60, 4, sword_opts.GOLD_ALLOY, 80)
terumet.reg_tools('Coreglass', 'cgls', id('ingot_cgls'), {2.5, 1.2, 0.7}, 75, 4, sword_opts.COREGLASS, 120)
terumet.reg_tools('Teruchalcum', 'tcha', id('ingot_tcha'), {1.8, 0.7, 0.45}, 90, 3, sword_opts.BRONZE_ALLOY, 60)

-- ore saw
terumet.do_lua_file('tool/ore_saw')

-- mesecon interop
if minetest.get_modpath('mesecons') then
    terumet.do_lua_file('interop/mesecons')
end

-- machines
terumet.do_lua_file('machine/heater/furnace_htr')
terumet.do_lua_file('machine/heater/solar_htr')
terumet.do_lua_file('machine/heater/entropic_htr')
terumet.do_lua_file('machine/asmelt')
terumet.do_lua_file('machine/htfurnace')
terumet.do_lua_file('machine/vulcan')
terumet.do_lua_file('machine/lavam')
terumet.do_lua_file('machine/meseg')
terumet.do_lua_file('machine/repm')
terumet.do_lua_file('machine/crusher')
terumet.do_lua_file('machine/vacoven')

-- transfer machines
terumet.do_lua_file('machine/transfer/heatray')
terumet.do_lua_file('machine/transfer/hline')
terumet.do_lua_file('machine/transfer/hline_in')
terumet.do_lua_file('machine/transfer/thermobox')
terumet.do_lua_file('machine/transfer/thermdist')

-- convertible blocks
local blocks = {
    'default:stone','default:cobble','default:stonebrick','default:stone_block',
    'default:desert_stone','default:desert_cobble','default:desert_stonebrick',
    'default:wood','default:junglewood','default:pine_wood','default:acacia_wood','default:aspen_wood',
    'terumet:block_pwood'
}
for _,b in ipairs(blocks) do
    terumet.register_convertible_block(b, b:match(":(.+)"))
end

-- repairable default tools
local dmv_values = {
    steel={10, 'default:steel_ingot'},
    bronze={30, 'default:bronze_ingot'},
    mese={90, 'default:mese_crystal'},
    diamond={100, 'default:diamond'}
}
for dmat,v in pairs(dmv_values) do
    terumet.register_repairable_item("default:pick_"..dmat, v[1]*3)
    terumet.register_repairable_item("default:axe_"..dmat, v[1]*3)
    terumet.register_repairable_item("default:shovel_"..dmat, v[1])
    terumet.register_repairable_item("default:sword_"..dmat, v[1]*2)
    terumet.register_repair_material(v[2], v[1])
end

-- more materials
terumet.do_lua_file('material/concrete')
terumet.do_lua_file('material/coalproc')

-- optional interops
local INTEROPS = {'3d_armor', 'doors', 'unified_inventory', 'tubelib', 'dungeon_loot', 'moreores', 'farming', 'extra'}
for _,mod in ipairs(INTEROPS) do
    if minetest.get_modpath(mod) then terumet.do_lua_file('interop/'..mod) end
end

if terumet.settings.moreblocks_integration then
    terumet.do_lua_file('interop/moreblocks')
end

local vacfood_options = terumet.options.vac_oven.VAC_FOOD
if vacfood_options and vacfood_options.ACTIVE then terumet.do_lua_file('material/vacfood') end
terumet.do_lua_file('interop/crusher_misc')

-------------------
-- Slow all Terumet machines to 0.5× speed
-------------------
local TERU_MULT = 0.5

-- Furnace machines
if terumet.options.furnace and terumet.options.furnace.TIME_MULT then
    terumet.options.furnace.TIME_MULT = terumet.options.furnace.TIME_MULT * TERU_MULT
end

-- Generic machine options (if used)
if terumet.options.machine and terumet.options.machine.TIME_MULT then
    terumet.options.machine.TIME_MULT = terumet.options.machine.TIME_MULT * TERU_MULT
end
