
local con = respec.const
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right
local UNSET = con.unset
local PARENT = con.parent
local GONE = con.gone
local PACKED = con.chain_packed
local SPREAD = con.chain_spread

local side_to_str = respec.util.side_to_str
local num_or = respec.util.num_or
local min0 = respec.util.min0
local log_error = respec.log_error
local tblmap = respec.util.map
local concat = table.concat
local function clamp(value, min, max)
  if value < min then return min elseif value > max then return max else return value end
end

local funcs = {}

local function get_parent_value(parentNode, refSide, isWidth)
    local refValue, offset = 0, 0
    local parentMeas = parentNode.element.measured
    local parentMarg = parentNode.element.margins
    if refSide == TOP or refSide == LFT then
      refValue = parentMeas[refSide]
      if refValue == UNSET then return nil end
    else
      local oppRefSide = TOP ; if refSide == RGT then oppRefSide = LFT end
      local size = parentMeas.h ; if isWidth then size = parentMeas.w end
      if parentMeas[oppRefSide] == UNSET then return nil end
      refValue = parentMeas[oppRefSide] + parentMarg[oppRefSide] + size + parentMarg[refSide]
    end
    if isWidth then offset = parentNode.element.measured.xOffset else offset = parentNode.element.measured.yOffset end
    return refValue + offset
end

local function update_container_measurements(side, value, layoutMeasurements)
  if side == TOP or side == BOT then
    if value > layoutMeasurements.max_y then layoutMeasurements.max_y = value end
  else
    if value > layoutMeasurements.max_x then layoutMeasurements.max_x = value end
  end
end

local function invalidate_tree_and_opposite_if_unset(root, isWidth, checkOpposite, cameFrom)
  if not root then return end
  root.resolved = false
  local ms = root.element.measured
  ms[root.side] = UNSET
  if checkOpposite then
    if isWidth then
      ms.w = UNSET ; ms.xOffset = 0
    else
      ms.h = UNSET ; ms.yOffset = 0
    end
  end
  for _, child in ipairs(root.childNodes) do
    if child ~= cameFrom then
      invalidate_tree_and_opposite_if_unset(child, isWidth, true, root)
    end
  end
  if checkOpposite and root.oppositeNode and root.oppositeNode.side == UNSET then
    invalidate_tree_and_opposite_if_unset(root.oppositeNode, isWidth, false)
  end
end

local function set_fixed_size_if_possible(element)
  local measured = element.measured
  if measured.w == UNSET and element.width > 0 then
    measured.w = element.width
  end

  if measured.h == UNSET and element.height > 0 then
    measured.h = element.height
  end
end

local function set_dynamic_size_if_possible(element, measured, margins)
  if element.visibility == GONE then
    measured.w = 0
    measured.h = 0
    return
  end
  if measured.w == UNSET then
    if element.width == 0 then -- width set from aligns
      if measured[LFT] ~= UNSET and measured[RGT] ~= UNSET then
        measured.w = min0(measured[RGT] - measured[LFT]) - margins[RGT] - margins[LFT]
      end
    -- elseif element.width == con.wrap_content -- TODO - currently only supported for Layout which is handled elsewhere
    end
  end

  if measured.h == UNSET then
    if element.height == 0 then -- height set from measured y/ey
      if measured[TOP] ~= UNSET and measured[BOT] ~= UNSET then
        measured.h = min0(measured[BOT] - measured[TOP]) - margins[TOP] - margins[BOT]
      end
    -- elseif element.height == con.wrap_content -- TODO - currently only supported for Layout which is handled elsewhere
    end
  end
end

-- returns a new table with valid margins, which may be 0
-- expects defaultMargins to be 0 if they're
local function merge_margins(elemM, defaultMargins)
  local mar = {}
  for _, SIDE in ipairs({TOP, BOT, LFT, RGT}) do
    local ems = elemM[SIDE] ; if ems == UNSET then ems = nil end
    mar[SIDE] = num_or(ems, defaultMargins[SIDE])
  end
  return mar
