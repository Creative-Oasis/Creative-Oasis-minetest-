-- comod_report/init.lua

local reports = {}
local selected_reports = {}
local pending_replies = {} -- [report_id][reporter_name] = reply text

-- Privilege
minetest.register_privilege("comod_report", {
    description = "Can view and manage player reports",
    give_to_singleplayer = false,
})

-- /report command
minetest.register_chatcommand("report", {
    params = "<playername> <reason>",
    description = "Report a player",
    func = function(name, param)
        local reported_name, reason = param:match("^(%S+)%s+(.+)$")
        if not reported_name or not reason then
            return false, "Usage: /report <playername> <reason>"
        end
        minetest.show_formspec(name, "comod_report:report_form",
            "size[6,4]"..
            "label[0,0;Report players below. Do not abuse this command!]"..
            "field[0.5,1.5;5,1;playername;Player Name;"..reported_name.."]"..
            "field[0.5,2.5;5,1;reason;Reason;"..reason.."]"..
            "button_exit[2,3;2,1;submit;Submit]"
        )
        return true
    end
})

-- Submit report
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local pname = player:get_player_name()
    if formname == "comod_report:report_form" and fields.submit then
        local target = fields.playername or ""
        local reason = fields.reason or ""
        if target == "" or reason == "" then
            minetest.chat_send_player(pname,"Please fill in both player name and reason.")
            return
        end
        table.insert(reports,{reporter=pname,target=target,reason=reason,time=os.time()})
        minetest.chat_send_player(pname,"Report submitted for "..target)
    end
end)

-- Build reportlist formspec
local function build_reportlist_formspec(player_name)
    local sel = selected_reports[player_name]
    local fs = "size[12,14]"

    -- Left panel
    fs = fs.."label[0,0;Reports (click to view details):]"
    local y = 0.5
    for i, rep in ipairs(reports) do
        fs = fs.."button[0,"..y..";6,0.7;report_"..i..";"..rep.reporter.." -> "..rep.target.."]"
        y = y + 0.8
    end

    -- Right panel
    if sel and reports[sel] then
        local rep = reports[sel]
        local x = 7.0
        local y = 0.2
        local w = 4.8

        fs = fs.."label["..x..","..y..";***Report Details***]"; y=y+0.6
        fs = fs.."label["..x..","..y..";Reporter: "..rep.reporter.."]"; y=y+0.6
        fs = fs.."label["..x..","..y..";Reported: "..rep.target.."]"; y=y+0.6
        fs = fs.."textarea["..x..","..y..";"..w..",4;report_reason;;"..rep.reason.."]"; y=y+4.2

        fs = fs.."button["..x..","..y..";"..w..",0.7;delete;Delete]"; y=y+1.0

        fs = fs.."label["..x..","..y..";Warn Reason (red text to reported player):]"; y=y+0.5
        fs = fs.."field["..x..","..y..";"..w..",0.6;warn_reason;;]"; y=y+0.7
        fs = fs.."button["..x..","..y..";"..w..",0.7;warn;Warn Player]"; y=y+1.0

        fs = fs.."label["..x..","..y..";Kick Reason (optional):]"; y=y+0.5
        fs = fs.."field["..x..","..y..";"..w..",0.6;kick_reason;;]"; y=y+0.7
        fs = fs.."button["..x..","..y..";"..w..",0.7;kick;Kick Player]"; y=y+1.0

        fs = fs.."label["..x..","..y..";Reply to Reporter (optional):]"; y=y+0.5
        fs = fs.."field["..x..","..y..";"..w..",0.6;reply_text;;]"; y=y+0.7
        fs = fs.."button["..x..","..y..";"..w..",0.7;reply;Send Reply]"
    end

    fs = fs.."button_exit[5,13.5;2,0.7;close;Close]"
    return fs
end

-- /reportlist
minetest.register_chatcommand("reportlist", {
    description = "View player reports",
    privs = {comod_report=true},
    func = function(name)
        minetest.show_formspec(name,"comod_report:reportlist",build_reportlist_formspec(name))
        return true
    end
})

-- Reply GUI
local function show_reply_to_reporter(reporter, reply_text)
    if reply_text == "" then return end
    if minetest.get_player_by_name(reporter) then
        minetest.show_formspec(reporter, "comod_report:reply",
            "size[6,4]"..
            "label[0,0;***Report result***]"..
            "textarea[0.5,1;5,2;reply;;"..reply_text.."]"..
            "button_exit[2,3;2,1;close;Close]"
        )
    end
end

-- Handle actions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local pname = player:get_player_name()
    if formname ~= "comod_report:reportlist" then return end

    for key,_ in pairs(fields) do
        local id = key:match("^report_(%d+)$")
        if id and reports[tonumber(id)] then
            selected_reports[pname] = tonumber(id)
            minetest.show_formspec(pname,"comod_report:reportlist",build_reportlist_formspec(pname))
            return
        end
    end

    local sel = selected_reports[pname]
    if not sel or not reports[sel] then return end
    local rep = reports[sel]

    if fields.delete then
        table.remove(reports, sel)
        selected_reports[pname] = nil
        minetest.show_formspec(pname,"comod_report:reportlist",build_reportlist_formspec(pname))
        return
    end

    if fields.warn then
        local reason = fields.warn_reason or ""
        if reason ~= "" then
            minetest.chat_send_player(rep.target,
                minetest.colorize("#FF0000","*** WARNING: "..reason.." ***"))
        end
        return
    end

    if fields.kick then
        local reason = fields.kick_reason or "You were kicked by staff."
        minetest.kick_player(rep.target, reason)
        return
    end

    if fields.reply then
        local reply = fields.reply_text or ""
        if reply ~= "" then
            show_reply_to_reporter(rep.reporter, reply)
            pending_replies[sel] = pending_replies[sel] or {}
            pending_replies[sel][rep.reporter] = reply
        end
        return
    end
end)

-- Deliver pending replies
minetest.register_on_joinplayer(function(player)
    local pname = player:get_player_name()
    for _, replies in pairs(pending_replies) do
        local msg = replies[pname]
        if msg then
            show_reply_to_reporter(pname, msg)
            replies[pname] = nil
        end
    end
end)
