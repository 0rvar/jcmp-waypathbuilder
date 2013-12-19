class('NamedWP')

function NamedWP:__init()
  Events:Subscribe("ModuleLoad", self, self.Load)
  Events:Subscribe("ClientModuleLoad", self, self.ClientLoaded)
  Network:Subscribe("NamedWPAdd", self, self.Add)
  Network:Subscribe("NamedWPUpdate", self, self.Update)
  Network:Subscribe("NamedWPRemove", self, self.Remove)
  Network:Subscribe("NamedWPTeleport", self, self.Teleport)
end

function NamedWP:Load()
  self.db = NamedWP_Database()
  self.waypoints = self.db:Load()
  self:Broadcast()
end

function NamedWP:ClientLoaded(args)
  Network:Send(args.player, "NamedWPList", self.waypoints)
end

function NamedWP:Broadcast()
  Network:Broadcast("NamedWPList", self.waypoints)
end

function NamedWP:Add(args, sender)
  local name = args[1]
  local wp = args[2]
  if not self.waypoints[name] then
    self.waypoints[name] = wp
    self.db:Add(name, wp)
    self:FileSync()
    self:Broadcast()
    Chat:Broadcast("[WPB] Added waypoint " .. name, sharedSettings.chatColor)
  else
    Chat:Send(sender, "[WPB] Waypoint "..name.." already exists", sharedSettings.chatColor)
  end
end

function NamedWP:Update(args, sender)
  local name = args[1]
  local wp = args[2]
  if self.waypoints[name] then
    self.waypoints[name] = wp
    self.db:Add(name, wp)
    self:FileSync()
    self:Broadcast()
    Chat:Broadcast("[WPB] Updated waypoint " .. name, sharedSettings.chatColor)
  else
    Chat:Send(sender, "[WPB] No waypoint named "..name, sharedSettings.chatColor)
  end
end

function NamedWP:Remove(name, sender)
  if self.waypoints[name] then
    self.waypoints[name] = nil
    self.db:Remove(name)
    self:FileSync()
    self:Broadcast()
    Chat:Broadcast("[WPB] Removed waypoint " .. name, sharedSettings.chatColor)
  else
    Chat:Send(sender, "[WPB] No waypoint named "..name, sharedSettings.chatColor)
  end
end

function NamedWP:Teleport(name, sender)
  if self.waypoints[name] then
    sender:SetPosition(self.waypoints[name]["position"])
    Chat:Send(sender, "[WPB] Teleported you to "..name, sharedSettings.chatColor)
  else
    Chat:Send(sender, "[WPB] No waypoint named "..name, sharedSettings.chatColor)
  end
end

function NamedWP:FileSync()
  self:FileSyncJSON()
  self:FileSyncLua()
end

function NamedWP:FileSyncJSON()
  local json = require "JSON"
  local filename = "export/named_waypoints.json"

  local file, e = io.open(filename, "w+")
  if file == nil then
    Chat:Broadcast("[WPB] Could not synchronize waypoints: "..tostring(e), Color(255, 0, 0))
    return
  end

  wp_table = {}

  for wpname,wp in pairs(self.waypoints) do
    wp_table[wpname] = WPUtils.ToTable(wp)
  end

  file:write(json.encode(wp_table))
  file:write("\n")

  file:close()
end

function NamedWP:FileSyncLua()
  local filename = "export/named_waypoints.lua"

  local file, e = io.open(filename, "w+")
  if file == nil then
    Chat:Broadcast("[WPB] Could not synchronize waypoints: "..tostring(e), Color(255, 0, 0))
    return
  end

  file:write(WPUtils.ToLua(self.waypoints))

  file:close()
end

nwp = NamedWP()