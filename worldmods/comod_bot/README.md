# comod_bot

Creative Oasis Discord bridge for Luanti 5.14 / Minetest Game.

## Features

- Luanti chat -> Discord relay
- Discord relay -> Luanti chat
- Join/leave messages
- `/report <message>` -> Discord report channel
- `/login <IGN> <password>` -> verifies the existing Luanti account password
- `/logout` -> logs the Discord account out of the bot
- Optional debug relay
- Shared text files only; no HTTP and no LuaSocket

## Discord login

`/login` uses Luanti's own authentication data. The Lua side gets the player's auth entry and uses `minetest.check_password_entry()` to verify the supplied password. This avoids trying to reimplement Luanti's password hashing/SRP format in Python.

The Discord slash command response is ephemeral, so normal channel members do not see the login result.

Important: `/login` should only be used for a password the player is comfortable submitting to the bot. Do not post passwords in ordinary Discord messages. The bot never prints the submitted password to its console or Discord.

## Setup

1. Put the `comod_bot` folder in your MTG `mods` directory.
2. Put the Python files where your Python process can access the same `Relay` directory.
3. Edit `bot.conf` with your bot token and channel IDs.
4. If you want slash commands to appear immediately, put your Discord server ID in `guild_id`. Otherwise leave it at `0` and use global sync.
5. Add this to `minetest.conf` if not already trusted:

```ini
secure.trusted_mods = comod_bot
```

If you already have trusted mods, append `,comod_bot` instead of replacing them.

6. Install current discord.py 2.x:

```bash
python3 -m pip install -U discord.py
```

7. Start `Main.py`.

## Pterodactyl

The Lua server and Python bot must access the same six relay files:

```text
Relay/Lua.txt
Relay/Python.txt
Relay/Report.txt
Relay/Debug_action.txt
Relay/Auth_request.txt
Relay/Auth_response.txt
```

A separate Python host/container will not automatically share these files with the Luanti container.
