-- defines the specific elements

local con = respec.const
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right
local WRAP = con.wrap_content
local UNSET = con.unset
local PARENT = con.parent

-- utility funcs

local num_or = respec.util.num_or
local str_or =  respec.util.str_or
local bool_or =  respec.util.bool_or
local min0 = respec.util.min0
local log_error = respec.log_error
local engine = respec.util.engine
local elems = respec.elements
local concatTbl = table.concat
local mapTbl = respec.util.map

local get_valid_style = elems.get_valid_style
elems.get_valid_style = nil
local measure_text = respec.internal.measure_text
respec.internal.measure_text = nil

local function get_style_type_data(spec)
  if type(spec) ~= "table" then return nil end
  local entires = {}
  for k, v in pairs(spec) do
    local typeV = type(v)
    if typeV == "string" or typeV == "number" or typeV == "boolean" then
      entires[tostring(k)] = tostring(v)
    end
  end
  return entires
end

 local function get_valid_dropdown_items(specItems)
  if type(specItems) ~= "table" then return {} end
  return concatTbl(specItems, ",")
 end

-- returns invloc, listname
local function get_inv_loc_and_name_from_data(data, persist)
  local invLoc = data[1] or ""
  local listName = data[2] or ""
  local state = persist.state
  if invLoc == -1  then -- special case to autopopulate with position from state
    if not state or not state.info or not state.info.pos then
      log_error("Error: List cannot be created, did you forget to use `show_on_node_rightclick()`?")
      return ""
    end
    local pos = state.info.pos
    invLoc = "nodemeta:"..pos.x..","..pos.y..","..pos.z
  end
  return invLoc, listName
end

local function get_merged_styles(persist, useCommon, typeStyleName, elemStyleData)
  local baseSt = {}
  if useCommon then
    local all = persist["style_*"]
    if all then for k, v in pairs(all) do baseSt[k] = v end end
  end
  if typeStyleName then
    local st = persist[typeStyleName]
    if st then for k,v in pairs(st) do baseSt[k] = v end end
  end
  if type(elemStyleData) == "table" then
    for k,v in pairs(elemStyleData) do baseSt[k] = v end
  end
  return baseSt
end

local function get_valid_orientation(orientStr)
  if type(orientStr) ~= "string" or string.len(orientStr) == 0 then return "vertical" end
  if orientStr:sub(1,1) == "h" then
    return "horizontal"
  else
    return "vertical"
  end
end

local function get_scrollbar_spec_for_container(cont, spec)
  local id = cont.id ; if id == "" then id = cont.internalId end
  local rs = {
    w = 0, h = 0,
    id = id.."_scrollbar",
    listener = spec.scrollbarListener,
    orientation = cont.orientation,
  }
  local isVert = cont.orientation:sub(1,1) == "v"
  if isVert then
    rs.w = cont.barSize
    rs.h = cont.height
    rs.centerVer = cont.id
    rs.after = cont.id
    rs.marginStart = -cont.margins[RGT]
    rs.marginTop = cont.margins[TOP]
  else
    rs.w = cont.width
    rs.h = cont.barSize
    rs.centerHor = cont.id
    rs.below = cont.id
    rs.marginTop = -cont.margins[BOT]
    rs.marginStart = cont.margins[LFT]
  end
  return rs
end

