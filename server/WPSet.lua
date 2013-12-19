class('WPSet')

function WPSet:__init()
  Network:Subscribe("WPSetSave", self, self.SaveWaypoints)
end

-- Export as JSON / LUA
function WPSet:SaveWaypoints(args, sender)
  if #args < 2 then
    return
  end
  local filetype = args[1]
  local prefix = args[3]
  local waypoints = args[2]

  local filename = os.date("%Y-%m-%d_%H.%M.%S.")
  if filetype == "lua" then
    filename = filename .. "export."
  end
  filename = filename .. filetype
  if prefix ~= nil then
    filename = prefix .. "_" .. filename
  end
  filename = "export/"..filename

  local str = ""
  if filetype == "json" then
    local json = require "JSON"
    local wps = {}
    for i,wp in ipairs(waypoints) do
      table.insert(wps, WPUtils.ToTable(wp))
    end
    str = json.encode({waypoints = wps}) .. "\n"
  elseif filetype == "lua" then
    str = WPUtils.ToLua(waypoints)
  end

  local file, e = io.open(filename, "w+")
  if file == nil then
    Chat:Send(sender, "[WPBS] Could not save waypoints: "..tostring(e), Color(255, 0, 0))
    return
  end
  file:write(str)
  file:close()

  Chat:Send(sender, "[WPBS] Saved waypoints as: " .. filename, sharedSettings.chatColor)
end

wpsets = WPSet()
