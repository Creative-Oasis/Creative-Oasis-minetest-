# Staffranks -- By Salzar

This mod adds ranks, in chat and in nametags.

## Base ranks

All ranks can be found in ranks.lua.

* Administrator
* Moderator
* Developer
* Builder
* Contributor
* VIP

## Logs

You can see the logs in the world folder (`Luanti/worlds/<worldname>`).

## Commands

### Without Chat Command Builder:

* `/add_rank <name> <rankname>` - Add a rank to a player. If the rank name is 'clear', it resets the player's rank.
* `/ranks_list` - See the list of all ranks.
* `/view_rank <name>` - View a player's rank.

### With Chat Command Builder (recommended):

* `/ranks <add | clear | view | list> [<player>]` - Add, clear, view, or list all ranks of players.

## Customization

If you want to modify existing ranks or create new ones, simply use the `staffranks.register_rank()` function and add the rank name, prefix, and color.

## API

* `staffranks.register_rank(name, prefix, color)` - Registers a rank, with its name, prefix, and color.
* `staffranks.rank_exist(rankname)` - Checks that the rank exists.
* `staffranks.add_rank(name, rankname)` - Adds a specific rank to a player.
* `staffranks.set_nametag(player)` - Sets a player's nametag.
* `staffranks.clear_nametag(player)` - Removes a player's nametag.
* `staffranks.rankslist()` - Displays the list of ranks.
* `staffranks.has_rank(player_name, rankname)` - Checks whether a player has a specific rank.
* `staffranks.log(level, message)` - Saves a message in the logs (with different levels: `message` (chat) or `info`).