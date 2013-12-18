class('WPB')

function WPB:__init()
  Network:Subscribe("SaveWaypoints", self, self.SaveWaypoints)
  Events:Subscribe("PlayerChat", self, self.ChatCommand)
end

-- Export as JSON
-- TODO: Add options to export as lua
function WPB:SaveWaypoints(args)
  if #args < 3 then
    return
  end
  local filetype = args[1]
  local prefix = args[2]
  local waypoints = args[3]

  local filename = os.date("%Y-%m-%d_%H.%M.%S.")
  if filetype == "lua" then
    filename = filename .. "export."
  end
  filename = filename .. filetype
  if prefix ~= nil then
    filename = prefix .. "_" .. filename
  end

  local str = ""
  
  if filetype == "json" then
    str = '{\n  "Waypoints": ['
    for i,wp in ipairs(waypoints) do
      if i > 1 then
        str = str .. ","
      end
      str = str .. "\n    "
      str = str .. string.format('{"x":%f,"y":%f,"z":%f}', wp.x, wp.y, wp.z)
    end
    str = str .. '\n  ]\n}'
  elseif filetype == "lua" then
    str = "local waypoints = {"
    for i,wp in ipairs(waypoints) do
      if i > 1 then
        str = str .. ","
      end
      str = str .. "\n  "
      str = str .. string.format('Vector3(%f, %f, %f)', wp.x, wp.y, wp.z)
    end
    str = str .. '\n}'
  end

  local file = io.open(filename, "w+")
  file:write(str)
  file:close()

  Chat:Broadcast("[WPB] Saved waypoints as: " .. filename, sharedSettings.chatColor)
end

-- TODO: Remove this function, send prefix with same network packet as save
function WPB:SetPrefix(prefix)
  self.prefix = prefix
end

function WPB:ChatCommand(args)
  local msg = args.text

  if msg:sub(1, 1) ~= "/" then
      return true
  end

  -- Truncate the starting character
  msg = msg:sub(2)

  -- Split the message
  local cmd_args = msg:split(" ")
  local cmd_name = cmd_args[1]
 
  -- Remove the command name
  table.remove( cmd_args, 1 )

  if cmd_name == "wpb" then
    Network:Send(args.player, "Command", cmd_args)
    return false
  end
 
  return true
end

wpb = WPB()
