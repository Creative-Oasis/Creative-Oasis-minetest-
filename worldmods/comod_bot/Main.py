import asyncio
import configparser
import os
import time
import uuid
import re
import subprocess

import discord
from discord.ext import commands

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_FILE = os.path.join(BASE_DIR, "bot.conf")

config = configparser.ConfigParser()
config.read(CONFIG_FILE)

BOT_TOKEN = config["BOT"]["bot_token"]
PREFIX_BASE = config["BOT"].get("command_prefix", "!cmd").rstrip()

# Support both ! and !cmd.
# !cmd remains the configured command namespace, while ! also works.
PREFIXES = ("!cmd ", "!")

GUILD_ID = config["BOT"].getint("guild_id", fallback=0)

def relay_path(key, default):
    return os.path.join(BASE_DIR, config["RELAY"].get(key, default))

LUA_FILE = relay_path("lua_file_path", "Relay/Lua.txt")
PYTHON_FILE = relay_path("python_file_path", "Relay/Python.txt")
REPORT_FILE = relay_path("report_file_path", "Relay/Report.txt")
DEBUG_FILE = relay_path("debug_action_file_path", "Relay/Debug_action.txt")
AUTH_REQUEST_FILE = relay_path("auth_request_file_path", "Relay/Auth_request.txt")
AUTH_RESPONSE_FILE = relay_path("auth_response_file_path", "Relay/Auth_response.txt")
IDENTITY_FILE = relay_path("identity_file_path", "Relay/Discord_Names.txt")
COMMAND_FILE = relay_path("command_file_path", "Relay/Discord_Command.txt")
COMMAND_RESPONSE_FILE = relay_path("command_response_file_path", "Relay/Discord_Command_Response.txt")

COMMAND_TIMEOUT = max(3.0, config["RELAY"].getfloat("command_timeout", fallback=15.0))
RELAY_CHANNEL_ID = config["RELAY"].getint("relay_channel")
REPORT_CHANNEL_ID = config["RELAY"].getint("report_channel")
DEBUG_CHANNEL_ID = config["RELAY"].getint("debug_channel")
USE_NICKNAMES = config["RELAY"].getboolean("use_nicknames", fallback=True)
COOLDOWN = max(0.05, config["RELAY"].getfloat("cooldown", fallback=0.05))
ENABLE_DEBUG = config["RELAY"].getboolean("enable_debug", fallback=True)
LOGIN_COOLDOWN = config["LOGIN"].getfloat("cooldown", fallback=30)
LOGIN_TIMEOUT = config["LOGIN"].getfloat("timeout", fallback=20)

SERVER_LOG_FILE = "/home/miaou/aerohost/data/servers/59c93931/server.log"
SERVER_LOG_INTERVAL = 0.2
server_log_position = 0
server_log_initialized = False

SERVER_STATUS_INTERVAL = 0.5
SERVER_PROCESS_PATH = "/home/miaou/luanti/bin/luanti"
SERVER_PORT = "30500"
server_status = None
server_status_initialized = False

# Debug batching / rate-limit protection.
DEBUG_BATCH_WINDOW = 0.5
DEBUG_MAX_CHARS = 1900
DEBUG_MIN_SEND_INTERVAL = 0.55
DEBUG_RETRY_CAP = 10.0

intents = discord.Intents.default()
intents.message_content = True
intents.members = True
intents.guilds = True

bot = commands.Bot(command_prefix=PREFIXES, intents=intents)

discord_to_luanti = []
pending_logins = {}
last_login_attempt = {}
sessions = {}
pending_commands = {}

class DiscordSendQueues:
    def __init__(self):
        self.chat_queue = asyncio.Queue()
        self.debug_queue = asyncio.Queue()

    async def put(self, item):
        if item[0] in {"server_log", "debug"}:
            await self.debug_queue.put(item)
        else:
            await self.chat_queue.put(item)

    async def get_chat(self):
        return await self.chat_queue.get()

    async def get_debug(self):
        return await self.debug_queue.get()

    def chat_done(self):
        self.chat_queue.task_done()

    def debug_done(self):
        self.debug_queue.task_done()

