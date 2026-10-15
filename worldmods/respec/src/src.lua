local PATH = respec.MODPATH.."/src/"
respec.internal = {}

-- order matters
dofile(PATH.."const.lua")
dofile(PATH.."settings.lua")
dofile(PATH.."util.lua")
dofile(PATH.."measure_text.lua")
dofile(PATH.."register.lua")
dofile(PATH.."graph.lua")
dofile(PATH.."element.lua")
dofile(PATH.."elements.lua")
dofile(PATH.."layout_logic.lua")
dofile(PATH.."layout.lua")
dofile(PATH.."form.lua")
dofile(PATH.."utility_api.lua")