end

local function notify_elem_if_measured(elem)
  if type(elem.after_measure) == "function" then
    local measured = elem.measured
    if measured[LFT] ~= UNSET and measured[RGT] ~= UNSET
        and measured[TOP] ~= UNSET and measured[BOT] ~= UNSET
        and measured.width ~= UNSET and measured.height ~= UNSET then
    elem:after_measure()
    end
  end
end

--[[
 S1: nearer to zero side
 S2: futher from zero, opposite side
 align: the element.align table - read-only
 margins: the element.margins table - read-only
 measured: the element.measured table, read-write
 size: the elements set width or height (depending)
 bias: the hor/ver bias (depending)
 set_measured_size: func to set the measured width/height
 set_measured_custom_offset: func to set the custom X/Y offset
]]
local function update_side_logic(isGone, S1, S2, align, measured, margins, size, bias, set_measured_size, set_measured_custom_offset)
  -- NOTE: nested ifs cannot be flattened! Logic needs to hold as it is
  if align[S1].side == UNSET and align[S2].side == UNSET then
    -- not a good user case, S2h S1/S2 were unset. But resolve it now
    if isGone then
      measured[S1] = 0 ; measured[S2] = 0
    else
      measured[S1] = 0 ; measured[S2] = size + margins[S1] + margins[S2]
      set_measured_size(size)
    end
  elseif align[S1].side == UNSET then -- S1 was unset but S2 was set
    if isGone then
      measured[S1] = measured[S2]
    else
      if measured[S2] ~= UNSET and size > 0 then -- S2 was also already measured
        measured[S1] = measured[S2] - size - margins[S1] - margins[S2]
        set_measured_size(size)
      end
    end
  elseif align[S2].side == UNSET then -- S2 was unset but S1 was set
    if isGone then
      measured[S2] = measured[S1]
    else
      if measured[S1] ~= UNSET and size > 0 then -- S1 was also already measured
        measured[S2] = measured[S1] + size + margins[S1] + margins[S2]
        set_measured_size(size)
      end
    end
  elseif not isGone then-- S2h align S1 and S2 were set
    if measured[S1] ~= UNSET and measured[S2] ~= UNSET then
      if size > 0 then -- position element equally between start/end
        -- calc custom offset
        local availSpace = measured[S2] - measured[S1] - margins[S1] - margins[S2]
        local leftoverSpace = availSpace - size -- note that this CAN go negative
        local bias2 = clamp(bias or 0.5, 0, 1)
        local spaceBefore = leftoverSpace * bias2
        set_measured_size(size)
        set_measured_custom_offset(spaceBefore)
      else -- size was 0 or unset, just set it from our width minus margins
        set_measured_size(measured[S2] - measured[S1] - margins[S1] - margins[S2])
      end
    end
  end
end

-- returns if the oopposite side to this side should be invalidated due to offset changes
local function update_element_sides_based_on_align(elem, side, measured, margins)
  local align = elem.align
  local isGone = elem.visibility == GONE
  local invalidateOtherSide = false
  if side == TOP or side == BOT then
    update_side_logic(isGone, TOP, BOT, align, measured, margins, elem.height, elem.verBias or 0.5,
      function(v) measured.h = v end,
      function(v) measured.yOffset = v ; invalidateOtherSide = true end
    )
  elseif side == LFT or side == RGT then
    update_side_logic(isGone, LFT, RGT, align, measured, margins, elem.width, elem.horBias or 0.5,
      function(v) measured.w = v end,
      function(v) measured.xOffset = v ; invalidateOtherSide = true end
    )
  end
  return invalidateOtherSide
end

