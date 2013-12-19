class('WPSet')

function WPSet:__init()
  self.waypoints = {}
  Events:Subscribe("Render", self, self.Render)
end

-- Render waypoints
function WPSet:Render()
  -- TODO: Prettier display (perhaps display distance?)
  local targetIndex = self:GetTargetIndex()
  local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )

  local color, mmMarkerType
  for i,wp in ipairs(self.waypoints) do
    if i == targetIndex then
      color = Settings.ColorTarget
    else
      color = Settings.ColorDefault
    end

    -- World
    Graphics.DrawWP(wp, tostring(i), color)

    -- Minimap
    mmMarkerType = Graphics.MarkerType.Normal
    if i == targetIndex then
      mmMarkerType = Graphics.MarkerType.Target
    end
    Graphics.DrawToMinimap(wp, mmMarkerType)
  end
end

-- Returns the index of the waypoint closest to the crosshair
function WPSet:GetTargetIndex()
  local minDistance = 1000
  local index = -1
  local player_pos = LocalPlayer:GetPosition()
  local camera_angle = Camera:GetAngle()

  local angle, crosshair, d, dist, pos
  for i,wp in ipairs(self.waypoints) do
    pos = wp["position"]
    dist = player_pos:Distance(pos)
    angle = camera_angle * Vector3(0, 0, -1) -- Convert camera angle to Vector3 format
    crosshair = player_pos + angle * dist -- Crosshair at same distance as point
    d = crosshair:Distance(pos)
    if d < minDistance then
      minDistance = d
      index = i
    end
  end

  return index
end

function WPSet:Add()
  local pos = LocalPlayer:GetPosition()
  local angle = LocalPlayer:GetAngle()
  local wp = {position = pos, angle = angle}
  table.insert(self.waypoints, wp)
  self:Print("Added waypoint " .. #self.waypoints .. " at {"..tostring(wp["position"]) .. "}")
end

function WPSet:Remove()
  local index = self:GetTargetIndex()
  if index < 0 then
    self:Print("No waypoint selected")
    return
  end
  table.remove(self.waypoints, index)
  self:Print("Removed waypoint " .. index)
end

function WPSet:Nudge(delta)
  local index = self:GetTargetIndex()
  self:Reorder(index+delta)
end

function WPSet:Reorder(to_index)
  local index = self:GetTargetIndex()
  if index < 0 then
    self:Print("No waypoint selected")
    return
  end

  if to_index < 1 or to_index > #self.waypoints then
    return
  end

  local wp = self.waypoints[index]
  table.remove(self.waypoints, index)
  table.insert(self.waypoints, to_index, wp)
  self:Print("Moved waypoint " .. index .. " to " .. to_index)
end

function WPSet:Clear()
  self.waypoints = {}
  self:Print("Waypoints cleared")
end

-- Send waypoints to server to save as file
function WPSet:Save(filetype, prefix)
  Network:Send("WPSetSave", {filetype, self.waypoints, prefix})
end

function WPSet:HandleCommand(cmd, cmd_args)
  local invalidCommand = function()
    self:Print(Settings.InvalidCommand)
  end

  if cmd == "save" or cmd == "savejson" then
    self:Save("json", cmd_args[1])
  elseif cmd == "savelua" then
    self:Save("lua", cmd_args[1])
  elseif cmd == "clear" then
    self:Clear()
  elseif cmd == "add" then
    self:Add()
  elseif cmd == "del" or cmd == "remove" or cmd == "delete" then
    self:Remove()
  elseif cmd == "reorder" and #cmd_args > 0 then
    local to = cmd_args[1]
    if to == "+" then
      self:Nudge(1)
    elseif to == "-" then
      self:Nudge(-1)
    else
      local to_index = tonumber(to)
      if to_index ~= nil then
        self:Reorder(to_index)
      else 
        self:Print("Invalid reorder index: use +, - or a number")
      end
    end
  else
    invalidCommand()
  end
end

function WPSet:Print(arg)
  Chat:Print("[WPBS] "..tostring(arg), sharedSettings.chatColor)
end
