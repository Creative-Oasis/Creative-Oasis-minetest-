
minetest.register_chatcommand("adaptation_check", {
    params = "<item_exists> <tiles_match> <sounds_match>",
    description = "Check loaded adaptation",
    privs = {debug=true},
    func = function(name, param)
       -- check param
        if (param==nil) or (param=="") then
          return false, "Use /adaptation_check item_exists tiles_match";
        end
        local params = string.split(param, " ")
        local item_exists = true
        local tiles_match = true
        local sounds_match = true
        if (params[1] and (params[1]=="no")) then
          item_exists = false
        end
        if (params[2] and (params[2]=="no")) then
          tiles_match = false
        end
        if (params[3] and (params[3]=="no")) then
          sounds_match = false
        end
        
        local all_ok = true
        
        for item_key, item_data in pairs(adaptation_lib.items) do
          local def = minetest.registered_items[item_data.name]
          if def then
            if tiles_match and item_data.tiles then
              match = def.tiles~=nil
              if match then
                for key,tile in pairs(item_data.tiles) do
                  if (def.tiles[key]~=tile) then
                    match = false
                    all_ok = false
                    break
                  end
                end
              end
              if match then
                for key,tile in pairs(def.tiles) do
                  if (item_data.tiles[key]~=tile) then
                    match = false
                    all_ok = false
                    break
                  end
                end
              end
              if not match then
                minetest.log("error", "Tiles for item "..item_data.name.." is different from registereditem tiles. Item key is "..item_key..".")
              end
            end
            if sounds_match and item_data.sounds then
            end
          elseif item_exists then
            minetest.log("error", "Item "..item_data.name.." not found in registered items. Item key is "..item_key..".")
            all_ok = false
          end
        end
        if all_ok then
          return true, "Registered adapation lib items check done. No problem has been found."
        else
          return true, "Registered adapation lib items check done. See results in minetest terminal."
        end
      end
  })

