Graphics = {}

function Graphics.DrawWP(wp, text, color)
  local origin = Vector3(0,0,0)
  local pos = wp["position"]
  local c_angle = wp["angle"] * Angle( 0, math.pi, 0 )
  local text_angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )
  local text_width = Render:GetTextWidth(text, Settings.TextSize, Settings.TextScale)

  local t = Transform3()
    t:Translate(pos)
    t:Rotate(c_angle)
  Render:SetTransform(t)
  Render:DrawCircle(origin, Settings.CircleRadius, color)

  t = Transform3()
    t:Translate(pos)
    t:Rotate(text_angle)
  Render:SetTransform(t)
  Render:DrawText(Settings.TextPos - Vector3(text_width/2, 0, 0), text, color, Settings.TextSize, Settings.TextScale)

  Render:ResetTransform()
end

-- Draw a marker on the minimap. 
-- Partially stolen from JC2-MP-Racing
function Graphics.DrawToMinimap(wp, markertype)
  local color1, color2
  if markertype == Graphics.MarkerType.Target then
    color1 = Settings.MinimapTargetCPColor1
    color2 = Settings.MinimapTargetCPColor2
  elseif markertype == Graphics.MarkerType.Named then
    color1 = Settings.MinimapNamedCPColor1
    color2 = Settings.MinimapNamedCPColor2
  else
    color1 = Settings.MinimapDefaultCPColor1
    color2 = Settings.MinimapDefaultCPColor2
  end
  local pos = wp.position
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

Graphics.MarkerType = {}
Graphics.MarkerType.Normal = 0
Graphics.MarkerType.Target = 1
Graphics.MarkerType.Named = 2

