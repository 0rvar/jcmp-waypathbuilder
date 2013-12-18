class('WPB')

function WPB:__init()
  self.prefix = nil
  Network:Subscribe("SaveWaypoints", self, self.SaveWaypoints)
  Network:Subscribe("SetPrefix", self, self.SetPrefix)
  Events:Subscribe("PlayerChat", self, self.ChatCommand)
end

-- Export as JSON
function WPB:SaveWaypoints(args)
  local filename = os.date("%Y-%m-%d_%H.%M.%S.json")
  if self.prefix then
    filename = self.prefix .. "_" .. filename
  end
  
  local str = '{\n  "Waypoints": ['
  for i,wp in ipairs(args) do
    if i > 1 then
      str = str .. ","
    end
    str = str .. "\n    "
    str = str .. string.format('{"x":%f,"y":%f,"z":%f}', wp.x, wp.y, wp.z)
  end
  str = str .. '\n  ]\n}'

  local file = io.open(filename, "w+")
  file:write(str)
  file:close()

  Chat:Broadcast("Saved waypoints as: " .. filename, Color(220, 255, 220))
end

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
