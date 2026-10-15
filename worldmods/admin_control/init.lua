-- admin_control/init.lua
-- Shutdown and restart commands with extended countdown up to 10h and green messages

-- Define countdown intervals in seconds
local countdown_intervals = {
    36000, 32400, 28800, 25200, 21600, 18000, 14400, 10800, 7200, 3600,
    3000, 1800, 600, 300, 60, 30, 20, 10, 5, 4, 3, 2, 1
}

local function parse_param(param)
    -- param format: "<time> <reason>"
    local time_sec, reason = param:match("^(%d+)%s*(.*)$")
    if time_sec then
        time_sec = tonumber(time_sec)
    else
        time_sec = 0
        reason = param or ""
    end
    return time_sec, reason
end

local function schedule_countdown(total_time, reason, restart)
    for _, t in ipairs(countdown_intervals) do
        if t <= total_time then
            local delay = total_time - t
            minetest.after(delay, function()
                local msg
                if t >= 3600 then
                    msg = string.format("%d hour%s left! Reason: %s", t/3600, t/3600>1 and "s" or "", reason)
                elseif t >= 60 then
                    msg = string.format("%d minute%s left! Reason: %s", t/60, t/60>1 and "s" or "", reason)
                else
                    msg = string.format("%d second%s left! Reason: %s", t, t>1 and "s" or "", reason)
                end
                minetest.chat_send_all(minetest.colorize("#00FF00", msg)) -- green color
            end)
        end
    end

    -- final shutdown/restart
    minetest.after(total_time, function()
        minetest.chat_send_all(minetest.colorize("#00FF00",
            restart and "Server restarting now!" or "Server shutting down now!"))
        minetest.request_shutdown(reason, true, restart)
    end)
end

-- Shutdown command
minetest.register_chatcommand("shutdown", {
    description = "Shut down the server with optional delay and reason",
    privs = {server = true},
    func = function(name, param)
        local delay, reason = parse_param(param)
        reason = reason ~= "" and reason or "Manual shutdown, please come back later!  More informations on Discord: https://discord.gg/kMYd9UW4kW"

        if delay > 0 then
            minetest.chat_send_all(minetest.colorize("#00FF00",
                string.format("Server will shut down in %d seconds! Reason: %s", delay, reason)))
            schedule_countdown(delay, reason, false)
        else
            minetest.chat_send_all(minetest.colorize("#00FF00", "Server shutting down! Reason: " .. reason))
            minetest.request_shutdown(reason, true)
        end
        return true
    end,
})

-- Restart command
minetest.register_chatcommand("restart", {
    description = "Restart the server with optional delay and reason",
    privs = {server = true},
    func = function(name, param)
        local delay, reason = parse_param(param)
        reason = reason ~= "" and reason or "Manual restart, please come back in few minutes! More informations on Discord: https://discord.gg/kMYd9UW4kW"

        if delay > 0 then
            minetest.chat_send_all(minetest.colorize("#00FF00",
                string.format("Server will restart in %d seconds! Reason: %s", delay, reason)))
            schedule_countdown(delay, reason, true)
        else
            minetest.chat_send_all(minetest.colorize("#00FF00", "Server restarting! Reason: " .. reason))
            minetest.request_shutdown(reason, true, true)
        end
        return true
    end,
})

