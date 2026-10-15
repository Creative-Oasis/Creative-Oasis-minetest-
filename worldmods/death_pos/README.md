# Death Position

Minetest mod that adds a command to teleport to player's last death position

### Usage

Use ``/death_pos`` command to return back to the last death position.

#### Settings
To disable message that sends a tip when player dies, add setting ``death_pos.send_tip_on_die`` in ``minetest.conf`` and set it to ``false``, it should be like this: ``death_pos.send_tip_on_die = false``. When player uses the ``/death_pos`` command it clears the death pos and the player can't teleport to the last death position again, but you can disable it, add this setting in ``minetest.conf``: ``death_pos.clear_pos = false``.
