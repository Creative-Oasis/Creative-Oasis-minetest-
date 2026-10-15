respec.util = {}
local con = respec.const
local TOP = con.top
local BOT = con.bottom
local LFT = con.left
local RGT = con.right
local PARENT = con.parent
local UNSET = con.unset
local concatTbl = table.concat

respec.util.engine = core or minetest
local engine = respec.util.engine

respec.TRANSLATOR = engine.get_translator(respec.MODNAME)

----------------------------------------------------------------
-- helpers
----------------------------------------------------------------

local function grid_cell(x,y)
  local clr = "#3F3F3F"
  if (x + y) % 2 == 1 then clr = "#222222" end
  return "box["..x..","..y..";1,1;"..clr.."]"
end

----------------------------------------------------------------
-- public functions
----------------------------------------------------------------

-- Code from http://lua-users.org/wiki/SimpleLuaClasses with slight modifications
respec.util.Class = function (base, init)
  local c = {}    -- a new class instance
  if not init and type(base) == 'function' then
  init = base
  base = nil
  elseif type(base) == 'table' then
  -- our new class is a shallow copy of the base class!
    for i,v in pairs(base) do
        c[i] = v
    end
    c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl, ...)
  local obj = {}
  setmetatable(obj,c)
  if init then
    init(obj,...)
  elseif obj.init then
    obj.init(obj, ...)
  elseif base and base.init then
    base.init(obj, ...)
  end
  return obj
  end
  c.init = init
  c.is_a = function(self, klass)
    local m = getmetatable(self)
    while m do 
        if m == klass then return true end
        m = m._base
    end
    return false
  end
  setmetatable(c, mt)
  return c
end

if type(engine.log) == "function" then
  respec.log_error = function(msg)
    engine.log("error", msg)
    print("ReSpec ERROR: "..msg)
  end
  respec.log_warn = function(msg)
    engine.log("warning", msg)
    print("ReSpec WARNING: "..msg)
  end
else
  respec.log_error = function(msg)
    print("ReSpec ERROR: "..msg)
  end
  respec.log_warn = function(msg)
    print("ReSpec WARNING: "..msg)
  end
end

function respec.util.list_to_set(table)
  local set = {}
  for _, v in ipairs(table) do
    set[v] = true
  end
  return set
end

function respec.util.side_to_str(side)
  if side == TOP then return "Top"
  elseif side == BOT then return "Bottom"
  elseif side == LFT then return "Left"
  elseif side == RGT then return "Right"
  elseif side == PARENT then return "Parent"
  elseif side == UNSET then return "Unset"
  else return "<unknown>" end
end

function respec.util.opposite_side(side)
  if side == TOP then return BOT
  elseif side == BOT then return TOP
  elseif side == LFT then return RGT
  else return LFT end
end

function respec.util.grid(width, height, divsPerUnit)
  divsPerUnit = divsPerUnit or 4
  if divsPerUnit <= 0 then divsPerUnit = 1 end
  local tmp = {}
  local w = math.floor(width)
  local h = math.floor(height)
  for x = 0, w do
    for y = 0, h do
      table.insert(tmp, grid_cell(x, y))
    end
  end
  local lines = ""
  for i = 0, (w + 1)  * divsPerUnit do
    lines=lines.."box["..(i / divsPerUnit)..",0;0.01,"..(h + 1)..";#888888]"
  end
  for j = 1, (h + 1) * divsPerUnit do
    lines=lines.."box[0,"..(j / divsPerUnit)..";"..(w + 1)..",0.01;#888888]"
  end

  return concatTbl(tmp, "")..lines
end

-- makes a "name[arg1;arg2;arg3]" string
function respec.util.fs_make_elem(name, ...)
  local ret = {name, "["}
  if ... ~= nil then
    local args = {...}
    ret[#ret + 1] = concatTbl(args, ";")
  end
  ret[#ret + 1] = "]"
  return concatTbl(ret, "")
end

-- make an outline with given x,y and width,height (ints)
-- optClr (string) is optional
local fme = respec.util.fs_make_elem
local olf = 0.01 -- tricky..
function respec.util.fs_make_outline(x, y, w, h, optClr, noclip)
  local bx = ""
  if noclip then bx = "style_type[box;noclip=true]" end
  if not optClr then optClr = "#FF00FFAA" end
  bx=bx..fme("box", x..","..y, "0,"..h, optClr) -- left
  bx=bx..fme("box", x..","..y, w..",0", optClr) -- top
  bx=bx..fme("box", (x+w-olf)..","..y, "0,"..h, optClr) -- right
  bx=bx..fme("box", x..","..(y+h-olf), w..",0", optClr) -- bot
  return bx
end
local outl = respec.util.fs_make_outline

function respec.util.num_or(v, o) if type(v) == "number" then return v else return o end end
function respec.util.str_or(v, o) if type(v) == "string" then return v else return o end end
function respec.util.bool_or(v, o) if type(v) == "boolean" then return v else return o end end

local num_or = respec.util.num_or
function respec.util.min0(value)
  if num_or(value, 0) <= 0 then return 0 else return value end
end
local min0 = respec.util.min0

function respec.util.map(tbl, funcOnVal)
  local ret = {}
  for k, v in pairs(tbl) do
    ret[k] = funcOnVal(v)
  end
  return ret
end

----------------------------------------------------------------
-- debug stuff
----------------------------------------------------------------

function respec.internal.fs_elem_box(obj, notDebug, clr)
  if notDebug or respec.settings.debug() then
    local ms = obj.measured
    local mg = obj.margins
    local mgt = min0(mg[TOP])
    local mgb = min0(mg[BOT])
    local mgl = min0(mg[LFT])
    local mgr = min0(mg[RGT])
    local boundColor = clr or "#0000FF38"
    local elemColor = clr or "#00FF0038"
    local bound = ""
    local elem = ""

    if not notDebug then
      local bx = ms[LFT] + min0(ms.xOffset)
      local by = ms[TOP] + min0(ms.yOffset)
      local bw = ms.w + mgl + mgr
      local bh = ms.h + mgt + mgb
      bound = "box["..bx..","..by..";"..bw..","..bh..";"..boundColor.."]"
      bound = bound..outl(bx, by, bw, bh)
    end

    local ex = ms[LFT] + mgl + min0(ms.xOffset)
    local ey = ms[TOP] + mgt + min0(ms.yOffset)
    local ew = ms.w
    local eh = ms.h
    if not notDebug then
      elem = "box["..ex..","..ey..";"..ew..","..eh..";"..elemColor.."]"
    end
    elem = elem..outl(ex, ey, ew, eh, boundColor)
    return bound..elem
  else return "" end
end


local d = {} -- bad debug
local dlog = function(str)
  print(str)
  engine.chat_send_all(str)
end
d.log = function(str)
  dlog(os.date("%H:%M:%S: ")..str)
end
