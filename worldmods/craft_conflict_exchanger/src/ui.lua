
local elem = respec.elements
local resinv = respec.inv

local INPUT_LIST_NAME = "main"

--------------------------------
-- Common
--------------------------------

local det_inv_name = craft_conflict_exchanger.get_detached_inventory_name_for

local function get_craft_grid_elements(recipe, w, h)
  local spacing = 0.05
  local iw = w / 3 - spacing
  local ih = h / 3 - spacing
  local res = {}
  for y = 1, 3 do
  for x = 1, 3 do
    local recipeEntry = recipe[(y-1)*3 + x]
    if recipeEntry ~= nil then
      local itemAndGrpInfo = craft_conflict_exchanger.get_item_for_group_or_item(recipeEntry)
      local tooltip
      if itemAndGrpInfo.isGroup then
        tooltip = recipeEntry
      else
        tooltip = ItemStack(itemAndGrpInfo.item):get_description()
      end

      local elemId = "cgimg_"..x..y
      local def =  { id = elemId,
        w = iw, h = ih,
        item = itemAndGrpInfo.item,
        tooltip = tooltip
      }

      if y == 1 then def.alignTop = true
      else def.below = "cgimg_1"..(y-1) end
      if x > 1 then def.after = "cgimg_"..(x-1)..y end
      if x < 3 then def.marginEnd = spacing end
      if y < 3 then def.marginBottom = spacing end

      res[#res+1] = elem.ItemButton(def)
      if itemAndGrpInfo.isGroup then
        res[#res+1] = elem.Label {
          text = "G",
          centerHor = elemId, centerVer = elemId,
        }
      end
    end -- end nil check of recipeEntry
  end
  end
  return res
end

--------------------------------
-- Exchange page
--------------------------------

local noItemFoundLabel = elem.Label {
  toTop = true, centerHor = true, margins = 0.5,
  text = "No items with\nsame recipe found."
}
local cannotExchangeDamagedTools = elem.Label {
  toTop = true, centerHor = true, margins = 0.5,
  text = "Cannot exchange damaged tools.\nRepair tool first."
}

local function get_exchange_info(state)
  local info = state.info
  local inv = craft_conflict_exchanger.get_detached_inv_for(info.playerName)
  if not inv then return { output = "", input = "" } end
  local lastInputName = state.lastInputName or ""
  local currItemStack = inv:get_stack(INPUT_LIST_NAME, 1)
  local currIdx = state.currentIndex or 0
  if currItemStack:is_empty() then
    state.lastInputName = ""
    return { output = "", input = "" }
  end

  local swapInfo
  if currItemStack:get_name() ~= lastInputName then
    currIdx = 0
    state.currentIndex = 0
    swapInfo = craft_conflict_exchanger.get_swappable_items_for(currItemStack)
    state.swapInfo = swapInfo
    state.lastInputName = currItemStack:get_name()
  else
    swapInfo = state.swapInfo
  end
  if not swapInfo then
    swapInfo = craft_conflict_exchanger.get_swappable_items_for(currItemStack)
  end

  local swappableItems = {}
  for _, sw in ipairs(swapInfo) do
    for _, item in ipairs(sw.exchanges) do
      swappableItems[#swappableItems+1] = {
        item = item,
        recipe = sw.recipe,
        input = sw.input,
      }
    end
  end

  local selectionList = {}
  local recipeGrid = {}
  local output = ""
  local exactInput
  if #swappableItems <= 0 then
    table.insert(selectionList, noItemFoundLabel)
  elseif currItemStack:get_wear() > 0 then
    table.insert(selectionList, cannotExchangeDamagedTools)
  else
    if currIdx >= 1 and currIdx <= #swappableItems then
      output = swappableItems[currIdx].item:to_string()
    end

    for i, singleItemInfo in ipairs(swappableItems) do
      local btnDef = { id = "btn"..i,
        centerHor = true, w = 0, h = 0.7, marginStart = 0.9,
        text = singleItemInfo.item:get_description(),
        onClick = function(ss, _)
            ss.currentIndex = i
        end
      }
      local imgDef = {
        w = 0.7, h = 0.7, item = singleItemInfo.item:to_string(),
        toStart = true, alignTop = "btn"..i
      }

      if i == 1 then btnDef.toTop = true
      else btnDef.below = "btn"..(i - 1) end

      if i == currIdx then
        exactInput = singleItemInfo.input
        btnDef.style = {
          textcolor = "#CCFF00", bgcolor = "#117700"
        }
        table.insert(
          recipeGrid,
          elem.Label { id = "recipelbl",
            text = "Shared Recipe",
            after = "placeholder", toEnd = true, marginTop = 0.2,
          }
        )
        local recipeSize = 2.75
        table.insert(
          recipeGrid,
          elem.Container { w = recipeSize, h = recipeSize,
            pixelBorder = "#AAAACA",
            after = "placeholder", below = "recipelbl", toEnd = true,
            elements = get_craft_grid_elements(singleItemInfo.recipe, recipeSize, recipeSize)
          }
        )
      end

      table.insert(selectionList, elem.Button(btnDef))
      table.insert(selectionList, elem.ItemImage(imgDef))
    end
  end
  local selectionListElem = elem.ScrollContainer { id = "scroll",
    w = 5.5, paddings = { before = 0.1, after = 0.1, above = 0.1, below = 0.2},
    marginsVer = 0.2,
    centerHor = "placeholder", centerVer = "placeholder",
    elements = selectionList,
  }

  return {
    input = (exactInput or ItemStack()):to_string(),
    output = output,
    elements = { selectionListElem },
    recipeGrid = recipeGrid,
  }
end

local function get_exchanger_page(state)
  local exchangeInfo = get_exchange_info(state)
  local outputStack = ItemStack(exchangeInfo.output)
  local exInputStack = ItemStack(exchangeInfo.input)

  local base = {
      elem.Label { id = "inputLbl",
        text = "1. Place Item",
        toTop = true, above = "playerInv", marginStart = 0.2,
      },
      elem.List { id = "input",
        w = 1, h = 1, below = "inputLbl", marginStart = 0.5,
        inv = resinv.detached(det_inv_name(state.info.playerName), INPUT_LIST_NAME),
      },

      elem.Label { id = "selectLbl",
        text = "2. Select Exchange",
        toTop = true, centerHor = "placeholder", marginTop = 0.2,
      },
      elem.Box { id = "placeholder",
        color = "#88888833", w = 5.5,
        after = "input", before = "inputExact", below = "selectLbl", above = "playerInv",
        marginsHor = 0.1, marginBottom = 0.2,
      },

      elem.Label { id = "outputLbl",
        text = "3. Exchange Items", marginStart = 0.1, marginEnd = 0.3,
        alignStart = "inputExact", alignEnd = "output", toTop = true, above = "playerInv",
      },
      elem.ItemImage { id = "inputExact",
        w = 1, h = 1, below = "outputLbl", before = "excharrow", marginsVer = 0.1,
        item = exInputStack:to_string(), tooltip = exInputStack:get_name().."\n"..exInputStack:get_description(),
      },
      elem.Image { id = "excharrow",
        w = 1, h = 1, below = "outputLbl", before = "output",
        image = "item_exchanger_arrow.png",
      },
      elem.ItemImage { id = "output",
        w = 1, h = 1,  below = "outputLbl", toEnd = true, marginsVer = 0.1, marginEnd = 1.0,
        item = outputStack:to_string(), tooltip = outputStack:get_name().."\n"..outputStack:get_description(),
      },
      elem.Button { id = "exone",
        h = 0.8, w = 2.5, marginEnd = 0.4, marginBottom = 0.1, text = "Exchange\nOne",
        alignStart = "inputExact", alignEnd = "output", below = "output",
        onClick = function(ss, _)
          local inf = ss.info
          local inv = craft_conflict_exchanger.get_detached_inv_for(inf.playerName)
          local leftover = craft_conflict_exchanger.perform_exchange_for(
            inf.player, inv:get_stack(INPUT_LIST_NAME, 1), exInputStack, outputStack, 1
          )
          inv:set_stack(INPUT_LIST_NAME, 1, leftover)
        end
      },
      elem.Button { id = "exst",
        h = 0.8, w = 2.5, marginEnd = 0.4, marginBottom = 0.1, text = "Exchange\nStack",
        alignStart = "inputExact", alignEnd = "output", below = "exone",
        onClick = function(ss, _)
          local inf = ss.info
          local inv = craft_conflict_exchanger.get_detached_inv_for(inf.playerName)
          local leftover = craft_conflict_exchanger.perform_exchange_for(
            inf.player, inv:get_stack(INPUT_LIST_NAME, 1), exInputStack, outputStack, 2
          )
          inv:set_stack(INPUT_LIST_NAME, 1, leftover)
        end
      },
      elem.Button { id = "exall",
        h = 0.8, w = 2.5, marginEnd = 0.4, marginBottom = 0.1, text = "Exchange\nAll in Inv.",
        alignStart = "inputExact", alignEnd = "output", below = "exst",
        onClick = function(ss, _)
          local inf = ss.info
          local inv = craft_conflict_exchanger.get_detached_inv_for(inf.playerName)
          local leftover = craft_conflict_exchanger.perform_exchange_for(
            inf.player, inv:get_stack(INPUT_LIST_NAME, 1), exInputStack, outputStack, 3
          )
          inv:set_stack(INPUT_LIST_NAME, 1, leftover)
        end
      },

      elem.List { id = "playerInv",
        toBottom = true, centerHor = true, marginTop = 0.2,
        w = craft_conflict_exchanger.main_inv_width, h = 4,
        inv = resinv.player("main"),
      },
      elem.ListRing {
        resinv.player("main"),
        resinv.detached(det_inv_name(state.info.playerName), INPUT_LIST_NAME)
      },
  }

  table.insert_all(base, exchangeInfo.elements or {})
  table.insert_all(base, exchangeInfo.recipeGrid or {})
  return base
end

--------------------------------
-- Conflicts pages UI
--------------------------------
local NUM_CONFLICT_ICONS_PER_ROW = 7
local CONFLICT_ICON_SIZE = 1
local CONFLCIT_ICON_SPACING = 0.2
local CONFLICT_CONTAINER_W =
  NUM_CONFLICT_ICONS_PER_ROW * CONFLICT_ICON_SIZE + (NUM_CONFLICT_ICONS_PER_ROW - 1) * CONFLCIT_ICON_SPACING

local STATE_FILTER_TEXT = "filtxt"
local STATE_RECIPE_IDX = "recidx"

local function get_conflicts_page(state)
  local tabIndex = state.tabIndex
  local conflictsTable
  if tabIndex == 2 then
    conflictsTable = craft_conflict_exchanger.get_all_shaped_conflics()
  elseif tabIndex == 3 then
    conflictsTable = craft_conflict_exchanger.get_all_shapeless_conflics()
  elseif tabIndex == 4 then
    conflictsTable = craft_conflict_exchanger.get_all_cook_conflics()
  else
    return {}
  end

  local filterText = state[STATE_FILTER_TEXT..tabIndex] or ""

  local entires = {}
  local lastId = ""
  local recipeIndex = state[STATE_RECIPE_IDX..tabIndex] or 0
  local rowCounter = 1
  for i, oneConflictTable in ipairs(conflictsTable) do
    local oneConflictEntires = {}
    local recBtnDef = { id = "confrecbtn"..i, w = 6, h = 0.6,
      text = "See Recipe for Item Conflicts "..i, marginTop = 0.3, marginStart = 0.2, marginBottom = 0.1,
      onClick = function(ss, _)
        ss[STATE_RECIPE_IDX..tabIndex] = i
      end,
    }
    if lastId == "" then recBtnDef.toTop = true else recBtnDef.below = lastId end

    oneConflictEntires[#oneConflictEntires+1] = elem.Button(recBtnDef)
    local tmpLastId = recBtnDef.id

    local addThisConflictEntries = filterText == ""
    for j, itemStack in ipairs(oneConflictTable) do
      if not addThisConflictEntries then
        addThisConflictEntries =
          itemStack:to_string():find(filterText) ~= nil or itemStack:get_description():find(filterText) ~= nil
      end
      local itemImgDef = { id = "confimg"..i.."_"..j,
        w = CONFLICT_ICON_SIZE, h = CONFLICT_ICON_SIZE,
        marginBottom = CONFLCIT_ICON_SPACING, marginStart = CONFLCIT_ICON_SPACING,
        item = itemStack:to_string(),
        tooltip = itemStack:get_name().."\n\n"..itemStack:get_description(),
      }
      local row = math.floor(j / NUM_CONFLICT_ICONS_PER_ROW)
      local col = math.fmod(j, NUM_CONFLICT_ICONS_PER_ROW)
      if row == 0 then
        itemImgDef.below = recBtnDef.id
      else
        itemImgDef.below = "confimg"..i.."_"..(j - NUM_CONFLICT_ICONS_PER_ROW + 1)
      end
      if col > 1 then
        itemImgDef.after = "confimg"..i.."_"..(col - 1)
      end
      tmpLastId = itemImgDef.id
      oneConflictEntires[#oneConflictEntires+1] = elem.ItemImage(itemImgDef)
    end
    if addThisConflictEntries then
      local boxColor = "#3A3A3F" ; if math.fmod(rowCounter, 2) == 1 then boxColor = "#2F2A2F" end
      local boxDef = {
        toStart = true, toEnd = true, alignTop = recBtnDef.id, alignBottom = tmpLastId,
        color = boxColor,
      }
      entires[#entires+1] = elem.Box(boxDef)
      table.insert_all(entires, oneConflictEntires)
      lastId = tmpLastId
      rowCounter = rowCounter + 1
    end
  end

  local typetxt = "Shaped Crafting"
  if tabIndex == 3 then typetxt = "Shapeless Crafting" elseif tabIndex == 4 then typetxt = "Cooking" end
  local ret = {
    elem.Label {
      marginStart = 0.5, marginTop = 0.2,
      text = "Groups of "..typetxt.." items that have the same crafting recipe"
    },
    elem.ScrollContainer { id = "conflcont",
      w = CONFLICT_CONTAINER_W, h = 11, toTop = true, toStart = true, marginTop = 1,
      elements = entires,
      pixelBorder = "#222222",
    },
    elem.Field { id = "fieldfilter",
      below = "conflcont", marginStart = 0.2, label = "Search for conflict items",
      text = filterText, closeOnEnter = false,
      w = 4, h = 0.8,
      listener = function(ss, value, fields)
        if not fields["clearfilter"] then
          ss[STATE_FILTER_TEXT..ss.tabIndex] = value
        end
      end
    },
    elem.Button { id = "clearfilter",
      w = 0.8, h = 0.8, after = "fieldfilter", alignBottom = "fieldfilter",
      text = "X", tooltip = "Clear Search",
      onClick = function(ss, _)
        ss[STATE_FILTER_TEXT..ss.tabIndex] = nil
        return true
      end,
    },
  }
  local recipeSize = 4
  if recipeIndex > 0 and conflictsTable[recipeIndex] and conflictsTable[recipeIndex].recipe then
    ret[#ret+1] = elem.Label { id = "confrectitle",
      alignStart ="crftcon", marginTop = 2.5, marginStart = 0.2, marginBottom = 0.2,
      text = "Recipe for group "..recipeIndex,
    }
    ret[#ret+1] = elem.Container { w = recipeSize, h = recipeSize, id = "crftcon",
      pixelBorder = "#AAAACA",
      after = "conflcont", below = "confrectitle", toEnd = true, marginStart = 0.2,
      elements = get_craft_grid_elements(conflictsTable[recipeIndex].recipe, recipeSize, recipeSize)
    }
  end

  return ret
end

--------------------------------
-- Common ui
--------------------------------

local function get_page_content(state)
  if state.tabIndex == 1 then return get_exchanger_page(state)
  else return get_conflicts_page(state) end
end

-- Form
local exchangerForm = respec.Form(
  { ver = 3, w = 14, h = 13.5,
    paddings = { before = 0.25, after = 0.25, above = 0, below = 0.25 },
    reshowOnInteract = true,
  },
  function(istate)
    if istate.tabIndex == nil then istate.tabIndex = 1 end
    local def = {
      elem.ListColors{
        target = "list",
        slotBg = "#555555", slotBorder = "#222222", slotBgHover = "#888888"
      },
      elem.Tabs { id = "tabs",
        items = {"Exchange", "Craft Conflicts", "Shapeless Conflicts", "Cook Conflicts"},
        index = istate.tabIndex,
        listener = function(s,v,f) s.tabIndex = tonumber(v) or 1 ; return true end,
      },
    }
    local content = get_page_content(istate)
    table.insert_all(def, content)
    return def
  end
)

--------------------------------
-- Public Functions
--------------------------------

function craft_conflict_exchanger.get_exchanger_respec_form()
  return exchangerForm
end
