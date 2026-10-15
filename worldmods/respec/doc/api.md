# General Info

The Respec API is based on the [Luanti Formspec API](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#formspec). Knowledge of that API may be useful in understanding what certain elements do.

This document is the full API specification in detail.<br>
If you just want to quickly gets started, or see an overview of features, see the [Getting Started page on the Github Wiki](https://github.com/ZenonSeth/respec/wiki)

All names of values specified in the tables below are case sensitive, so `w = 4` will work to set the width, but `W = 4` won't.

# Form
Defines a form with all its configuration and elements it contains.
```lua
respec.Form(configFunc, elemsFunc)
```

## State
Forms have a concept of `state` - a lua table that persists from the `show(..)` function, until the form is closed.

While you can put any data you want in the state, there's two fields you shouldn't modify:
- `state.info` - which contains at the very least `playerName`, and can contain more (see below)
- `state.rintern` - which is used for storing internal data used by some elements to make life easier

The initial table can be given to a form's `show()` function, and the `state` is passed when creating the form, as well as to any event-handler functions in each element (e.g. button click listeners) where the `state` can be modified to change what is displayed on the form.

There are some entires in the `state` table that have special meaning (see [Showing Form From Rightclick](#showing-a-form-for-a-nodes-on_rightclick)):
```lua
{
  info = { playerName = "name of player to whom the form is shown" },
  -- When showing a form via `show_on_node_rightclick`, extra information is stored in the `info` table
  -- Some values are used by `respec.inv.form(listName)` to auto-populate inventory location
}
```

## `configFunc`
`configFunc` provides the configuration of the form.<br>
It must be a either:
- A simple `config` table with the format shown below
- A function that accepts the `state` object, `function(state)`. The function must return the `config` table.

`config` table format:
 ```lua
 {
    w = 8, h = 9, 
    -- Optional: the width and height of the formspec. Corresponds to `size[]`
    -- Special values: respec.const.wrap_content to simply make the form big enough for all the elements it contains
    -- if either w/h is unset, wrap_content is assumed for the missing value.

    ver = 4, -- or: formspecVersion = 4, 
    -- Required: cannot be lower than 2 (due to real_coordinates)  Corresponds to `formspec_version[]`
    
    -- Paddings are all optional.
    -- Form (aka Layout) Paddings will push all elements inwards from the corresponding edge.
    paddings = 3,
     -- sets paddings on all four sides to 3
    paddings = { hor = 4, ver = 2 }
     -- sets before/after paddings to 4 and above/below paddings to 2
    paddings = { before = 3, after = 3, above = 3, below = 4 }
    -- sets the paddings on each side correspondingly

    posX = 0.5, posY = 0.5, 
    -- Optional: the position on the screen (0-1). Corresponds to `position[]` formspec element
    
    anchorX = 0.5, anchorY = 0.5,
    -- Optional: the anchor for the on-screen position. Corresponds to `anchor[]`

    screenPaddingX = 0.05, screenPaddingY = 0.05,
    -- Optional: the padding required around the form, in screen proportion. Corresponds to `padding[]`
    
    noPrepend = false,
    -- Optional: disables player:set_formspec_prepend. Corresponds to `no_prepend[]`
    
    allowClose = true,
    -- Optional. Default is true. If set to false, disable using closing formspec via esc or similar.
    -- Corresponds to `allow_close[]`

    -- Background Color config: these 3 elements correspond to a `bgcolor[]` formspec element

    bgColor = "#RRGGBB",
    -- Optional: the background color of the formspec, in a formspec `ColorString` format
    -- Usually requires `noPrepend = true` in order to have an effect

    fbgColor = "#RRGGBB",
    -- Optional: Only if formspec_ve >= 3.
    -- The full-screen background color when showing the formspec, in a formspec `ColorString` format

    bgFullscreen = "false",
    -- Optional, if formspec_ver >= 3, otherwise must be present if `bgcolor` is present.
    -- string, can have one of these values:
    -- "false": Only the non-fullscreen background color is drawn. (default)
    -- "true": Only the fullscreen background color is drawn.
    -- "both": Only if formspec_ver >= 3. The non-fullscreen and the fullscreen background color are drawn.
    -- "neither": Only if formspec_ver >= 3. No background color is drawn.

    pixelBorder = "#RRGGBB",
    -- Optional. Specify the color of a 1px border to be drawn around the form
    -- This uses a box[] to draw a form's outline. Experimental, may not work right.

    setFocus = "id",
    -- Corresponds to set_focus[id]. Set which element is focused when the form is opened.
    -- Only certain elements can be focused.
    -- See: https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#set_focusnameforce

    reshowOnInteract = false,
    -- Optional. Default is `true`
    -- When `true` (default), the form will always be re-shown to the user after they
    -- interact with an element that triggers a callback
    -- When `false`, each individual element is required to `return true` from its 
    -- individual interaction function in order to reshow the form to the user.

    -- Default margins. Optional. All 3 versions do the same thing, but allow shorthands
    -- If present, the default margins will be used for any element that doesn't specify a corresponding margin

    defaultElementMargins = 3,
     -- sets all four default margins to 3
    defaultElementMargins = { hor = 4, ver = 2 }
     -- sets before/after margins to 4 and above/below ,margins to 2
    defaultElementMargins = { before = 3, after = 3, above = 3, below = 4 }
     -- sets the default margins to given values
    
    tooltipBgColor = "#RRGGBB",
    -- Optional, sets the background color for any tooltips in this form
    tooltipFontColor = "#RRGGBB",
    -- Optional, sets the font color for any tooltips in this form

    onClose = function(state, playerName, closedBecausePlayerLeft) end,
    -- Optional. A function to be called when the form is closed.
    -- `state` is the state of the form at time of closing
    -- `playerName` will be the name of the player
    -- `closedBecausePlayerLeft` will be true if the player left the game,
    --                           causing the close, and false otherwise
 }
```
## `elemsFunc`
The `elemsFunc` provides the list elements to be shown in the form.<br>
It must be either:
- A simple table
- A function `function(state)` which gets passed the Form's `state`, and must return a table
 
In both cases, the table must be a list of `respec.elements` which will be shown on the form.

The order of the elements in the list **does not** matter. Elements are not positioned by the order they're specified in, but rather entirely by their alignment properties. Elements can also be aligned to other elements that are positioned further down the list.

## Showing the Form
Forms can be shown by calling their `:show(playerName, state)` function, where:
- `playerName` is the player to whom you want to show the form.
- `state` is optional, and should be a lua table which will then get passed to the applicable functions, as listed above.<br>
  If omitted, the form functions will still get an empty table as their state

If for some reason you have a reference to a form (say `myForm`), and need to manually reshow it, you can do so by calling:
```lua
  myForm:reshow(playerName) -- playerName must be a string
```
This function won't do anything if the form isn't already shown to this player.

You do not need to call `reshow(playerName)` to reshow the form from element interaction/click callbacks - those will automatically reshow the function after executing, unless configured otherwise in the form's config.

## Showing a Form from a Node's `on_rightclick`
If you need to show a form from a node's `on_rightclick` callback, the Form class provides a utility method to do so easily:

```lua
function Form:show_on_node_rightclick(state, checkProtection)
```
Parameters:
- `state`: optional. The state data to be sent to the form's config/elem functions.
- `checkProtection`: optional. If true, the form will check `core.is_protected(pos)`, and only show the form to players who have access to the position.

When you use this method, the `Form`'s `state` table will have a table entry called `rightclick` (which will override any entires by that name provided in the `state` param):
```lua
  {
    info = {
      playerName = "player name",
      -- This is always present, as mentioned above
      -- the name of the player to whom the form is shown

      pos = position,
      -- the pos param from the callback, is a vector with x,y,z coords

      node = nodeTable,
      -- the node table callback param

      nodeMeta = meta,
      -- the node's looked-up meta-data object, using core.get_meta(pos) function

      player = objectRef,
      -- the `clicker` callback param, the live object reference to a Player (checked to be a player)

      itemstack = ItemStack,
      -- the callback param, ItemStack object that the user used to right-click on the node

      pointed_thing = pointed_thing,
      -- the pointed thing data passed by callback
    }
  }
```
For further info on these params see Luanti's [Node definition](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#node-definition) documentation.

Showing From from on_rightclick example:
```lua
  local myForm = respec.Form(...) -- create a new form
  core.register_node("mymod:mynode", {
    -- other defs here
    on_rightclick = myForm:show_on_node_rightclick(nil, true)
     -- form will be shown when user right-clicks this node, but only if the user has protection access
  })
```

## Example
Creating and immediately showing a formspec to `singleplayer`:
 ```lua
  respec.Form({
      ver = 5,
      margins = 0.25,
    },
    {
      respec.elements.Label { text = "Hello World!" },
    }
  ):show("singleplayer")
 ```

# Config Elements

An element simply corresponds to a formspec element.
Elements come in two categories: Physical and Config (aka Non-physical).

Config elements are elements that aren't displayed, and don't take up space on the screen, but instead perform some sort of configuration. These elements each have their own custom specifications, see below for each.

# List of Config Elements

## ListRing
Corresponds to the `listring` formspec element. [Lua API doc](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#listringinventory-locationlist-name)
```lua
  respec.elements.ListRing(spec)
```
`spec` is an optional parameter that may be omitted/nil to simply create a `listring[]`

`spec` example:
```lua
{
  respec.inv.player("main"),
  -- you can use the utility functions to easily create inventory location/listname pairs
  respec.inv.node("input"),
  respec.inv.player("main"),

  {"inventory_location1", "list_name1"},
    -- you can also just manually specify the pairs if you really need

  -- Each entry (whether with respec.inv. or manual) will create a new 
  -- `listring[inv_location, list_name]` formspec element, in the order they're specified.
}
```
See the [Inventory utils](#inventory-utils) for details on the `respec.inv.` functions.

## StyleType
Corresponds to the `style_type` formspec element
```lua
  respec.elements.StyleType(spec)
```

Note:<br>
This element must be specified **before** any other elements that you wish to style with this style.

spec:<br>
```lua
{
  target = "selector1,selector2,.." 
  -- Required. Specifies which element types this Style applies to. See below for format.
  styleName1 = "value1",
  styleName2 = "value2", -- repeated for as many styles as wanted. 
  -- "styleName" should be one of the valid styles for the target element type
  -- The valid styles are listed in each element's definition.
}
```
- An individual `selector` should be either `<element_type>` or `<element_type>:<state>`
- `<state>` is a list of states, separated by the `+` character if more than one
  - valid states: `hovered`, `pressed`, `focused`
- `<element_type>`s which are supported: (taken from Luanti docs)
  - `animated_image` - by default inherits style from "image"
  - `box`
  - `button`
  - `button_exit` - by default inherits style from "button"
  - `checkbox`
  - `dropdown`
  - `field`
  - `image`
  - `image_button`
  - `item_image_button`
  - `label`
  - `list`
  - `model`
  - `pwdfield` - by default inherits style from "field"
  - `scrollbar`
  - `tabheader`
  - `table`
  - `textarea`
  - `textlist`
  - `vertlabel` - by default inherits style from "label"

## ListColors
Corresponds to the `listcolors` formspec element
```lua
  respec.elements.ListColors(spec)
```
Note:<br>
This element must be specified **before** any lists you want to affect.

spec:<br>
```lua
{
  slotBg = "#RRGGBB" -- Required
  -- the background color of list slots, in ColorString format
  
  slotBgHover = "#RRGGBB" -- Required
  -- the background color of list slots when mouse is hovering over it, in ColorString format

  slotBorder = "#RRGGBB" -- Optional, must be present if tooltipBg is present below
  -- the color of list slot borders, in ColorString format

  tooltipBg = "#RRGGBB" -- Optional, must be specified together with tooltipFont
  -- Color of list tooltip background

  tooltipFont = "#RRGGBB" -- Optional, must be specified together with tooltipBg
  -- Color of the font used in list tooltips
}
```

## ScrollbarOptions
Corresponds to the `scrollbaroptions` formspec element
```lua
  respec.elements.ScrollbarOptions(spec)
```
Note:<br>
This element must be specified **before** any scrollbar you want to affect.
It will set the settings for all further scrollbars, unless overwritten by something.

spec:<br>
```lua
{
  min = 0, -- Optional, int. Default 0
  max = 1000, -- Optional, int, Default 1000
  smallstep = 2, -- Optional, int. Default 10. Amount scrolled by mousewheel or arrow click
  largestep = 2, -- Optional, int, Default 100. Amount scrolled by PageUp/PagdeDn
  thumbsize = 10, -- Optional, int, Defaults to 10. How much vertical space the scrollbar's thumb takes up
  arrows = "show" -- Or "hide", or "default". Optional, if absent defaults to "default"
  -- "show" : always show arrows
  -- "hide" : never show the arrows
  -- "default" : shows the arrows if there's enough space, but hides them if its too small
}
```

# Physical Element

A Physical Element is a type of element that can be displayed, positioned, and resized in some way.

## Physical Element Common Spec
This spec is common between all physical elements, and each Physical Element has its own additional data that can be added to its spec. (see `List of Physical Elements` below)

```lua
{
  id = "string", 
  -- Optional. Can be used by other elements to align to this one. IDs within the same Layout must be unique.
  -- This field is also used as the formspec name param for all interactive elements,
  -- Which means its required for them - otherwise events won't be sent to their listeners
  
  w = 3, -- or width = 3, 
  -- Usually required. Some elements support wrap_content.
  -- Set to 0 and use start+end constraints to let constraints determine width
  
  h = 3, -- or height = 3,
  -- Usually required. Some elements support wrap_content.
  -- Set to 0 and use top+bottom constraints to let constraints determine height

  -- w/h: the following elements support wrap_content, and assume that if w/h is not present:
  --   Label, Checkbox, Button, ButtonUrl
  -- For all other elements, a value of 0 is used as as default if w/h is not specified.

  tooltip = "Tooltip text to show",
  -- Optional.
  -- Sets the tooltip to show when user hovers mouse over this element.

  visibility = respec.const.visible,
  -- Optional. Default value is `visible`
  -- can be one of respec.const.[visible/invisible/gone]
  -- Visible elements take up space and are drawn in the formspec.
  -- Invisible elements take up space, but are not drawn in the formspec.
  -- Gone elements don't take up space, nor are they drawn in the formspec.

  visible = true -- or false : accepts booleans instead of constants
  -- Optional. Can be used instead of specifying `visibility`
  -- Same as specifying visibility = VISIBLE or visibility = GONE
  
-- Margins: All margins are optional. Default value is 0 for all of them.
-- Any combination of the below are acceptable.
-- Negative margins are allowed, though behavior may not be as expected.
-- If multiple are present, then more specific margins override the more general ones

  margins = 4, -- sets all margins to 4
  marginsHor = 5, -- sets both start and end margins to 5
  marginsVer = 3, -- sets both top and bottom margins to 3
  marginStart = 1, -- sets start margin to 1
  marginEnd = 1, -- sets the end margin to 1
  marginTop = 1, -- sets the top margin to 1
  marginBottom = 1, -- sets the bottom margin to 1

-- Alignment: All alignments are optional.
-- If no vertical alignment specified, top_to_parent_top is assumed.
-- If no horizontal alignment is specified, start_to_parent_start is assumed.
-- When height or width are 0, then both the corresponding alignments should be specified instead to determine size.
-- You should not specify multiple alignments - e.g. don't align top to multiple elements.
-- If multiple conflicting alignments are present, only one will be used.
-- Alignment happens to the outside of an element (which includes their margins)
-- Aligning to elements which have visibility = gone is allowed, and the alignment
-- will instead inherit the gone element's alignment

  alignTop = "other_id",
  -- aligns the top of this element to the top of the element with id "other_id"
  alignBottom = "other_id",
  -- aligns the bottom of this element to the bottom of the element with id "other_id"
  alignStart = "other_id",
  -- aligns the start of this element to the start of the element with id "other_id"
  alignEnd = "other_id",
  -- aligns the end of this element to the end of the element with id "other_id"
  
  below = "other_id",
  -- aligns the top of this element to the bottom of the element with id "other_id"
  above = "other_id",
  -- aligns the bottom of this element to the top of the element with id "other_id"
  before = "other_id",
  -- aligns the end of this element to the start of the element with id "other_id"
  after = "other_id"
  -- aligns the start of this element to the end of the element with id "other_id"
  
  toTop = true,
  -- when set to `true`, aligns the top of the element to the parent Layout's top
  toBottom = true,
   -- whenever set to `true`, aligns the bottom of the element to the parent Layout's bottom
  toStart = true,
  -- when set to `true, aligns the start of the element to the parent Layout's start
  toEnd = true,
  -- when set to `true, aligns the end of the element to the parent Layout's end
  
  centerHor = true,
  -- shorthand for setting both `toStart` and `toEnd` to true
  centerVer = true,
  -- shorthand for setting both `toTop` and `toBottom` to true
  centerHor = "other_id",
  -- shorthand for setting both `alignStart="other_id"` and `alignEnd="other_id"`
  centerVer = "other_id",
  -- shorthand for specifying both `alignTop="other_id"` and `alignBottom="other_id"`

  -- Verbose alignment flags - do the same as the above flags, but in a more descriptive way.
  -- Can be used instead of shorter versions above
  top_to_top_of = "other_id", -- same as `alignTop`
  top_to_bottom_of = "other_id", -- same as `below`
  top_to_parent_top = true, -- same as `toTop`
  bottom_to_top_of = "other_id", -- same as `above`
  bottom_to_bottom_of = "other_id", -- same as `alignBottom`
  bottom_to_parent_bottom = true, -- same as `toBottom`
  start_to_start_of = "other_id", -- same as `alignStart`
  start_to_end_of = "other_id", -- same as `after`
  start_to_parent_start = true, -- same as `toStart`
  end_to_start_of = "other_id", -- same as `before`
  end_to_end_of = "other_id", -- same as `alignEnd`
  end_to_parent_end = true, -- same as `toEnd`
  
  -- Chain defs --

  chainTypeHor = respec.const.chain_packed,
  chainTypeVer = respec.const.chain_packed,
  -- Optional
  -- respec.const.chain_packed or respec.const.chain_spread, or respec.const.chain_spread_inside
  -- Only the chain_type of the 1st element in the chain is used (and thus other elements don't need to specify it)
  -- See the section on Chains for details on the different chain types and how to create chains
  -- If not set, both default to using Packed

  weightHor = 1, -- Number, greater than 0
  weightVer = 1, -- Number, greater than 0
  -- Optional, defaults to 1
  -- IF chain_type is chain_spread or chain_spread_inside, and this element's width is 0, it will attempt to fill out all
  -- the remaining space, shared equally between elements. This doesn't work with chain_packed however.
  -- By setting this weight, each individual element can request more of the space, relative to the other element's weights

-- Biases: all are optional. 
-- When applicable, they shift how far along the element is positioned between its start and end points.
-- Biases also affect chains - only the bias of the 1st element in the chain is used. See `Chains` section for info
--
-- For example: an element with start_to_parent_start and end_to_parent_end and biasHor of 0.5 (the default) will be placed in the center:
-- |    [ELEMENT]      |
-- Setting biasHor to 0 will place the element to its alignment's start:
-- |[ELEMENT]          |
-- Setting biasHor to 1 will place the element to its alignment's end:
-- |          [ELEMENT]|
--
-- Biases apply only when both corresponding side constraints are specified and the corresponding size is fixed (not 0)
  biasHor = 0.5,
  -- the horizontal bias, defaults to 0.5 if not specified. Requires a start and end constraint to be set
  biasVer = 0.5,
  -- the vertical bias, default to 0.5 if not specified. Requires a top and bottom constraint to be set.

  style = styleDef, -- see the [Element Style Definition] section below.
  -- Optional. 
  -- Defines the style of this specific element. Each entry corresponds to a style prop.

  pixelBorder = "#RRGGBB",
  -- Optional. Separate from style above. If not specified, no border is drawn.
  -- Specify the color of a 1px border to be drawn around the element (not including margins)
  -- This doesn't use the formspec style[] element, it is manually done on top of whatever style[] you set. This is here primarily because not all elements support a border in style[]
}

```
## Visibility
When an element is `visible` or `invisible` it will take up space for the purposes of other elements aligning to it.

When an element is set to `gone` (aka `visible = false`) then any other element aligning to it will try to inherit the alignment of the `gone` element as best as it can. This means that a series elements where each aligns to the one before it should still work if an element in the series is set to `visible = false`.

## Chains
Chains are a way of positioning a horizontal or vertical group of elements together. This description will refer to horizontal chains only, but the same logic works for vertical chains.

## Create a chain
To create a chain, you need 2 or more elements such that:
- One element, considered the 'first' of the chain, explicitly has its `start` aligned to a fixed position, such as the end of another element that's not in the chain, or parent's start.
- One element, considered the 'last' of the chain explicitly has its `end` aligned to a fixed position, such as the end of another element that's not in the chain, or parent's end.
- All other elements in between align their starts/ends to each other or to the 'first' or 'last' element of the chain

For example:
```lua
  respec.elements.Button {
    id = "btn1", toStart = true, before = "btn2", text = "First"
  },
  respec.elements.Button {
    id = "btn2", after = "btn1", before = "btn3", text = "Second"
  },
  respec.elements.Button {
    id = "btn3", after = "btn2", toEnd = true, text = "Third"
  },
```
This can be extended to any number of elements so long as they follow the chaining rules.

## Chain types

The default chain type (used when one isn't specified) is `respec.const.chain_packed` which results in the default laying out of elements (as the above code would result in):
```
|       [First][Second][Third]     |
```
Where the elements are packed together in the center and positioned equally from each side.

Using `respec.const.chain_spread` results in:
```
|   [First]   [Second]   [Third]   |
```
Where the elements are spread apart by equal distance between themselves and from the sides

Using `respec.const.chain_spread_inside` results in:
```
|[First]      [Second]      [Third]|
```
Where the elements are spread apart by equal distance between themselves, but the first and last are aligned to their start/end side respectively.

## Chain bias
The `biasHor` and `biasVer` also affect positioning chained elements relative to the sides. Only the bias from the First element in the chain is used.

Biases of less than 0.5 will result in the chain being positioned closer to its starting side, and greater than 0.5 will result in the chain being positioned closer to its ending side. Note that biases do not affect `chain_spread_inside` at all.

## Weighted Elements

If any element in the chain has set its size set to 0, say its width: `w = 0`, then it will be treated as though it's attempting to fill out any remaining space. In such a case, the chain type doesn't matter.

Multiple elements within the same chain can have their widths set to 0 and will equally attempt to fill out remaining space.

By default each element assumes it has a weight of 1, but this can be overwritten by setting `weightHor` and `weightVer` on any element in the chain, and (if that element has a corresponding size of 0), the elements will take proportionally as much space. The exact space taken up is determined by the formula: `elementSize = freeSpace * elementWeight / weightSum` - where the `weightSum` is the sum of all weighted elements in the chain.

## Element Style Definition
Due to the formspec api, only these elements support individual styling:<br>
`AnimatedImage`, `Model`, `Field`, `TextArea`, `Hypertext`, `Button`, `ButtonUrl`, `ImageButton`, `ItemImageButton`, `TextList`, `TabHeader`, `Dropdown`, `Checkbox`, `Scrollbar`, `Table`

All other elements may instead be styled collectively by their type using [StyleType](#styletype).


The `style` field for a supported Physical Element must be specified as a table:
```lua
{
    styleName1 = "value1",
    styleName2 = "value2", -- repeated for as many styles as wanted. 
    -- "styleName" is one of the valid styles for this element (or element type),

    "state" = { 
      styleName1 = "value1", -- as above, repeated
    }
    -- Optional. "state" can be "hovered", "pressed", or "focused" or a combination, e.g.: "hovered+focused"
    -- Only applies for certain elements that support it.
    -- If present, these styles are applied to the element, or type of element, when in those states
}
```
The above styles, values, and states get mapped directly to a `style[]` formspec element.

The supported style and their values are listed in each element's entry below.

For details on styleName and values functionality see :<br> https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#styling-formspecs

# List of Physical Elements

All Physical Elements take a `spec` table as input.
This `spec` table may contain any of the common physical elements spec entries above, alongside element-specific specifications listed below.

## Label
Corresponds to formspec `label` and `vertlabel`
```lua
  respec.elements.Label(spec)
```
spec:
```lua
{
  w, h, -- Optional. Support respec.const.wrap_content. If absent, defaults to wrap_content

  text = "Label text here",
  -- string to be shown in label

  vertical = true, -- Optional, false by default.
  -- If set to true, this will be a `vertlabel`, which draws its text one character at a time, each on a new line.

  area = true,
  -- if set to `true` then make this an area label, which constraints its text to the size.
  -- No effect if `vertical` is set to true
  -- For more info see: https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#labelxywhlabel
}
```
Styling
- Only supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `font`, `font_size`, `noclip`

## Button
Corresponds to formspec `button`
```lua
  respec.elements.Button(spec)
```
spec:
```lua
{
  w, h, -- Optional. Support respec.const.wrap_content. If absent, defaults to wrap_content

  text = "Button text",
  -- Optional. String to be shown in Button
  
  paddings = 3, -- set paddings on all four sides to 3
  paddingsHor = 2, paddingsVer = 5, -- sets horizontal paddings to 2, and vertical paddings to 5
  -- All 3 are Optional. Only used when w/h are wrap_content.
  -- Unlike margins (common to all elements), this padding adds space inside the Button itself,
  -- This results in more space between the button's edge and the inner text.

  exit = true, -- Optional
  -- If set to true, button will close the form upon click. Default is false.
  -- the onClick listener will be called even when this is set to true

  onClick = function(state, fields) return true end,
  -- Optional. A function to be called when the button is clicked
  -- `state` is the form's state, can be modified here.
  -- `fields` is the map of value of the fields in the form
  -- Note that only fields with specified IDs will be present
  -- if reshowOnInteract is false, then return `true` from this function to re-show the formspec
}
```
Styling:
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `alpha`, `bgcolor`, `bgimg`, `bgimg_middle`, `font`, `font_size`, `border`, `content_offset`, `noclip`, `sound`, `textcolor`

## ImageButton
Corresponds to formspec `image_button` and `image_button_exit`
```lua
  respec.elements.ImageButton(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

spec:
```lua
{
  image = "texture_name.png",
  -- Required. The texture to display inside the button

  label = "Some label",
  -- Optional. Text to show over the image, centered in the button

  exit = true, -- Optional
  -- If set to true, button will close the form upon click. Default is false.
  -- the onClick listener will be called even when this is set to true

  ratio = 1.0, -- Optional. Number greater than 0
  -- If set, makes the ImageButton be constrained to this w/h aspect ratio.
  -- If not set, the ImageButton stretches to fill out its bounds as normal

  onClick = function(state, fields) return true end,
  -- Optional. A function to be called when the button is clicked
  -- `state` is the form's state, can be modified here.
  -- `fields` is the map of value of the fields in the form

  noclip = true, -- Optional, defaults to false
  -- means the image button doesn't need to be within specified formsize

  border = false, -- Optional, defaults to true
  -- Whether to draw the button border or not

  pressedImage = "pressed_texture_name.png" -- Optional
  -- The image to show inside the button when the button is pressed
}
```
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `alpha`, `bgcolor`, `bgimg`, `bgimg_middle`, `font`, `font_size`, `border`, `content_offset`, `noclip`, `sound`, `textcolor`

## ItemButton
Corresponds to formspec `item_image_button`
```lua
  respec.elements.ItemButton(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

spec:
```lua
{
  item = "somemod:itemname",
  -- Required. The registered name of an item/node

  label = "Some label",
  -- Optional. Text to show over the image, centered in the button

  ratio = 1.0, -- Optional. Number greater than 0
  -- If set, makes the ItemButton be constrained to this w/h aspect ratio.
  -- If not set, the ItemButton stretches to fill out its bounds as normal

  onClick = function(state, fields) return true end,
  -- Optional. A function to be called when the button is clicked
  -- `state` is the form's state, can be modified here.
  -- `fields` is the map of value of the fields in the form
}
```
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `alpha`, `bgcolor`, `bgimg`, `bgimg_middle`, `font`, `font_size`, `border`, `content_offset`, `noclip`, `sound`, `textcolor`

## ButtonUrl
Corresponds to formspec `button_url` and `button_url_exit`
```lua
  respec.elements.ButtonUrl(spec)
```

spec:
```lua
{
  w, h, -- Optional. Support respec.const.wrap_content. If absent, defaults to wrap_content

  text = "Text to show on the button",
  -- Optional. If not present, defaults to `url` instead

  url = "http://luanti.org",
  -- Required. Must be a valid URL starting with `http://` or `https://`

  paddings = 3, -- set all paddings on all four sides to 3
  paddingsHor = 2, paddingsVer = 5, -- sets horizontal paddings to 2, and vertical paddings to 5
  -- All 3 are Optional. Only used when w/h are wrap_content.
  -- Unlike margins (common to all elements), this padding adds space inside the Button itself,
  -- This results in more space between the button's edge and the inner text.

  exit = true, -- Optional
  -- If set to true, button will close the form upon click. Default is false.
  -- the onClick listener will be called even when this is set to true

  onClick = function(state, fields) return true end,
  -- a function to be called when the button is clicked
  -- `state` is the form's state, can be modified here.
  -- `fields` is the map of value of the fields in the form
  -- Note that only fields with specified IDs will be present
  -- if reshowOnInteract is false, then return `true` from this function to re-show the formspec
}
```

## Checkbox
Corresponds to formspec `checkbox`
```lua
  respec.elements.Checkbox(spec)
```
spec:
```lua
{
  w, h, -- Optional. Support respec.const.wrap_content. If absent, defaults to wrap_content

  text = "Checkbox text",
  -- string to be shown (to the right of the checkbox)

  on = true, -- Optional, boolean.
  -- Defaults to false. Whether the checkbox is checked (true) or not (false)

  onClick = function(state, fields) return true end
  -- a function to be called when the checkbox is clicked
  -- `state` is the form's state, can be modified here
  -- `fields` is the map of value of the fields in the form
  -- Note that only fields with specified IDs will be present
  -- if reshowOnInteract is false, then return `true` from this function to re-show the formspec
}
```
Styling:
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`, `sound`

## List
Corresponds to formspec `list` (meaning, an inventory list)
```lua
  respec.elements.List(spec)
```
spec:
```lua
{
  w = 8, h = 4, -- w/h are inherited from common physical element formspec
  -- Required. The w and h of the List are different than other elements.
  -- They do NOT measure in coordinates, but rather specify number of inventory slots
  -- The List element internally calculates its width/height in real units
  
  inv = respec.inv.node(listName)
  -- Required. The location of the inventory, and list name to show.
  -- It is easiest to use one of the `respec.inv` utility methods.
  -- The format is { "inventory location", "list name" }

  startIndex = 3,
  -- Optional. The index of the first (upper-left) item to start from, starting at 0.
  -- Default is 0.
}
```
For details on using respec.inv. methods see [Inventory utils](#inventory-utils)

Styling:
- Only supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`, `size`, `spacing`

## Dropdown
Corresponds to formspec `dropdown`
```lua
  respec.elements.Dropdown(spec)
```
spec:
```lua
{
  w = 2, h = 1, -- width is Required. height is Optional (though recommended to set)
  
  items = {
    "list", "of items", "to show", "in dropdown"
  }
  -- Required. Should be a list of strings

  index = 3, -- Optional
  -- The selected index. Defaults to 0

  indexEvent = true, -- Optional. Defaults is false
  -- Only has effect if formspec version >= 4
  -- If set to true, the listener will receive the index of the selected item as the value.
  -- Otherwise (if false, or formspec version < 4), the selected item's value is sent instead.
  
  listener = function(state, value, fields) end, -- Optional
  -- Function that gets called when an item is selected.
  -- Value is either the index or the selected item's value, as determined from above
}
```

Styling:
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`, `sound`

## Background
Corresponds to formspec `background` and `background9`
```lua
  respec.elements.Background(spec)
```
spec:
```lua
{
  w,h -- as inherited from PhysicalElement
  -- w,h: For this element, these are Optional by default, but Required if `fill = false` is set.

  texture = "texture name.png",
  -- Required. The texture to display at the given coords

  fill = true -- corresponds to formspec auto_clip
  -- Optional, default is `true`
  -- When true, w/h are ignored and the background will fill the entire form, with x/y being used as insets
  -- When false, the background will be drawn at the x/y position with the given w/h

  middle = "x" -- or "x,y" or "x1,y1,x2,y2"
  -- Optional. Must be integers.
  -- If present, will draw the background texture as a 9-slice, turning this element into a background9
  -- specifies how man pixels off the sides the 'middle' of the 9-slice starts.
  -- "x" : middle starts x pixels from each side
  -- "x,y" : middle starts x pixels from left/right and y pixels from top/bottom
  -- "x1,y1,x2,y2" : middle starts x1 from left, x2 from right, y1 from top, y2 from bottom
}
```
Note that this element is special in that ignores Layout padding completely.<br>
For more info on how background9 works, see: https://en.wikipedia.org/wiki/9-slice_scaling


## Field and PasswordField
Corresponds to formspec `field` and `pwdfield`
```lua
  respec.elements.Field(spec)
  respec.elements.PasswordField(spec)
```
Both elements share the same spec:
```lua
{
  text = "Text to be shown in field",
  -- Optional. Sets the text inside the field. Not used for PasswordField.

  label = "Label of field",
  -- Optional. Shows a small label above the field, describing it.
  -- Note: Setting this label will automatically add a marginTop the Field,
  -- to allow for room for the Label to be drawn above the field.
  -- If you then set marginTop in any other way, it will override this

  closeOnEnter = false,
  -- Optional. Default is true.
  -- If set to false, the form won't close when user presses enter while typing in the field.

  enterAfterEdit = true,
  -- Optional. Experimental - only affects Android clients. Default is false.
  -- If set to true, pressing "Done" on Android software text input will
  -- simulate an Enter key press, and submit the field

  listener = function(state, value, fields) end
  -- a function to be called when the user types and presses Enter in the field
  -- `state` is the form's state, can be modified here.
  -- `value` is the value of the Field or PasswordField
  -- `fields` is the map of value of the fields in the form
  -- Note that only fields with specified IDs will be present
  -- if reshowOnInteract is false, then return `true` from this function to re-show the formspec
}
```
Styling:
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `border`, `font`, `font_size`, `noclip`, `textcolor`

## TextList
Corresponds to formspec `textlist`
```lua
  respec.elements.TextList(spec)
```
Note that this element does not support auto-sizing, so its width and height must be specified or aligned.

spec:
```lua
{
  items = {
    "list", "of", "items", "to", "show"
  }
  -- Required, list of items to display in the list.
  -- Items can start with "#RRGGBB" (only, not alpha) colorstring to colorize it

  index = 1, -- Optional.
  -- The selected index in the list. Don't specify to let it handle its own selection on clicking.

  transparent = true, -- Optional, boolean. Default `false`
  -- Set to `true` to hide the background that's drawn automatically for this element

  listener = function(state, value, fields) end, -- Optional
  -- Function that gets called when an item is selected.
  -- Value is the table created by core.explode_textlist_event, the format being:
  -- { type = "CHG", index = 1 }
  -- where `type` can be "INV": No row selected. "CHG": item selected. "DCL" : item double-clicked.
  -- index is valid only if "CHG" or "DCL"
}
```
Styling:
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `font`, `font_size`, `noclip`

## Container
Corresponds to formspec `container`
```lua
  respec.elements.Container(spec)
```
Note that this element does not support auto-sizing, so its width and height must be specified or aligned.

Elements added inside the container take the container's position as origin, and, if asked to align to parent start/top/end/bottom - they will align to the size of the container. Containers in Luanti also do not clip their content to their size.

spec:
```lua
{
  elements = {
    respec.elements.<element>, -- repeated list of elements
  }
  -- Required. The list of elements to put inside the containers
  -- These elements can be be aligned between themselves in the exact same way
  -- that elements in a form can, using relative positioning.
  -- These elements cannot align to elements outside the container.
  -- The IDs of these elements must not repeat any IDs from outside the container,
  -- Basically all element IDs in a Form must be unique, even if inside containers

  -- Paddings are all optional.
  -- Paddings will push all elements inwards from the corresponding edge.
  paddings = 3,
    -- sets paddings on all four sides to 3
  paddings = { hor = 4, ver = 2 }
    -- sets before/after paddings to 4 and above/below paddings to 2
  paddings = { before = 3, after = 3, above = 3, below = 4 }
  -- sets the paddings on each side correspondingly

  -- Default margins. Optional. All 3 versions do the same thing, but allow shorthands
  -- If present, the default margins will be used for any element that doesn't specify a corresponding margin
  defaultElementMargins = 3,
    -- sets all four default margins to 3
  defaultElementMargins = { hor = 4, ver = 2 }
    -- sets before/after margins to 4 and above/below ,margins to 2
  defaultElementMargins = { before = 3, after = 3, above = 3, below = 4 }
    -- sets the default margins to given values
}
```

## ScrollContainer
Corresponds to formspec `scroll_container`
```lua
  respec.elements.ScrollContainer(spec)
```
Note that this element does not support auto-sizing, so its width and height must be specified or aligned.

Elements added inside the scroll container take the scroll container's position as origin, and, if asked to align to parent start/top/end/bottom - they will align to the size of the container.

spec:
```lua
{
  id = "id", -- Inherited from physical element: Required if not using externalScrollbar

  orientation = "horizontal", -- or "vertical" or "h" or "v" for shorthand
  -- Optional. If absent, "vertical" is assumed

  scrollFactor = 0.1,
  -- Optional. If absent, defaults to 0.1

  elements = {
    respec.elements.<element>, -- repeated list of elements
  }
  -- Required. The list of elements to put inside the scroll containers
  -- These elements can be be aligned between themselves in the exact same way
  -- that elements in a form can, using relative positioning.
  -- These elements cannot align to elements outside the scroll container.
  -- The IDs of these elements must not repeat any IDs from outside the scroll container,
  -- Basically all element IDs in a Form must be unique, even if inside scroll containers

  externalScrollbar = "name_of_scrollbar",
  -- Optional. Only specify if you want to make your own scrollbar - recommended not to.
  -- If absent, the ScrollContainer will automatically create its own Scrollbar,
  -- and resize it correctly - this works on all formspec versions that support scroll_container.
  -- The built-in Scrollbar will be named "[id_of_scroll_container]_scrollbar"

  scrollbarSize = 0.2,
  -- Optional. If absent, 0.2 is default value
  -- This specifies how wide or how tall (depending if orientation is vertical or horizontal)
  -- the built-in scrollbar should be. Has no effect on externalScrollbars 

  scrollbarOptions = scrollbarOptionsSpec, 
  -- Optional. Only used if externalScrollbar is not set.
  -- The options to apply to this scrollbar, in the format of the spec for `ScrollbarOptions`
  -- Note that because the way formspecs work, these scrollbar options will also
  -- be applied to any consequent scrollbars in this form.

  scrollbarListener = scrollbarListenerFunction,
  -- Optional. Only used if `externalScrollbar` is not specified.
  -- The listener function for the built-in scrollbar, see `Scrollbar` class for info.

  -- Paddings are all optional.
  -- Paddings will push all elements inwards from the corresponding edge.
  paddings = 3,
    -- sets paddings on all four sides to 3
  paddings = { hor = 4, ver = 2 }
    -- sets before/after paddings to 4 and above/below paddings to 2
  paddings = { before = 3, after = 3, above = 3, below = 4 }
  -- sets the paddings on each side correspondingly

  -- Default margins. Optional. All 3 versions do the same thing, but allow shorthands
  -- If present, the default margins will be used for any element that doesn't specify a corresponding margin
  defaultElementMargins = 3,
    -- sets all four default margins to 3
  defaultElementMargins = { hor = 4, ver = 2 }
    -- sets before/after margins to 4 and above/below ,margins to 2
  defaultElementMargins = { before = 3, after = 3, above = 3, below = 4 }
    -- sets the default margins to given values
}
```
The `ScrollContainer` class will create its own scrollbar, unless you specify an external scrollbar name via `externalScrollbar`. 

This built-in scrollbar will be positioned below (if orientation is horizontal) or to the right (if orientation is vertical) of the scroll container, and a margin will be set (or added) to make room for it. The scrollbar's name will be `[id_of_scroll_container]_scrollbar` - which can be used to be read via the `fields` variable 

## Scrollbar
Corresponds to formspec `scrollbar`
```lua
  respec.elements.Scrollbar(spec)
```
Note that you **do not need** to create a `Scrollbar` for each `ScrollContainer` - the `ScrollContainer` will make and position its own `Scrollbar`, unless specified otherwise.

spec:
```lua
{
  orientation = "horizontal", -- or "vertical", or "h"/"v" for shorthand
  
  listener = function(state, explodedEvent, fields),
  -- Optional, the function to call when a scrollbar event happens.
  -- `state` is the form's state, can be modified here.
  -- `explodedEvent` is the event in table format, as returned by `core.explode_scrollbar_event`.
  --                The format { type="CHG", value=500 }
  --                where "type" can be "INV" = failed. "CHG" = value changed, "VAL" = no change
  -- `fields` is the map of value of the fields in the form
}
```
Styling:
- See also [ScrollbarOptions](#scrollbaroptions)
- Supports per-element `style` entry in their spec, if `id` is set.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`

## Image
Corresponds to formspec `image` and `animated_image`
```lua
  respec.elements.Image(spec)
```
This element can display both a regular image and an animated image.

Animated images are defined by having multiple frames all stacked vertically (from first on top, to last on bottom) in a single texture. The number of frames and time between frames is then passed as params in the spec.

spec:
```lua
{
  image = "texture_name.png"
  -- Required: the image to display

  middle = "x" -- or "x,y" or "x1,y1,x2,y2"
  -- Optional. Formspec Version 6 or higher. Must be integers.
  -- If present, will draw the image as a 9-slice, turning this element into a background9
  -- specifies how man pixels off the sides the 'middle' of the 9-slice starts.
  -- "x" : middle starts x pixels from each side
  -- "x,y" : middle starts x pixels from left/right and y pixels from top/bottom
  -- "x1,y1,x2,y2" : middle starts x1 from left, x2 from right, y1 from top, y2 from bottom

  ratio = 1.0, -- Optional. Must be greater than 0
  -- If specified, the image will be drawn to the specified aspect ratio of Width/Height
  -- fitting inside the bounds it gets.
  -- If not specified, the image will be stretched to fill its bounds.

  -- Animation params --
  -- Optional, but frameCount and frameTime are both required to make an animation
  -- If all are specified, this image will become an animated_image element
  
  frameCount = 4, -- number of frames in animation
  frameTime = 10, -- milliseconds between each frame. 0 means frames don't advance
  frameStart = 1, -- Optional, index of the frame to start on. Default is 1
  
  listener = function(state, frame, fields) end
  -- Optional event listener that gets called when an animation frame changes
  -- In order for this to work, you must specify a valid unique `id` in the image spec
  -- `state` is the form's state, can be modified
  -- `frame` is the integer value of the frame now displayed
  -- `fields` is the rest of the formspec fields in a map of id->value  
}
```
Styling:
- Animated images support per-element `style` entry in their spec.
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`

## ItemImage
Corresponds to formspec `item_image`
```lua
  respec.elements.ItemImage(spec)
```
spec:
```lua
{
  item = "item name" -- Required. Name of the registered item/node

  ratio = 1.0, -- Optional. Number, must be greater than 0. You probably want 1
  -- If set, makes the item image be shown in this w/h aspect ratio.
  -- If not set, the image stretches to fill out its bounds
}
```
Styling:
- Supports type-styling via [StyleType](#styletype) only
- Supported style properties:<br>
  `noclip`

## TextArea
Corresponds to formspec `textarea`
```lua
  respec.elements.TextArea(spec)
```
spec:
```lua
{
  id = "unique_id" -- inherited from physical element.
  -- Required if `editable = true` is set, used to lookup of value of TextArea in the fields.

  editable = true, -- Optional
  -- Default `false`. Whether the user can edit this area or not.

  label = "Text to show above text area"
  -- Optional. Shows a small label above the text area.
  -- Note: Setting this label will automatically add a marginTop the TextArea,
  -- to allow for room for the Label to be drawn above the field.
  -- If you then set marginTop in any other way, it will override the automatic margin

  text = "default text to show"
  -- The text to show in the TextArea
}
```
Styling:
- Supports per-element `style` entry in their spec, if `id` is set
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `border`, `font`, `font_size`, `noclip`, `textcolor`

## Tabs
Corresponds to formspec `tabheader`
```lua
  respec.elements.Tabs(spec)
```

spec:
```lua
{
  aboveForm = true, -- Optional. Default is true.
  -- Makes the tabs appear above the form, and won't be affected by alignment, or form padding.
  -- You can still control their positioning in a limited way using margins.
  -- If set to `false`, then the Tabs can be positioned inside the form using alignments.

  w = 2, h = 1, -- Optional.
  -- If not using aboveForm tabs, and you want to align other elements to the Tabs,
  -- you _must_ specify at least a `w` - otherwise tabs will assume entire width of container.
  -- Specifying a width for aboveForm tabs is also valid, even if not necessary at all
  -- Height works fine with both aboveForm tabs and otherwise.

  items = { "Tab 1 Caption", "Tab 2 Caption", "Tab 3 Caption" },
  -- Required. A list of strings, each corresponding to a tab

  index = 1,
  -- Optional. Defaults to 1. Which tab is the selected tab

  transparent = true, -- Optional. Default is true
  -- Whether to draw tabs semi-transparent
  -- NOTE: does not seem to work in current formspec version

  drawBorder = true,  -- Optional Default is true
  -- Whether to draw tabs' borders
  -- NOTE: does not seem to work in current formspec version

  listener = function(state, value, fields) end,
  -- Optional. Called when a tab is selected
  -- `state` is the form's state, can be modified here.
  -- `value` is the tab index that was selected
  -- `fields` is the map of value of the fields in the form
}
```
- Supports per-element `style` entry in their spec, if `id` is set
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `noclip`, `sound`, `textcolor`

## Model
Corresponds to formspec `model`
```lua
  respec.elements.Model(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

spec:
```lua
{
  mesh = "mesh.obj" -- Required.
  -- the mesh to display

  textures = "texture1.png,texture2.png", -- Required
  -- The mesh textures to use according to the mesh materials. Textures must be separated by commas.

  rotation = "x,y", -- Optional. "#,#" format
  -- Initial rotation to use, axes are euler angles in degrees.

  autoRotate = true, -- Optional. Boolean
  -- Whether the rotation auto-rotates aka continuous. Default `false`

  control = true, -- Optional. Boolean
  -- True/false whether the model can be rotated with mouse. Default `true`

  loopRange = "<begin frame>,<end frame>", -- Optional. "#,#" format
  -- Range of the animation frames to show. Defaults to full range of all frames.

  animSpeed = 60, -- Optional
  -- Sets the anim speed in Frames Per Second. Default 0 FPS.
}
```
- Supports per-element `style` entry in their spec, if `id` is set
- Supports type-styling via [StyleType](#styletype)
- Supported style properties:<br>
  `bgcolor`, `noclip`

## Table
Corresponds to formspec `table`, and includes `tablecolumns` and `tableoptions`
```lua
  respec.elements.Table(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

spec:
```lua
{
  -- The `config` param corresponds to `tableoptions`, configuring the properties of the table
  -- It is entirely optional. Due to the way formspecs work, if not specified, any previous config will instead
  -- affect this table.
  -- Any combination of the config options may be specified, and as many omitted if desired
  config = { -- optional (but highly recommended)
    color = "#RRGGBBAA", -- Optional. Text color. Defaults to white (#FFFFFF)
    bg = "#RRGGBBAA", -- Optional. Table background color. Defaults to black (#000000)
    border = true, -- Optional, true/false. Default is true. Whether to draw the borders of the table
    highlight = "#RRGGBBAA" -- Optional. Highlight background color. Defaults to #466432 (dark green-ish)
    opendepth = 2, -- Optional, integer. All subtrees (if present) with depth < value will be open by default
                   -- Only useful if there's a column of type "tree"
  },

  -- The `columns` param corresponds to `tablecolumns`.
  -- It configures what type each column will be, and implicitly specifies how many columns there are
  -- Each entry in this table defines a new column, and its properties. This is then used to interpret
  -- the data specified for the table.
  -- The number of entires in this field implicitly defines how many columns there will be,
  -- with exceptions of columsn that configure other columns (e.g. color, indent, tree)
  columns = {
    -- contains a list of repeated strings, where each string follows the tablecolumns format (described below)
    -- Example:
    "tree", -- column 1: "tree" type, allowing for collapsing elements
    "text,align=left,tooltip=Task name", -- column2: left-aligned text, with tooltip of "Task name"
    "image,align=right,0=blank.png,1=unchecked.png,2=checked.png", -- column 3: an image, where values of 0,1,2 show the specified images
    "color", -- column 4: specifies a color for the rest of the columns
    "text,align=left,tooltip=Task description", -- column5: left aligned text, tooltip of "Task description"
  },

  -- The `data` param is the actual data to show in this table, following the format defined by `columns` above
  -- To be correct, the number of data must always be a multiple of the number of columns,
  -- e.g. in the example above `columns` defines 5 columns (tree, text, image, color, text)
  -- so the data below should have 5, or 10, or 15, etc number of entires in order to be correct.
  -- You may find it easier to have "row" (represented by amount of data same as column number) be
  -- created by a function, depending on the state of whatever you want to display (e.g. quests)
  --
  -- Entires can be a string or integer. Each entry will be interpreted as defined by the `columns` above
  cells = {
    -- example, following the columns config above:
    0, "Main tasks",      0, "#333333", "",
    1, "Read tutorial",   1, "#FFFF33", "Go to spawn and read the tutorial",
    1, "Agree to rules",  1, "#66FF33", "Read the rules book and agree",
    1, "Find the badger", 2, "#AAAAFF", "Follow the trail...",
  },

  index = 1, -- Optional. Defaults to 1. The index of the row to be selected, first row is 1.

  listener = function(state, value, fields) end,
  -- Optional. Gets called back when a table row is selected.
  -- `state` is the form state, can be modified here
  -- `value` is a table from explode_table_event() in the format
  --         `{type = "INV" or "CHG" or "DLC", row = 1, column = 2}`
  -- `fields` is the table mapping to rest of the form's fields

}
```
The format of each entry of the `columns`, meaning definition of a column type and properties, above is:
```lua
"<type>,<option>,<option>..."
```
Where:
- `<type>` can be: `text`, `image`, `color`, `indent`, `tree`
  - `text`:   show cell contents as text
  - `image`:  cell contents are an image index, use column options to define
              images. images are scaled down to fit the row height if necessary.
  - `color`:  cell contents are a ColorString and define color of following
              cell.
  - `indent`: cell contents are a number and define indentation of following
              cell.
  - `tree`:   same as indent, but user can open and close subtrees
                (treeview-like).
- `<option>` cab be:
  - `align=<value>`
    - for `text` and `image`: content alignment within cells.
      Available values: `left` (default), `center`, `right`, `inline`
  - `width=<value>`
    - for `text` and `image`: minimum width in em (default: `0`)
    - for `indent` and `tree`: indent width in em (default: `1.5`)
  - `padding=<value>`: padding left of the column, in em (default `0.5`).
    Exception: defaults to 0 for indent columns
  - `tooltip=<value>`: tooltip text (default: empty)
  - `image` column options:
    - `0=<value>` sets image for image index 0
    - `1=<value>` sets image for image index 1
    - `2=<value>` sets image for image index 2
    - and so on; defined indices need not be contiguous. empty or
      non-numeric cells are treated as `0`.
  - `color` column options:
    - `span=<value>`: number of following columns to affect
      (default: infinite).

## Hypertext
Corresponds to formspec `hypertext`
**Note from luanti's API**: This element is currently unstable and subject to change.
```lua
  respec.elements.Hypertext(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

For details on the *Markup Language* see Luanti's API: https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#markup-language

spec:
```lua
{
  text = "Markup Text", -- Text to show, formatted by the Markup Language linked above

  listener = function(state, value, fields) end,
  -- Optional - receives the actions as defined by the Markup Language.
  -- `state` is the form's state, can be modified here.
  -- `value` is the value of the action, usually encoded as "action:name"
  -- `fields` is the map of value of the fields in the form
}
```

## Box
Corresponds to formspec `box`
```lua
  respec.elements.Box(spec)
```
This element does not support wrapping width/height, and those must be specified or aligned.

spec:
```lua
{
  color = "#RRGGBBAA", -- Optional
  -- the color to draw the box in. If alpha component is not specified, semi-transparent will be used
  -- If no color is specified, then the box style options will be used.
  -- If a color is specified, all style options will be ignored
}
```
- Supports type-styling via [StyleType](#styletype) only
- Supported style properties:<br>
  `noclip`: whether box is allowed to exceed clipping of form
  `colors`: can be 1, 2, or 4 colors, specifying all corners, top/bottom, or top-left,top-right,bottom-right, bottom-left
  `bordercolors`: Can also be 1, 2, or 4 colors, as above
  `borderwidths`: pixel width. If negative, border is drawn inside box. If positive, outside box

# Utility Methods

## Inventory utils
Utility Methods for creating a `{"inventory location", "listname" }` description:
- `respec.inv.player(playerName, listName)`
  - `playerName` is a player's name
  - `listName` is the name of the list to show
- `respec.inv.player(listName)`
  - As above, but sets `current_player` as the inventory location
  - `listName` is the list to show
- `respec.inv.node(pos, listName)`<br>
  - `pos` is a vector in the `{x=x, y=y, z=z}` format
  - `listName` is the name of the list to show
- `respec.inv.node(listName)`<br>
  - As above, but sets the inventory location to the `pos` specified in the form's `state`
  - `listName` is the name of the list to show
  - Can be used if the form is shown via `show_on_node_rightclick()`, see [Showing a Form from rightlick](#showing-a-form-from-a-nodes-on_rightclick)
- `respec.inv.detached(invName, listName)`<br>
  `invName` is the detached inventory name to use.
  `listName` is the name of the list from the detached inventory to show.
