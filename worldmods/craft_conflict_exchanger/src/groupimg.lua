local GROUP_PREFIX = "group:"

local itemNameToItemCache = {}

-- returns the first (as defined in registered_items) item name for the given group(s) as a string
-- returns "air" as the item name if no items match the group
local function get_group_item_name(groups)
  local groupNames = groups:split(",")
  for itemName, _ in pairs(minetest.registered_items) do
    for _, groupName in ipairs(groupNames) do
      if core.get_item_group(itemName, groupName) ~= 0 then
        return itemName
      end
    end
  end
  return "air"
end

--[[ Checks if itemName is a group or not, and returns a table of:
```
{
  item = itemString, -- either the itemName if it wasn't a group, or appropriate item otherwise
  isGroup = false, -- true if itemName was a group, false otherwise
}
```
]]
function craft_conflict_exchanger.get_item_for_group_or_item(itemName)
  local cached = itemNameToItemCache[itemName]
  if cached then
    return cached
  elseif string.sub(itemName, 1, #GROUP_PREFIX) ~= GROUP_PREFIX then
    cached = {
      item = itemName,
      isGroup = false,
    }
  else
    local grpMinusPrefix = string.sub(itemName, #GROUP_PREFIX + 1, #itemName)
    local itemFromGroup = get_group_item_name(grpMinusPrefix)
    cached = {
      item = itemFromGroup,
      isGroup = true,
    }
  end
  itemNameToItemCache[itemName] = cached
  return cached
end
