
local con = respec.const
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right
local UNSET = con.unset
local VISIBLE = con.visible
local INVISIBLE = con.invisible
local GONE = con.gone
local PARENT = con.parent
local PACKED = con.chain_packed
local SPREAD = con.chain_spread
local SPREAD_INSIDE = con.chain_spread_inside

local NO_INTERACT = 0
local SEND_FIELDS = 1
local SEND_VALUE_AND_FIELDS = 2
local SEND_VALUE_AND_FIELDS_ON_ENTER = 3

respec.elements = {} -- init this table here
local Class = respec.util.Class
local log_warn = respec.log_warn
local log_error = respec.log_error
local str_or = respec.util.str_or
local concatTbl = table.concat

local elementsWithName = {
  animated_image = true, model = true, pwdfield = true, field = true,
  textarea = true, hypertext = true, button = true, button_url = true,
  image_button = true, item_image_button = true, button_exit = true,
  button_url_exit = true, image_button_exit = true, textlist = true,
  tabheader = true, dropdown = true, checkbox = true, scrollbar = true, table = true
}

local function minf(tbl) return { name = tbl[1], minVer = tbl[2], inFields = tbl[3] } end

-- format is { name = "formspec_name", minVer = MIN_VERSION_INT, inFields = 0/1/SEND_VALUE_AND_FIELDS }

respec.internal.supported_elements = {
  _LAYOUT =           minf { "_LAYOUT", 1, NO_INTERACT },
  label =             minf { "label", 1, NO_INTERACT },
  button =            minf { "button", 1, SEND_FIELDS },
  container =         minf { "container", 1, NO_INTERACT },
  scroll_container =  minf { "scroll_container", 3, NO_INTERACT },
  list =              minf { "list", 1, SEND_VALUE_AND_FIELDS },
  listring =          minf { "listring", 1, NO_INTERACT },
  listcolors =        minf { "listcolors", 1, NO_INTERACT },
  tooltip =           minf { "tooltip", 1, NO_INTERACT },
  image =             minf { "image", 1, NO_INTERACT },
  animated_image =    minf { "animated_image", 6, SEND_VALUE_AND_FIELDS },
  model =             minf { "model", 1, NO_INTERACT },
  item_image =        minf { "item_image", 1, NO_INTERACT },
  background =        minf { "background", 1, NO_INTERACT },
  background9 =       minf { "background9", 2, NO_INTERACT },
  pwdfield =          minf { "pwdfield", 1, SEND_VALUE_AND_FIELDS_ON_ENTER },
  field =             minf { "field", 1, SEND_VALUE_AND_FIELDS_ON_ENTER },
  field_enter_after_edit = minf { "field_enter_after_edit", 7, NO_INTERACT }, -- incorporate into field
  field_close_on_enter =  minf { "field_close_on_enter", 1, NO_INTERACT }, -- incorporate into field
  textarea =          minf { "textarea", 1, SEND_FIELDS },
  hypertext =         minf { "hypertext", 1, SEND_VALUE_AND_FIELDS },
  vertlabel =         minf { "vertlabel", 1, NO_INTERACT },
  button_url =        minf { "button_url", 1, SEND_FIELDS },
  image_button =      minf { "image_button", 1, SEND_FIELDS },
  item_image_button = minf { "item_image_button", 1, SEND_FIELDS },
  button_exit =       minf { "button_exit", 1, SEND_FIELDS }, -- incorporate into button
  button_url_exit =   minf { "button_url_exit", 1, SEND_FIELDS }, -- incorporate into button_url
  image_button_exit = minf { "image_button_exit", 1, SEND_FIELDS }, -- incorporate into image_button
  textlist =          minf { "textlist", 1, SEND_VALUE_AND_FIELDS },
  tabheader =         minf { "tabheader", 1, SEND_VALUE_AND_FIELDS },
  box =               minf { "box", 1, NO_INTERACT },
  dropdown =          minf { "dropdown", 1, SEND_VALUE_AND_FIELDS },
  checkbox =          minf { "checkbox", 1, SEND_FIELDS },
  scrollbar =         minf { "scrollbar", 1, SEND_VALUE_AND_FIELDS },
  scrollbaroptions =  minf { "scrollbaroptions", 1, NO_INTERACT },
  table =             minf { "table", 1, SEND_VALUE_AND_FIELDS },
  tableoptions =      minf { "tableoptions", 1, NO_INTERACT }, -- hmm
  tablecolumns =      minf { "tablecolumns", 1, NO_INTERACT }, -- maybe incorporate into table
  style =             minf { "style", 1, NO_INTERACT },
  style_type =        minf { "style_type", 1, NO_INTERACT },
}
local elem_info = respec.internal.supported_elements

