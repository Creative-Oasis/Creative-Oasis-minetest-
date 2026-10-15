
local xocean_mod = "xocean"

if minetest.get_modpath("hades_xocean") then
  xocean_mod = "hades_xocean"
end

adaptation_lib.add_item("seagrass", {
    name = xocean_mod..":seagrass"
  })

