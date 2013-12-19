class('WPB')

function WPB:__init()
  self.wpset = WPSet()
  self.namedwaypoints = NamedWP()
  Events:Subscribe("KeyDown", self, self.KeyHandler)
  Events:Subscribe("LocalPlayerChat", self, self.ChatCommand)
  Events:Subscribe("ModulesLoad", self, self.ModulesLoad)
  Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
end

function WPB:KeyHandler(args)
  if args.key == 107 then -- Numpad Plus
    self.wpset:Add()
  elseif args.key == 109 then -- Numpad Minus
    self.wpset:Remove()
  elseif args.key == 106 then -- Numpad Mult
    self.wpset:Nudge(-1)
  elseif args.key == 111 then -- Numpad Divide
    self.wpset:Nudge(1)
  end
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

  if cmd_name == "wpbs" then
    local cmd = cmd_args[1]
    table.remove( cmd_args, 1 )
    self.wpset:HandleCommand(cmd, cmd_args)
    return false
  elseif cmd_name == "wpb" then
    local cmd = cmd_args[1]
    table.remove( cmd_args, 1 )
    self.namedwaypoints:HandleCommand(cmd, cmd_args)
    return false
  end
 
  return true
end

function WPB:Print(arg)
  Chat:Print("[WPB] "..tostring(arg), sharedSettings.chatColor)
end

function WPB:ModulesLoad()
  Events:FireRegisteredEvent( "HelpAddItem", {
    name = "Waypath Builder",
    text = [[
You can easily build sets of waypoints:
* /wpbs add or <NumPadPlus> - Add a waypoint to your set
* /wpbs del or <NumPadMinus> - Remove target from set
* /wpbs save [prefix] or /wpb savejson [prefix] - Save set as json
* /wpbs savelua [prefix] - Save set as a lua table of Vector3 points
* /wpbs clear - Clear all waypoints
* /wpbs reorder + or <NumPadMultiply> - Reorder target (+1)
* /wpbs reorder - or <NumPadDivide> - Reorder target (-1)
* /wpbs reorder <n> - Reorder target (=n)
Files are saved in <script_folder>/exports/ with a timestamped filename, with optional prefix.

You can add, remove and teleport to named waypoints.
They are automatically exported and synchronized.
* /wpb add <name> - Add named waypoint
* /wpb update <name> - Update named waypoint
* /wpb remove <name> - Remove named waypoint
* /wpb tp <name> - Teleport to named waypoint
The named waypoints can be found in export/named_waypoints.lua. 
    ]]
  })
end

function WPB:ModuleUnload()
  Events:FireRegisteredEvent( "HelpRemoveItem",{
    name = "Waypath Builder"
  })
end

Events:Subscribe("ModuleLoad", function()
  local wpb = WPB()
end)