local function get_valid_table_options(spec)
  if type(spec.config) ~= "table" then return "" end
  local cgf = spec.config
  local ret = {}
  if str_or(cgf.color) then ret[#ret+1] = "color="..cgf.color end
  if str_or(cgf.bg) then    ret[#ret+1] = "background="..cgf.bg end
  if bool_or(cgf.border) ~= nil then ret[#ret+1] = "border="..tostring(cgf.border) end
  if str_or(cgf.highlight) then ret[#ret+1] = "highlight="..cgf.highlight end
  if num_or(cgf.opendepth) then ret[#ret+1] = "opendepth="..cgf.opendepth end
  return concatTbl(ret, ";")
end

local function update_measurements_to_fit_aspect_ratio(m, r)
  if r and r > 0 and m.h > 0 then
    local sR = m.w / m.h
    if sR > r then -- height is limiting, so make width smaller
      local nw = r * m.h
      m.xOffset = m.xOffset + (m.w - nw) / 2 ; m.w = nw
    else -- width is limiting so make height smaller
      local nh = m.w / r
      m.yOffset = m.yOffset + (m.h - nh) / 2 ; m.h = nh
    end
  end
end

local function apply_wrap_and_paddings_to_clickable(clk, persist, localStyleName, optExtraWidth, unaffectedByGlobal)
  if clk.origW == WRAP or clk.origH == WRAP then
    local style = get_merged_styles(persist, (not unaffectedByGlobal), localStyleName, clk.styleData)
    local wh = measure_text(clk.txt, persist.playerName, style.font == "mono", style.font_size)
    wh.width = wh.width + (optExtraWidth or 0)
    if clk.origW == WRAP then clk.width = wh.width + (clk.paddingsHor or 0) end
    if clk.origH == WRAP then clk.height = wh.height + (clk.paddingsVer or 0) end
  end
end

local function get_valid_textlist_items(items)
  if type(items) ~= "table" then return {} end
  local ret = {}
  local ri = 1
  for i = 1, #items do
    ret[ri] = tostring(items[i])
    ri = ri + 1
  end
  return concatTbl(ret, ",")
end

-- minv/maxv in range 0-255
local function randclrval(minv, maxv)
  return string.format("%x", math.random(minv, maxv))
end

local elemInfo = respec.internal.supported_elements

--- debug box stuff

local fsmakeelem = respec.util.fs_make_elem
local make_elem = function (obj, ...)
  return fsmakeelem(obj.fsName, ...)
end

-- common funcs

-- returns a "x,y" position string
local function pos_only(obj, customY, customX)
  if not customY then customY = 0 end
  local x = obj.measured[LFT] + obj.margins[LFT] + obj.measured.xOffset + num_or(customX, 0)
  local y = obj.measured[TOP] + obj.margins[TOP] + obj.measured.yOffset + num_or(customY, 0)
  return ""..x..","..y
end

-- returns a "x,y;w,h" position + size string
local function pos_and_size(obj, customY, customX)
  local ms = obj.measured
  return pos_only(obj, customY, customX)..";"..(ms.w)..","..(ms.h)
end

local function get_list_xywh(self)
  return pos_only(self)..";"..self.slotW..","..self.slotH
end

local function set_to_wrap_if_absent(spec)
  if not spec.w and not spec.width then spec.w = WRAP end
  if not spec.h and not spec.height then spec.h = WRAP end
end

local Class = respec.util.Class

----------------------------------------------------------------
--- Public API : Elements
----------------------------------------------------------------

----------------------------------------------------------------
-- Physical Elements
----------------------------------------------------------------

----------------------------------------------------------------
-- Label (label and vertlabel)
----------------------------------------------------------------
elems.Label = Class(respec.PhysicalElement)
function elems.Label:init(spec)
  set_to_wrap_if_absent(spec)
  local einf =  elemInfo.label
  self.vertical = (spec.vertical == true)
  if self.vertical then einf = elemInfo.vertlabel end
  respec.PhysicalElement.init(self, einf, spec)
  self.origW = self.width ; self.origH = self.height
  self.txt = str_or(spec.text, "")
  self.areaLabel = spec.area == true
end
-- override
function elems.Label:to_formspec_string(ver, _)
  if (not self.vertical) and self.areaLabel and ver >= 9 then
    return make_elem(self, pos_and_size(self), self.txt)
  else
  local xOffset, yOffset
  if self.vertical then
    xOffset = self.measured.w / 2
  else
    yOffset = self.measured.h / 2
    if num_or(self.numLines, 1) > 1 then
      yOffset = self.measured.h / (self.numLines * 2)
    end
  end
  return make_elem(self, pos_only(self, yOffset, xOffset), self.txt)
  end
end
-- override
function elems.Label:before_measure(persist)
  local style = get_merged_styles(persist, true, "style_label")
  if self.origW == WRAP or self.origH == WRAP then
    local wh = measure_text(self.txt, persist.playerName, style.font == "mono", style.font_size, 1, self.vertical)
    self.numLines = wh.numLines
    if self.origW == WRAP then self.width = wh.width end
    if self.origH == WRAP then self.height = wh.height end
  end
end

----------------------------------------------------------------
-- Button
----------------------------------------------------------------
elems.Button = Class(respec.PhysicalElement)
function elems.Button:init(spec)
  local ei = elemInfo.button ; if spec.exit == true then ei = elemInfo.button_exit end
  set_to_wrap_if_absent(spec)
  respec.PhysicalElement.init(self, ei, spec)
  self.origW = self.width ; self.origH = self.height
  self.paddingsHor = num_or(spec.paddingsHor or spec.paddings)
  self.paddingsVer = num_or(spec.paddingsVer or spec.paddings)
  if not self.paddingsVer then self.paddingsVer = 0.1 end
  if not self.paddingsHor then self.paddingsHor = 0.1 end
  self.paddingsVer = self.paddingsVer * 2
  self.paddingsHor = self.paddingsHor * 2

  self.styleData = get_style_type_data(spec.style)
  self.txt = str_or(spec.text, "")
  if type(spec.onClick) == "function" then
    self.on_interact = spec.onClick
  end
end
-- override
function elems.Button:before_measure(persist)
  apply_wrap_and_paddings_to_clickable(self, persist, "style_button")
end
-- override
function elems.Button:to_formspec_string(_, _)
  return make_elem(self, pos_and_size(self), self.internalId, self.txt)
end

----------------------------------------------------------------
-- ButtonUrl (button_url)
----------------------------------------------------------------
elems.ButtonUrl = Class(respec.PhysicalElement)
function elems.ButtonUrl:init(spec)
  local ei = elemInfo.button_url ; if spec.exit == true then ei = elemInfo.button_url_exit end
  set_to_wrap_if_absent(spec)
  respec.PhysicalElement.init(self, ei, spec)
  self.url = str_or(spec.url, "")
  self.txt = str_or(spec.text, self.url)
  self.origW = self.width ; self.origH = self.height
  self.paddingsHor = num_or(spec.paddingsHor or spec.paddings)
  self.paddingsVer = num_or(spec.paddingsVer or spec.paddings)
  if not self.paddingsVer then self.paddingsVer = 0.1 end -- button seems to cut off text if its too close to top/bottom
  if not self.paddingsHor then self.paddingsHor = 0.1 end
  self.paddingsVer = self.paddingsVer * 2
  self.paddingsHor = self.paddingsHor * 2

  if type(spec.onClick) == "function" then
    self.on_interact = spec.onClick
  end
end
-- override
function elems.ButtonUrl:before_measure(persist)
  apply_wrap_and_paddings_to_clickable(self, persist, "style_button")
end
-- override
function elems.ButtonUrl:to_formspec_string(_, _)
  return make_elem(self, pos_and_size(self), self.internalId, self.txt, self.url)
end

----------------------------------------------------------------
-- ImageButton (image_button)
----------------------------------------------------------------
elems.ImageButton = Class(respec.PhysicalElement)
function elems.ImageButton:init(spec)
  local ei = elemInfo.image_button ; if spec.exit == true then ei = elemInfo.image_button_exit end
  respec.PhysicalElement.init(self, ei, spec)

  self.img = str_or(spec.image, "")
  self.label = str_or(spec.label)
  self.exit = spec.exit == true
  self.noclip = bool_or(spec.noclip)
  self.border = bool_or(spec.border)
  self.imgPressed = str_or(spec.imagePressed)
  self.ratio = num_or(spec.ratio)
  if type(spec.onClick) == "function" then
    self.on_interact = spec.onClick
  end
end
-- override
function elems.ImageButton:to_formspec_string(_, _)
  update_measurements_to_fit_aspect_ratio(self.measured, self.ratio)
  if self.noclip ~= nil or self.border ~= nil or self.imgPressed then
    return make_elem(self, pos_and_size(self),
      self.img, self.internalId, self.label or "",
      tostring(bool_or(self.noclip, false)),
      tostring(bool_or(self.border, true)),
      self.imgPressed or ""
    )
  else
    return make_elem(self, pos_and_size(self), self.img, self.internalId, self.label or "")
  end
end

----------------------------------------------------------------
-- ItemButton (item_image_button)
----------------------------------------------------------------
elems.ItemButton = Class(respec.PhysicalElement)
function elems.ItemButton:init(spec)
  respec.PhysicalElement.init(self, elemInfo.item_image_button, spec)
  self.item = str_or(spec.item, "")
  self.label = str_or(spec.label)
  self.ratio = num_or(spec.ratio)
  if type(spec.onClick) == "function" then
    self.on_interact = spec.onClick
  end
end
-- override
function elems.ItemButton:to_formspec_string(_, _)
  update_measurements_to_fit_aspect_ratio(self.measured, self.ratio)
  return make_elem(self, pos_and_size(self), self.item, self.internalId, self.label or "")
end

----------------------------------------------------------------
-- checkbox
----------------------------------------------------------------
elems.Checkbox = Class(respec.PhysicalElement)
function elems.Checkbox:init(spec)
  set_to_wrap_if_absent(spec)
  respec.PhysicalElement.init(self, elemInfo.checkbox, spec)
  self.origW = self.width ; self.origH = self.height
  self.txt = str_or(spec.text, "")
  self.checked = (spec.on == true) or (spec.checked == true)
  self.styleData = get_style_type_data(spec.style)
  if type(spec.onClick) == "function" then
    self.on_interact = spec.onClick
  end
end
-- override
function elems.Checkbox:before_measure(persist)
  apply_wrap_and_paddings_to_clickable(self, persist, "style_checkbox", 2/5, true)
end
-- override
function elems.Checkbox:to_formspec_string(ver, _)
  local yOffset = 0
  if ver >= 3 then yOffset = self.measured.h / 2 end
  return make_elem(self, pos_only(self, yOffset), self.internalId, self.txt, tostring(self.checked))
end

----------------------------------------------------------------
-- list
----------------------------------------------------------------
elems.List = Class(respec.PhysicalElement)
function elems.List:init(spec)
  respec.PhysicalElement.init(self, elemInfo.list, spec)
  if type(spec.inv) ~= "table" then
    log_error("List spec incorrect, `inv` param must be a table!")
  else
    self.inv = spec.inv
  end
  self.slotW = self.width -- copy these as they will be overwritten later
  self.slotH = self.height
  self.startIndex = min0(num_or(spec.startIndex, 0))
end
-- override
function elems.List:to_formspec_string(_, persist)
  local invLoc, listName = get_inv_loc_and_name_from_data(self.inv, persist)
  return make_elem(self, invLoc, listName, get_list_xywh(self), self.startIndex)
end
-- override
function elems.List:before_measure(persist)
  local sizeX = 1 ; local sizeY = 1
  local padX = 0.25 ; local padY = 0.25
  local style = persist["style_list"]
  if style then
    local size = style["size"] or "1"
    local v1 = size:split(",", false)
    sizeX = v1[1] ; sizeY = v1[2] or v1[1]
    local pad = style["spacing"] or "0.25"
    local v2 = pad:split(",", false)
    padX = v2[1] ; padY = v2[2] or v2[1]
  end
  self.width = min0(self.slotW * (sizeX + padX) - padX)
  self.height = min0(self.slotH * (sizeY + padY) - padY)
end

----------------------------------------------------------------
-- Dropdown
----------------------------------------------------------------
elems.Dropdown = Class(respec.PhysicalElement)
function elems.Dropdown:init(spec)
  if not spec.h and not spec.height then spec.h = WRAP end -- set to wrap height if unset
  respec.PhysicalElement.init(self, elemInfo.dropdown, spec)
  self.itemsStr = get_valid_dropdown_items(spec.items)
  self.index = min0(num_or(spec.index, 0))
  self.indexEvent = bool_or(spec.indexEvent)
  if type(spec.listener) == "function" then
    self.on_interact = spec.listener
  end
end
-- override
function elems.Dropdown:before_measure(persist)
  if self.height == WRAP then
    self.height = measure_text("W", persist.playerName).height -- hacky?
  end
end
-- override
function elems.Dropdown:to_formspec_string(ver, _)
  local idxEv = nil ; if ver >= 4 then idxEv = tostring(self.indexEvent == true) end
  return make_elem(self, pos_and_size(self), self.internalId, self.itemsStr, self.index, idxEv)
end

----------------------------------------------------------------
-- Background (background[] and background9[])
----------------------------------------------------------------
elems.Background = Class(respec.PhysicalElement)
function elems.Background:init(spec)
  spec.width = num_or(spec.width or spec.w, 1)
  spec.height = num_or(spec.height or spec.h, 1)
  self.ignoreLayoutPaddings = true -- special flag used in layout_logic
  local elem = elemInfo.background
  if type(spec.middle) == "number" or type(spec.middle) == "string" then elem = elemInfo.background9 end

  respec.PhysicalElement.init(self, elem, spec)

  self.texture = spec.texture
  if type(spec.fill) == "boolean" then
    self.fill = spec.fill
  else
    self.fill = true
  end
  if elem == elemInfo.background9 then
    self.middle = tostring(spec.middle)
  end
end
-- override
function elems.Background:to_formspec_string(_, _)
  if self.middle then
    local autoclip = self.fill
    if autoclip == nil then autoclip = true end
    return make_elem(self, pos_and_size(self), self.texture, tostring(autoclip), self.middle)
  else
    local autoclip = self.fill
    if autoclip ~= nil then autoclip = tostring(autoclip) end
    return make_elem(self, pos_and_size(self), self.texture, autoclip)
  end
end

----------------------------------------------------------------
-- Field
----------------------------------------------------------------
elems.Field = Class(respec.PhysicalElement)
function elems.Field:init(spec)
  local einf = elemInfo.field
  local isPassword = (spec.isPassword == true)
  if isPassword then einf = elemInfo.pwdfield end
  respec.PhysicalElement.init(self, einf, spec)
  self.isPassword = isPassword
  self.txt = str_or(spec.text, "")
  self.label = str_or(spec.label, "")
  self.closeOnEnter = bool_or(spec.closeOnEnter)
  self.enterAfterEdit = bool_or(spec.enterAfterEdit)
  if type(spec.listener) == "function" then
    self.on_interact = spec.listener
  end
end
-- override
function elems.Field:before_measure(persist)
  if self.label ~= "" then
    if self.margins[TOP] == UNSET then
      local ms = measure_text(self.label, persist.playerName)
      self.margins[TOP] = ms.height
    end
  end
end
-- override
function elems.Field:to_formspec_string(_, _)
  local elems = {}
  if self.closeOnEnter == false then
    table.insert(elems, fsmakeelem("field_close_on_enter", self.internalId, "false"))
  end
  if self.enterAfterEdit == true then
    table.insert(elems, fsmakeelem("field_enter_after_edit", self.internalId, "true"))
  end
  local deftxt = self.txt ; if self.isPassword then deftxt = nil end
  table.insert(elems, make_elem(self, pos_and_size(self), self.internalId, self.label, deftxt))
  return concatTbl(elems, "")
end

----------------------------------------------------------------
-- PasswordField (pwdfield[])
----------------------------------------------------------------
elems.PasswordField = Class(elems.Field)
function elems.PasswordField:init(spec)
  spec.isPassword = true
  elems.Field.init(self, spec)
end

----------------------------------------------------------------
-- TextList
----------------------------------------------------------------
elems.TextList = Class(respec.PhysicalElement)
function elems.TextList:init(spec)
  respec.PhysicalElement.init(self, elemInfo.textlist, spec)
  self.itemsStr = get_valid_textlist_items(spec.items)
  self.index = num_or(spec.index)
  self.trans = bool_or(spec.transparent)
  if type(spec.listener) == "function" then
    self.on_select = spec.listener
    self.on_interact = function(state, value, fields)
      self.on_select(state, engine.explode_textlist_event(value), fields)
    end
  end
end
-- override
function elems.TextList:to_formspec_string(ver, persist)
  if self.trans or self.index then
    local tr = "false" ; if self.trans ~= nil then tr = tostring(self.trans) end
    return make_elem(self, pos_and_size(self), self.internalId, self.itemsStr, self.index or "", tr)
  else
    return make_elem(self, pos_and_size(self), self.internalId, self.itemsStr)
  end
end

----------------------------------------------------------------
-- Container
----------------------------------------------------------------
elems.Container = Class(respec.PhysicalElement)
function elems.Container:init(spec)
  self.internal_elements = spec.elements or {}
  spec.elements = nil

  local einf = elemInfo.container
  if spec.is_scroll_container == true then einf = elemInfo.scroll_container end
  respec.PhysicalElement.init(self, einf, spec)

  self.layout = respec.Layout(spec)
end
-- when added to parent layout
function elems.Container:on_added(idGen, layout)
  self.layout:set_elements(self.internal_elements, idGen, layout.ids, layout.fieldElemsById)
  return {}
end
-- before being measured
function elems.Container:before_measure(persist)
  self.layout.playerName = persist.playerName
end
-- after measured is complete
function elems.Container:after_measure()
  self.layout.width = self.measured.w
  self.layout.height = self.measured.h
  if self.visibility == con.visible then
    self.layout:measure(true)
  end
end
-- override
function elems.Container:to_formspec_string(ver, persist)
  local str = {}
  str[#str+1] = make_elem(self, pos_and_size(self))
  str[#str+1] = self.layout:to_formspec_string(ver, persist)
  str[#str+1] = fsmakeelem("container_end")
  return concatTbl(str, "")
end

----------------------------------------------------------------
-- ScrollContainer (scroll_container)
----------------------------------------------------------------
elems.ScrollContainer = Class(elems.Container)
function elems.ScrollContainer:init(spec)
  spec.is_scroll_container = true
  elems.Container.init(self,spec)

  self.orientation = get_valid_orientation(spec.orientation)
  self.isVert = self.orientation:sub(1,1) == "v"

  local exScroll = type(spec.externalScrollbar) == "string"
  self.scrollFactor = num_or(spec.scrollFactor, 0.1)

  if exScroll then
    self.externalScrollbar = spec.externalScrollbar
  else
    self.barSize = num_or(spec.scrollbarSize, 0.2)
    if self.barSize <= 0 then self.barSize = 0.2 end
    if self.orientation:sub(1,1) == "v" then -- vertical
      if self.margins[RGT] == UNSET then self.margins[RGT] = self.barSize
      else self.margins[RGT] = self.margins[RGT] + self.barSize end
    else -- horizontal
      if self.margins[BOT] == UNSET then self.margins[BOT] = self.barSize
      else self.margins[BOT] = self.margins[BOT] + self.barSize end
    end
    if type(spec.scrollbarOptions) == "table" then
      self.scrBarOptSpec = spec.scrollbarOptions
    end
    local scrollbarSpec = get_scrollbar_spec_for_container(self, spec)
    self.scrollbar = elems.Scrollbar(scrollbarSpec)
  end
end
-- when added to parent layout
function elems.ScrollContainer:on_added(idGen, layout)
  elems.Container.on_added(self, idGen, layout)
  return { self.scrollbar }
end
-- after measured is complete
function elems.ScrollContainer:after_measure()
  if not self.layout.measurePerformed then
    if self.isVert then
      self.layout.width = self.width ; self.layout.height = WRAP
    else
      self.layout.width = WRAP ; self.layout.height = self.height
    end
    if self.visibility == con.visible then
      self.layout:measure(true)
    end
  end
end
-- override, completely custom
function elems.ScrollContainer:to_formspec_string(ver, persist)
  local str = {}
  local sbid = self.externalScrollbar or ""
  if self.scrollbar then sbid = self.scrollbar.internalId or "" end
  local sbos = self.scrBarOptSpec
  if sbos == nil then sbos = {} end
  if sbos.min == nil and sbos.max == nil then -- adjust automatically
    local lay = self.layout
    sbos.min = 0
    if self.isVert then
      local layH = lay.measured.h + lay.paddings[TOP] + lay.paddings[BOT]
      sbos.max = (layH - self.measured.h) / self.scrollFactor
      sbos.thumbsize = sbos.max / self.measured.h
    else
      local layW = lay.measured.w + lay.paddings[LFT] + lay.paddings[RGT]
      sbos.max = (layW - self.measured.w) / self.scrollFactor
      sbos.thumbsize = sbos.max / self.measured.w
    end
    sbos.smallstep = sbos.max / 100
    sbos.largestep = sbos.max / 10
  end
  str[#str+1] = elems.ScrollbarOptions(sbos):to_formspec_string()
  local paddParam = nil; if ver >= 8 then paddParam = "" end
  str[#str+1] = make_elem(self, pos_and_size(self), sbid, self.orientation, self.scrollFactor, paddParam)
  str[#str+1] = self.layout:to_formspec_string(ver, persist)
  str[#str+1] = fsmakeelem("scroll_container_end")
  return concatTbl(str, "")
end

----------------------------------------------------------------
-- Scrollbar 
----------------------------------------------------------------
elems.Scrollbar = Class(respec.PhysicalElement)
function elems.Scrollbar:init(spec)
  respec.PhysicalElement.init(self, elemInfo.scrollbar, spec)
  self.orientation = get_valid_orientation(spec.orientation)
  self.value = str_or(spec.value, "0-1000")
  if type(spec.listener) == "function" then
    self.on_scroll = spec.listener
  end
  self.on_interact = function(state, value, fields)
    local ex = engine.explode_scrollbar_event(value)
    state.rintern[self.internalId] = ex.value
    if self.on_scroll ~= nil then
      return self.on_scroll(state, ex, fields)
    else
      if ex.type == "CHG" then return false else return nil end
    end
  end
end
-- override
function elems.Scrollbar:to_formspec_string(ver, persist)
  local value = persist.state.rintern[self.internalId] or 0
  return make_elem(self, pos_and_size(self), self.orientation, self.internalId, value)
end

----------------------------------------------------------------
-- Image 
----------------------------------------------------------------
elems.Image = Class(respec.PhysicalElement)
function elems.Image:init(spec)
  local einf = elemInfo.image
  if num_or(spec.frameCount, 0) > 0 then
    einf = elemInfo.animated_image
    self.frameC = spec.frameCount
    self.frameT = num_or(spec.frameTime, 0)
    self.frameS = num_or(spec.frameStart)
    if type(spec.listener) == "function" then
      self.on_interact = spec.listener
    end
  end
  respec.PhysicalElement.init(self, einf, spec)
  self.img = str_or(spec.image, "")
  if type(spec.middle) == "number" or type(spec.middle) == "string" then
    self.mid = tostring(spec.middle)
  end
  self.ratio = num_or(spec.ratio)
end
-- override
function elems.Image:to_formspec_string(ver, _)
  update_measurements_to_fit_aspect_ratio(self.measured, self.ratio)
  local mid = nil
  if self.mid and ver >= 6 then mid = self.mid end
  if self.frameC then
    return make_elem(self, pos_and_size(self), self.internalId, self.img, self.frameC, self.frameT, self.frameS or 1, mid)
  else
    return make_elem(self, pos_and_size(self), self.img, mid)
  end
end

----------------------------------------------------------------
-- ItemImage (item_image)
----------------------------------------------------------------
elems.ItemImage = Class(respec.PhysicalElement)
function elems.ItemImage:init(spec)
  respec.PhysicalElement.init(self, elemInfo.item_image, spec)
  self.img = str_or(spec.item, "")
  local r = num_or(spec.ratio, 0)
  if r > 0.01 then self.ratio = r end
end
-- override
function elems.ItemImage:to_formspec_string(_, _)
  update_measurements_to_fit_aspect_ratio(self.measured, self.ratio)
  return make_elem(self, pos_and_size(self), self.img)
end

----------------------------------------------------------------
-- TextArea
----------------------------------------------------------------
elems.TextArea = Class(respec.PhysicalElement)
function elems.TextArea:init(spec)
  respec.PhysicalElement.init(self, elemInfo.textarea, spec)
  self.label = str_or(spec.label, "")
  self.txt = str_or(spec.text, "")
  self.editable = bool_or(spec.editable)
end
-- override
function elems.TextArea:before_measure(persist)
  if self.label ~= "" then
    if self.margins[TOP] == UNSET then
      local ms = measure_text(self.label, persist.playerName)
      self.margins[TOP] = ms.height
    end
  end
end
-- override
function elems.TextArea:to_formspec_string(_, _)
  update_measurements_to_fit_aspect_ratio(self.measured, self.ratio)
  local id = "" ; if self.editable then id = self.internalId end
  return make_elem(self, pos_and_size(self), id, self.label, self.txt)
end

----------------------------------------------------------------
-- Tabs (tabheader)
----------------------------------------------------------------
local TAB_HEADER_DEFAULT_HEIGHT = 4/5 -- by default
elems.Tabs = Class(respec.PhysicalElement)
function elems.Tabs:init(spec)
  -- set default height, if one wasn't set
  if not spec.h and not spec.height then spec.h = TAB_HEADER_DEFAULT_HEIGHT end

  respec.PhysicalElement.init(self, elemInfo.tabheader, spec)

  -- override alignents if using aboveForm version (by default)
  if spec.aboveForm == nil or spec.aboveForm == true then
    self.abf = true ; self.ignoreLayoutPaddings = true
    local uns = {ref = "", side = UNSET}
    local prt = {ref = "", side = PARENT}
    self.align = { [TOP] = prt, [BOT] = uns, [LFT] = prt, [RGT] = prt }
  else -- custom setup for positionable
    -- if width is not set, and right side is not aligned, then set right side to parent
    if self.width <= 0 and self.align[RGT].side == UNSET then self.align[RGT].side = PARENT end
  end

  self.itemsStr = get_valid_dropdown_items(spec.items)
  self.idx = num_or(spec.index, 1)
  self.trp = bool_or(spec.transparent)
  self.bor = bool_or(spec.drawBorder)
  if type(spec.listener) == "function" then
    self.on_interact = spec.listener
  end
end
-- override
function elems.Tabs:to_formspec_string(_, _)
  local trp = self.trp ; if trp ~= nil then trp = tostring(trp) else trp = "" end
  local bor = self.bor ; if bor ~= nil then bor = tostring(bor) else bor = "" end
  local sizeStr = nil
  if self.width > 0 then -- both wdith and height should be set
    sizeStr = tostring(self.width)..","..tostring(self.height)
  elseif self.height ~= TAB_HEADER_DEFAULT_HEIGHT then -- only set height
    sizeStr = tostring(self.height)
  end
  local offset = TAB_HEADER_DEFAULT_HEIGHT ; if self.abf then offset = 0 end
  if sizeStr ~= nil then
    return make_elem(self,
      pos_only(self, offset), sizeStr,
      self.internalId, self.itemsStr, self.idx, trp, bor
    )
  else
    return make_elem(self,
      pos_only(self, offset),
      self.internalId, self.itemsStr, self.idx, trp, bor
    )
  end
end

----------------------------------------------------------------
-- Model
----------------------------------------------------------------
elems.Model = Class(respec.PhysicalElement)
function elems.Model:init(spec)
  respec.PhysicalElement.init(self, elemInfo.model, spec)
  self.mesh = str_or(spec.mesh or spec.model)
  self.textures = str_or(spec.textures)
  self.rotation = str_or(spec.rotation)
  self.autoRot = bool_or(spec.autoRotate or spec.continuous)
  self.control = bool_or(spec.control)
  self.loopRange = str_or(spec.loopRange)
  self.animSpeed = num_or(spec.animSpeed)
end
-- override
function elems.Model:to_formspec_string(_, _)
  local autoRot = "" ; if self.autoRot ~= nil then autoRot = tostring(self.autoRot) end
  local control = "" ; if self.control ~= nil then control = tostring(self.control) end
  local animSp = "" ; if self.animSpeed ~= nil then animSp = tostring(self.animSpeed) end
  return make_elem(
    self, pos_and_size(self), self.internalId,
    self.mesh or "",
    self.textures or "",
    self.rotation or "",
    autoRot,
    control,
    self.loopRange or "",
    animSp
  )
end

----------------------------------------------------------------
-- Table (`table`, and includes `tablecolumns` and `tableoptions` internally)
----------------------------------------------------------------
elems.Table = Class(respec.PhysicalElement)
function elems.Table:init(spec)
  respec.PhysicalElement.init(self, elemInfo.table, spec)

  self.configStr = get_valid_table_options(spec)
  self.columnStr = concatTbl(spec.columns or {}, ";")
  if type(spec.cells) ~= "table" then spec.cells = {} end
  self.cellsStr = concatTbl(mapTbl(spec.cells, function(v) return tostring(v) end), ",")
  self.idx = tostring(num_or(spec.index, 1))

  if type(spec.listener) == "function" then
    self.on_select = spec.listener
    self.on_interact = function(state, value, fields)
      self.on_select(state, engine.explode_table_event(value), fields)
    end
  end
end
-- override
function elems.Table:to_formspec_string(_, _)
  local ret = {}
  -- tableoptions first
  if self.configStr ~= "" then
    ret[#ret+1] = "tableoptions["..self.configStr.."]"
   end
  -- tablecolumns second
  if self.columnStr ~= "" then
    ret[#ret+1] = "tablecolumns["..self.columnStr.."]"
  end
  ret[#ret+1] = make_elem(self, pos_and_size(self), self.internalId, self.cellsStr, self.idx)
  return concatTbl(ret, "\n")
end

----------------------------------------------------------------
-- Hypertext
----------------------------------------------------------------
elems.Hypertext = Class(respec.PhysicalElement)
function elems.Hypertext:init(spec)
  respec.PhysicalElement.init(self, elemInfo.hypertext, spec)
  self.txt = str_or(spec.text, "")
  if type(spec.listener) == "function" then
    self.on_interact = spec.listener
  end
end
-- override
function elems.Hypertext:to_formspec_string(_, _)
  return make_elem(self, pos_and_size(self), self.internalId, self.txt)
end

----------------------------------------------------------------
-- Box
----------------------------------------------------------------
elems.Box = Class(respec.PhysicalElement)
function elems.Box:init(spec)
  respec.PhysicalElement.init(self, elemInfo.box, spec)
  self.color = str_or(spec.color, "")
end
-- override
function elems.Box:to_formspec_string(_, _)
  return make_elem(self, pos_and_size(self), self.color)
end

----------------------------------------------------------------
-- Non-Physical Elements
----------------------------------------------------------------

----------------------------------------------------------------
-- listring
----------------------------------------------------------------
elems.ListRing = Class(respec.Element)
function elems.ListRing:init(spec)
  respec.Element.init(self, elemInfo.listring)
  self.rings = spec
  if type(self.rings) ~= "table" then self.rings = {} end
end
-- override
function elems.ListRing:to_formspec_string(_, persist)
  local s = ""
  for _, ring in ipairs(self.rings) do
    local invloc, listname = get_inv_loc_and_name_from_data(ring, persist)
    s = s..make_elem(self, invloc, listname)
  end
  if s == "" then s = make_elem(self) end
  return s
end

----------------------------------------------------------------
-- StyleType (style_type)
----------------------------------------------------------------
elems.StyleType = Class(respec.Element)
function elems.StyleType:init(spec)
  respec.Element.init(self, elemInfo.style_type)
  self.target = str_or(spec.target, nil)
  if self.target then
    self.style = get_valid_style(self.fsName, spec)
    if self.style then
      self.styleData = get_style_type_data(spec)
    end
  end
end
-- override
function elems.StyleType:before_measure(persist)
  if self.styleData then
    persist["style_"..self.target] = self.styleData
  end
end
-- override
function elems.StyleType:to_formspec_string(_, _)
  if not self.target or type(self.style) ~= "table" then return "" end
  local propsStr = self.style[""]
  if propsStr == "" then return "" end
  return make_elem(self, self.target, propsStr)
end

----------------------------------------------------------------
-- listcolors
----------------------------------------------------------------
elems.ListColors = Class(respec.Element)
function elems.ListColors:init(spec)
  respec.Element.init(self, elemInfo.listcolors)
  self.slotStr = str_or(spec.slotBg, "")..";"..str_or(spec.slotBgHover, "")
  self.borderStr = str_or(spec.slotBorder)
  if spec.tooltipBg or spec.tooltipFont then
    self.borderStr = str_or(self.borderStr, "")
    self.tooltipStr = str_or(spec.tooltipBg, "")..";"..str_or(spec.tooltipFont, "")
  end
end
-- override
function elems.ListColors:to_formspec_string(_, _)
  return make_elem(self, self.slotStr, self.borderStr, self.tooltipStr)
end

----------------------------------------------------------------
-- ScrollbarOptions
----------------------------------------------------------------
local function valid_arrows(arrowStr)
  if type(arrowStr) ~= "string" or string.len(arrowStr) == 0 then return "default" end
  if arrowStr:sub(1,1) == "s" then
    return "show"
  else
    return "hide"
  end
end
elems.ScrollbarOptions = Class(respec.Element)
function elems.ScrollbarOptions:init(spec)
  respec.Element.init(self, elemInfo.scrollbaroptions)
  self.min = num_or(spec.min, 0)
  self.max = num_or(spec.max, 1000)
  self.sstep = num_or(spec.smallstep, 10)
  self.lstep = num_or(spec.largestep, 100)
  self.thumb = num_or(spec.thumbsize, 10)
  self.arrows = valid_arrows(spec.arrows)
end
-- override
function elems.ScrollbarOptions:to_formspec_string(_, _)
  return make_elem(self, 
    "min="..self.min, "max="..self.max, "smallstep="..self.sstep, "largestep="..self.lstep,
    "thumbsize="..self.thumb, "arrows="..self.arrows
  )
end
