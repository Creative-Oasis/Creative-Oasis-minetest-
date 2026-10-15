# Roadmap to ReSpec 1.0

## Planned features
- `wrap_contents` width for certain elements:
  - [x] Labels
  - [x] Buttons
  - [x] Vert Label
  - [x] Checkbox
  - [x] Use `core.get_player_window_information(player_name)` to scale on 5.7+ clients
  - [x] Test on 5.1.0 (the min supported version)

## Post 1.0 goals
- [DONE] Element Chains: same as constraint layout chains
  - [DONE] packed/packed-inside/spread/weighted
- Guidelines: same as constraint layout guidelines
  - Why? Because they're not really that hard to implement.
  - Why not? Because Luanti formspecs aren't nearly as dynamic as Layouts on Android
- Possibly optimize form reshowing if alignments haven't changed
- Maybe implement custom Tab Headers / helpers

## Supported Formspec Elements

Checked ones are done.

- [x] `formspec_version`
- [x] `size` : missing fixed_size param
- [x] `position`
- [x] `anchor`
- [x] `padding`
- [x] `no_prepend`
- [x] `allow_close`
- [x] `bgcolor`: To be added to Form specification

- [x] `tabheader` : Implemented, allowing the 3 variants of w/h
- [x] `table`
- [x] `tableoptions` : Added as part of respec.elements.Table spec
- [x] `tablecolumns` : Added as part of respec.elements.Table spec
- [x] `container` : Sub-layout
- [x] `scroll_container`: contains its own layout
- [x] `scrollbar`
- [x] `scrollbaroptions` : nonphysical
- [x] `listring`: Maybe worth rethinking this one
- [x] `list` : Needs special attention since w/h are specified in num slots, not size
- [x] `listcolors` : probably leave it as standalone element since it can apply to multiple lists
- [x] `tooltip` : gui_element_name ones should be build into each `PhysicalElement`
- [x] `image`
- [x] `animated_image`
- [x] `item_image`
- [x] `background` : standalone
- [x] `background9` : standalone
- [x] `pwdfield`
- [x] `field`
- [x] `field_enter_after_edit` : incorporated as flag in regular field
- [x] `field_close_on_enter` : incorporated as flag in regular field
- [x] `textarea`
- [x] `label`
- [x] `model`
- [x] `hypertext`
- [x] `vertlabel` : Added as flag on existing Label
- [x] `button`
- [x] `button_url`
- [x] `set_focus` : Implemented as part of Form's specification
- [x] `image_button` : optional params noclip, drawborder, pressed texture name
- [x] `item_image_button`
- [x] `button_exit` : incorporate as flag into regular button
- [x] `button_url_exit` : incorporated as flag into regular button_url
- [x] `image_button_exit` : incorporated as flag into regular image_button
- [x] `textlist` : optional params selected idx, transparent
- [x] `box`
- [x] `dropdown` : may require w+h
- [x] `checkbox` : Still needs wrap_content, if necessary
- [x] `style` : nonphysical. Incorporated into physical elements' spec.
- [x] `style_type` : nonphysical


## Specifically not supported Formspec Elements
- `real_coordinates[<bool>]`<br>
  Reason: This is the default past formspec v2, and the layout algorithm is build
  with this being always on in mind. Therefore, we always assume this is true, and
  don't support turning it off or lower formspec versions.

- Size-less `field[]`<br>
  Reason: Edge-case usage, and most of its usage is for trivial forms that
  don't require any complex laying out of elements.<br>
  Note that regular `field[]` elements and all their functionalities are fully supported.