-- returns true if measuring was successful, false if the root can't be measured
local function perform_layout_of_node(layout, node, containerMeasurements, parentNode)
  local side = node.side
  local elem = node.element
  local align = elem.align
  local ref = align[side]
  local refSide = ref.side
  local measured = elem.measured
  local margins = elem.margins
  local childNodes = node.childNodes
  local isWidth = (side == LFT or side == RGT)

  -- first see if we can first easily set the height or width
  set_fixed_size_if_possible(elem)

  if node.resolved then
    return true
  end

  if not parentNode then
    -- root node 
    -- check if refSide was set
    if refSide ~= UNSET  then
      if refSide ~= PARENT then
        -- this is an error, and should be fixed - but still continue as though we're aligned to parent
        log_error("Side ["..side_to_str(side).."] of '"..elem.id.."' references unknown elemnt: '"..ref.ref.."'")
      end
      local value = layout.measured[side]
      if value == UNSET then -- parent layout hasn't set its bounds yet, likely due to wrap content
        return false -- we need to wait until after other stuff is measured
      end

      local marginSign = 1 ; if side == BOT or side == RGT then marginSign = -1 end
      if not elem.ignoreLayoutPaddings then
        value = value + marginSign * layout.paddings[side]
      end

      measured[side] = value

      set_dynamic_size_if_possible(elem, measured, margins)
      local invalOpp = update_element_sides_based_on_align(elem, side, measured, margins)
      update_container_measurements(side, value, containerMeasurements)
      -- node.resolvedVal = elem.measured[side]
      node.resolved = true
      if not funcs.hadle_post_setting_child_nodes(
        layout, childNodes, containerMeasurements, node, isWidth, invalOpp
      ) then
        node.resolved = false ; return false
      end
      notify_elem_if_measured(elem)
      return true
    else --if refSide == UNSET then
      -- check if other side is set
      local invalOpp = update_element_sides_based_on_align(elem, side, measured, margins)
      update_container_measurements(side, measured[side], containerMeasurements)
      if measured[side] ~= UNSET then -- we set it
        node.resolved = true
        if not funcs.hadle_post_setting_child_nodes(
          layout, childNodes, containerMeasurements, node, isWidth, invalOpp
        ) then
          node.resolved = false ; return false
        end
        notify_elem_if_measured(elem)
        return true -- child nodes should resolve fine because they only depend on parent (hmm)
      else return false end -- could happen when side depends on opposite side, but that wasn't resolved yet
    end
  else -- a child node (aka side) should be ready to resolve from parent node (aka referenced side)
    -- get the aligned side's measured value
    local parentCalcVal = get_parent_value(parentNode, refSide, isWidth)
    if parentCalcVal == nil then return false end -- can happen if opposite side dependency exists
    measured[side] = parentCalcVal
    set_dynamic_size_if_possible(elem, measured, margins)
    local invalOpp = update_element_sides_based_on_align(elem, side, measured, margins)
    -- node.resolvedVal = elem.measured[side]
    node.resolved = true
    update_container_measurements(side, parentCalcVal, containerMeasurements)
    if not funcs.hadle_post_setting_child_nodes(
      layout, childNodes, containerMeasurements, node, isWidth, invalOpp
    ) then
      return false
    end
    notify_elem_if_measured(elem)
    return true
  end
  -- not reachable here
end

funcs.peform_layout_of_children = function(layout, childNodes, containerMeasurements, node, isWidth, invalidate)
  local inval = invalidate_tree_and_opposite_if_unset
  if not invalidate then inval = function(_,_,_) end end
    for chi = 1, #childNodes do
      inval(childNodes[chi], isWidth, true)
      local ret = perform_layout_of_node(layout, childNodes[chi], containerMeasurements, node)
      if not ret then node.resolved = false ; return false end -- in theory this shouldn't happen
    end
  return true
end