discord_send_queue = DiscordSendQueues()

mention_users = {}
mention_roles = {}
mention_cache_time = 0.0
MENTION_CACHE_SECONDS = 30.0

def invalidate_mention_cache():
    global mention_cache_time
    mention_cache_time = 0.0

def debug_print(message):
    if ENABLE_DEBUG:
        print(f"[comod_bot DEBUG] {message}")

def read_and_clear(path):
    try:
        if not os.path.exists(path):
            return []
        with open(path, "r", encoding="utf-8") as f:
            data = f.read()
        if not data.strip():
            return []
        with open(path, "w", encoding="utf-8") as f:
            f.write("")
        return [line.rstrip("\n") for line in data.splitlines() if line.strip()]
    except Exception as e:
        print(f"[comod_bot] File read error {path}: {e}")
        return []

def write_if_empty(path, messages):
    if not messages:
        return False
    try:
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                if f.read().strip():
                    return False
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(str(x) for x in messages) + "\n")
            f.flush()
        return True
    except Exception as e:
        print(f"[comod_bot] File write error {path}: {e}")
        return False

ROLE_ALIASES = {
    "staff": 1434255663575470143,
    "builder": 1407724428757827614,
    "masterbuilder": 1407724428757827614,
    "dev": 1407723885712904212,
    "developer": 1407723885712904212,
}

def get_relay_guild():
    channel = bot.get_channel(RELAY_CHANNEL_ID)
    if channel is not None and getattr(channel, "guild", None) is not None:
        return channel.guild
    if GUILD_ID:
        guild = bot.get_guild(GUILD_ID)
        if guild is not None:
            return guild
    for guild in bot.guilds:
        if guild.get_channel(RELAY_CHANNEL_ID) is not None:
            return guild
    return None

def build_mention_lookup(guild):
    users = {}
    roles = {alias.lower(): role_id for alias, role_id in ROLE_ALIASES.items()}
    if guild is None:
        return users, roles
    for member in guild.members:
        names = {x for x in (member.name, member.global_name, member.display_name, member.nick if USE_NICKNAMES else None) if x}
        for name in names:
            clean = name.strip().lower()
            if clean:
                users[clean] = member.id
    for role in guild.roles:
        if not role.is_default():
            name = role.name.strip().lower()
            if name:
                roles[name] = role.id
    return users, roles

def get_cached_mention_lookup():
    global mention_users, mention_roles, mention_cache_time
    now = time.monotonic()
    if now - mention_cache_time < MENTION_CACHE_SECONDS:
        return mention_users, mention_roles
    mention_users, mention_roles = build_mention_lookup(get_relay_guild())
    mention_cache_time = now
    return mention_users, mention_roles

def replace_game_mentions(text):
    if not text or "@" not in text:
        return text
    users, roles = get_cached_mention_lookup()
    pattern = re.compile(r"(?<![\w@])@([\w.-]+)", re.UNICODE)
    def repl(match):
        name = match.group(1).strip().lower()
        if name in roles:
            return f"<@&{roles[name]}>"
        if name in users:
            return f"<@{users[name]}>"
        return match.group(0)
    return pattern.sub(repl, text)

def is_luanti_server_running():
    try:
        proc = subprocess.run(
            ["pgrep", "-af", SERVER_PROCESS_PATH],
            capture_output=True, text=True, timeout=1.0
        )
        if proc.returncode != 0:
            return False
        for line in proc.stdout.splitlines():
            if SERVER_PROCESS_PATH not in line:
                continue
            command_line = line.split(None, 1)[1] if len(line.split(None, 1)) == 2 else line
            if "--server" in command_line and f"--port {SERVER_PORT}" in command_line:
                return True
        return False
    except Exception:
        return False

