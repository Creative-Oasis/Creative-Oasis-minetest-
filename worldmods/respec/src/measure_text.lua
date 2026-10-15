
local byte = string.byte
local slen = string.len

local DEFAULT_FONT_SIZE = 16
local DEFAULT_MONO_WIDTH = 27/160
local DEFAULT_WIDTH = 14/80 -- trying to guesstimate most other characters
local DEFAULT_LINE_HEIGHT = 16/40 -- at default font size
local VERT_LABEL_LINE_HEIGHT = 12/40
local DEFAULT_LINE_SPACING = 1/6 -- seems to be constant

-- for adjustments based on font size
local WIDTH_SLOPE = 0.84
local HEIGHT_SLOPE = 0.3

-- the size of window for which the measuring algorithm was calibrated
local BASE_WIN_W = 1920
local BASE_WIN_H = 1009

local get_translated_string = respec.util.engine.get_translated_string or function(_,v) return v end
local get_player_information = respec.util.engine.get_player_information or function(_) return {} end
local get_player_window_info = respec.util.engine.get_player_window_information or function(_) return {} end

local function make_range(s, e, val) return {
  s = s, e = e, width = val
} end

local special_widths = { -- really just eyeballing these
  [byte("!")] = 3/40,
  [byte("%")] = 5/20,
  [byte("&")] = 3/10,
  [byte("'")] = 3/40,
  [byte(",")] = 3/40,
  [byte("*")] = 2/20,
  [byte("/")] = 2/10,
  [byte("@")] = 3/10,
  [byte("'")] = 3/40,
  [byte("f")] = 3/40,
  [byte("i")] = 3/40,
  [byte("j")] = 3/40,
  [byte("l")] = 1/20,
  [byte("m")] = 4/20,
  [byte("r")] = 2/20,
  [byte("t")] = 1/20,
  [byte("{")] = 1/20,
  [byte("|")] = 1/20,
  [byte("}")] = 1/10,
  [byte("F")] = 2/20,
  [byte("I")] = 1/20,
  [byte("J")] = 6/40,
  [byte("M")] = 7/40,
  [byte("W")] = 8/40,
}

local ranges = {
  make_range(0x41, 0x5a, 8/40), -- A-Z
}

local function get_other_width(charByte, modifier)
  local chw = special_widths[charByte]
  if not chw then
    for _, range in ipairs(ranges) do
      if charByte >= range.s and charByte <= range.e then return range.width end
    end
  end
  if not chw then chw = DEFAULT_WIDTH end
  return chw * modifier
end

local function parseFontSizeStr(fontSizeStr)
  if type(fontSizeStr) == "number" then return fontSizeStr
  elseif type(fontSizeStr) == "string" then
    local firstChar = fontSizeStr:sub(1, 1)
    if firstChar == "+" or firstChar == "-" then
      return DEFAULT_FONT_SIZE + (tonumber(fontSizeStr) or 0)
    else
      return tonumber(fontSizeStr) or DEFAULT_FONT_SIZE
    end
  else
    return DEFAULT_FONT_SIZE
  end

end

local function get_modifier(fontSizeStr, adjust, winSizeAdjust, slope)
  local fontSize = parseFontSizeStr(fontSizeStr)
  if not adjust then adjust = 1 end
  local adjFontSize = slope * (fontSize / DEFAULT_FONT_SIZE - 1) + 1
  return adjFontSize * adjust * winSizeAdjust
end

-- this is far from ideal, but has a positive effect
local function get_adjustment_for_window(playerName)
  local plWinInf = get_player_window_info(playerName)
  if type(plWinInf) ~= "table" then return 1 end
  local size = plWinInf.size -- this is only available on 5.7+ clients
  if type(size) ~= "table" or type(size.x) ~= "number" or type(size.y) ~= "number" then return 1 end
  local winWR = size.x / BASE_WIN_W
  local winHR = size.y / BASE_WIN_H
  local minRatio = winWR ; if winHR < minRatio then minRatio = winHR end
  -- adjust the window adjustment effect, based on whether window is larger or smaller.
  -- this is very finicky
  if minRatio > 1 then minRatio = 1.2 * (minRatio - 1) + 1
  else minRatio = 0.2 * (minRatio - 1) + 1 end
  if minRatio < 0.1 then minRatio = 0.1 end -- ensure no divbyzero
  return 1 / minRatio
