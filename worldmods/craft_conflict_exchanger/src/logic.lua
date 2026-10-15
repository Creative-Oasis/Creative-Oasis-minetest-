
local shapedCraftConflicts = {}
local shapelessCraftConflicts = {}
local cookConflicts = {}
local LIST_MAIN = "main"

--[[
  swappable tables format:
  item_name = {
    input = ItemStack,
    outputs = { ItemStack, ItemStack, ItemStack }
  }
--]]
local swappableShaped = {}
local swappableShapeless = {}
local swappableCook = {}

-- needed because aliases exist and can be used in recipes
local function get_actual_name(itemName)
  return ItemStack(itemName):to_string()
end

----------------------------------------------------------------
-- Recipe processing
----------------------------------------------------------------

local function pad_and_compact_recipe_items(recipeItems, recipeWidth)
  local newItems = {}

  -- replace nil entires with empty string
  if recipeWidth == 1 then
    newItems[1] = recipeItems[1] ; newItems[4] = recipeItems[2] ; newItems[7] = recipeItems[3]
  elseif recipeWidth == 2 then
    newItems[1] = recipeItems[1] ; newItems[2] = recipeItems[2]
    newItems[4] = recipeItems[3] ; newItems[5] = recipeItems[4]
    newItems[7] = recipeItems[5] ; newItems[8] = recipeItems[6]
  else
    for i = 1,9 do newItems[i] = recipeItems[i] end
  end

  -- fill in missing pieces and actual names
  for i = 1,9 do
    if newItems[i] == nil then newItems[i] = ""
    else newItems[i] = get_actual_name(newItems[i]) end
  end

  -- compact empty rows
  if newItems[1] == "" and newItems[2] == "" and newItems[3] == "" then
    if newItems[4] == "" and newItems[5] == "" and newItems[6] == "" then
      -- two empty rows
      newItems[1] = newItems[7] ; newItems[2] = newItems[8] ; newItems[3] = newItems[9]
      newItems[7] = "" ;          newItems[8] = "" ;          newItems[9] = ""
    else
      -- one empty row
      newItems[1] = newItems[4] ; newItems[2] = newItems[5] ; newItems[3] = newItems[6]
      newItems[4] = newItems[7] ; newItems[5] = newItems[8] ; newItems[6] = newItems[9]
      newItems[7] = "" ;          newItems[8] = "" ;          newItems[9] = ""
    end
  end
  -- compact empty columns
  if newItems[1] == "" and newItems[4] == "" and newItems[7] == "" then
    if newItems[2] == "" and newItems[5] == "" and newItems[8] == "" then
      -- two empty columns
      newItems[1] = newItems[3] ; newItems[4] = newItems[6] ; newItems[7] = newItems[9]
      newItems[3] = "" ;          newItems[6] = "" ;          newItems[9] = ""
    else
      -- one empty column
      newItems[1] = newItems[2] ; newItems[4] = newItems[5] ; newItems[7] = newItems[8]
      newItems[2] = newItems[3] ; newItems[5] = newItems[6] ; newItems[8] = newItems[9]
      newItems[3] = "" ;          newItems[6] = "" ;          newItems[9] = ""
    end
  end

  return newItems
end

-- returns a single string value as the key, where items are separated by |
local function make_shapeless_recipe_key(recipe)
  local items = {}
  for _, item in ipairs(recipe) do
    table.insert(items, item)
  end
  table.sort(items)
  return table.concat(items, "|")
end

local function make_width_recipe_key(recipe, width)
  local items = {}
  for _, item in ipairs(recipe) do
    table.insert(items, item or "")
  end
  return ""..width.."|"..table.concat(items, "|")
end

local function append_if_not_present(list, item)
  for _, v in ipairs(list) do
    if v == item then return end
  end
  table.insert(list, item)
end

