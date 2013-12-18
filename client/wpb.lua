class('WPB')

function WPB:__init()
  self.waypoints = {}
  Events:Subscribe("KeyDown", self, self.KeyHandler)
  Events:Subscribe("Render", self, self.Render)
  Network:Subscribe("Command", self, self.ServerCommandHandler)
end

-- Render waypoints
function WPB:Render()
  -- TODO: Prettier display (perhaps display distance?)
  local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )

  local origin = Vector3(0,0,0)

  local targetIndex = self:GetTargetIndex()

  local circleColor, success, pos3d, pos2d, t
  for i,pos in ipairs(self.waypoints) do
    if i == targetIndex then
      circleColor = settings.circleColorTarget
    else
      circleColor = settings.circleColorDefault
    end

    t = Transform3()
      t:Translate(pos)
      t:Rotate( angle )

    Render:SetTransform(t)
    Render:DrawCircle(origin, settings.circleRadius, circleColor)
    Render:DrawText(settings.textPos, tostring(i), settings.textColor, settings.textSize, settings.textScale)
    Render:ResetTransform()

    -- Minimap
    self:DrawToMinimap(pos, i == targetIndex)
  end
end

-- Draw a marker on the minimap. 
-- Partially stolen from JC2-MP-Racing
function WPB:DrawToMinimap(pos, isTarget)
  local color1, color2
  if isTarget then
    color1 = settings.minimapTargetCPColor1
    color2 = settings.minimapTargetCPColor2
  else
    color1 = settings.minimapDefaultCPColor1
    color2 = settings.minimapDefaultCPColor2
  end

  local pos3d , success = Render:WorldToMinimap(pos)
  if not success then
    return
  end
  local pos2d = Vector2(math.floor(pos3d.x + 0.5) , math.floor(pos3d.y + 0.5))

  Render:FillArea(pos2d + Vector2(-4 , -4) , Vector2(2 , 2) , color2)
  Render:FillArea(pos2d + Vector2(3 , -4) , Vector2(2 , 2) , color2)
  Render:FillArea(pos2d + Vector2(3 , 3) , Vector2(2 , 2) , color2)
  Render:FillArea(pos2d + Vector2(-4 , 3) , Vector2(2 , 2) , color2)
  
  Render:FillArea(pos2d + Vector2(-5 , -2) , Vector2(2 , 5) , color2)
  Render:FillArea(pos2d + Vector2(4 , -2) , Vector2(2 , 5) , color2)
  Render:FillArea(pos2d + Vector2(-2 , -5) , Vector2(5 , 2) , color2)
  Render:FillArea(pos2d + Vector2(-2 , 4) , Vector2(5 , 2) , color2)
  
  
  Render:FillArea(pos2d + Vector2(-5 , -1) , Vector2(1 , 3) , color1)
  Render:FillArea(pos2d + Vector2(5 , -1) , Vector2(1 , 3) , color1)
  Render:FillArea(pos2d + Vector2(-1 , -5) , Vector2(3 , 1) , color1)
  Render:FillArea(pos2d + Vector2(-1 , 5) , Vector2(3 , 1) , color1)
  
  Render:FillArea(pos2d + Vector2(-4 , -3) , Vector2(1 , 2) , color1)
  Render:FillArea(pos2d + Vector2(4 , -3) , Vector2(1 , 2) , color1)
  Render:FillArea(pos2d + Vector2(-4 , 2) , Vector2(1 , 2) , color1)
  Render:FillArea(pos2d + Vector2(4 , 2) , Vector2(1 , 2) , color1)
  
  Render:FillArea(pos2d + Vector2(-3 , -4) , Vector2(2 , 1) , color1)
  Render:FillArea(pos2d + Vector2(2 , -4) , Vector2(2 , 1) , color1)
  Render:FillArea(pos2d + Vector2(-3 , 4) , Vector2(2 , 1) , color1)
  Render:FillArea(pos2d + Vector2(2 , 4) , Vector2(2 , 1) , color1)
end

-- Returns the index of the waypoint closest to the crosshair
function WPB:GetTargetIndex()
  local minDistance = 1000
  local index = -1
  local player_pos = LocalPlayer:GetPosition()
  local camera_angle = Camera:GetAngle()

  local angle, crosshair, d, dist
  for i,pos in ipairs(self.waypoints) do
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
  if args.key == 107 then -- Numpad Plus
    self:AddWaypoint()
  elseif args.key == 109 then -- Numpad Minus
    self:RemoveWaypoint()
  elseif args.key == 106 then -- Numpad Mult
    self:NudgeWaypoint(-1)
  elseif args.key == 111 then -- Numpad Divide
    self:NudgeWaypoint(1)
  end
end

function WPB:ServerCommandHandler(cmd_args)
  local cmd = cmd_args[1]
  if cmd == "save" or cmd == "savejson" then
    self:SaveWaypoints("json", cmd_args[2])
  elseif cmd == "savelua" then
    self:SaveWaypoints("lua", cmd_args[2])
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
    self:Print("Available commands: add, del, clear, save, savelua [prefix], move <+|-|number>")
  end
end

-- Send waypoints to server to save as file
function WPB:SaveWaypoints(filetype, prefix)
  Network:Send("SaveWaypoints", {filetype, self.waypoints, prefix})
end

function WPB:Print(arg)
  Chat:Print("[WPB] "..tostring(arg), sharedSettings.chatColor)
end
 
wpb = WPB()