async def announce_server_status(status):
    messages = {
        "online": "🟢 **Server is online.**",
        "offline": "🔴 **Server is offline.**",
        "restart": "🔄 **Server restarted.**",
    }
    if status in messages:
        await discord_send_queue.put(("server_status", RELAY_CHANNEL_ID, messages[status]))

async def server_status_loop():
    global server_status, server_status_initialized
    while True:
        try:
            current = "online" if is_luanti_server_running() else "offline"
            if not server_status_initialized:
                server_status = current
                server_status_initialized = True
                await announce_server_status(current)
            elif current != server_status:
                previous = server_status
                server_status = current
                await announce_server_status("offline" if current == "offline" else "restart" if previous == "offline" else current)
        except Exception as e:
            print(f"[comod_bot] Server status loop error: {e}")
        await asyncio.sleep(SERVER_STATUS_INTERVAL)

def cleanup_sessions():
    now = time.time()
    for token, data in list(sessions.items()):
        if now - data["time"] > LOGIN_TIMEOUT:
            sessions.pop(token, None)

def create_login_token(user_id):
    token = uuid.uuid4().hex[:12]
    sessions[token] = {"user_id": user_id, "time": time.time()}
    return token

@bot.event
async def on_ready():
    print(f"[comod_bot] Logged in as {bot.user} ({bot.user.id})")
    print(f"[comod_bot] Relay interval: {COOLDOWN}s")
    print(f"[comod_bot] Debug batch: {DEBUG_BATCH_WINDOW}s")
    print("[comod_bot] Both ! and !cmd prefixes enabled.")

@bot.event
async def on_message(message):
    if message.author.bot:
        return

    content = message.content

    # !cmd X and ! X both enter the in-game command relay.
    command_text = None
    if content.startswith("!cmd "):
        command_text = content[5:].strip()
    elif content.startswith("!"):
        command_text = content[1:].strip()

    if command_text is not None:
        if not command_text:
            await message.channel.send("Use `! +` or `!cmd +` to see the available in-game commands.")
            return

        request_id = uuid.uuid4().hex[:12]
        pending_commands[request_id] = {
            "discord_id": str(message.author.id),
            "channel_id": message.channel.id,
            "created": time.time(),
        }
        if not write_if_empty(COMMAND_FILE, [f"{request_id}\t{message.author.id}\t{command_text}"]):
            pending_commands.pop(request_id, None)
            await message.channel.send("The command relay is busy. Please try again.")
        return

    if message.channel.id == RELAY_CHANNEL_ID:
        member = message.author
        display_name = member.display_name if USE_NICKNAMES else member.name
        username = member.name
        role_color = "#99AAB5"
        role_name = "Member"
        for role in sorted(getattr(member, "roles", []), key=lambda r: r.position, reverse=True):
            if role.is_default():
                continue
            color_value = getattr(role.color, "value", 0)
            if color_value:
                role_color = f"#{color_value:06X}"
                role_name = str(role.name or "Member")
                break

        def clean(value):
            return str(value).replace("\r", " ").replace("\n", " ").replace("\t", " ")

        discord_to_luanti.append(
            f"DMSG\t{role_color}\t{clean(role_name)}\t{clean(display_name)}\t{clean(username)}\t{clean(content)}"
        )
        return

    await bot.process_commands(message)

async def write_discord_messages():
    global discord_to_luanti
    if not discord_to_luanti:
        return
    messages = discord_to_luanti[:]
    if write_if_empty(PYTHON_FILE, messages):
        del discord_to_luanti[:len(messages)]

