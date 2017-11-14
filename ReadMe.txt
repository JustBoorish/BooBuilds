*** How to install ***

Unpack the BooBuilds directory into \Data\Gui\Custom\Flash\ located in the root of your The Secret World directory, so it looks like this:

\Data\Gui\Custom\Flash\BooBuilds\BooBuilds.swf
\Data\Gui\Custom\Flash\BooBuilds\CharPrefs.xml
\Data\Gui\Custom\Flash\BooBuilds\Modules.xml
\Data\Gui\Custom\Flash\BooBuilds\LICENSE.txt
\Data\Gui\Custom\Flash\BooBuilds\ReadMe.txt

PLEASE NOTE: Make sure you restart your client after installing this add-on. Always restart your client when adding XML files as these only get read on load.

ALSO: Do not have an old version of BooBuilds anywhere in the \Data\Gui\Custom\Flash\ folder.  It confuses SWL and the addon will not load.  Either delete the old version or move it outside the \Data\Gui\Custom\Flash\ folder.

*** How to uninstall ***

Delete the BooBuilds directory from \Data\Gui\Custom\Flash\

*** Help web page ***

https://tswact.wordpress.com/boobuilds/


Change Log

Version 2.2
Added support for anima assignment in saved builds
Fixed bug where a rare talisman was being loaded instead of an epic talisman with the same name
Changed full outfit loading to always equip the underlying outfit items 1st to allow glow effects to come through the outfit
Fixed bug where you could not clear an icon from the favourites bar
Fixed the Tank, DPS and Heals icons on the favourite bars to change background and not be offset

Version 2.1
Move to SWL specific curse site

Version 2.0.1
Fixed bug where weapon temporarily disappeared from your bags! (reloadui to fix it)

Version 2.0
Fix bug in outfits causing certain items not to load
Place unloaded weapons in same bag slot as new weapons when loading a build
Fix weapon bag placement in additional inventory bags
Add a use GearManager build option to utilise the in-game GearManager
Add a new favourites bar to quickly choose your favourite builds or outfits

Version 1.9
Make build and outfit selector display upwards if icon on lower part of screen
Fix help button to display on the correct page
Fix outfit chat command loading
Make quick build update remember the checkboxes set for the build
Change outfits to use the DressingRoom api to fix male on female issues

Version 1.8
Added new quick build functionality
Added weapon skins to outfits
Override weapon swap key to switch between last 2 builds
Ignore skills on cooldown if they are in the same place in the new build
Fix crash when a build or outfit group had more than 25 entries

Version 1.7
Add a pet to outfits
Add new Manage duplicate clothing feature

Version 1.6
Complete rewrite of the inventory throttle code
Fix issue with male clothing being applied to female characters
Fix weapon visibility for outfits
Add a sprint to outfits

Version 1.5
Initial support for switching outfits
Added Backup and restore features
Added Change group ability
Added restore from Fashionista
Added option to dismount before loading build
Added more throttle settings

Version 1.4
Made builds include the weapon hidden status
Stopped builds from loading when a skill has an active cooldown
Continue loading a build if one talisman fails to load

Version 1.3
Fixed bug in chat command loading

Version 1.2
Added loading builds from the chat command line
Added talisman switching
Put in throttle for weapon and talisman switch speed
Fixed bug where weapons with zero xp were not switching
Added the help page
Made weapon and talisman switching optional

Version 1.1
Added support for switching weapons
Fixed a bug when switching builds with basic abilities in different places

Version 1.0
Initial release supporting skills and passives only
