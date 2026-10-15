staffranks = {}

local ranks = {}

function staffranks.register_rank(name, prefix, color)
	ranks[name] = {name = name, prefix = prefix, color = color}
end

function staffranks.rank_exist(rankname)
    return ranks[rankname] ~= nil
end

function staffranks.add_rank(name, rankname)
    local player = core.get_player_by_name(name)
	local meta = player:get_meta()
    for _, rankData in pairs(ranks) do
        if rankname == rankData.name then
            rank_prefix = rankData.prefix
            rank_name = rankData.name
            rank_color = rankData.color
            meta:set_string("staffranks:rank", rank_name)
            meta:set_string("staffranks:rank_prefix", rank_prefix)
            meta:set_string("staffranks:rank_color", rank_color)
            return
        end
    end
end

function staffranks.init_nametag(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    local rank_color = meta:get_string("staffranks:rank_color")
    local rank_name = meta:get_string("staffranks:rank_prefix")
    player:set_nametag_attributes({text = core.colorize(rank_color, "[" .. rank_name .. "] ") .. name})
end

function staffranks.clear_nametag(player)
    local name = player:get_player_name()
    player:set_nametag_attributes(name)
end

function staffranks.rankslist()
    local ranklist = ""
    local number_ranks = 0
    for _, rankData in pairs(ranks) do
        number_ranks = number_ranks + 1
        local separator = ", "
        if lastIndex == #ranks then
            separator = "."
        end
        ranklist = ranklist .. rankData.prefix .. " (" .. rankData.name .. ")" .. separator
    end
    return ranklist
end

function staffranks.has_rank(player_name, rankname)
    local player = core.get_player_by_name(player_name)
	local meta = player:get_meta()
	local rank = meta:get_string("staffranks:rank")
    if rank == rankname then
        return true
    end
    return false
end

function staffranks.log(level, message)
    local worldpath = core.get_worldpath()
    local file = io.open(worldpath .. "/staffranks.log", "a")
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local message = message:gsub("T@staffranks%)", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\27%[[^m]*m", ""):gsub("\27.", "")
    if level == "message" then
        file:write(time .. " [MESSAGE] " .. message .. "\n")
    elseif level == "info" then
        file:write(time .. " [INFO] " .. message .. "\n")
        core.log("info", "[StaffRanks] " .. message)
    end
    file:close()
end