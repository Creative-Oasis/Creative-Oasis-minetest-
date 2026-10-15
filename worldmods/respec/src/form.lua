local con = respec.const

local engine = respec.util.engine
local log_warn = respec.log_warn
local log_error = respec.log_warn
local SEND_FIELDS = 1
local SEND_VALUE_AND_FIELDS = 2
local SEND_VALUE_AND_FIELDS_ON_ENTER = 3
--[[ shownForms entries format:
playerName = {
  formId = { form = formRef, state = state }
}
]]
local shownForms = {}

local function is_str(v) return type(v) == "string" end

local function make_form_outline(w, h, pixelBorder)
  return
    "style_type[box;colors=#0000;borderwidths=-1;bordercolors="..pixelBorder.."]"..
    "box[0,0;"..w..","..(h)..";]"
end

local function set_shown_form_data(playerName, formId, data)
  if not shownForms[playerName] then shownForms[playerName] = { count = 0 } end
  local formData = shownForms[playerName]
  formData.count = formData.count + 1
  formData[formId] = data -- just override anything else here before
end

-- returns the data for this form, or nil
local function get_shown_form_data(playerName, formId)
  if not shownForms[playerName] then
    return nil
  end
  return shownForms[playerName][formId]
end

local function remove_shown_form_data(playerName, formId)
  if not shownForms[playerName] then
    log_warn("Trying to remove form data for a player that wasn't there?")
    return
  end
  local formData = shownForms[playerName]
  formData[formId] = nil
  formData.count = formData.count - 1
  if formData.count <= 0 then -- it shoudn't be negative, but just in case
    shownForms[playerName] = nil
  end
end

local function notify_form_quit(form, playerName, state, fromPlayerLeave)
  if form.spec.onClose then
    form.spec.onClose(state, playerName, fromPlayerLeave)
  end
end

local function remove_all_data_on_player_leave(playerName)
  local plForms = shownForms[playerName]
  if plForms then
    for id, fData in pairs(plForms) do
      if type(fData) == "table" and fData.form then
        notify_form_quit(fData.form, playerName, fData.state, true)
      end
    end
  end
  shownForms[playerName] = nil
end

local function new_id_gen()
  return {
    idIndex = 0,
    id = function(self)
      local idi = self.idIndex + 1
      self.idIndex = idi
      return "id_"..idi
    end
  }
end

----------------------------------------------------------------
-- Form creation util
----------------------------------------------------------------
---
local function verify_specification(spec)
  if not spec or type(spec) ~= "table" then
    log_error("Specification was not a table!")
    spec.hadErrors = true
  end
  if (type(spec.w) ~= "number" and type(spec.width) ~= "number")
  or (type(spec.h) ~= "number" and type(spec.height) ~= "number") then
    log_error("Specification missing required width/height!")
    spec.hadErrors = true
  end
  if not spec.ver then spec.ver = spec.formspecVersion ; spec.formspecVersion = nil end
  if type(spec.ver) ~= "number" or spec.ver < 2 then
    log_error("Specification Formspec Version is invalid! Must be a number, and greater than 2")
    spec.hadErrors = true
  end
  if spec.onClose ~= nil and type(spec.onClose) ~= "function" then
    log_error("onClose value in form spec was present, but was not a function!")
    spec.hadErrors = true
  end
  -- TODO: verify optional params' types, though maybe without fatal errors
  return spec
end

local formspecID = 0
local function getNextFormspaceName()
  formspecID = formspecID + 1 -- overflow doesn't really matter here
  return "respec:form_"..(formspecID)
end

local function fsc(n,x,y)
  return ""..n.."["..x..","..y.."]"
end

local function get_valid_color(clrStr)
  if not is_str(clrStr) then return "" end
  return clrStr
end

local function get_valid_fullscreen(str)
  if type(str) == "boolean" then if str then return "true" else return "false" end end
  if not is_str(str) then return "" end
  if str == "true" or str == "false" or str == "both" or str == "neither" then
    return str
  end
  return ""
end