async def discord_sender():
    allowed_mentions = discord.AllowedMentions(users=True, roles=True, everyone=False)
    while True:
        items = []
        try:
            first = await discord_send_queue.get_chat()
            items.append(first)
            await asyncio.sleep(0.02)
            while True:
                try:
                    items.append(discord_send_queue.chat_queue.get_nowait())
                except asyncio.QueueEmpty:
                    break
            grouped = {}
            for message_type, channel_id, message in items:
                grouped.setdefault(channel_id, []).append(str(message))

            for channel_id, messages in grouped.items():
                channel = bot.get_channel(channel_id)

                if channel is None:
                    try:
                        channel = await bot.fetch_channel(channel_id)
                    except Exception as e:
                        print(f"[comod_bot] Could not fetch Discord channel/DM {channel_id}: {e}")
                        continue

                if channel is None:
                    continue

                chunks = []
                current = ""

                for message in messages:
                    if not message:
                        continue

                    if len(message) > 1900:
                        if current:
                            chunks.append(current)
                            current = ""
                        chunks.extend(
                            message[i:i+1900]
                            for i in range(0, len(message), 1900)
                        )
                        continue

                    candidate = message if not current else current + "\n" + message

                    if len(candidate) > 1900:
                        chunks.append(current)
                        current = message
                    else:
                        current = candidate

                if current:
                    chunks.append(current)

                for chunk in chunks:
                    await channel.send(
                        chunk,
                        allowed_mentions=allowed_mentions
                    )
        except Exception as e:
            print(f"[comod_bot] Discord live send error: {e}")
        finally:
            for _ in items:
                discord_send_queue.chat_done()

async def discord_debug_sender():
    """
    Dedicated debug sender:
    - waits 500ms after the first queued debug event;
    - drains everything accumulated during that window;
    - combines it into the fewest possible Discord messages;
    - enforces a local minimum send interval;
    - honors Discord's Retry-After on HTTP 429;
    - keeps failed batches in memory and retries them instead of dropping them.
    """
    allowed_mentions = discord.AllowedMentions.none()
    pending_lines = []
    next_send_at = 0.0
    retry_delay = 0.0

    while True:
        items = []
        try:
            first = await discord_send_queue.get_debug()
            items.append(first)

            # 500ms batching window.
            await asyncio.sleep(DEBUG_BATCH_WINDOW)

            while True:
                try:
                    items.append(discord_send_queue.debug_queue.get_nowait())
                except asyncio.QueueEmpty:
                    break

            # Preserve ordering and combine by channel.
            grouped = {}
            for message_type, channel_id, message in items:
                grouped.setdefault(channel_id, []).append(str(message))

            for channel_id, messages in grouped.items():
                channel = bot.get_channel(channel_id)
                if channel is None:
                    print(f"[comod_bot] Debug channel {channel_id} not found.")
                    continue

                lines = []
                for msg in messages:
                    msg = msg.replace("\r", "").strip()
                    if msg:
                        lines.append(msg)

                if not lines:
                    continue

                text = "\n".join(lines)
                chunks = [text[i:i+DEBUG_MAX_CHARS] for i in range(0, len(text), DEBUG_MAX_CHARS)]

                # Respect the local send interval and Discord retry timing.
                for chunk in chunks:
                    now = time.monotonic()
                    wait_for = max(0.0, next_send_at - now, retry_delay)
                    if wait_for:
                        await asyncio.sleep(wait_for)

                    try:
                        await channel.send(chunk, allowed_mentions=allowed_mentions)
                        next_send_at = time.monotonic() + DEBUG_MIN_SEND_INTERVAL
                        retry_delay = 0.0
                    except discord.HTTPException as e:
                        retry_after = getattr(e, "retry_after", None)
                        if getattr(e, "status", None) == 429 or retry_after is not None:
                            delay = float(retry_after or 1.0)
                            retry_delay = min(max(delay, 0.5), DEBUG_RETRY_CAP)
                            print(f"[comod_bot] Debug Discord rate limit; waiting {retry_delay:.2f}s.")
                            # Put unsent content back at the front-equivalent by requeueing it.
                            await discord_send_queue.debug_queue.put(("debug", channel_id, chunk))
                            break
                        raise
        except Exception as e:
            print(f"[comod_bot] Discord debug send error: {e}")
        finally:
            for _ in items:
                discord_send_queue.debug_done()