local function process_shaped_recipe(itemName, itemRecipe, itemRecipeWidth)
  itemRecipeWidth = itemRecipeWidth or 3
  local newShapedKey = make_width_recipe_key(itemRecipe, itemRecipeWidth)
  if shapedCraftConflicts[newShapedKey] ~= nil then
    -- conflicted detected, just add it to that recipes list of outputs
    append_if_not_present(shapedCraftConflicts[newShapedKey], itemName)
    return
  end
  -- if we got here, it's not a conflict recipe (yet), add new entry
  shapedCraftConflicts[newShapedKey] = { itemName }
  shapedCraftConflicts[newShapedKey].recipe = itemRecipe
end

local function process_shapeless_recipe(itemName, itemRecipe)
  local newShapelessKey = make_shapeless_recipe_key(itemRecipe)
  if shapelessCraftConflicts[newShapelessKey] ~= nil then
    -- conflicted detected, just add it to that recipes list of outputs
    append_if_not_present(shapelessCraftConflicts[newShapelessKey], itemName)
    return
  end
  -- if we got here, it's not a conflict recipe (yet), add new entry
  shapelessCraftConflicts[newShapelessKey] = { itemName }
  shapelessCraftConflicts[newShapelessKey].recipe = itemRecipe
end

local function process_cook_recipe(itemName, itemRecipe)
  local newCookKey = make_width_recipe_key(itemRecipe, 1)
  if cookConflicts[newCookKey] ~= nil then
    -- conflicted detected, just add it to that recipes list of outputs
    append_if_not_present(cookConflicts[newCookKey], itemName)
    return
  end
  -- if we got here, it's not a conflict recipe (yet), add new entry
  cookConflicts[newCookKey] = { itemName }
  cookConflicts[newCookKey].recipe = itemRecipe
end

local function process_recipe_for(itemName, recipe)
  if type(recipe) ~= "table" or not recipe.method or recipe.method == "fuel" then return end
  if recipe.output == "" then return end

  if recipe.method == "normal" then
    if recipe.width > 0 then
      local paddedItems = pad_and_compact_recipe_items(recipe.items, recipe.width)
      process_shaped_recipe(get_actual_name(recipe.output), paddedItems, 3) -- width always 3 due to our padding
    else
      process_shapeless_recipe(get_actual_name(recipe.output), recipe.items)
    end
  elseif recipe.method == "cooking" then
    process_cook_recipe(recipe.output, recipe.items)
  end
end

----------------------------------------------------------------
-- creating swappable tables
----------------------------------------------------------------

