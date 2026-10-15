
respec.graph = {}

local con = respec.const
local UNSET = con.unset
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right

local side_to_str = respec.util.side_to_str
local log_error = respec.log_error

-- recursive search of nodes
-- find any node, starting from the given `rootNode`, which has the given id + side
local function find_parent(id, side, rootNode)
  if rootNode.element.id == id and rootNode.side == side then return rootNode end
  -- depth first search child nodes
  for _, childNode in ipairs(rootNode.childNodes) do
    local res = find_parent(id, side, childNode)
    if res ~= nil then return res end
  end
  return nil
end

-- tries to find a node references by the ref in the given chain - returns it
local function find_parent_in_chain(id, side, chain)
  for i = 1, #chain do
    local node = chain[i]
    if node.element.id == id and node.side == side then return node end
    for _, childNode in ipairs(node.childNodes) do
      if node.parentNode ~= childNode then -- gignore the chained node
        local res = find_parent(id, side, childNode)
        if res ~= nil then return res end
      end
    end
  end
  return nil
end

----------------------------------------------------------------
-- node class
-- represents a single side of an element, and stores some info about arrangement
local Node = respec.util.Class()
function Node:init(element, side)
  self.element = element  -- the element for which this node describes a side
  self.side = side        -- the side of the element which this node describes
  self.parentNode = nil   -- which parent node this node is aligned to
  self.childNodes = {}    -- any nodes which align to this node
  -- resolvedVal = 0,
  self.resolved = false
