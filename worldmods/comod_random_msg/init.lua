-- init.lua for Random Messages Mod
-- Sends random tips to all connected players periodically

local S = core.get_translator(core.get_current_modname())

random_messages = {}

-- Disable mod if setting is true
if core.settings:get_bool("random_messages_disabled", false) then
	return
end

-- Seed RNG for randomness
math.randomseed(os.time())

-- All messages
local messages = {
	-- Commands & server tips
	S("Use /r or /rank to check your rank."),
	S("Use /msg <name> to talk privately with another player."),
	S("Use /toggle_pvp to enable or disable PvP mode."),
	S("To protect an area, use /area_pos1, /area_pos2, then /protect <area name>."),
	S("Use /report <name> <reason> to report a player to the admins."),
	S("Use /death_pos to teleport to your last death location."),
        S("Use /hide_death or /show_death to hide or show your last death location."),
	S("Use /mail <name> to send mail to another player."),
	S("Use /stats <name> to check a player's stats."),
	S("Use /tpr <name> to send a teleport request to a player."),
	S("Use /tphr <name> to request a player to teleport to you."),
	S("Use /tpr_mute <player> to ignore teleport requests from that player."),
	S("Join our Discord: https://discord.gg/kMYd9UW4kW"),
	S("If you are using Luanti 5.7 or older, you may see bug warnings due to outdated versions."),
	S("Leaves reduce fall damage and can be used for safe landings."),
	S("Type /spawn to quickly return to spawn."),
        S("Use /hotbar <number 8-16> to change your hotbar slots!"),
	S("Type /city to quickly return to the server city."),
    S("Join our Discord: https://discord.gg/kMYd9UW4kW"),
	S("You can cost 3 diamonds in your inventory to vote day. /vote_day or /vd"),
	S("If you have any suggestions, please send them using /mail Anastasiya or /report."),
	S("Type /help to see all available commands and their usage."),
    S("Join our Discord: https://discord.gg/kMYd9UW4kW"),
	S("Some special tools will glow in dark areas when you hold them."),
    S("Type /safe_yourself_one_hp to bring yourself back from death."),
	S("Flight potions are only available during specific events."),
	S("Items conflicting with each other? Try using an Item Exchanger."),
	S("Found a bug? Report it by using /mail Anastasiya or /report."),
    S("Join our Discord: https://discord.gg/kMYd9UW4kW"),
	S("Want daytime? Use 3 diamonds to start a vote by /vd or /vote_day."),
	S("Can't see stamina/HP bar? Rejoin the game."),
    S("Join our Discord: https://discord.gg/kMYd9UW4kW"),
    S("Type /safe_yourself_one_hp to bring yourself back from death."),

	-- Basic Machines
	S("[Basic_Machines] Can interact with nodes without player input."),
	S("[Basic_Machines] Many machines work well with logic signals."),

	-- TechPack
	S("[TechPack] Machines help automate early resource processing."),
	S("[TechPack] Some machines can work in parallel to increase output."),
	S("[TechPack] Integrates well with other tech mods."),

	-- Elepower
	S("[Elepower] Machines rely on a shared energy system."),
	S("[Elepower] Some devices require specific power levels."),
	S("[Elepower] Energy storage is important for stable operation."),

	-- Logistica
	S("[Logistica] Lets you access all connected storage from one interface."),
	S("[Logistica] Networks can move items without physical tubes."),
	S("[Logistica] Automatic crafting is possible."),

	-- Pipeworks
	S("[Pipeworks] Tubes automatically move items between blocks."),
	S("[Pipeworks] Filters control where items travel."),
	S("[Pipeworks] Vacuum tubes can collect dropped items."),

	-- Digilines
	S("[Digilines] Send text-based signals between machines."),
	S("[Digilines] Each device listens on a specific channel."),
	S("[Digilines] Can control machines, doors, and displays."),

	-- Power Generators
	S("[Power_Generators] Different generators use different fuel sources."),
	S("[Power_Generators] Some work better under specific conditions."),
	S("[Power_Generators] Power production affects how many machines can run at once."),

	-- Technic
	S("[Technic] Uses multiple voltage tiers for machines."),
	S("[Technic] Machines stop working if voltage is incorrect."),
	S("[Technic] Energy storage helps stabilize networks."),

	-- Terumet
	S("[Terumet] Focuses on advanced alloys and machines."),
	S("[Terumet] Progressing unlocks stronger technology."),
	S("[Terumet] Machines often require careful resource management."),

	-- Mesecons
	S("[Mesecons] Provides logic-based automation."),
	S("[Mesecons] Signals can trigger machines, doors, and traps."),
	S("[Mesecons] Complex logic can be built from simple components."),

	-- Bot Farm
	S("[Bot_Farm] Farm bots can harvest and replant crops automatically."),
	S("[Bot_Farm] Bots need proper conditions to work efficiently."),
	S("[Bot_Farm] Automated farms reduce manual farming work."),
}

-- Message interval (seconds)
local MESSAGE_INTERVAL = tonumber(core.settings:get("random_messages_interval")) or 120

-- Function to get a random message
function random_messages.get_random_message()
	return messages[math.random(#messages)]
end

-- Timer for globalstep
local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= MESSAGE_INTERVAL then
		if #core.get_connected_players() > 0 then
			core.chat_send_all(
				core.colorize("#808080", random_messages.get_random_message())
			)
		end
		timer = timer - MESSAGE_INTERVAL
	end
end)
