local W = minetest.settings:get("invman.width") or 8
if minetest.get_modpath("mcl_core") and W == 8 then
	W = 9
end
local tab = {}
local mode = {}
local target = {}
local offset = {}
local F = minetest.formspec_escape
local modes = {
	["Copy"] = "1",
	["Take"] = "2",
	["Remove"] = "3"
}

local function genlist(lists)
	local ilist = {}
	for lname,_ in pairs(lists) do
		if lname ~= "main" and lname ~= "craftpreview" and lname ~= "craftresult" then
			table.insert(ilist,lname)
		end
	end
	table.sort(ilist)
	table.insert(ilist, 1, "main")
	return ilist
end

local function im_fs(name)
	if not target[name] then return end
	local y = 0.7
	local x = 0
	local inv = minetest.get_inventory({type="player", name=target[name]})
	if not inv then return end
	local ilist = genlist(inv:get_lists())
	local size = #inv:get_list(ilist[(tab[name] or 1)])
	local formspec = "size["..(W+(size > W*4 and 0.4 or 0))..",".."4.7"..
	"]tabheader[0,0;tabs;"..table.concat(ilist,",")..";"..(tab[name] or "1")..";false;false]" ..
	"label[0,0;"..target[name].."]"..
	"label["..(W-4)..",0;Mode:]"..
	"dropdown["..(W-3.3)..",-0.1;1.2;mode;Copy,Take,Remove;"..(modes[mode[name]] or "1").."]"..
	"button["..(W-2)..",-0.2;2,1;update;Update]"
	offset[name] = offset[name] or 0
	local start = size >= W*4 and offset[name]*W+1 or 1
	local stop = start + (W*4-1)
	for i,stack in pairs(inv:get_list(ilist[(tab[name] or 1)])) do
		if i >= start and i <= stop then
			if not stack then
				stack = ItemStack("")
			end
			local name = stack:get_name()
			local count = stack:get_count()
			local descr = stack:get_short_description()
			if descr == name then
				descr = stack:get_name()
			else
				descr = descr.." ["..name.."]"
			end
			formspec = formspec .. ("item_image_button[%f,%f;1,1;%s;item:%i;\n\n\b\b\b%s]tooltip[item:%i;%s]"):format(
					x, y,
					name,
					i,
					count > 0 and tostring(count) or "",
					i,
					F(descr)
				)
			x = x + 1
			if x >= W then
				y = y + 1
				x = 0
			end
		end
	end
	if size > W*4 then
		formspec = formspec .. "set_focus[scroll;true]" ..
		"scrollbaroptions[min=0;max="..tostring(math.ceil(size/W))-4 ..";smallstep=1;largestep=4]" ..
		"scrollbar[8.1,0.7;0.3,3.9;vertical;scroll;"..offset[name].."]"
	end
	minetest.show_formspec(name,"invman",formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "invman" then return end
	local name = player and player:get_player_name()
	if not name then return end
	if fields.update then
		im_fs(name)
	end
	if fields.mode then
		mode[name] = fields.mode
	end
	if fields.scroll then
		local evnt = minetest.explode_scrollbar_event(fields.scroll)
		offset[name] = evnt.value
		im_fs(name)
	end
	if fields.tabs then
		tab[name] = tonumber(fields.tabs) or 1
		im_fs(name)
	end
	if not (fields.update or fields.quit or fields.tabs) then
		local num
		for key,val in pairs(fields) do
			num = tonumber(key:match("^item:(%d+)")) or num
		end
		local inv = minetest.get_inventory({type="player", name=target[name]})
		if not (num and inv) then return end
		local ilist = genlist(inv:get_lists())
		local stack = inv:get_list(ilist[(tab[name] or 1)])[num]
		if mode[name] == "Take" or mode[name] == "Remove" then
			inv:remove_item(ilist[(tab[name] or 1)], stack)
		end
		if mode[name] == "Copy" or mode[name] == "Take" then
			local oinv = player:get_inventory()
			oinv:add_item("main",stack)
		end
		im_fs(name)
	end
end)
minetest.register_privilege("invman",{description="Allows to use /invman",give_to_singleplayer=false})
minetest.register_chatcommand("invman",{
  description = "Open InvMan formspec",
  privs={invman=true},
  params = "<playername>",
  func = function(name,param)
	local user = minetest.get_player_by_name(name)
	if not user then
		return false, "You can't use /invman from IRC/Discord!"
	end
	local player = minetest.get_player_by_name(param)
	if not player then
		return false, "Target player is not online"
	end
	target[name] = param
	tab[name] = 1
	im_fs(name)
end})
