
local function exp_dump(var, indent)
  local text = ""
  if (not indent) then
    indent = "   "
  end
  if (type(var)=="table") then
    text = "{"
    for key,value in pairs(var) do
      text = text..indent.."  "..key.." = "..exp_dump(value, indent.."    ")
    end
    text = text..indent.."}"
  elseif (type(var)=="string") then
    text = "\""..var.."\""
  elseif (type(var)=="number") then
    text = tostring(var)
  elseif (type(var)=="nil") then
    text = "nil"
  else
    text  = "type: "..type(var)
  end
  return text
end

minetest.register_chatcommand("export_adaptation", {
    params = "<file>",
    description = "",
    privs = {debug=true},
    func = function(name, param)
       -- check param
        if (param==nil) or (param=="") then
          return false, "Use /export_adaptation filename";
        end
        -- command body
        local filename = minetest.get_worldpath().."/"..param;
         
        if isFile(filename) then
          return false, "File \""..filename.."\" already exists!";
        end

        local file = io.open(filename,"w");
        
        file:write("exported = {\n");
        for item_key, item_data in pairs(adaptation_lib.items) do
          local def = minetest.registered_items[item_data.name]
          if def then
            local item_string = "  [\""..item_key.."\"] = {\n"
            item_string = item_string.."    name = "..def.name..",\n"
            local find = def.name:find(":")
            if find then
              item_string = item_string.."    prefix = "..def.name:sub(1,find[1])..",\n"
            end
            if def.tiles then
              item_string = item_string.."    tiles = "..exp_dump(def.tiles)..",\n"
              item_string = item_string.."    tile = "..def.tiles[1]..",\n"
            end
            if def.sounds then
              
              item_string = item_string.."    sounds = "..exp_dump(def.sounds)..",\n"
            end
            item_string = item_string.."  },\n"
            file:write(item_string);
          end
        end
        file:write("}\n");
        file:close();
        return true, "List of registered items saved to file \""..filename.."\"."; 
      end
  })

