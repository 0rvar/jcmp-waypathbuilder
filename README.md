# JC2-MP Waypath Builder v0.1
![Screenshot](https://raw.github.com/awestroke/jcmp-waypathbuilder/master/screenshot.png "Screenshot of Waypath Builder in action")

A Just Cause 2: MP development tool for creating and exporting series of waypoints. 

Use to:
* Create racing tracks
* Create spawn locations for your game mode
* Create teleport positions
* Find positions for other purposes

## Usage

### Local numbered waypoint sets - Creating waypoints in bulk
**target** is the waypoint closest to your crosshair. It will be highlighted in green.
* ```/wpbs add``` or ```<NumPadPlus>```: Add a waypoint to your set
* ```/wpbs del``` or ```<NumPadMinus>```: Remove target from set
* ```/wpbs save [prefix]``` or ```/wpb savejson [prefix]```: Save set as json
* ```/wpbs savelua [prefix]```: Save set as a lua table of Vector3 points
* ```/wpbs clear```: Clear all waypoints
* ```/wpbs reorder +``` or ```<NumPadMultiply>```: Reorder target (+1)
* ```/wpbs reorder -``` or ```<NumPadDivide>```: Reorder target (-1)
* ```/wpbs reorder <n>```: Reorder target (=n)

Files are saved in exports/ with a timestamped filename.
If a prefix is supplied, the filename is prefixed with it, making it easier to browse through your saves.

### Named waypoints
You can add, remove and teleport to named waypoints. They are automatically exported and synchronized between all players.
* ```/wpb add <name>```: Add named waypoint
* ```/wpb update <name>```: Update named waypoint
* ```/wpb remove <name>```: Remove named waypoint
* ```/wpb tp <name>```: Teleport to named waypoint
The named waypoints can be found in export/named_waypoints.lua (and .json)

## Installing
```git clone``` the repository in the scripts folder of your server. Use only on a localhost private server, as there is no access check for saving waypoints on the server. 

See the [JC-MP Server documentation](http://wiki.jc-mp.com/Server) for how to use scripts. 

This script needs the [help script](https://github.com/jc2mp/help).

Use ```git pull``` in scripts/jcmp-waypathbuilder to upgrade.

## Reporting bugs
If you encounter a bug, please submit an issue with as much information as you can provide.

## Changelog
**0.1**
* Added named synchronized waypoints with database persistence and automatic export.
* Complete command overhaul
* Added help via the [help script](https://github.com/jc2mp/help)

**0.0.3**
* The target waypoint is now selected by aiming

**0.0.2**
* Added waypoints to minimap
* Added option to export as lua

**0.0.1**
* Initial commit

## TODO
* Better display of waypoints
* Teleport to waypoints in set


## Contributing
* All improvements are very welcome
* Test everything before you submit a pull request
* Adapt to the indentation used
