
local ri = respec.internal
local suppElems = ri.supported_elements
local con = respec.const
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right
local VISIBLE = con.visible
local log_error = respec.log_error
local str_or = respec.util.str_or
local concatTbl = table.concat

local layoutCount = 0
local function unique_layout_id()
  layoutCount = layoutCount + 1 -- overflow doesn't matter
  return "LAYOUT_"..layoutCount
end

local function get_layout_debug_formspec(layout)
  local s = ""
  if respec.settings.debug() then
    local inset = layout.paddings
    s=s.."box[0,0;"..inset[LFT]..","..layout.measured[BOT]..";#FFFF0028]"
    s=s.."box[0,0;"..layout.measured[RGT]..","..inset[TOP]..";#FFFF0028]"
    s=s.."box[0,"..
        (layout.measured[BOT] - inset[BOT])..";"..
        layout.measured[RGT]..","..inset[BOT]..";#FFFF0028]"
    s=s.."box["..(layout.measured[RGT] - inset[RGT])..
        ",0;"..
        inset[RGT]..","..layout.measured[BOT]..";#FFFF0028]"
  end
  return s
end

local function get_style_string_for_element(elem)
  if not elem.style then return "" end
  local ret = {}
  local elemName = elem.internalId
  for state, props in pairs(elem.style) do
    local st = "" ; if state ~= "" then st = ":"..state end
    table.insert(ret, "style["..elemName..st..";"..props.."]")
  end
  return concatTbl(ret, "")
end

local fs_elem_box = respec.internal.fs_elem_box
local fs_elem = respec.util.fs_make_elem
local function add_common_physical_formspec_string(elem, str, layout)
  local ret = { fs_elem_box(elem), get_style_string_for_element(elem), str} -- the style must be defined before the element
  if not elem.disableCustom and type(elem.pixelBorder) == "string" then
    ret[#ret+1] = fs_elem_box(elem, true, elem.pixelBorder)
  end
  if elem.tooltip then
    if elem.fsInfo.inFields > 0 then
      ret[#ret+1] = fs_elem("tooltip", elem.internalId, elem.tooltip, layout.tooltipBg, layout.tooltipFont)
    else
      local x = tostring(elem.measured[LFT] + elem.margins[LFT] + elem.measured.xOffset)
      local y = tostring(elem.measured[TOP] + elem.margins[TOP] + elem.measured.yOffset)
      local w = tostring(elem.measured.w)
      local h = tostring(elem.measured.h)
      ret[#ret+1] = fs_elem("tooltip", x..","..y, w..","..h, elem.tooltip, layout.tooltipBg, layout.tooltipFont)
    end
  end
  return concatTbl(ret, "")
end

local num_or = respec.util.num_or

local function parse_common_padd_marg_into(inf, tbl)
  if not inf then return tbl end
  if type(inf) == "number" then
    tbl[TOP] = inf ; tbl[BOT] = inf ; tbl[LFT] = inf ; tbl[RGT] = inf
  elseif type(inf) == "table" then
    local mL = num_or(inf.hor, 0) ; local mR = mL
    local mT = num_or(inf.ver, 0) ; local mB = mT
    mT = num_or(inf.above,  mT)
    mB = num_or(inf.below,  mB)
    mL = num_or(inf.before, mL)
    mR = num_or(inf.after,  mR)
    tbl[TOP] = mT ; tbl[BOT] = mB ; tbl[LFT] = mL ; tbl[RGT] = mR
  end
end

-- return a table of paddings, with 0 if not set
local function get_paddings(spec)
  local pad = {[TOP] = 0, [BOT] = 0, [LFT] = 0, [RGT] = 0}
  local inf = spec.paddings
  parse_common_padd_marg_into(inf, pad)
  return pad
end

local function get_default_element_margins(spec)
  local defM = {[TOP] = 0, [BOT] = 0, [LFT] = 0, [RGT] = 0}
  local inf = spec.defaultElementMargins
  parse_common_padd_marg_into(inf, defM)
  return defM
end

----------------------------------------------------------------
-- Layout class public functions
----------------------------------------------------------------

-- creates a new layout class that handles laying out other elements (including nested Layouts)
-- spec: table. A subset of the form's spec- see doc/api.md.
-- There shouldn't be a need to ever use this manually
respec.Layout = respec.util.Class(respec.PhysicalElement)

function respec.Layout:init(spec)
  if type(spec.id) ~= "string" then spec.id = unique_layout_id() end
  respec.PhysicalElement.init(self, suppElems._LAYOUT, spec)
  self.elements = {}
  self.fieldElemsById = {}
  self.elementsGraph = respec.graph.new()
  self.ids = {}
  self.paddings = get_paddings(spec)
  self.defaultMargins = get_default_element_margins(spec)
  self.serialized = nil
  self.tooltipBg = str_or(spec.tooltipBgColor)
  self.tooltipFont = str_or(spec.tooltipFontColor)
end
local function do_add(self, element, idGen)
  element.internalId = idGen:id()
  if self.serialized then
    -- TODO: check if anything related to layouting has changed, if not return last serialization
  end
  local other = {}
  if type(element.on_added) == "function" then -- it's a sub-layout element
    other = element:on_added(idGen, self) -- this returns other elements to add
  end
  local newId = element.id
  if not element.fsInfo then return self end -- invalid element
  if newId and newId ~= "" and self.ids[newId] then
    -- multiple elements with no ID are allowed, but not two with same ID
    log_error("Elements within the same layout cannot have the same ID: "..newId)
    return self
  end
  if newId then self.ids[newId] = true end
  table.insert(self.elements, element)

  if element.fsInfo.inFields > 0 then
    self.fieldElemsById[element.internalId] = element
  end
  self.elementsGraph:add_element(element)
  if type(other) == "table" then
    for i = 1, #other do
      do_add(self, other[i], idGen)
    end
  end
  return self
end

-- Sets the content of this layout. If any previous content was set, it will be overwritten
-- Use one of the `respec.elements.` functions to create elements.
-- idGen should be an object that has a :id() function to provide a unique ID
function respec.Layout:set_elements(elementsList, idGen, optIdTable, optFieldElemById)
  self.elementsGraph:clear()
  self.elements = {}
  self.ids = optIdTable or {}
  self.fieldElemsById = optFieldElemById or {}
  for _, element in ipairs(elementsList) do
    do_add(self, element, idGen)
  end
  self.elementsGraph:finish_adding()
  -- cleanup
  if not optIdTable then
    self.ids = nil
  end
  return self
end

function respec.Layout:measure(isRoot)
  if isRoot then
    ri.perform_layout_of_form_layout(self)
  else
    ri.perform_layout(self)
  end
  self.measurePerformed = true
  self.serialized = false
end

-- override of element func
function respec.Layout:to_formspec_string(ver, persist)
  -- TODO: since elements can be re-set, then check elements state against old state
  if not self.serialized then
    self.serialized = true
    local tbl = {}
    for _, el in ipairs(self.elements) do
      if el.fsName ~= nil and ver >= el.fsInfo.minVer then
        if el.physical == false then
          tbl[#tbl+1] = el:to_formspec_string(ver, persist)
        elseif el.visibility == VISIBLE then
          tbl[#tbl+1] = add_common_physical_formspec_string(el, el:to_formspec_string(ver, persist, self), self)
        end
      end
    end
    self.serialized = concatTbl(tbl, "")
  end
  local debug = get_layout_debug_formspec(self)
  return debug..self.serialized
end

function respec.Layout:get_interactive_elements()
  return self.fieldElemsById
end