local function is_num(v) return type(v) == "number" end
local function is_str(v) return type(v) == "string" end

local function clamp(value, min, max)
  if value < min then return min elseif value > max then return max else return value end
end

----------------------------------------------------------------
-- spec related funcs
----------------------------------------------------------------

local function valid_id(value)
  if not is_str(value) then return "" end
  return value
end

local function valid_size(value)
  if not is_num(value) then return 0 end
  return value
end

local function valid_bias(b)
  if is_num(b) then return clamp(b, 0, 1) end
  return nil
end

local function valid_chain_type(chainType)
  if chainType == PACKED or chainType == SPREAD or chainType == SPREAD_INSIDE then return chainType
  else return nil end
end

local function valid_weight(chainWeight)
  if not is_num(chainWeight) then return nil end
  if chainWeight < 0 then return 0 else return chainWeight end
end

local function get_visibility(spec)
  local nv = spec.visibility
  if is_num(nv) and (nv == VISIBLE or nv == INVISIBLE or nv == GONE) then
    return nv
  else
    if spec.visible == true then return VISIBLE
    elseif spec.visible == false then return GONE
    else return VISIBLE end
  end
end

local function get_margins(spec)
  local margins = {[TOP] = UNSET, [BOT] = UNSET, [LFT] = UNSET, [RGT] = UNSET}
  if is_num(spec.margins) then
    local mg = spec.margins
    margins[TOP] = mg ; margins[BOT] = mg ; margins[LFT] = mg ; margins[RGT] = mg
  end
  if is_num(spec.marginsHor) then
    local mg = spec.marginsHor
    margins[LFT] = mg ; margins[RGT] = mg
  end
  if is_num(spec.marginsVer) then
    local mg = spec.marginsVer
    margins[TOP] = mg ; margins[BOT] = mg
  end
  if is_num(spec.marginTop) then margins[TOP] = spec.marginTop end
  if is_num(spec.marginBottom) then margins[BOT] = spec.marginBottom end
  if is_num(spec.marginStart) then margins[LFT] = spec.marginStart end
  if is_num(spec.marginEnd) then margins[RGT] = spec.marginEnd end

  return margins
end

local function alref(v, a, func) if is_str(v) then func(v) elseif is_str(a) then func(a) end end
local function get_align(spec)
  local at = {ref = "", side = UNSET}
  local ab = {ref = "", side = UNSET}
  local al = {ref = "", side = UNSET}
  local ar = {ref = "", side = UNSET}

  local chor = spec.centerHor
  local cver = spec.centerVer
  if chor == true then al.side = PARENT ; ar.side = PARENT
  elseif is_str(chor) then
    al.ref = chor ; al.side = LFT
    ar.ref = chor ; ar.side = RGT
  end

  if cver == true then at.side = PARENT ; ab.side = PARENT
  elseif is_str(cver) then
    at.ref = cver ; at.side = TOP
    ab.ref = cver ; ab.side = BOT
  end

  if spec.top_to_parent_top == true or spec.toTop == true           then at.side = PARENT end
  if spec.bottom_to_parent_bottom == true or spec.toBottom == true  then ab.side = PARENT end
  if spec.start_to_parent_start == true or spec.toStart == true     then al.side = PARENT end
  if spec.end_to_parent_end == true or spec.toEnd == true           then ar.side = PARENT end

  alref(spec.top_to_top_of, spec.alignTop,    function(r) at.ref = r ; at.side = TOP end)
  alref(spec.top_to_bottom_of, spec.below,    function(r) at.ref = r ; at.side = BOT end)

  alref(spec.bottom_to_top_of, spec.above,          function(r) ab.ref = r ; ab.side = TOP end)
  alref(spec.bottom_to_bottom_of, spec.alignBottom, function(r) ab.ref = r ; ab.side = BOT end)

  alref(spec.start_to_start_of, spec.alignStart,    function(r) al.ref = r ; al.side = LFT end)
  alref(spec.start_to_end_of, spec.after,           function(r) al.ref = r ; al.side = RGT end)

  alref(spec.end_to_start_of, spec.before,    function(r) ar.ref = r ; ar.side = LFT end)
  alref(spec.end_to_end_of, spec.alignEnd,    function(r) ar.ref = r ; ar.side = RGT end)

  if at.side == UNSET and ab.side == UNSET then
    at.side = PARENT
  end
  if al.side == UNSET and ar.side == UNSET then
    al.side = PARENT
  end

  return { [TOP] = at, [BOT] = ab, [LFT] = al, [RGT] = ar }
