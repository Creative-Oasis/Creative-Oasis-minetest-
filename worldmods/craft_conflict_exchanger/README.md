# Craft Conflict Exchanger

A mod for [Luanti](www.luanti.org). Download this mod at [ContentDB](https://content.luanti.org/packages/ZenonSeth/craft_conflict_exchanger/)

Adds a machine that displays crafting and cooking recipe conflicts.

Also automatically allows exchange of items that share the same recipe, and thus for players to get items which cannot be crafted directly due to recipe conflicts.

## How to use the Exchanger
See [the wiki page for details](https://github.com/ZenonSeth/craft-conflict-exchanger/wiki)

## How to get the Exchanger

There's 2 ways, both enabled by default, but both may be disabled by server-wide setting (See settingtypes below)

1. Crafting recipe. This recipe uses groups, rather than items.
```
W = group:wood, S = group:stone
+---+---+---+
|   | S |   |
+---+---+---+
| W | W | S |
+---+---+---+
|   | S | W |
+---+---+---+
```

2. Chat command
Simply enter the command: `/item-exchanger` in chat, and if server has not disabled it, you will be given an Exchanger

## Dependencies
- [Respec](https://content.luanti.org/packages/ZenonSeth/respec/): formspec creation library, which itself has no dependencies.

## Compatibility

Exchanger functionality (listing conflicts and allowing exchanges) is compatible with any game.

The Exchanger's crafting recipe users group names, not specific items, so it is compatible with any default- and mcl- based games. 

It's also possible to obtain the Exchanger via a console command, which does not depend on any specific game.

## settingtypes

- `craft_conflict_exchanger_allow_exchanger_crafting` : `boolean`, default `true` - Whether the Exchanger node is craftable via craft recipe
- `craft_conflict_exchanger_allow_exchanger_command` : `boolean`, default `true` - Whether the Exchanger node can be obtained via console command
