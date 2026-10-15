# Tooltip API

This API provides a way for mods to collaboratively manage item tooltips, i.e. the `description` field of an item def and the `description` metadata field of an itemstack.

## Fields

Add these to the item definition.

* `_tt_ignore`: If `true`, the `description` of this item won’t be altered at all
* `_tt_help`: Custom help text to be added to the description

Once this mod has overwritten the `description` field of an item, it will save the original (unaltered) `description` in the `_tt_original_description` field.

## Snippets

Snippets are individual description fragments that are concatenated together by tt to produce the final description of an item or itemstack.

Mods register functions that create these snippets based either on the name of the item (typically by looking at properties of the item definition, e.g. groups) or an individual item stack (so the tooltip can change dynamically depending on itemstack meta data).

### `tt.register_snippet(func)`
### `tt.register_itemstack_snippet(func)`

These register a custom snippet function either based on an item name or an item stack.
`func` is a function of the form `func(itemstring)` or `func(itemstack)` respectively.

Item name based snippet functions will be passed the name of the item (extracted from the item stack when updating an itemstack description), and item stack based snippet functions will be passed an itemstack (built from the item name when run during server initialization).

Snippet functions should return two values, of which the first one is required.

1st return value: A string to be appended to the combined description or `nil` if nothing shall be appended.

2nd return value: If omitted or explicitly `nil`, `tt` will colorize the snippet with the default text color. If a ColorString in `"#RRGGBB"` format, that color is used to colorize the snippet. Return `false` to force `tt` to not apply any text colorization (e.g. to apply more than one color by calling `minetest.colorize` in the snippet function itself).

Example:

    tt.register_snippet(function(itemstring)
        if minetest.get_item_group(itemstring, "magic") == 1 then
            return "This item is magic"
        end
    end)

This mod automatically computes descriptions for (nearly) all items in an `on_mods_loaded` callback. This covers most use cases, but there are two situations where mods are required to explicitly ask `tt` to update a description:

1. snippet relevant properties of an item get modified in some mod’s `on_mods_loaded` callback (and `tt`’s `on_mods_loaded` callback may have run already)
2. snippet relevant properties of an item stack get modified

### `tt.update_item_description(itemstring)`

Override the item description with the (re)computed combined description (and set `_tt_original_description` if necessary).

A mod that registers a snippet that may be affected by `on_mods_loaded` callbacks registered in the mod itself or other mods can use the following approach:

1. change mod.conf to—in addition to the `tt` mod—(optionally) depend on all mods that are known to override—in those mod’s `on_mods_loaded` callbacks—items in a way relevant for any snippet registered by this mod
2. add an `on_mods_loaded` callback to the mod—which will run after the callbacks registered by the mods depended upon in the first step—and call `tt.update_item_description` for any item that may have been changed after `tt`’s `on_mods_loaded` callback was called

This function has no effect after server initialization is finished.

## `tt.update_itemstack_description(itemstack)`

Compute the combined description for the `itemstack`’s current state and update the `"description"` field in its metadata.

Will remove the `"description"` field from the stack’s metadata if the snippets recreate the default description to reenable stackability with "fresh" items (this only works if other mods do the same for the metadata fields used by them).

Returns: the modified stack