async def process_lua_messages():
    for message in read_and_clear(LUA_FILE):
        await discord_send_queue.put(("relay", RELAY_CHANNEL_ID, replace_game_mentions(message)))

async def process_reports():
    for report in read_and_clear(REPORT_FILE):
        await discord_send_queue.put(("report", REPORT_CHANNEL_ID, report))

async def process_debug_actions():
    if not ENABLE_DEBUG:
        return
    debug_messages = read_and_clear(DEBUG_FILE)
    if not debug_messages:
        return
    # Queue the complete poll batch as individual lines. The debug sender
    # is responsible for the 500ms aggregation and Discord size limit.
    for message in debug_messages:
        message = str(message).replace("\r", "").strip()
        if message:
            await discord_send_queue.put(("debug", DEBUG_CHANNEL_ID, message))

MINETEST_ESCAPE_RE = re.compile(
    r"\x1b\([^)]*\)|\x1bF|\x1bE|\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b."
)
LITERAL_ESCAPE_RE = re.compile(
    r"\\x1b\([^)]*\)|\\x1bF|\\x1bE|\\x1b\[[0-9;?]*[ -/]*[@-~]|\\x1b."
)
LUANTI_TAG_RE = re.compile(r"\(c@#[0-9A-Fa-f]{3,8}\)|\(T@[^)]*\)")

def clean_server_log_line(line):
    line = MINETEST_ESCAPE_RE.sub("", str(line or ""))
    line = LITERAL_ESCAPE_RE.sub("", line)
    line = LUANTI_TAG_RE.sub("", line)
    line = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", "", line)
    return re.sub(r"[ \t]{2,}", " ", line).strip()

def read_new_server_log_lines():
    global server_log_position, server_log_initialized
    try:
        if not os.path.exists(SERVER_LOG_FILE):
            return []
        file_size = os.path.getsize(SERVER_LOG_FILE)
        if file_size < server_log_position:
            server_log_position = 0
        if not server_log_initialized:
            server_log_position = file_size
            server_log_initialized = True
            return []
        if file_size <= server_log_position:
            return []
        with open(SERVER_LOG_FILE, "r", encoding="utf-8", errors="replace") as f:
            f.seek(server_log_position)
            data = f.read()
            server_log_position = f.tell()
        return data.splitlines() if data else []
    except Exception as e:
        print(f"[comod_bot] Server log read error: {e}")
        return []

async def process_server_log():
    if not ENABLE_DEBUG:
        return
    lines = read_new_server_log_lines()
    if not lines:
        return
    cleaned = [clean_server_log_line(x) for x in lines]
    cleaned = [x for x in cleaned if x]
    if cleaned:
        # One queue item per poll; the debug sender batches further with
        # Debug_action.txt and other low-priority debug events.
        await discord_send_queue.put(
            ("server_log", DEBUG_CHANNEL_ID, "```text\n" + "\n".join(cleaned)[:1940] + "```")
        )

async def server_log_loop():
    while True:
        try:
            await process_server_log()
        except Exception as e:
            print(f"[comod_bot] Server log loop error: {e}")
        await asyncio.sleep(SERVER_LOG_INTERVAL)

async def process_command_responses():
    for response in read_and_clear(COMMAND_RESPONSE_FILE):
        try:
            parts = response.split("\t", 3)
            if len(parts) < 4:
                continue
            request_id, discord_id, result, text = [x.strip() for x in parts]
            pending = pending_commands.pop(request_id, None)
            if pending is None or discord_id != pending["discord_id"]:
                continue
            message = f"✅ {text}" if result.upper() == "OK" else f"❌ {text}"
            await discord_send_queue.put(("command_response", pending["channel_id"], message))
        except Exception as e:
            print(f"[comod_bot] Command response error: {e}")

def process_command_timeouts():
    now = time.time()
    for request_id, data in list(pending_commands.items()):
        if now - data["created"] > COMMAND_TIMEOUT:
            pending_commands.pop(request_id, None)
            asyncio.create_task(discord_send_queue.put(("command_timeout", data["channel_id"], "❌ Command timed out. Make sure you are logged in with `/login` and the Luanti server is running.")))

