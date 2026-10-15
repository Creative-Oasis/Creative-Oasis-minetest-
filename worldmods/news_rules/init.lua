
minetest.register_privilege("news_bypass", {
	description = "Skip the Creative Oasis news/rules on join",
	give_to_singleplayer = false
})

-- Hardcoded news content
local news_text = [[
                         	   🌴 **Welcome to Creative Oasis!** 🌴

✨ **About the Server**
- This server is hosted from kattttt.ddns.net, hosted by Kattttt!
- Server website: https://kattttt.ddns.net/CO !
- A classic Minetest-Game world powered by the technical stuffs!
- Build factories, automate machines, generate power, process ores, and create massive tech systems. 
- A chill survival server for players who love engineering, automation, and big builds.
- As you can see, Creative Oasis is not creative mode, "Creative" means bring your creativity to this perfect, chilling and friendly community!
*Note: This server only allow 5.8 and newer version; if you are using 5.7 and lower version, you maybe get bugs!

📜 **Server Rules/Info**
1.1 No spamming/toxic behavior  
1.2 Follow staff instructions  
1.3 No server advertising  
1.4 You are welcome to use your preferred language!
1.5 Report players by using /report  
1.6 Join our Discord: https://discord.gg/kMYd9UW4kW  
1.7 You are welcome to bring your alt accounts to server! 
1.8 No hacks or unfair modifications
1.9 You can enable/disable your PvP mode by typing /toggle_pvp
2.1 Do not try to grief by spamming digging protected blocks, you may be died!
2.1 Send your suggestions to admin by using /mail Anastasiya
2.2 Type /tpr <player> to teleport to them
2.3 Type /tphr <player> to let them teleport to you
2.4 Type /tpr_mute <player> to ignore their tp requests
2.5 Type /hotbar <num> to change your hotbar slots number

💁 **Server staffs**
- Admin: Anastasiya
- Developer: Tomlaus, Opons, SFENCE, kattttt
- Co-Admin: Alexander_jones
- Manager: asudip, Zandar
- Moderator: 
- Guardian: Mother
- Builder: yayyer, Zandar, filx, kattttt, michi16bit
- Contributor: LadyK

👍 **Server updates 08.08.26**
- Server back to online 🎉 thanks to @kattttt
- server map got reset unfortunelly 👎
- add discord - luanti relay bot with commands! (/login to login, don't need to dm the bot) ✅
- our official website now is : https://kattttt.ddns.net/CO
- adjusted game logics
- added 2 bot players : Hailey and A
- /report system now connect to discord on ⁠❗│public-report channel!
- added moving blocks mod to server
- added new command /vd and /vote_day, to cost 3 diamond in your inventory to vote for day time!
- added /hotbar <num> cmd
- added weather mod

👍 **Server updates 12.23**
- Added mods: Technic, Basic_machine, Terumet, Elepower, Logistica, Techpack, etc.
- Edited gravelsieve mod
- Changed tower crane size to 50,50 max
- Server average active members: 7
- Multiple bugs fixed
- Increased trampoline jumping height
- Added more lumpblocks (by Opons)!
- More armors and tools added
- Added some custom "comod"s (tools, blocks)
- Created /report command system and /toggle_pvp command to manage PVP
- Updated area protection system
- Edited the strongest armor on the server: Hero Armor
- Added Illumination mod (holding an item with light will illuminate the surrounding area)


]]

-- Build formspec
local function get_formspec()
	local escaped = minetest.formspec_escape(news_text)
	return table.concat({
		"formspec_version[4]",
		"size[14,10]",
		"bgcolor[#101820EE;true]",

		"box[0,0;14,1.2;#23a3c3]",
		"label[0.4,0.3;🪶]",
		"style_type[label;font_size=24]",
		"label[1.0,0.3;Creative Oasis]",
		"style_type[label;font_size=16]",
		"box[0,1.2;14,0.05;#ffffff22]",

		"textarea[0.25,1.3;13.5,8;news;;", escaped, "]",

		"button_exit[5.5,9.1;3,0.8;exit;Close]"
	})
end

-- Show news on join for all players (except those with bypass)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    if minetest.get_player_privs(name).news_bypass then
        return
    end

    minetest.after(1, function()
        if player and player:is_player() then
            minetest.show_formspec(name, "creative_oasis_news", get_formspec())
        end
    end)
end)


-- /news command
minetest.register_chatcommand("news", {
	description = "Show the Creative Oasis news and rules",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			player:get_meta():set_int("news_shown", 1)
			minetest.show_formspec(name, "creative_oasis_news", get_formspec())
		end
	end
})

-- /rules command
minetest.register_chatcommand("rules", {
	description = "Show the Creative Oasis rules",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			player:get_meta():set_int("news_shown", 1)
			minetest.show_formspec(name, "creative_oasis_news", get_formspec())
		end
	end
})
