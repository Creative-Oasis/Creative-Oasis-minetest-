# Adaptation lib API

## Manupulate items API

### `adaptation_lib.get_item(variants)`

* return first found key item data or nil
* variants - string or array of strings with wanted keys

```
  local coal = adaptation_lib.get_item("lump_coal")
  
  local graphite = adaptation_lib.get_item({"graphite", "lump_charcoal, ""lump_coal"})
```

### `adaptation_lib.get_items(variants)`

* return all found keys item data or empty array
* variants - string or array of strings with wanted keys 

```
  local fire_sources = adaptation_lib.get_items({"flint_and_steel","torche"})
```

### `adaptation_lib.add_item(item_keys, item_data, auto_take, take_param, disable_check)`

* Add item to item list
* Metadata of node isn't affected.
* `item_keys` - string or array of strings with key names
* `item_data` - data of item. Field name is required
* `auto_take` - callback or nil, params `auto_take(item_data, def, take_param)`, update `item_data` from registered item definition
* `take_param` - parameters for `auto_take` callback
* `disbale_check` - prevent error log when adding items whithout definition

#### `item_data` table fields

* 'name' - required fiel with registered item name
* `name_craft_replace` - nil or name of empty replace item in craft recipes
* `lists` - optional array of list keys, for add item name
* `tiles` - list of textures, can be `auto_take` by `adaptation_lib.auto_take_tile_sounds` or `adaptation_lib.auto_take_images_sounds` from item definition
* `tile` - first image in `tiles` list
* `inventory_image` - can be `auto_take` by `adaptation_lib.auto_take_images_sounds` from item definition

* `inventory_overlay` - can be `auto_take` by `adaptation_lib.auto_take_images_sounds` from item definition
* `wield_image` - can be `auto_take` by `adaptation_lib.auto_take_images_sounds` from item definition
* `wield_overlay` - can be `auto_take` by `adaptation_lib.auto_take_images_sounds` from item definition
* `sounds` - sounds of item/node, can be `auto_take` by `adaptation_lib.auto_take_tile_sounds` or `adaptation_lib.auto_take_images_sounds` from item definition


### `adaptation_lib.update_item(key, update)`

* Update already registered key item data
* key - key for update
* udpate - update data

### `adaptation_lib.get_registered_item(variants)`

* return first found registered item
* variants - string or array of strings with wanted item names

```
local marble = adaptation_lib.get_registered_item({"technic:marble", "hades_core:marble", "greek:marble"})
```

### `adaptation_lib.get_registered_items(variants)`

* return list of all found registered items
* variants - string or array of strings with wanted item names

```
local stones = adaptation_lib.get_registered_items({"default:stone", "default:desert_stone", "hades_core:stone", "hades_core:chondrite"})
```

## Manupulate list API

### `adaptation_lib.get_list(variants)`

* Return first found list or nil.
* variantas - string or array of string

```
  local ropes = adaptation_lib.get_list("rope")
```

### `adaptation_lib.add_list_item(list, items)`

* Add items to list.
* list - list name
* items - string or array of string with registered item names

### `adaptation_lib.add_list_item_n(list, items, count)`

* Add items to list.
* list - list name
* items - string or array of string with registered item names
* count - count if items, number will be added to the end of item name taken from items list (can be used like `add_list_item_n("grass", "default:grass_", 5)`

## Manupulate groups API

### `adaptation_lib.get_group(variants)`

* Return first found group or nil.
* variantas - string or array of string

```
  local group_wood = adaptation_lib.get_group("wood")
```

### `adaptation_lib.add_group(key, group_string)`

* Add group to group list.
* key - string with group key
* `group_string` - group name (like `group:wood`, `group:stick`, `mcl_core:strick` etc.)

## Manupulate mods API

### `adaptation_lib.get_mod(variants)`

* Return first found mod or nil.
* variantas - string or array of string

```
  local player_mod = adaptation_lib.get_mod("player")
```

### `adaptation_lib.add_mod(key, mod_data)`

* Add mod to mod list.
* key - string with mod key
* `mod_data` - table of mod data

## Help functions

Predefined callbacks and etc.

### `adaptation_lib.check_keys_aviable(log_id, where, keys)`

* Check aviable of keys in where table. Return true if all keys is aviable. Print log message for every missing key
* `log_id` - Begining of log message or nil to disable log
* where - table where keys should be
* keys - array of keys for check 

```
  adaptation.coal = adaptation_lib.get_item("lump_coal")
  adaptation.copper = adaptation_lib.get_item("ingot_copper")
  
  if (not adaptation_lib.check_keys_aviable("[test_mod] Test keys check: ", adaptation, {"coal", "copper"})) then
    return
  end
```

### `adaptation_lib.get_item_name(item_data)`

* Return item name or unknown item string if name is not aviable.
* `item_data` - data of item returned from `adaptation_lib.get_item`

```
  adaptation.coal = adaptation_lib.get_item("lump_coal")
  adaptation.copper = adaptation_lib.get_item("ingot_copper")
  
  local N = adaptation_lib.get_item_name
  
  minetest,register_craft({
      output = "test_mod:copper_item",
      recipe = {
        {N(adaptation.copper), "test_mod:mod_item"},
        {"", N(adaptation.copper)},
      }
    })
```

### `adaptation_lib.get_item_name_or_nil(item_data)`

* Return item name or nil.
* `item_data` - data of item returned from `adaptation_lib.get_item`

### `adaptation_lib.get_craft_replacements(finished, unfinished)`

* Complete replacements table for craft recipe.
* finished - array of item pairs `{recipe_item, replace_item}`
* unfinished - array of `item_data`, replaced by `{item_data.name, item_data.name_craft_replace}` if `name_craft_replace` is aviable.

```
  adaptation.coal = adaptation_lib.get_item("lump_coal")
  adaptation.copper_wire = adaptation_lib.get_item("wire_copper")
  
  local N = adaptation_lib.get_item_name
  
  minetest,register_craft({
      output = "test_mod:copper_item",
      recipe = {
        {N(adaptation.copper_wire), "test_mod:mod_item"},
        {"", N(adaptation.copper_wire)},
      },
      replacements = adaptation_lib.get_craft_replacements(
          {{"test_mod:mod_item","test_mod:mod_item_empty"},},
          {adaptation.copper_wire, adaptation.copper_wire},
        ),
    })
```