def read_identity_file():
    mappings = {}
    if not os.path.exists(IDENTITY_FILE):
        return mappings
    try:
        with open(IDENTITY_FILE, "r", encoding="utf-8") as f:
            for line in f:
                parts = line.rstrip("\n").split("\t", 2)
                if len(parts) < 2:
                    continue
                user_id, username = parts[0].strip(), parts[1].strip()
                nickname = parts[2].strip() if len(parts) >= 3 else ""
                if user_id and username:
                    mappings[user_id] = (username, nickname)
    except Exception as e:
        print(f"[comod_bot] Identity read error: {e}")
    return mappings

def write_identity_file(mappings):
    temp_file = IDENTITY_FILE + ".tmp"
    try:
        with open(temp_file, "w", encoding="utf-8") as f:
            for user_id, (username, nickname) in mappings.items():
                f.write(f"{user_id}\t{username}\t{nickname}\n")
            f.flush()
        os.replace(temp_file, IDENTITY_FILE)
        return True
    except Exception as e:
        print(f"[comod_bot] Identity write error: {e}")
        try:
            if os.path.exists(temp_file):
                os.remove(temp_file)
        except Exception:
            pass
        return False

def set_discord_identity(user_id, username, nickname):
    mappings = read_identity_file()
    mappings[str(user_id)] = (username, nickname)
    return write_identity_file(mappings)

def remove_discord_identity(user_id):
    mappings = read_identity_file()
    mappings.pop(str(user_id), None)
    return write_identity_file(mappings)

async def process_login_responses():
    for response in read_and_clear(AUTH_RESPONSE_FILE):
        try:
            parts = response.split("\t", 5)
            if len(parts) >= 6:
                request_id, discord_id, username, result, message = [x.strip() for x in parts[:5]]
                privileges = parts[5].strip()
            elif len(parts) == 5:
                request_id, discord_id, username, result, message = [x.strip() for x in parts]
                privileges = ""
            elif len(parts) == 4:
                # Backward-compatible with the previous init.lua response:
                # request_id, discord_id, result, message/privileges
                request_id, discord_id, result, message = [x.strip() for x in parts]
                pending_old = pending_logins.get(request_id)
                username = pending_old.get("username", "") if pending_old else ""
                privileges = message if result.upper() == "OK" else "" 
                if result.upper() == "OK":
                    message = ""
            else:
                continue
            pending = pending_logins.pop(request_id, None)
            if pending is None or discord_id != pending["discord_id"]:
                continue
            if result.upper() == "OK":
                nickname = pending.get("nickname", "")
                if not set_discord_identity(discord_id, username, nickname):
                    await discord_send_queue.put(("login_error", pending["channel_id"], "❌ Login succeeded, but the Discord identity could not be saved."))
                    continue
                sessions[pending["token"]] = {"user_id": int(discord_id), "username": username, "time": time.time()}
                privilege_text = f"\nPrivileges: `{privileges}`" if privileges else ""
                await discord_send_queue.put(("login_success", pending["channel_id"], f"✅ Logged in as **{username}**.{privilege_text}"))
            else:
                sessions.pop(pending["token"], None)
                await discord_send_queue.put(("login_failed", pending["channel_id"], f"❌ {message or 'Login failed.'}"))
        except Exception as e:
            print(f"[comod_bot] Login response error: {e}")

def process_login_timeouts():
    cleanup_sessions()
    now = time.time()
    for request_id, data in list(pending_logins.items()):
        if now - data["created"] > LOGIN_TIMEOUT:
            pending_logins.pop(request_id, None)
            sessions.pop(data["token"], None)

@bot.event
async def on_member_join(member):
    invalidate_mention_cache()

@bot.event
async def on_member_remove(member):
    invalidate_mention_cache()

@bot.event
async def on_member_update(before, after):
    invalidate_mention_cache()

