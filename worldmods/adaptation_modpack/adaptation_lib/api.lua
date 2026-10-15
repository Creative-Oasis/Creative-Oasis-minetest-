
-- ITEMS
function adaptation_lib.get_item(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  for _,key in pairs(variants) do
    local item_data = adaptation_lib.items[key]
    if item_data then
      return item_data
    end
  end
  return nil
end

function adaptation_lib.get_items(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  local items = {}
  for _,key in pairs(variants) do
    local item_data = adaptation_lib.items[key]
    if item_data then
      items[key] = item_data
    end
  end
  return items
end

function adaptation_lib.add_item(keys, data, auto_take, param, disable_check)
  if (not data.name) then
    error "[adaptation_lib]: Registration of item without name is not allowed."
    return
  end
  if (type(keys)=="string") then
    keys = {keys}
  end
  for _,key in pairs(keys) do
    if (not adaptation_lib.items[key]) then
      adaptation_lib.items[key] = data
    else
      minetest.log("error", "[adaptation_lib]: Key "..key.." is already registered (name is "..data.name..").")
    end
  end
  
  if data.lists then
    for _,list in pairs(data.lists) do
      adaptation_lib.add_list_item(list, data.name)
    end
  end
  
  local def = minetest.registered_items[data.name]
  if (not def) then
    def = ItemStack(data.name):get_definition()
  end
  if (not def) and (not disable_check) then
    minetest.log("error", "[adaptation_lib]: Item "..data.name.." definition missing.")
  end
  if auto_take then
    if def then
      auto_take(data, def, param)
    elseif (disable_check) then
      minetest.log("error", "[adaptation_lib]: Callback auto_take failed. Item "..data.name.." definition missing.")
    end
  end
end

function adaptation_lib.update_item(key, update)
  local data = adaptation_lib.items[key]
  if data then
    for key,value in pairs(update) do
      data[key] = value
    end
  end
end

function adaptation_lib.get_registered_item(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  for _,key in pairs(variants) do
    if minetest.registered_items[key] then
      return key
    end
  end
  return nil
end

function adaptation_lib.get_registered_items(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  local items = {}
  for _,key in pairs(variants) do
    if minetest.registered_items[key] then
      table.insert(items, key)
    end
  end
  return items
end

-- LISTS
function adaptation_lib.get_list(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  for _,key in pairs(variants) do
    local list = adaptation_lib.lists[key]
    if list then
      return list
    end
  end
  return nil
end

function adaptation_lib.add_list_item(list, items)
  if (type(items)=="string") then
    items = {items}
  end
  adaptation_lib.lists[list] = adaptation_lib.lists[list] or {}
  for _,item in pairs(items) do
    table.insert(adaptation_lib.lists[list], item)
  end
end

function adaptation_lib.add_list_item_n(list, items, count)
  if (type(items)=="string") then
    items = {items}
  end
  adaptation_lib.lists[list] = adaptation_lib.lists[list] or {}
  for _,item in pairs(items) do
    for n = 1,count do
      table.insert(adaptation_lib.lists[list], item..n)
    end
  end
end

-- GROUPS

adaptation_lib.unknown_group = "-unknown_group-"

function adaptation_lib.get_group(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  for _,key in pairs(variants) do
    local group_data = adaptation_lib.groups[key]
    if group_data then
      return group_data
    end
  end
  return nil
end

function adaptation_lib.add_group(key, group_name)
  adaptation_lib.groups[key] = group_name
end

-- MODS
function adaptation_lib.get_mod(variants)
  if (type(variants)=="string") then
    variants = {variants}
  end
  for _,key in pairs(variants) do
    local mod_data = adaptation_lib.mods[key]
    if mod_data then
      return mod_data
    end
  end
  return nil
end

function adaptation_lib.add_mod(key, data)
  adaptation_lib.mods[key] = data
end

-- HELP

function adaptation_lib.check_keys_aviable(log_identificator, where, keys)
  local check = true
  for _,key in pairs(keys) do
    if (not where[key]) then
      if log_identificator then
        minetest.log("error", log_identificator.."key "..key.." is missing.")
      end
      check = false
    end
  end
  return check
end
  
adaptation_lib.unknown_item = "-unknown_item-"

function adaptation_lib.get_item_name(item_data)
  if item_data and item_data.name then
    return item_data.name
  end
  return adaptation_lib.unknown_item
end

function adaptation_lib.get_item_name_or_nil(item_data)
  if item_data and item_data.name then
    return item_data.name
  end
  return nil
end

function adaptation_lib.get_craft_replacements(finished, unfinished)
  local replacements = {}
  for _,replacement in pairs(finished or {}) do
    table.insert(replacements, replacement)
  end
  for _,item in pairs(unfinished or {}) do
    if item.name_craft_replace then
      table.insert(replacements, {item.name, item.name_craft_replace})
    end
  end
  return replacements
end

