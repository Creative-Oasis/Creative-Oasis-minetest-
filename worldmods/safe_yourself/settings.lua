
safe_yourself.settings = {}

local settings = safe_yourself.settings

-- Command names configuration
settings.respawn_command = core.settings:get("safe_yourself.respawn_command") or "safe_yourself_respawn"
settings.one_hp_command = core.settings:get("safe_yourself.one_hp_command") or "safe_yourself_one_hp"

-- Notification settings
settings.notify_old_clients = core.settings:get_bool("safe_yourself.notify_old_clients", true)
settings.notification_color = core.colorspec_to_colorstring(core.settings:get("safe_yourself.notification_color")) or "#FF8800"
settings.notification_delay = tonumber(core.settings:get("safe_yourself.notification_delay")) or 2.0