-- not public - return the form defition string
local ins = table.insert
local function get_form_str(form)
  local sp = form.spec
  local tbl = {}
  ins(tbl, "formspec_version["..sp.ver.."]")
  ins(tbl, fsc("size", sp.w, sp.h))
  if sp.posX and sp.posY then
    ins(tbl, fsc("position", sp.posX, sp.posY))
  end
  if sp.anchorX and sp.anchorY then
    ins(tbl, fsc("anchor", sp.anchorX, sp.anchorY))
  end
  if sp.screenPaddingX and sp.screenPaddingY then
    ins(tbl, fsc("padding", sp.screenPaddingX, sp.screenPaddingY))
  end
  if sp.noPrepend then
    ins(tbl, "no_prepend[]")
  end
  if sp.allowClose == false then
    ins(tbl, "allow_close[false]")
  end
  local bgC = get_valid_color(sp.bgColor)
  local fbgC = get_valid_color(sp.fbgColor)
  local bgF = get_valid_fullscreen(sp.bgFullscreen)
  if bgC ~= "" then
    local bgcf = ""
    if sp.ver >= 3 then
      bgcf = respec.util.fs_make_elem("bgcolor", bgC, bgF, fbgC)
    else
      bgcf = respec.util.fs_make_elem("bgcolor", bgC, bgF)
    end
    ins(tbl, bgcf)
  end
  if is_str(sp.setFocus) then
    local oID = sp.setFocus
    local mID = ""
    for kID, elem in pairs(form.layout.fieldElemsById) do
      if elem.id == oID then mID = kID ; break end
    end
    ins(tbl, "set_focus["..mID.."]")
  end
  if is_str(sp.pixelBorder) then
    ins(tbl, make_form_outline(sp.w, sp.h, sp.pixelBorder))
  end
  return table.concat(tbl, "")
end

-- not public
local function get_formspec_string(form, state, playerName)
  form.layout.playerName = playerName
  form.layout:measure(true)
  local spec = form.spec
  -- update if necessary
  if spec.w == con.wrap_content then spec.w = form.layout.measured[con.right] end
  if spec.h == con.wrap_content then spec.h = form.layout.measured[con.bottom] end
  local formDef = get_form_str(form)
  local debugGrid = ""
  if respec.settings.debug() then
    debugGrid = respec.util.grid(spec.w, spec.h, 5)
  end
  local persist = { state = state }
  local layoutFs = form.layout:to_formspec_string(spec.ver, persist)
  return formDef..debugGrid..layoutFs
end

-- `self` should be the form
local function handle_spec(self, state)
  local spec = "error"
  if type(self.init_spec) == "table" then spec = self.init_spec
  elseif type(self.init_spec) == "function" then
    spec = self.init_spec(state)
    if type(spec) ~= "table" then
      log_error("specification function did not return a table!")
      return
    end
  else
    log_error("specification must be a table or function!")
    return
  end
    -- customs setup of spec since its root layout
  if not spec.w and not spec.width then spec.w = con.wrap_content end
  if not spec.h and not spec.height then spec.h = con.wrap_content end
  self.spec = verify_specification(spec)
  self.layout = respec.Layout(spec)
  self.bgfullscreen = spec.bgFullscreen
  self.reshowOnInteract = true
  if spec.reshowOnInteract == false then self.reshowOnInteract = false end
  return true
end

-- self is the form
local function get_layout_data(self, state)
  if type(self.init_layout) == "table" then
    return self.init_layout
  elseif type(self.init_layout) == "function" then
    local data = self.init_layout(state)
    if type(data) ~= "table" then
      log_error("layoutBuilder returned a value that's not a table!")
      return nil
    end
    return data
  else
    log_error("layoutBuilder must be table or function!")
    return nil
  end
end

-- `self` is the form
-- return true if successful, false otherwise
local function setup_form_for_showing(self, state)
  if not handle_spec(self, state) then return false end
  if self.spec.hadErrors then
    log_error("Form spec had errors! Cannot be shown!")
    return false
  end
  local layoutData = get_layout_data(self, state)
  if not layoutData then return false end
  local idGen = new_id_gen()
  self.layout:set_elements(layoutData, idGen)
  return true
end

-- returns a new table with keys being the user-specified IDs of each element
local function get_translated_fields(fields, interactiveElems)
  local translated = {}
  for k, v in pairs(interactiveElems) do
    local fieldVal = fields[k]
    if fieldVal and v.id ~= "" then
      translated[v.id] = fieldVal
    end
  end
  return translated
end

----------------------------------------------------------------
-- Event handling functions
----------------------------------------------------------------

