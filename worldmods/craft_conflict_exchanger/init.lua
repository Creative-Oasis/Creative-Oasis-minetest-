
craft_conflict_exchanger = {}

craft_conflict_exchanger.MODNAME = core.get_current_modname() or "craft_conflict_exchanger"
craft_conflict_exchanger.MODPATH = core.get_modpath(craft_conflict_exchanger.MODNAME)

dofile(craft_conflict_exchanger.MODPATH.."/src/settings.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/common.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/detachedinv.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/groupimg.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/logic.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/ui.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/recipes.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/commands.lua")
dofile(craft_conflict_exchanger.MODPATH.."/src/blocks.lua")
