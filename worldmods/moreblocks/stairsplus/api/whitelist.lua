local f = string.format

local s = stairsplus.settings
local api = stairsplus.api

if s.whitelist_mode then
	api.whitelisted = {}
	local filename = futil.path_concat(minetest.get_worldpath(), "stairsplus.whitelist")
	local contents = futil.load_file(filename)
	if not contents then
		error(f("error initializing stairsplus whitelist: %s does not exist", filename))
	end
	local items = contents:split("\n")
	for i = 1, #items do
		api.whitelisted[items[i]] = true
	end
	stairsplus.log("action", f("%s nodes whitelisted", #api.whitelisted))
end

function api.is_whitelisted(name)
	if not s.whitelist_mode then
		return true
	end
	return api.whitelisted[name]
end
