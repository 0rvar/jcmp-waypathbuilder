class('NamedWP')

function NamedWP:__init()
  self.waypoints = {}
  Network:Subscribe("NamedWPList", self, self.RefreshList)
  Events:Subscribe("Render", self, self.Render)
end

-- Receive waypoints from server
function NamedWP:RefreshList(waypoints)
  self.waypoints = waypoints
end

-- Render waypoints
function NamedWP:Render()
  local color
  for text,wp in pairs(self.waypoints) do
    -- World
    Graphics.DrawWP(wp, text, Settings.ColorNamedWP)

    -- Minimap
    mmMarkerType = Graphics.MarkerType.Named
    Graphics.DrawToMinimap(wp, mmMarkerType)
  end
end

function NamedWP:Add(name)
  local pos = LocalPlayer:GetPosition() + Vector3(0, 0.5, 0)
  local angle = LocalPlayer:GetAngle()
  local wp = {position = pos, angle = angle}
  Network:Send("NamedWPAdd", {name, wp})
end

function NamedWP:Remove(name)
  Network:Send("NamedWPRemove", name)
end

function NamedWP:Update(name)
  local pos = LocalPlayer:GetPosition()
  local angle = LocalPlayer:GetAngle()
  local wp = {position = pos, angle = angle}
  Network:Send("NamedWPUpdate", {name, wp})
end

function NamedWP:Teleport(name)
  Network:Send("NamedWPTeleport", name)
end

function NamedWP:List()
  local wps = ""
  local fst = true
  for k,_ in pairs(self.waypoints) do
    if not fst then
      wps = wps .. ","
    else
      fst = false
    end
    wps = wps .. k
  end
  self:Print("Waypoints: " .. wps)
end

function NamedWP:HandleCommand(cmd, cmd_args)
  local invalidCommand = function()
    self:Print(Settings.InvalidCommand)
  end

  if #cmd_args > 0 and (cmd == "add" or cmd == "a") then
    self:Add(cmd_args[1])
  elseif #cmd_args > 0 and (cmd == "remove" or cmd == "r") then
    self:Remove(cmd_args[1])
  elseif #cmd_args > 0 and (cmd == "update" or cmd == "u") then
    self:Update(cmd_args[1])
  elseif #cmd_args > 0 and (cmd == "tp" or cmd == "teleport" or cmd == "goto") then
    self:Teleport(cmd_args[1]) 
  elseif cmd == "list" then
    self:List()
  else
    invalidCommand()
  end
end

function NamedWP:Print(arg)
  Chat:Print("[WPB] "..tostring(arg), sharedSettings.chatColor)
end