end
function Node:__tostring()
  local cstr = {}
  for _, c in ipairs(self.childNodes) do
    if self.parentNode ~= c then
      cstr[#cstr + 1] = "\n"..tostring(c)
    end
  end
  local ar = self.element.align[self.side]
  return ""..self.element.id..":"..respec.util.side_to_str(self.side).." -> "..ar.ref..":"..respec.util.side_to_str(ar.side)..
        ("\nchlidren = ["..table.concat(cstr,"")):gsub("\n", "\n  ").."]\n"
end
local function create_node(element, side)
  return Node(element, side)
end

local function connect_nodes(parent, child)
  table.insert(parent.childNodes, child)
  child.parentNode = parent
end

local function add_root(graph, node)
  graph.roots[graph.rootsPos] = node
  graph.rootsPos = graph.rootsPos + 1
end

-- Takes newChain and inserts it in the existing chainList, if applicable
-- newChain should be a list of nodes, in order (e.g. LFT/RGT or TOP/BOT)
-- returns true/false, chainList -- if successfully added or not, and the ref to the chain (either on root or the new one)
local function attach_new_chain_to_end_of_existing(chainList, chainListSize, newChain)
  local added = false
  local ret = newChain
  local frontOtherNode = newChain[1].oppositeNode
  for ci = 1, chainListSize do
    local oChain = chainList[ci]
    if oChain then
      local oCount = #oChain
      if oChain[oCount] == frontOtherNode then -- we found our chain, attach
        local ni = 1
        for i = oCount + 1, oCount + #newChain + 1 do
          oChain[i] = newChain[ni] ; ni = ni + 1
        end
        added = true
        ret = oChain
        break
      end
    end
  end
  return added
end

-- Takes newChain and attaches to the end of it any existing chain, if applicable - removing the existing chain from chainList if done
-- newChain should be a list of nodes, in order (e.g. LFT/RGT or TOP/BOT)
-- returns newChain - that may contain new elements added to it
local function attach_existing_chain_to_new_chain(chainList, chainListSize, newChain)
  local nCount = #newChain
  local lastOtherNode = newChain[nCount].oppositeNode
  for ci = 1, chainListSize do
    local oChain = chainList[ci]
    if oChain then
      if oChain[1] == lastOtherNode then -- we found our chain, attach and remove
        local oCount = #oChain
        local oi = 1
        for i = nCount + 1, nCount + oCount + 1 do
          newChain[i] = oChain[oi] ; oi = oi + 1
        end
        chainList[ci] = nil -- remove
        break
      end
    end
  end
  return newChain
end

-- checks if nodes are chained, and attaches them to existing chains if applicable.
local function check_and_add_to_chains(graph, node1, node2)
  if node1.parentNode ~= node2 or node2.parentNode ~= node1 then return end
  -- else: nodes reference each other, might be chains
  local e1, e2 = node1.element, node2.element
  local s1, s2 = node1.side, node2.side
  if s1 == s2 then -- they represent the same side of different elements, this is an error, not a chain
    log_error("Elements ["..e1.id.."] and ["..e2.id.."] have their "..side_to_str(s1).." sides reference each other. This is not allowed")
    return
  end

  if s1 == TOP then -- s2 is BOT
    local newChain = attach_existing_chain_to_new_chain(graph.verChainLists, graph.verChainPos, { node2, node1 })
    local added = attach_new_chain_to_end_of_existing(graph.verChainLists, graph.verChainPos, newChain)
    if not added then -- chain wasn't added, so add it now
      graph.verChainPos = graph.verChainPos + 1
      graph.verChainLists[graph.verChainPos] = newChain
    end
  elseif s1 == BOT then -- s2 is TOP
    local newChain = attach_existing_chain_to_new_chain(graph.verChainLists, graph.verChainPos, { node1, node2 })
    local added = attach_new_chain_to_end_of_existing(graph.verChainLists, graph.verChainPos, newChain)
    if not added then -- chain wasn't added, so add it now
      graph.verChainPos = graph.verChainPos + 1
      graph.verChainLists[graph.verChainPos] = newChain
    end
  elseif s1 == LFT then -- s2 is RGT
    local newChain = attach_existing_chain_to_new_chain(graph.horChainLists, graph.horChainPos, { node2, node1 })
    local added = attach_new_chain_to_end_of_existing(graph.horChainLists, graph.horChainPos, newChain)
    if not added then -- chain wasn't added, so add it now
      graph.horChainPos = graph.horChainPos + 1
      graph.horChainLists[graph.horChainPos] = newChain
    end
  elseif s1 == RGT then -- s2 is LFT
    local newChain = attach_existing_chain_to_new_chain(graph.horChainLists, graph.horChainPos, { node1, node2 })
    local added = attach_new_chain_to_end_of_existing(graph.horChainLists, graph.horChainPos, newChain)
    if not added then -- chain wasn't added, so add it now
      graph.horChainPos = graph.horChainPos + 1
      graph.horChainLists[graph.horChainPos] = newChain
    end
  end
end

  -- element - the table raf to the element
  -- newNode: a node representing one of the sides
  -- returns the new node created, or nil if it failed
local function add_side(self, element, newNode)
  local side = newNode.side
  local sideRef = element.align[side]
  if sideRef.ref ~= "" and sideRef.ref == element.id then
    log_error("Element with ID "..(element.id)..", side: "..side_to_str(side).." reference itself. This is not allowed")
    return
  end

  -- if side has a reference, try to find it in existing node
  if sideRef.ref ~= "" then
    local foundParent = nil
    local parentIsFromChain = false
    for _, rootNode in pairs(self.roots) do
      foundParent = find_parent(sideRef.ref, sideRef.side, rootNode)
      if foundParent then break end
    end
    if not foundParent then -- check for parent in the chains
      local chainLists = self.verChainLists ; if side == LFT or side == RGT then chainLists = self.horChainLists end
      for _, chain in pairs(chainLists) do
        foundParent = find_parent_in_chain(sideRef.ref, sideRef.side, chain)
        if foundParent then parentIsFromChain = true ; break end
      end
    end
    if foundParent then
      connect_nodes(foundParent, newNode)
      if not parentIsFromChain then
        check_and_add_to_chains(self, foundParent, newNode)
      end
    else
      add_root(self, newNode)
    end
  else -- side has no reference ID
    -- even nodes without ref ID need to be in the graph, if they align with parent,
    -- or in case something else needs to align to them
    add_root(self, newNode)
  end

  -- now find any parentless nodes (aka roots) which may reference this node
  local ourId = element.id
  if ourId ~= "" then
    for k, rootNode in pairs(self.roots) do
      local ref =  rootNode.element.align[rootNode.side]
      if ref.ref == ourId and ref.side == side then
        connect_nodes(newNode, rootNode)
        -- remove rootNode from roots as it now has a parent
        self.roots[k] = nil
        check_and_add_to_chains(self, newNode, rootNode)
      end
    end
  end

  return newNode
end

local function add_sides_with_dependency_check(self, elem, S1, S2)
  local n1 = create_node(elem, S1)
  local n2 = create_node(elem, S2)
  if n1 then n1.oppositeNode = n2 end
  if n2 then n2.oppositeNode = n1 end
  if elem.align[S1] == UNSET then -- side 1 _might_ depend on S2
    add_side(self, elem, n2)
    add_side(self, elem, n1)
  else -- anything else just add them in order
    add_side(self, elem, n1)
    add_side(self, elem, n2)
  end
end

-- returns newList, newListSize
local function compact(list, maxIndex)
  local newList = {}
  local ni = 0
  for ori = 1, maxIndex do
    local oVal = list[ori]
    if oVal then
      ni = ni + 1
      newList[ni] = oVal
    end
  end
  return newList, ni
end

local function add_start_end_to_chain(chainList)
  local sz = #chainList
  if sz == 0 then return end
  chainList[sz + 1] = chainList[sz].oppositeNode
  -- now to add to the front.. slow :/
  table.insert(chainList, 1, chainList[1].oppositeNode)
end

-- Public functions
----------------------------------------------------------------
-- graph class
-- represents a graph of side-to-side reference
function respec.graph.new()
  local graph = {
    finishedAdding = false,
    rootsPos = 1, -- this isn't an index, unless finish_adding() is called
    roots = {},
    horChainPos = 1, -- not an index unless finish_adding() is called
    horChainLists = {}, -- stores lists of chained nodes, in order
    verChainPos = 1, -- not an index unless finish_adding() is called
    verChainLists = {}, -- stores lists of chained nodes, in order
  }

  function graph:add_element(elem)
    if self.finishedAdding then log_error("Can't add element to graph after finish_adding() is called!") ; return end
    if not elem.physical then return end -- graph is for rendered elements only
    add_sides_with_dependency_check(self, elem, TOP, BOT)
    add_sides_with_dependency_check(self, elem, LFT, RGT)
    return self
  end

  function graph:clear()
    self.finishedAdding = false
    self.rootsPos = 1
    self.roots = {}
    self.horChainPos = 1
    self.horChainLists = {}
    self.verchainPos = 1
    self.verChainLists = {}
  end

  function graph:finish_adding()
    if self.finishedAdding then log_error("finish_adding() called twice!") ; return end
    self.finishedAdding = true
    -- compact the graph roots and chains
    local nr, nrs = compact(self.roots, self.rootsPos)
    self.roots = nr ; self.rootsPos = nrs
    local nhc, nhcs = compact(self.horChainLists, self.horChainPos)
    self.horChainLists = nhc ; self.horChainPos = nhcs
    local nvc, nvs = compact(self.verChainLists, self.verChainPos)
    self.verChainLists = nvc ; self.verChainPos = nvs
    -- update the chains to include their start/end nodes
    for i = 1, self.horChainPos do
      add_start_end_to_chain(self.horChainLists[i])
    end
    for i = 1, self.verChainPos do
      add_start_end_to_chain(self.verChainLists[i])
    end
    return self
  end
  return graph
end
