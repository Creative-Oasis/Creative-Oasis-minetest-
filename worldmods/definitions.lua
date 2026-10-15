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


-- Minetest Game:
lumpblocks.register_lump_block{'copper',    'default:copper_lump',      colours = {'#973F23', '#F4D352'}, description = S('Raw Copper Block')};
lumpblocks.register_lump_block{'gold',      'default:gold_lump',        colours = {'#BD4B00', '#FFF444'}, description = S('Raw Gold Block')};
lumpblocks.register_lump_block{'iron',      'default:iron_lump',        colours = {'#7F3E24', '#D47F4E'}, description = S('Raw Iron Block')};
lumpblocks.register_lump_block{'tin',       'default:tin_lump',         colours = {'#878787', '#C3C3C3'}, description = S('Raw Tin Block')};

-- Repixture:
lumpblocks.register_lump_block{'bronze',    'rp_default:lump_bronze',   colours = {'#B13F07', '#FBA24F'}, description = S('Raw Bronze Lump')};
lumpblocks.register_lump_block{'copper',    'rp_default:lump_copper',   colours = {'#973F23', '#F4D352'}, description = S('Raw Copper Block')};
lumpblocks.register_lump_block{'iron',      'rp_default:lump_iron',     colours = {'#7F3E24', '#D47F4E'}, description = S('Raw Iron Block')};
lumpblocks.register_lump_block{'tin',       'rp_default:lump_tin',      colours = {'#878787', '#C3C3C3'}, description = S('Raw Tin Block')};
lumpblocks.register_lump_block{'gold',      'rp_gold:lump_gold',        colours = {'#BD4B00', '#FFF444'}, description = S('Raw Gold Block')};

-- More Ores:
lumpblocks.register_lump_block{'mithril',   'moreores:mithril_lump',    colours = {'#1C2D7E', '#806DD5'}, description = S('Raw Mithril Block')};
lumpblocks.register_lump_block{'silver',    'moreores:silver_lump',     colours = {'#7488AA', '#F4F8FD'}, description = S('Raw Silver Block')};

-- Technic:
lumpblocks.register_lump_block{'chromium',  'technic:chromium_lump',    colours = {'#8AB0B0', '#F5F8F8'}, description = S('Raw Chromium Block')};
lumpblocks.register_lump_block{'lead',      'technic:lead_lump',        colours = {'#454545', '#EBEBEB'}, description = S('Raw Lead Block')};
lumpblocks.register_lump_block{'sulfur',    'technic:sulfur_lump',      colours = {'#B69A00', '#FFE400'}, description = S('Raw Sulphur Block')};
lumpblocks.register_lump_block{'uranium',   'technic:uranium_lump',     colours = {'#00592A', '#99ED1A'}, description = S('Raw Uranium Block'), groups = {radioactive = 1}};
lumpblocks.register_lump_block{'zinc',      'technic:zinc_lump',        colours = {'#6CB5C9', '#DCF2F8'}, description = S('Raw Zinc Block')};

-- Nether:
lumpblocks.register_lump_block{'nether',    'nether:nether_lump',       colours = {'#586628', '#AEBF72'}, description = S('Raw Nether Block')};

-- Glooptest:
lumpblocks.register_lump_block{'akalin',    'glooptest:akalin_lump',    colours = {'#8A84C6', '#A5B4EB'}, description = S('Raw Akalin Block')};
lumpblocks.register_lump_block{'alatro',    'glooptest:alatro_lump',    colours = {'#4B1778', '#C290EC'}, description = S('Raw Alatro Block')};
lumpblocks.register_lump_block{'arol',      'glooptest:arol_lump',      colours = {'#197115', '#84D97D'}, description = S('Raw Arol Block')};
lumpblocks.register_lump_block{'kalite',    'glooptest:kalite_lump',    colours = {'#700000', '#B90000'}, description = S('Raw Kalite Block')};
lumpblocks.register_lump_block{'talinite',  'glooptest:talinite_lump',  colours = {'#259496', '#42D5D7'}, description = S('Raw Talinite Block'), def = {light_source = 6}};

-- Techage:
lumpblocks.register_lump_block{'baborium',  'techage:baborium_lump',    colours = {'#6D1414', '#D4691A'}, description = S('Raw Baborium Block')};