end

local function measure_vertlabel(str, oneWidth, heightMod)
  local oneHeight = VERT_LABEL_LINE_HEIGHT * heightMod
  local numLines = 0
  local i = 1
  local str_length = slen(str)
  while i <= str_length do
    local ch = byte(str, i)
    if ch == 0x1b then
       -- Luanti starts escape sequence with 0x1b (ESC char), followed by ( until a )
      local n = i + 1
      if str:sub(n, n) == '(' then
        i = str:find(')', i, true) or str_length
      end
    elseif ch == 0x0a then -- 0x0a = '\n'
      numLines = numLines + 1
    elseif ch == 0xe1 or ch > 0xe1 and ch < 0xf5 then
      numLines = numLines + 1
      i = i + 2
    elseif ch < 0x80 or ch > 0xbf then
      numLines = numLines + 1
    end
    i = i + 1
  end
  return {
    width = 2 * oneWidth,
    height = numLines * oneHeight,
    numLines = numLines,
  }
end

-- string is the string to measure
-- playerName: the player name
-- isMono: Optional. Bool flag if mono flag is used. Deafults to false
-- fontSize: Optional. The string modifying the font size, e.g. "+3", "-2", "18" etc.
-- adjust: Optional. A height/width adjustment factor. Default to 1.0
-- isVertlabel: If this is meant to be for a vertlabel
-- returns table of width = w, height = h, numLines = #
local function measure_text(string, playerName, isMono, fontSize, adjust, isVertlabel)
  local player_info = get_player_information(playerName)
  local lang = player_info and player_info.lang_code or "en"
  local str = get_translated_string(lang, string)
  local adjustForWinSize = get_adjustment_for_window(playerName)
  local width = 0
  local maxWidth = 0
  local numLines = 1
  if isMono == nil then isMono = false end
  if not adjust then adjust  = 1 end
  local widthMod = get_modifier(fontSize, adjust, adjustForWinSize, WIDTH_SLOPE)
  local oneWidth = DEFAULT_MONO_WIDTH * widthMod; if not isMono then oneWidth = widthMod * DEFAULT_WIDTH end
  local twoWidths = 2 * oneWidth
  local heightMod = get_modifier(fontSize, adjust, 1, HEIGHT_SLOPE)
  local oneHeight = DEFAULT_LINE_HEIGHT * heightMod

  if isVertlabel then
    return measure_vertlabel(string, oneWidth, heightMod)
  end

  local i = 1
  local str_length = slen(str)
  while i <= str_length do
    local ch = byte(str, i)
    if ch == 0x1b then
       -- Luanti starts escape sequence with 0x1b (ESC char), followed by ( until a )
      local n = i + 1
      if str:sub(n, n) == '(' then
        i = str:find(')', i, true) or str_length
      end
    elseif ch == 0x0a then -- 0x0a = '\n'
      if width > maxWidth then maxWidth = width end
      width = 0
      numLines = numLines + 1
    elseif ch == 0xe1 then
      i = i + 1
      if (byte(str, i) or 0) < 0x84 then -- U+1000 - U+10FF
        width = width + oneWidth
      else -- U+1100 - U+2000
        width = width + twoWidths
      end
      i = i + 1
    elseif ch > 0xe1 and ch < 0xf5 then -- U+2000 - U+10FFFF
      width = width + twoWidths
      i = i + 2
    elseif ch < 0x80 or ch > 0xbf then
      if isMono then
        width = width + oneWidth
      else
        width = width + get_other_width(ch, widthMod)
      end
    end
    i = i + 1
  end
  if width < 0.1 then width = 0.1 end -- for our layout purposes don't let width be 0
  if width > maxWidth then maxWidth = width end
  return {
    width = maxWidth,
    height = numLines * (oneHeight + DEFAULT_LINE_SPACING) - DEFAULT_LINE_SPACING,
    numLines = numLines,
  }
end

respec.internal.measure_text = measure_text