end

-- returns a table (or nil): {"":"prop=val;prop=val",} - where the key is the state and the value is the string of props
local function get_valid_style(fsName, styleSpec)
  if fsName ~= "style_type" and not elementsWithName[fsName] then return nil end
  local parsed = {}
  local baseProps = {}
  if type(styleSpec) ~= "table" then return end
  for k, v in pairs(styleSpec) do
    local vType = type(v)
    if k == "target" then
      -- skip this one, due to this function being used from elements.StyleType()
    elseif vType == "string" then
      table.insert(baseProps, tostring(k).."="..v)
    elseif vType == "number" or vType == "boolean" then
      table.insert(baseProps, tostring(k).."="..tostring(v))
    elseif vType == "table" then
      local props = {}
      for subK, subV in pairs(v) do
        if type(subV) == "string" then
          table.insert(props, tostring(subK).."="..subV)
        end
      end
      parsed[tostring(k)] = concatTbl(props, ";")
    end
  end
  parsed[""] = concatTbl(baseProps, ";")
  return parsed
end
-- export for use in elements.lua
respec.elements.get_valid_style = get_valid_style

----------------------------------------------------------------
-- public functions
----------------------------------------------------------------

-- base element, for non-physical elements
respec.Element = Class()

function respec.Element:init(fselem)
  if fselem and fselem.name and elem_info[fselem.name] then
    self.fsName = fselem.name
    self.fsInfo = fselem
  else
    log_error("Unsupported element created: "..dump(fselem))
  end
  self.physical = false
end

-- To be overriden by child classes
-- ver: an int, the current formspec version
-- persist: A data object that persists throughout the layout process.
--   persist.state is the From's `state` object
function respec.Element:to_formspec_string(ver, persist, layout)
  log_warn("called base to_formspec_string") ; return ""
end

-- to be overriden by child elems, if necessary
-- `persist` is an object that persits and gets passed to all elements, in order they exist
function respec.Element:before_measure(persist) end

respec.PhysicalElement = Class(respec.Element)
--[[
--- Do not use directly. Use one of the `respec.elements.` functions instead
--- `fselem` must be an entry from the respec.internal.supported_elements table
--- `spec` must be a table as documented in doc/api.md
]]
function respec.PhysicalElement:init(fselem, spec)
  -- o = respec.Element:new(o, fsName)
  -- setmetatable(o, self)
  -- self.__index = self
  respec.Element.init(self, fselem)
  self.id = valid_id(spec.id)
  self.width = valid_size(spec.width or spec.w)  -- the width set by user
  self.height = valid_size(spec.height or spec.h) -- the height set by user
  self.visibility = get_visibility(spec)
  self.margins = get_margins(spec) -- the margins
  self.align = get_align(spec)
  self.horBias = valid_bias(spec.biasHor)
  self.verBias = valid_bias(spec.biasVer)
  self.pixelBorder = spec.pixelBorder
  self.chainTypeHor = valid_chain_type(spec.chainTypeHor)
  self.chainTypeVer = valid_chain_type(spec.chainTypeVer)
  self.chainWeightHor = valid_weight(spec.weightHor)
  self.chainWeightVer = valid_weight(spec.weightVer)
  self.measured = { -- represents the location of the outer bounds that include margins
      [TOP] = UNSET, [BOT] = UNSET, [LFT] = UNSET, [RGT] = UNSET,
      w = UNSET, h = UNSET, -- the actual elements (not bounds) w/h
      xOffset = 0, yOffset = 0 -- customX/Y add an offset
  }
  self.tooltip = str_or(spec.tooltip)
  self.style = get_valid_style(self.fsName, spec.style)
  -- self.on_interact = function(...) end -- to be overwritten by interactive elements

  self.physical = true
end
