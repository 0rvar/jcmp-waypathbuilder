# JC2-MP Waypath Builder v0.0.2
![Screenshot](https://raw.github.com/awestroke/jcmp-waypathbuilder/master/screenshot.png "Screenshot of Waypath Builder in action")

A Just Cause 2: MP development tool for creating and exporting series of waypoints. 

Use to:
* Create racing tracks
* Create spawn locations for your game mode
* Create teleport positions
* Find positions for other purposes

## Usage
**target** is the closest waypoint. It will be highlighted in green.
* ```/wpb add``` or ```<NumPadPlus>```: Add a waypoint
* ```/wpb del``` or ```<NumPadMinus>```: Remove target
* ```/wpb save [prefix]``` or ```/wpb savejson [prefix]```: Save waypoints as json
* ```/wpb savelua [prefix]```: Save waypoints as a lua table of Vector3 points
* ```/wpb clear```: Clear all waypoints
* ```/wpb move +``` or ```<NumPadMultiply>```: Reorder target (+1)
* ```/wpb move -``` or ```<NumPadDivide>```: Reorder target (-1)
* ```/wpb move <n>```: Reorder target (=n)

Files are saved in the Waypath Builder script folder. 
If a prefix is supplied, the file name is prefixed with it, making it easier to browse through your saves.

## Installing
```git clone``` the repository in the scripts folder of your server. Use only on a localhost private server, as there is no access check for saving waypoints on the server. 

See the [JC-MP Server documentation](http://wiki.jc-mp.com/Server) for how to use scripts. 

Use ```git pull``` in scripts/jcmp-waypathbuilder to upgrade.

## Reporting bugs
If you encounter a bug, please submit an issue with as much information as you can provide.

## Changelog
**0.0.2**
* Added waypoints to minimap
* Added option to export as lua

**0.0.1**
* Initial commit

## TODO
* Select target waypoint by aiming
* Better display of waypoints
* Load waypoints with ```/wpb load <partialFileName>```

## Contributing
* All improvements are very welcome
* Test everything before you submit a pull request
* Adapt to the indentation used
