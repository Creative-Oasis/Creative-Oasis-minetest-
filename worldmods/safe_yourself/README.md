# Luanti mod: safe_yourself

This mod provides rescue commands for players who get stuck in death loops, which can happen when using an outdated client to connect to a server. The mod automatically detects players using older protocol versions and notifies them about available rescue commands.

## Features

- **Automatic detection** of players using old clients based on protocol version
- **0 HP detection** - notifies players who join with 0 HP (can happen than respawn formspec is hidden by game formspec)
- **Configurable rescue commands** to help players escape death loops:
  - Respawn command - forces player respawn
  - One HP command - sets player HP to 1 if they have 0 HP
- **Customizable notifications** with configurable colors and timing
- **Smart notification system** - avoids sending duplicate notifications (0 HP takes priority over old client warning)
- **Flexible configuration** - command names, colors, delays, and thresholds can be adjusted via settings
- **Server logging** - administrators are informed about players with old clients or 0 HP on join

## Commands

- `/safe_yourself_respawn` - Respawn yourself if stuck in death
- `/safe_yourself_one_hp` - Set your HP to 1 if you have 0 HP

Note: Command names can be customized in mod settings.

## Configuration

All settings can be configured in `minetest.conf` or through the game's settings menu. See `settingtypes.txt` for all available options including:
- Custom command names
- Notification colors (supports hex codes and named colors)
- Notification delay timing
- Protocol version threshold for old client detection

## Source code

Copyright (c) 2026 SFENCE
MIT - check [LICENSE.md] file