local function make_itemstack_list_from_items(items)
  local ret = {}
  for _, itemName in ipairs(items) do
    ret[#ret+1] = ItemStack(itemName)
  end
  return ret
end

local function compile_swappable_table_and_get_trimmed(swappableTable, conlictsTable)
  local trimmedConflictsTable = {}
  for _, items in pairs(conlictsTable) do
    if #items > 1 then
      local itemstackList = make_itemstack_list_from_items(items)
      itemstackList.recipe = items.recipe
      trimmedConflictsTable[#trimmedConflictsTable+1] = itemstackList
      for _, itemstack in ipairs(itemstackList) do
        if swappableTable[itemstack:get_name()] == nil then swappableTable[itemstack:get_name()] = {} end
        table.insert(swappableTable[itemstack:get_name()], itemstackList)
      end
    end
  end
  return trimmedConflictsTable
end

local function compile_swappable_tables_and_trim_conflicts()
  shapedCraftConflicts = compile_swappable_table_and_get_trimmed(swappableShaped, shapedCraftConflicts)
  shapelessCraftConflicts = compile_swappable_table_and_get_trimmed(swappableShapeless, shapelessCraftConflicts)
  cookConflicts = compile_swappable_table_and_get_trimmed(swappableCook, cookConflicts)
end

local function add_swapple_entry_into(swapTableOfTables, itemName, outputTable)
  for _, swapTable in ipairs(swapTableOfTables) do
    local result = {}
    local exchanges = {}
    for _, itemstack in ipairs(swapTable) do
      result.recipe = swapTable.recipe
      if itemstack:get_name() ~= itemName then
        exchanges[#exchanges+1] = itemstack
      else
        result.input = itemstack
      end
    end
    result.exchanges = exchanges
    outputTable[#outputTable+1] = result
  end
end

-- registration of callback

core.register_on_mods_loaded(function()
  for itemName, _ in pairs(core.registered_items) do
    local recipes = core.get_all_craft_recipes(itemName)
    if type(recipes) == "table" then
      for _, recipe in ipairs(recipes) do
        process_recipe_for(itemName, recipe)
      end
    end
  end
  compile_swappable_tables_and_trim_conflicts()

  -- core.after(10, function()
  --   core.debug("shaped conflicts = "..dump(swappableShaped))
  --   core.debug("shapeless conflicts = "..dump(swappableShapeless))
  --   core.debug("cook conflicts = "..dump(swappableCook))
  -- end)

end)

----------------------------------------------------------------
-- Exchange logic and player inv management
----------------------------------------------------------------

-- find the smallest number that can be taken from the input stack at a time and given as a whole to output
-- aka preserving the ratio between the take/give amounts and original stack sizes
-- Brute force, but worst is O(n)~outputStackSize and stack sizes are rarely big
-- returns table: `{ smallestTake = smallestTake, smallestGive = smallestGive }`
local function find_smallest_take_amount(inputStackSize, outputStackSize)
  local iss, oss, smallestGive = inputStackSize, outputStackSize, outputStackSize
  for i = 1, oss - 1 do
    -- Check must meet condition: is_whole_number(iss / oss * (oss - i))
    local div = iss * (oss - i) / oss
    if div == math.floor(div) then smallestGive = oss -  i end
  end
  return { smallestTake = iss * smallestGive / oss, smallestGive = smallestGive }
end

local function put_in_player_inv_or_drop_at_feet(playerObj, itemStack)
  local inv = playerObj:get_inventory()
  if not inv then return end
  local leftover = inv:add_item(LIST_MAIN, itemStack)
  if not leftover:is_empty() then
    core.item_drop(leftover, playerObj, playerObj:get_pos())
  end
end

-- Gives items to player, or drops them on ground if no space in teir main inventory.
-- Gives in multiples of at most itemStack's get_stack_max()
local function give_to_player(playerObj, itemStack, amount)
  local maxStack = itemStack:get_stack_max()
  local wholeStacksToGive = math.floor(amount / maxStack)
  local partialToGive = amount - wholeStacksToGive * maxStack
  local wholeStack = ItemStack(itemStack) ; wholeStack:set_count(maxStack)
  for i = 1, wholeStacksToGive do
    put_in_player_inv_or_drop_at_feet(playerObj, wholeStack)
  end
  if partialToGive > 0 then
    local partial = ItemStack(itemStack) ; partial:set_count(partialToGive)
    put_in_player_inv_or_drop_at_feet(playerObj, partial)
  end
end

local function exchange_all_possible_in_player_inv(playerObj, inputStack, takeStack, giveStack)
  local tginfo = find_smallest_take_amount(takeStack:get_count(), giveStack:get_count())
  local smallestTake, smallestGive = tginfo.smallestTake, tginfo.smallestGive
  local takeName = takeStack:get_name()
  local inv = playerObj:get_inventory()
  local emptyStack = ItemStack()
  local takenFromInv = 0

  if giveStack:is_empty() then return inputStack end

  if inputStack:get_wear() == 0 and inputStack:get_name() == takeName then
    takenFromInv = takenFromInv + inputStack:get_count()
    inputStack:set_count(0)
  end

  for i = 1, inv:get_size(LIST_MAIN) do
    local stack = inv:get_stack(LIST_MAIN, i)
    if stack:get_wear() == 0 and stack:get_name() == takeName then
      takenFromInv = takenFromInv + stack:get_count()
      inv:set_stack(LIST_MAIN, i, emptyStack)
    end
  end

  local leftover = takenFromInv
  local toGive = 0
  while leftover - smallestTake >= 0 do
    toGive = toGive + smallestGive
    leftover = leftover - smallestTake
  end
  if leftover > 0 then
    local leftoverStack = ItemStack(takeName)
    give_to_player(playerObj, leftoverStack, leftover)
  end
  if toGive > 0 then
    give_to_player(playerObj, giveStack, toGive)
  end
  return inputStack
end

-- takes from the input stack and gives corresponding output stack to player
-- takeAll : boolean, if true, takes max possible, otherwise triest to take at most for one giveStack's size
-- returns leftover to replace inputStack
local function take_from_input_stack_and_give_to_player(playerObj, inputStack, takeStack, giveStack, takeAll)
  local tginfo = find_smallest_take_amount(takeStack:get_count(), giveStack:get_count())
  local smallestTake, smallestGive = tginfo.smallestTake, tginfo.smallestGive
  local maxToTake = takeAll and inputStack:get_stack_max() or takeStack:get_count()
  local leftoverStack = ItemStack(inputStack)

  local taken = 0
  local given = 0
  while taken + smallestTake <= maxToTake and leftoverStack:get_count() >= smallestTake do
    taken = taken + smallestTake
    given = given + smallestGive
    leftoverStack:set_count(leftoverStack:get_count() - smallestTake)
  end
  local toGive = ItemStack(giveStack)
  give_to_player(playerObj, toGive, given)
  return leftoverStack
end

----------------------------------------------------------------
-- public functions
----------------------------------------------------------------

--[[ Returns a naturally indexed list of tables, each entry is:
```
  {
    recipe = {"", "", "" ...} -- 9 strings representing the recipe of the exchange item 
    exchanges = {ItemStack, ItemStack}, -- list of items that can be exchanged
    input = ItemStack, -- the itemstack (with count) that needs to be taken to exchange
  }
```
if no entries are present, then no swappable items exist
]]
function craft_conflict_exchanger.get_swappable_items_for(itemStack)
  local itemName = itemStack:get_name()
  local shapedSwaps = swappableShaped[itemName] or {}
  local shapelessSwaps = swappableShapeless[itemName] or {}
  local cookSwaps = swappableCook[itemName] or {}

  local combinedRes = {}
  add_swapple_entry_into(shapedSwaps, itemName, combinedRes)
  add_swapple_entry_into(shapelessSwaps, itemName, combinedRes)
  add_swapple_entry_into(cookSwaps, itemName, combinedRes)

  return combinedRes
end

-- Returns a table of tables, where each entry is a group of ItemStacks representing a conflict group
-- Each entry also contains a .recipe field which is the common recipe for all items in that group
-- Note that modifying this table will result in problems!
function craft_conflict_exchanger.get_all_shaped_conflics()
  return shapedCraftConflicts
end

function craft_conflict_exchanger.get_all_shapeless_conflics()
  return shapelessCraftConflicts
end

function craft_conflict_exchanger.get_all_cook_conflics()
  return cookConflicts
end

--[[
Attempts to perform the exchange, and places results in player's inventory.<br>
```
mode can be:
  1 : perform exactly 1 exchange
  2 : perform exchange of entire inputStack (or as close to as possible)
  3 : perform exchange of inputStack AND all of same items in player inventory
```
Returns a leftoverStack to replace inputStack
]]
function craft_conflict_exchanger.perform_exchange_for(player, inputStack, takeStack, giveStack, mode)
  if mode == 1 or mode == 2 then
    return take_from_input_stack_and_give_to_player(player, inputStack, takeStack, giveStack, mode == 2)
  elseif mode == 3 then
    return exchange_all_possible_in_player_inv(player, inputStack, takeStack, giveStack)
  end
  return inputStack
end
