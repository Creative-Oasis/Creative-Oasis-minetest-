minetest.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	local stack = ItemStack("default:book_written")
	stack:set_metadata(minetest.serialize({
		title = "Technic Elepower Compat Manual",
		text = [[Overview:

In this manual you will get important instructions on what the Technic Elepower Compatibility mod does, what settings are available to you, and the future of this mod.

Table of Contents
- About this Mod
- Available or to be Added Features/Settings
- Other Important Information
- Planned Future Features

About this Mod
	This mod's entire purpose is to make Technic and Elepower work together. Because of this, no new features will be added unless it is to make Technic and Elepower work together better. This mod is in its beta stages, and some features mentioned above may not be bug free or completely finished yet.
We would greatly appreciate any feedback you could give us like bug reports or ideas you have for the mod. Please send bug reports and feature requests to
https://GitHub.com/DumbDave961/technic_elepower_compat/issues.

Available or to be Added Features/Settings
	To make Elepower and Technic work together, this mod makes machine processing recipes work in both Elepower and Technic machines. For example, you can make the same kind of silicon wafer in both the Technic and Elepower alloy furnaces. Whether you get the Elepower one or Technic one is up to you. You can even make each kind in their respective machines if you want. It also adds groups for things like lead and zinc so that you can use either lead or zinc in regular recipes. You can choose to use both kinds of lead or zinc, or just one of each. If you do decide to use one kind of lead or zinc, be aware that the ore for the lead or zinc that you aren't using will be PERMANENTLY REPLACED WITH STONE. This mod is supposed to be highly customizable, so you can choose which ingredients to use in recipes. There is also a beta power converter node that transmits energy from the Elepower grid to the Technic LV grid and vice versa. This is not enabled by default because it is currently incomplete.
					
Planned Future Features:
- Make power converter work for all Technic tiers.
- Add efficiency variable to conversion logic.
- Fix duplication glitches that result from having Technic and Elepower together.
]],
        owner = "Bob64 and DumbDave961 as the editor",
    }))
    inv:add_item("main", stack)
end)
