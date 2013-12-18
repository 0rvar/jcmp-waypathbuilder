class('WPB')

function WPB:__init()
  self.waypoints = {}
  Events:Subscribe("KeyUp", self, self.KeyHandler)
  Events:Subscribe("Render", self, self.Render)
  Network:Subscribe("Command", self, self.ServerCommandHandler)
end

-- TODO: Prettier display (perhaps display distance?)
function WPB:Render()
  local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )

  local origin = Vector3(0,0,0)
  local circleRadius = 2
  local circleNormalColor = Color(200, 200, 200)
  local circleHoverColor = Color(0, 255, 0)

  local textPos = Vector3(1, -3, 0)
  local textSize = TextSize.Large
  local textScale = 1/15
  local textColor = Color(255, 255, 255)

  local targetIndex = self:GetTargetIndex()

  for i,pos in ipairs(self.waypoints) do
    local circleColor = circleNormalColor
    if i == targetIndex then
      circleColor = circleHoverColor
    end
    local t = Transform3()
      t:Translate(pos)
      t:Rotate( angle )
    Render:SetTransform(t)
    Render:DrawCircle(origin, circleRadius, circleColor)
    Render:DrawText(textPos, tostring(i), textColor, textSize, textScale)
  end
end

-- Returns the index of the closest waypoint
-- TODO: Would like to use aiming, but couldn't figure out the Angle class
function WPB:GetTargetIndex()
  local minDistance = 1000
  local index = -1
  local player_pos = LocalPlayer:GetPosition()
  for i,pos in ipairs(self.waypoints) do
    local d = player_pos:Distance(pos)
    if d < minDistance then
      minDistance = d
      index = i
    end
  end

  return index
end

function WPB:AddWaypoint()
  local pos = LocalPlayer:GetPosition()
  table.insert(self.waypoints, pos)
  self:Print("Added waypoint " .. #self.waypoints .. " at {"..tostring(pos) .. "}")
end

function WPB:RemoveWaypoint()
  local index = self:GetTargetIndex()
  if index < 0 then
    self:Print("No waypoint selected")
    return
  end
  table.remove(self.waypoints, index)
  self:Print("Removed waypoint " .. index)
end

function WPB:NudgeWaypoint(delta)
  local index = self:GetTargetIndex()
  self:MoveWaypoint(index+delta)
end

function WPB:MoveWaypoint(to_index)
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

function WPB:ClearWaypoints()
  self.waypoints = {}
  self:Print("Waypoints cleared")
end

function WPB:KeyHandler(args)
  if args.key == 107 then
    self:AddWaypoint()
  elseif args.key == 109 then
    self:RemoveWaypoint()
  elseif args.key == 106 then
    self:NudgeWaypoint(-1)
  elseif args.key == 111 then
    self:NudgeWaypoint(1)
  end
end

function WPB:ServerCommandHandler(cmd_args)
  local cmd = cmd_args[1]
  if cmd == "save" then
    self:SaveWaypoints(cmd_args[2])
  elseif cmd == "clear" then
    self:ClearWaypoints()
  elseif cmd == "add" then
    self:AddWaypoint()
  elseif cmd == "del" or cmd == "remove" or cmd == "delete" then
    self:RemoveWaypoint()
  elseif cmd == "move" and #cmd_args > 1 then
    local to = cmd_args[2]
    if to == "+" then
      self:NudgeWaypoint(1)
    elseif to == "-" then
      self:NudgeWaypoint(-1)
    else
      local to_index = tonumber(to)
      if to_index ~= nil then
        self:MoveWaypoint(to_index)
      else 
        self:Print("Invalid move index: use +, - or a number")
      end
    end
  else
    self:Print("Available commands: add, del, clear, save [prefix], move <+|-|number>")
  end
end

function WPB:SaveWaypoints(prefix)
  Network:Send("SetPrefix", prefix)
  Network:Send("SaveWaypoints", self.waypoints)
end


function WPB:Print(arg)
  Chat:Print("[WPB] "..tostring(arg), Color(220, 255, 220))
end
 
wpb = WPB()
