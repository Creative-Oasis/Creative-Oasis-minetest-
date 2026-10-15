--[[
    Raw Ore Blocks — adds block form of metal lumps to Minetest
    Copyright © 2022, Silver Sandstone <@SilverSandstone@craftodon.social>

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
]]


local S = lumpblocks.S;


local get_sounds;
if minetest.get_modpath('default') then
    get_sounds = default.node_sound_metal_defaults or default.node_sound_stone_defaults;
elseif minetest.get_modpath('mcl_sounds') then
    get_sounds = mcl_sounds.node_sounds_metal_defaults;
elseif minetest.get_modpath('rp_sounds') then
    get_sounds = rp_sounds.node_sound_defaults;
end;

if not get_sounds then
    function get_sounds(sounds)
        return sounds or {};
    end;
end;


local function update(tbl, ...)
    for __, updates in ipairs{...} do
        for k, v in pairs(updates) do
             tbl[k] = v;
        end;
    end;
    return tbl;
end;


function lumpblocks.register_lump_block(options)
    --[[
        lumpblocks.register_lump_block{base_name: string, lump_name: string, <options>} -> string or nil

        Options:
            name: string
                Overrides the name of the node.

            texture: string
                Provides a custom texture.

            dark_colour: ColourSpec (alias: colour)
                The darker (or only) colour of the texture.

            light_colour: ColourSpec
                The lighter colour of the texture.

            colours: {ColourSpec, ColourSpec}
                A shortcut for dark_colour and light_colour.

            description: string
                Overrides the description of the node.

            def: table
                Anything in this table will be added to the definition.

            groups: table
                Defines node group values, overriding the defaults.

        Registers a block variant of the specified lump item. At least
        one of `colour`, `dark_colour`, or `texture` must be specified.

        Returns the node name on success, or nil on failure.
    ]]

    local base_name;
    local lump_name;
    local name;
    local texture;
    local dark_colour;
    local light_colour;
    local description;
    local def = {};
    local groups = {};
    for key, value in pairs(options) do
        if key == 'base_name' or key == 1 then
            base_name = value;
        elseif key == 'lump' or key == 2 then
            lump_name = value;
        elseif key == 'name' then
            name = value;
        elseif key == 'texture' then
            texture = value;
        elseif key == 'dark_colour' or key == 'colour' then
            dark_colour = value;
        elseif key == 'light_colour' then
            light_colour = value;
        elseif key == 'colours' then
            dark_colour, light_colour = unpack(value);
        elseif key == 'description' then
            description = value;
        elseif key == 'def' then
            def = table.copy(value);
        elseif key == 'groups' then
            groups = value;
        else
            minetest.log('error', ('Invalid key [%q] in lumpblocks.register_lump_block().'):format(key));
        end;
    end;

    assert(lump_name,              'No lump name specified!');
    assert(base_name,              'No base name specified!');
    assert(texture or dark_colour, 'No texture or colour specified!');

    local lump_def = minetest.registered_items[lump_name];
    if not lump_def then
        return nil;
    end;

    name = name or ('lumpblocks:%s_block'):format(base_name);

    def.description         = description or S('@1 Block', lump_def.description);
    def.groups              = update({cracky = 3, lump_block = 1}, def.groups or {}, groups);
    def.tiles               = {texture or lumpblocks.generate_lumpblock_texture(dark_colour, light_colour)};
    def.sounds              = update(get_sounds(), def.groups or {});
    def._doc_items_longdesc = S('A compressed block form of @1 for decoration or efficient storage.', lump_def.description);
    minetest.register_node(name, def);

    -- Crafting recipes:
    minetest.register_craft(
    {
        output = name;
        recipe =
        {
            {lump_name, lump_name, lump_name},
            {lump_name, lump_name, lump_name},
            {lump_name, lump_name, lump_name},
        };
    });

    minetest.register_craft(
    {
        type   = 'shapeless';
        output = lump_name .. ' 9';
        recipe = {name};
    });

    if minetest.get_modpath('rp_crafting') then
        crafting.register_craft(
        {
            output = name;
            items  = {lump_name .. ' 9'};
        });

        crafting.register_craft(
        {
            output = lump_name .. ' 9';
            items  = {name};
        });
    end;

    return name;
end;


function lumpblocks.generate_lumpblock_texture(dark_colour, light_colour)
    --[[
        lumpblocks.generate_lumpblock_texture(dark_colour: ColourSpec, light_colour: ColourSpec) -> string

        Generates a raw ore block texture in the specified colour.
    ]]

    assert(dark_colour, 'No colour specified!');
    if light_colour then
        -- New colouring system:
        dark_colour  = minetest.colorspec_to_colorstring(dark_colour);
        light_colour = minetest.colorspec_to_colorstring(light_colour);
        local mask = 'lumpblocks_lump_block_mask.png';
        return ('(%s^[multiply:#00000000^[invert:a^[colorize:%s:255)^(%s^[multiply:%s)'):format(mask, dark_colour, mask, light_colour);
    else
        -- Old colouring system:
        local colour = minetest.colorspec_to_colorstring(dark_colour);
        local inverted = lumpblocks.invert_colour(colour);
        local base = 'lumpblocks_lump_block.png';
        return ('((%s^[invert:rgb)^[multiply:%s^[invert:rgb)^(%s^[multiply:%s^[opacity:127)'):format(base, inverted, base, colour);
    end;
end;


function lumpblocks.invert_colour(colour)
    --[[
        lumpblocks.invert_colour(colour: ColourSpec) -> string

        Inverts a colour in RGB space.
    ]]

    local bytes = minetest.colorspec_to_bytes(colour);
    local values = {nil, nil, nil, bytes:byte(4)};
    for index = 1, 3 do
        values[index] = 255 - bytes:byte(index);
    end;
    return ('#%02X%02X%02X%02X'):format(unpack(values));
end;