funcs.hadle_post_setting_child_nodes = function(layout, childNodes, containerMeasurements, node, isWidth, invalOpp)
  if not funcs.peform_layout_of_children(
    layout, childNodes, containerMeasurements, node, isWidth, false
  ) then return false end -- one of child layout failed
  if invalOpp then
    funcs.peform_layout_of_children(
      layout, node.oppositeNode.childNodes, containerMeasurements, node.oppositeNode, isWidth, true
    )
  end
  return true
end

local function update_container_based_on_measurements(layout, containerMeasurements)
  local align = layout.align
  local measured = layout.measured
  local paddings = layout.paddings

  if layout.width == con.wrap_content then
    if align[LFT].side == UNSET and align[RGT] == UNSET then
      -- both left/right were unaligned - treat this as a root
      measured[LFT] = 0 ; measured[RGT] = containerMeasurements.max_x + paddings[RGT]-- - paddings[RGT] - paddings[LFT]
      measured.w = containerMeasurements.max_x
    elseif align[LFT].side == UNSET then -- left was usnet but right was set
      measured[LFT] = measured[RGT] - containerMeasurements.max_x -- unsure if this is correct..
      measured.w = containerMeasurements.max_x
    elseif align[RGT].side == UNSET then -- right was usnet but left was set
      measured[RGT] = measured[LFT] + containerMeasurements.max_x + paddings[RGT] -- - paddings[RGT]
      measured.w = containerMeasurements.max_x
    -- else: both set? wrap content will be ignored
    end
  end
  if layout.height == con.wrap_content then
    if align[TOP].side == UNSET and align[BOT] == UNSET then
      -- both left/right were unaligned - treat this as a root
      measured[TOP] = 0 ; measured[BOT] = containerMeasurements.max_y + paddings[BOT] -- - paddings[BOT] - paddings[TOP]
      measured.h = containerMeasurements.max_y
    elseif align[TOP].side == UNSET then -- left was usnet but right was set
      measured[TOP] = measured[BOT] - containerMeasurements.max_y -- unsure if this is correct..
      measured.h = containerMeasurements.max_y
    elseif align[BOT].side == UNSET then -- right was usnet but left was set
      measured[BOT] = measured[TOP] + containerMeasurements.max_y + paddings[BOT] -- - paddings[BOT]
      measured.h = containerMeasurements.max_y
    -- else: both set? wrap content will be ignored
    end
  end
end

-- returns true if anything was invalidated
local function invalidate_roots_that_align_to_parent(graph, SIDE)
  local invalidated = false
  for _, root in pairs(graph.roots) do
    if root.side == SIDE and root.element.align[SIDE].side == PARENT then
      invalidate_tree_and_opposite_if_unset(root, true, true)
      invalidated = true
    end
  end
  return invalidated
end

local function perform_layout_of_all_children_of_chain(chain, layout, isHorizontal, containerMeasurements)
  for ni = 1, #chain do
    local node = chain[ni]
    local childNodes = node.childNodes
    for chi = 1, #childNodes do
      if node.parentNode ~= childNodes[chi] then
        invalidate_tree_and_opposite_if_unset(childNodes[chi], isHorizontal, true)
        perform_layout_of_node(layout, childNodes[chi], containerMeasurements, node)
      end
    end
  end
end