@bot.event
async def on_guild_role_create(role):
    invalidate_mention_cache()

@bot.event
async def on_guild_role_delete(role):
    invalidate_mention_cache()

@bot.event
async def on_guild_role_update(before, after):
    invalidate_mention_cache()

@bot.tree.command(name="help", description="Show Creative Oasis Discord bot help")
async def discord_help(interaction: discord.Interaction):
    await interaction.response.send_message("/login\n/logout\n/help\n! +\n!cmd +\nin-game cmd", ephemeral=True)

class LoginModal(discord.ui.Modal, title="Creative Oasis Login"):
    username = discord.ui.TextInput(label="Luanti username", placeholder="Your in-game username", required=True, max_length=32)
    password = discord.ui.TextInput(label="Luanti password", placeholder="Your Luanti password", required=True, min_length=1, max_length=128, style=discord.TextStyle.short)

    async def on_submit(self, interaction: discord.Interaction):
        user_id = str(interaction.user.id)
        now = time.time()
        previous = last_login_attempt.get(interaction.user.id, 0)
        if now - previous < LOGIN_COOLDOWN:
            await interaction.response.send_message("Please wait before trying `/login` again.", ephemeral=True)
            return
        last_login_attempt[interaction.user.id] = now
        request_id = uuid.uuid4().hex[:12]
        pending_logins[request_id] = {
            "discord_id": user_id,
            "channel_id": interaction.channel_id,
            "token": create_login_token(interaction.user.id),
            "username": str(self.username.value).strip(),
            "nickname": interaction.user.display_name if USE_NICKNAMES else interaction.user.name,
            "created": time.time(),
        }
        request = f"{request_id}\t{user_id}\t{pending_logins[request_id]['username']}\t{self.password.value}"
        if not write_if_empty(AUTH_REQUEST_FILE, [request]):
            pending_logins.pop(request_id, None)
            await interaction.response.send_message("❌ Login system is busy. Please try again.", ephemeral=True)
            return
        await interaction.response.send_message("Login request sent. Please wait a moment.", ephemeral=True)

@bot.tree.command(name="login", description="Login your Discord account to Luanti")
async def login(interaction: discord.Interaction):
    await interaction.response.send_modal(LoginModal())

@bot.tree.command(name="logout", description="Logout your Discord account from Luanti")
async def logout(interaction: discord.Interaction):
    user_id = interaction.user.id
    for request_id, data in list(pending_logins.items()):
        if data["discord_id"] == str(user_id):
            pending_logins.pop(request_id, None)
    for request_id, data in list(pending_commands.items()):
        if data["discord_id"] == str(user_id):
            pending_commands.pop(request_id, None)
    removed = []
    for token, data in list(sessions.items()):
        if data["user_id"] == user_id:
            sessions.pop(token, None)
            removed.append(token)
    identity_removed = remove_discord_identity(user_id)
    await interaction.response.send_message("You have been logged out." if removed or identity_removed else "You were not logged in.", ephemeral=True)

@bot.event
async def setup_hook():
    try:
        synced = await bot.tree.sync()
        print(f"[comod_bot] Synced {len(synced)} slash command(s).")
    except Exception as e:
        print(f"[comod_bot] Slash command sync error: {e}")
    asyncio.create_task(relay_loop())
    asyncio.create_task(discord_sender())
    asyncio.create_task(discord_debug_sender())
    asyncio.create_task(server_log_loop())
    asyncio.create_task(server_status_loop())

async def relay_loop():
    print("[comod_bot] Relay loop started.")
    while True:
        start = time.monotonic()
        try:
            await write_discord_messages()
            await process_lua_messages()
            await process_reports()
            await process_debug_actions()
            await process_command_responses()
            process_command_timeouts()
            await process_login_responses()
            process_login_timeouts()
        except Exception as e:
            print(f"[comod_bot] Relay error: {e}")
        await asyncio.sleep(max(0.01, COOLDOWN - (time.monotonic() - start)))

bot.run(BOT_TOKEN)