local function on_receive_fields(player, formname, fields)
  if not player or not player:is_player() then return false end
  local playerName = player:get_player_name()
  local formData = get_shown_form_data(playerName, formname)
  if not formData then return false end
  local form = formData.form

  local interactiveElems = form.layout:get_interactive_elements()
  local translatedFields = get_translated_fields(fields, interactiveElems)
  local formReshow = form.reshowOnInteract
  local reshow = nil
  local functionCalled = false
  for elemId, elem in pairs(interactiveElems) do
    if fields[elemId] ~= nil and type(elem.on_interact) == "function" then
      local elemInFields = elem.fsInfo.inFields
      local proceed = true
      if elemInFields == SEND_VALUE_AND_FIELDS_ON_ENTER then
        proceed = fields.key_enter and fields.key_enter_field == elemId
      end
      if proceed then
        local requestedReshow
        if elemInFields == SEND_FIELDS then
          requestedReshow = elem.on_interact(formData.state, translatedFields)
        elseif elemInFields == SEND_VALUE_AND_FIELDS or elemInFields == SEND_VALUE_AND_FIELDS_ON_ENTER then
          requestedReshow = elem.on_interact(formData.state, fields[elemId], translatedFields)
        end
        if requestedReshow == true then reshow = true --any one element requsting reshow, we reshow
        elseif requestedReshow == false and reshow == nil then
          reshow = false -- ensure we don't reshow if function specifically didn't want it, and is only one
        end
        functionCalled = true
      end
    end
  end

  -- Keep this last
  if fields.quit then
    notify_form_quit(form, playerName, formData.state, false)
    remove_shown_form_data(playerName, formname)
    return true
  end

  if (reshow == true) or (formReshow and functionCalled and reshow ~= false) then
    form:reshow(playerName)
  end

  return true
end

local function on_player_leave(obj, _)
  if not obj or not obj:is_player() then return end
  local playerName = obj:get_player_name()
  remove_all_data_on_player_leave(playerName)
end

----------------------------------------------------------------
-- Public API
----------------------------------------------------------------

respec.Form = respec.util.Class()

--[[
  Create a form, with the given specification and layoutBuilder function
]]
function respec.Form:init(specification, layoutBuilder)
  self.id = getNextFormspaceName()
  self.init_spec = specification
  self.init_layout = layoutBuilder
end

--[[ 
  Show the formspec to the player by the given name.
  `playerName` is required, must be a string
  `state` is optional, and is the object passed to the build function. 
   If not specified, an empty table will be passed to the creation functions.
  returns true if successfully shown, false otherwise
  In case the form happens to already be shown to this player, it will be closed
  and re-shown with the clean new state provided
--]]
function respec.Form:show(playerName, state)
  state = state or {}
  if not state.info then state.info = { playerName = playerName } end
  if not state.rintern then state.rintern = {} end
  if not setup_form_for_showing(self, state) then return false end

  local id = self.id
  local existing = get_shown_form_data(playerName, id)
  if existing then -- why was this already there? remove it.
    engine.close_formspec(playerName, id)
    remove_shown_form_data(playerName, id)
  end

  engine.show_formspec(playerName, id, get_formspec_string(self, state, playerName))
  set_shown_form_data(playerName, id, { form = self, state = state })
  return true
end

-- reshows the form to the player, only if it was already shown!
-- returns true if successfully reshown, false otherwise
function respec.Form:reshow(playerName)
  local data = get_shown_form_data(playerName, self.id)
  if not data then return false end
  local state = data.state
  if not setup_form_for_showing(self, state) then return false end
  engine.show_formspec(playerName, self.id, get_formspec_string(self, state, playerName))
  return true
end

-- Closes the form, if it was shown to the player by `playerName
-- returns true if the form was shown and got closed, false otherwise
function respec.Form:close(playerName)
  local data = get_shown_form_data(playerName, self.id)
  if not data then return false end
  engine.close_formspec(playerName, self.id)
  return true
end

--[[ 
  `extraState` is optional, can be nil
  `checkProtection` is optional, if `true` then the function will check against protection
  This method will automatically add some data to the `state`
  See doc/api.md for information
]]
local get_meta = respec.util.engine.get_meta
local is_protected = respec.util.engine.is_protected
function respec.Form:show_on_node_rightclick(state, checkProtection)
  return function(pos, node, user, itemstack, pointed_thing)
    if not user or not user:is_player() then return end
    local playerName = user:get_player_name() ; if type(playerName) ~= "string" then return end
    if checkProtection then
      if is_protected(pos, playerName) then return end
    end
    local st = state or {}
    st.info = {
      pos = pos,
      node = node,
      nodeMeta = get_meta(pos),
      player = user,
      playerName = playerName,
      itemstack = itemstack,
      pointed_thing = pointed_thing,
    }
    st.rintern = {}
    self:show(playerName, st)
  end
end

----------------------------------------------------------------
-- Minetest callbacks registration
----------------------------------------------------------------

engine.register_on_player_receive_fields(on_receive_fields)
engine.register_on_leaveplayer(on_player_leave)