-- performs the layout of the given chain - note that this overrides element measured positions
local function perform_layout_of_chain(chain, S1, S2, getSize, getBias, getChainType, getChainWeight, setSize)
  local chainSize = #chain
  local firstElemStart = chain[1].element.measured[S1]
  local lastElemEnd = chain[chainSize].element.measured[S2]
  if firstElemStart == UNSET then
    log_error("Element "..(chain[1].element.id)..
          " is the start of a chain, but doesn't have its"..
          side_to_str(S1).." side aligned! Skipping")
    return
  end
  if lastElemEnd == UNSET then
    log_error("Element "..(chain[chainSize].element.id)..
          " is the end of a chain, but doesn't have its"..
          side_to_str(S2).." side aligned! Skipping")
    return
  end

  local availSpace = min0(lastElemEnd - firstElemStart)
  local chainType = getChainType(chain[1].element) or PACKED
  -- gather all the sizes
  local totS = 0
  local totW = 0 -- total weight sum
  local elemProps = {} -- contains: { s = sizeWithoutMargins, sm = sizeWithMargins, w = weight, e = elem}
  local noFillElems = true
  local fillS = availSpace -- space that is available to "fill" elements
  for i = 1, chainSize, 2 do -- skipping every other node because they come in s/e pairs
    local elem = chain[i].element
    local elemS = getSize(elem)
    if elemS <= 0 then elemS = 0 ; noFillElems = false end
    local elemW = getChainWeight(elem) or 1
    local elemSM = elemS + elem.margins[S1] + elem.margins[S2]
    elemProps[#elemProps + 1] = { s = elemS, sm = elemSM, w = elemW, e = elem }
    if elemS == 0 then -- weighted element
      totW = totW + elemW
    else -- fixed element
      totS = totS + elemSM
    end
    chain[i].resolved = true
    chain[i+1].resolved = true
  end
  if totW == 0 then totW = 1000000 end -- just a failsafe to prevent divby0
  local numElems = #elemProps
  fillS = min0(availSpace - totS)

  -- calc space before
  local start = firstElemStart
  local innerSpace = 0
  if noFillElems then -- fill elements just push everything together because they take up all the space
    if chainType == PACKED then
      local bias = getBias(chain[1].element)
      start = start + bias * min0(availSpace - totS)
    elseif chainType == SPREAD then
      local bias = getBias(chain[1].element)
      innerSpace = min0(availSpace - totS) / (numElems + 1) -- +1 because 3 spread elements have 4 spacings to fill
      start = start + bias * innerSpace * 2
    else -- chainType == SPREAD_INSIDE - the space before/after is 0
      innerSpace = min0(availSpace - totS) / (numElems - 1) -- +1 because 3 elements have 2 spacings inebtween
    end
  end

  -- now apply the positions
  for i = 1, numElems do
    local elemProp = elemProps[i]
    local elem = elemProp.e
    if elemProp.s == 0 then -- weighted element
      elem.measured[S1] = start
      local takeUp = fillS * elemProp.w / totW
      elem.measured[S2] = start + takeUp
      setSize(elem, min0(takeUp) - elem.margins[S1] - elem.margins[S2])
      start = start + takeUp + innerSpace
    else
      elem.measured[S1] = start
      elem.measured[S2] = start + elemProp.sm
      setSize(elem, elemProp.s)
      start = start + elemProp.sm + innerSpace
    end
    notify_elem_if_measured(elem)
  end
end

local function perform_layout_of_chains(layout, graph, containerMeasurements)
  local horChains = graph.horChainLists
  local verChains = graph.verChainLists
  for i = 1, graph.horChainPos do
    local chain = horChains[i]
    perform_layout_of_chain(
      chain, LFT, RGT,
      function(e) return e.width end, function(e) return e.horBias or 0.5 end,
      function(e) return e.chainTypeHor end, function(e) return e.chainWeightHor end,
      function(e,s) e.measured.w = s end
    )
    perform_layout_of_all_children_of_chain(chain, layout, true, containerMeasurements)
  end
  for i = 1, graph.verChainPos do
    local chain = verChains[i]
    perform_layout_of_chain(
      chain, TOP, BOT,
      function(e) return e.height end, function(e) return e.verBias or 0.5 end,
      function(e) return e.chainTypeVer end, function(e) return e.chainWeightVer end,
      function(e,s) e.measured.h = s end
    )
    perform_layout_of_all_children_of_chain(chain, layout, false, containerMeasurements)
  end
end

--================================================================
-- public functions
--================================================================

-- To be called internally only
-- Performs the laying-out process of each element
function respec.internal.perform_layout(layout, containerMeasurementsOpt)
  local graph = layout.elementsGraph

  -- TODO possibly go through all elements and mark as unmeasured? only an issue if remeasured twice which shouldn't happen
  -- starting from each root, evaluate all nodes - mark them as measured

  local remaining = {}
  local numRemaining = 0
  local containerMeasurements = containerMeasurementsOpt or { max_x = 0, max_y = 0 }

  -- Common pre-layout functionality
  local persist = { playerName = layout.playerName }
  layout:before_measure(persist)
  for ei = 1, #layout.elements do
    local elem = layout.elements[ei]
    elem:before_measure(persist)
    if elem.physical == true then
      elem.margins = merge_margins(elem.margins, layout.defaultMargins)
    end
  end
  for i = 1, graph.rootsPos do
    local root = graph.roots[i]
    local res = perform_layout_of_node(layout, root, containerMeasurements)
    if not res then numRemaining = numRemaining + 1 ; remaining[numRemaining] = root end
  end
  update_container_based_on_measurements(layout, containerMeasurements)

  -- chains here. From testing, might be the right place
  perform_layout_of_chains(layout, graph, containerMeasurements)

  local oldMaxX = containerMeasurements.max_x
  local oldMaxY = containerMeasurements.max_y
  while numRemaining > 0 do
    for i, node in ipairs(remaining) do
      local res = perform_layout_of_node(layout, node, containerMeasurements)
      if res then table.remove(remaining, i) end
    end
    local newRemainig = #remaining
    if newRemainig == numRemaining then -- this is an issue. At least one should have been resolved
      log_error(
        "Unable to resolve some layouts in "..dump(layout.elements)..
        "\n--graph.roots = \n"..concat(tblmap(graph.roots,
          function(n) local e = n.element
            return "  "..tostring(n)
          end), "\n")..
        "\n--graph.horChains =\n"..concat(tblmap(graph.horChainLists,
          function(chain) return concat(tblmap(chain, function(n)
            return "  "..tostring(n)
          end), "\n")
        end), "\n")..
        "\n--graph.verChains =\n"..concat(tblmap(graph.verChainLists,
          function(chain) return concat(tblmap(chain, function(n)
            return "  "..tostring(n)
          end), "\n")
        end), "\n")
      )
      return false
    end
    numRemaining = newRemainig
  end

  update_container_based_on_measurements(layout, containerMeasurements)

  local changedEnd = oldMaxX ~= containerMeasurements.max_x
  local changedBot = oldMaxY ~= containerMeasurements.max_y

  if changedEnd or changedBot then
    -- invalidate corresponding nodes
    local mustRelayout = false
    if changedEnd then
      local res = invalidate_roots_that_align_to_parent(graph, RGT)
      mustRelayout = res or mustRelayout
    end
    if changedBot then
      local res = invalidate_roots_that_align_to_parent(graph, BOT)
      mustRelayout = res or mustRelayout
    end
    if mustRelayout then
      respec.internal.perform_layout(layout, containerMeasurements)
    end
  end
end

-- To be called internally only
-- Special case of perform layout where the layout is the root one in the form
function respec.internal.perform_layout_of_form_layout(formLayout)
  -- form root layout always starts at 0, 0 - but may have wrap width/height
  local ms = formLayout.measured
  ms[LFT] = 0 -- mg[LFT]
  ms[TOP] = 0 -- mg[TOP]
  if formLayout.width > 0 then
    ms[RGT] = formLayout.width -- - min0(mg[RGT])
    ms.w = formLayout.width --  - min0(mg[LFT]) - min0(mg[RGT])
  end
  if formLayout.height > 0 then
    ms[BOT] = formLayout.height -- - min0(mg[BOT])
    ms.h = formLayout.height -- - min0(mg[TOP]) - min0(mg[BOT])
  end
  respec.internal.perform_layout(formLayout) -- do the rest of the layout
end
