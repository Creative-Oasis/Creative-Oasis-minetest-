respec.const = {}
local CONST = respec.const

CONST.max_formspec_version = 9 -- to be updated when new features added

CONST.wrap_content = -1 -- WIP, only works with Layouts, not general elements
CONST.parent = -2
CONST.unset  = -10000 -- just a neg value unlikely to be reached

CONST.top    = -10
CONST.bottom = -11
CONST.left   = -12
CONST.right  = -13

-- "chain" feature is WIP, not functional yet
CONST.chain_packed = -30
CONST.chain_spread = -31
CONST.chain_spread_inside = -32

CONST.visible = -40
CONST.invisible = -41
CONST.gone = -42
