//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Log;
import com.GameInterface.Input;
import com.Utils.Archive;
import com.Utils.StringUtils;
import com.boobuilds.BIcon;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildList;
import com.boobuilds.BuildSelector;
import com.boobuilds.Controller;
import com.boobuilds.Favourite;
import com.boobuilds.FavouriteBar;
import com.boobuilds.FavouriteTab;
import com.boobuilds.Localisation;
import com.boobuilds.OptionsTab;
import com.boobuilds.Outfit;
import com.boobuilds.OutfitList;
import com.boobuilds.OutfitSelector;
import com.boobuilds.QuickBuildList;
import com.boobuilds.QuickSwitchIcons;
import com.boobuilds.Settings;
import com.boobuildscommon.Colours;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.IconButton;
import com.boobuildscommon.InfoWindow;
import com.boobuildscommon.Proxy;
import com.boobuildscommon.TabWindow;
import mx.utils.Delegate;

/**
 * There is no copyright on this code
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * Author: Boorish
 */
class com.boobuilds.Controller extends MovieClip
{
	public static var VERSION = "2.3";
	public static var SKILL_ID:String = "SkillId";
	public static var AUGMENT_ID:String = "AugmentId";
	public static var PASSIVE_ID:String = "PassiveId";
	public static var GEAR_ITEM:String = "GearItem";
	public static var GROUP_PREFIX:String = "GROUP";
	public static var GROUP_NAME:String = "Name";
	public static var GROUP_PARENT:String = "Parent";
	public static var GROUP_POSITION:String = "Position";
	public static var AUXILLIARY_SLOT_ACHIEVEMENT:Number = 5437;
	public static var AUGMENT_SLOT_ACHIEVEMENT:Number = 6277;
	public static var AEGIS_SLOT_ACHIEVEMENT:Number = 6817;
	public static var MAX_BUTTONS:Number = 7;
	public static var MAX_TABS:Number = 8;
	public static var MAX_GROUPS:Number = 50;
	public static var MAX_BUILDS:Number = 300;
	public static var MAX_OUTFITS:Number = 300;
	public static var MAX_FAVOURITE_BARS:Number = 2;
	public static var MAX_FAVOURITE_BUTTONS:Number = 16;
	
	private static var m_instance:Controller = null;
	
	private var m_debug:DebugWindow = null;
	private var m_info:InfoWindow = null;
	private var m_icon:BIcon;
	private var m_mc:MovieClip;
	private var m_defaults:Object;
	private var m_settings:Object;
	private var m_settingsPrefix:String = "BooBuilds";
	private var m_clientCharacter:Character;
	private var m_characterName:String;
	private var m_buttonBar:MovieClip;
	private var m_yBottom:Number;
	private var m_configWindow:TabWindow;
	private var m_optionsTab:OptionsTab;
	private var m_buildList:BuildList;
	private var m_outfitList:OutfitList;
	private var m_quickBuildList:QuickBuildList;
	private var m_favouritesTab:FavouriteTab;
	private var m_buildSelectorWindow:BuildSelector;
	private var m_outfitSelectorWindow:OutfitSelector;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_quickBuilds:Object;
	private var m_quickBuildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_redrawInterval:Number;
	private var m_redrawCount:Number;
	private var m_loadBuildDV:DistributedValue;
	private var m_loadQuickBuildDV:DistributedValue;
	private var m_loadOutfitDV:DistributedValue;
	private var m_quickSwitchIcons:QuickSwitchIcons;
	private var m_favouriteIcons:Array;
	private var m_favourites:Array;
	
	//On Load
	function onLoad():Void
	{
		m_instance = this;
		Settings.SetVersion(VERSION);
		
		m_mc = this;
		m_info = InfoWindow.CreateInstance(m_mc);
		
		m_clientCharacter = Character.GetClientCharacter();
		
		if (m_debug == null)
		{
			if (m_clientCharacter != null && (m_clientCharacter.GetName() == "Boorish" || m_clientCharacter.GetName() == "Boor" || m_clientCharacter.GetName() == "BoorGirl"))
			{
				m_debug = DebugWindow.GetInstance(m_mc, DebugWindow.Debug, "BooBuildsDebug");
			}
		}
		DebugWindow.Log(DebugWindow.Info, "BooBuilds Loaded");
		_root["boobuilds\\boobuilds"].OnModuleActivated = Delegate.create(this, OnModuleActivated);
		_root["boobuilds\\boobuilds"].OnModuleDeactivated = Delegate.create(this, OnModuleDeactivated);
		
		m_mc._x = 0;
		m_mc._y = 0;
		
		m_redrawCount = 0;
		m_redrawInterval = 0;

		m_characterName = null;
		SetDefaults();
		
		Localisation.SetLocalisation();
		
		m_loadBuildDV = DistributedValue.Create("BooBuilds_LoadBuild");
		m_loadBuildDV.SetValue("");
		m_loadQuickBuildDV = DistributedValue.Create("BooBuilds_LoadQuickBuild");
		m_loadQuickBuildDV.SetValue("");
		m_loadOutfitDV = DistributedValue.Create("BooBuilds_LoadOutfit");
		m_loadOutfitDV.SetValue("");
	}
	
	function OnModuleActivated(config:Archive):Void
	{
		Settings.SetVersion(VERSION);
		Settings.SetArchive(config);
		
		m_loadBuildDV.SignalChanged.Connect(LoadBuildCmd, this);
		m_loadQuickBuildDV.SignalChanged.Connect(LoadQuickBuildCmd, this);
		m_loadOutfitDV.SignalChanged.Connect(LoadOutfitCmd, this);
		
		if (Character.GetClientCharacter().GetName() != m_characterName)
		{
			DebugWindow.Log(DebugWindow.Debug, "BooBuilds OnModuleActivated"); // + config.toString());
			if (m_configWindow != null)
			{
				m_configWindow.SetVisible(false);
				m_configWindow.Unload();
			}
			
			m_settings = Settings.Load(m_settingsPrefix, m_defaults);
			OptionsTab.ApplyOptions(m_settings, null);
			LoadBuildGroups();
			LoadBuilds();
			SetQuickBuildGroups();
			LoadQuickBuilds();
			LoadOutfitGroups();
			LoadOutfits();
			LoadFavourites();
			Build.SetCurrentBuildID(m_settings[Settings.CURRENT_BUILD]);
			Build.SetCurrentToggleID(Settings.GetCurrentToggleID(m_settings));
			Build.SetPrevToggleID(Settings.GetPrevToggleID(m_settings));
			Outfit.SetCurrentOutfitID(m_settings[Settings.CURRENT_OUTFIT]);
			
			if (m_buildGroups.length == 0)
			{
				SetDefaultBuildGroups();
			}
			
			if (m_outfitGroups.length == 0)
			{
				SetDefaultOutfitGroups();
			}
			
			m_clientCharacter = Character.GetClientCharacter();
			m_characterName = m_clientCharacter.GetName();
			DebugWindow.Log(DebugWindow.Info, "BooBuilds OnModuleActivated: connect " + m_characterName);

			m_icon = new BIcon(m_mc, _root["boobuilds\\boobuilds"].BooBuildsIcon, VERSION, m_settings, Delegate.create(this, ToggleBuildSelectorVisible), Delegate.create(this, IconRightClick), Delegate.create(this, IconShiftLeftClick), Delegate.create(this, ToggleDebugVisible), m_settings[BIcon.ICON_X], m_settings[BIcon.ICON_Y]);
			
			SetQuickSwitchIcons(false);
			SetFavouriteIcons();
			
			FeatInterface.BuildFeatList();
		}
		
		OverwriteSwapKey(Settings.GetOverrideKey(m_settings));
	}
		
	function OnModuleDeactivated():Archive
	{
		SaveSettings();
		m_loadBuildDV.SignalChanged.Disconnect(LoadBuildCmd, this);
		m_loadQuickBuildDV.SignalChanged.Disconnect(LoadQuickBuildCmd, this);
		m_loadOutfitDV.SignalChanged.Disconnect(LoadOutfitCmd, this);
		OverwriteSwapKey(false);
		var ret:Archive = Settings.GetArchive();
		
		//DebugWindow.Log("BooBuilds OnModuleDeactivated: " + ret.toString());
		return ret;
	}
	
	private function SetDefaults():Void
	{
		m_defaults = new Object();
		m_defaults[Settings.X] = 650;
		m_defaults[Settings.Y] = 600;
		m_defaults[BIcon.ICON_X] = -1;
		m_defaults[BIcon.ICON_Y] = -1;
		m_defaults[OptionsTab.INVENTORY_THROTTLE] = 0;
		m_defaults[OptionsTab.DISMOUNT_PRELOAD] = 0;
		m_defaults[Settings.CURRENT_BUILD] = "";
		m_defaults[Settings.CURRENT_OUTFIT] = "";
		m_defaults[QuickSwitchIcons.X] = -1;
		m_defaults[QuickSwitchIcons.Y] = -1;
		
		for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
		{
			m_defaults[FavouriteBar.X + indx] = 100;
			m_defaults[FavouriteBar.Y + indx] = 100 * (indx + 1);
			Settings.SetFavouriteIconsPerRow(m_defaults, indx, MAX_BUTTONS);
			if (indx == 0)
			{
				Settings.SetFavouriteBarEnabled(m_defaults, indx, true);
			}
			else
			{
				Settings.SetFavouriteBarEnabled(m_defaults, indx, false);
			}
		}
		
		Settings.SetOverrideKey(m_defaults, true);
		Settings.SetPrevToggleID(m_defaults, "");
		Settings.SetRightClickOutfit(m_defaults, false);
	}
	
	private function SetDefaultBuildGroups():Void
	{
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Solo", Colours.PURPLE));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "DPS", Colours.RED));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Heals", Colours.GREEN));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Tank", Colours.BLUE));
	}
	
	private function SetDefaultOutfitGroups():Void
	{
		m_outfitGroups.push(new BuildGroup(BuildGroup.GetNextID(m_outfitGroups), "Solo", Colours.PURPLE));
	}
	
	private function SaveBuildGroups():Void
	{
		var archive:Archive = Settings.GetArchive();
		var groupNumber:Number = 1;
		for (var indx:Number = 0; indx < m_buildGroups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_buildGroups[indx];
			if (thisGroup != null)
			{
				thisGroup.Save(Build.GROUP_PREFIX, archive, groupNumber);
				++groupNumber;
			}
		}
		
		for (var indx:Number = groupNumber; indx <= MAX_GROUPS; ++indx)
		{
			BuildGroup.ClearArchive(Build.GROUP_PREFIX, archive, indx);
		}
	}
	
	private function LoadBuildGroups():Void
	{
		m_buildGroups = new Array();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_GROUPS; ++indx)
		{
			var thisGroup:BuildGroup = BuildGroup.FromArchive(Build.GROUP_PREFIX, archive, indx + 1);
			if (thisGroup != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded build group " + thisGroup.GetName());
				m_buildGroups.push(thisGroup);
			}
		}
	}
	
	private function SetQuickBuildGroups():Void
	{
		m_quickBuildGroups = new Array();
		m_quickBuildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_quickBuildGroups), "DPS", Colours.RED));
		m_quickBuildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_quickBuildGroups), "Heals", Colours.GREEN));
		m_quickBuildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_quickBuildGroups), "Tank", Colours.BLUE));
	}
	
	private function SaveBuilds():Void
	{
		var archive:Archive = Settings.GetArchive();
		var buildNumber:Number = 1;
		for (var indx:String in m_builds)
		{
			var thisBuild:Build = m_builds[indx];
			if (thisBuild != null)
			{
				thisBuild.Save(Build.BUILD_PREFIX, archive, buildNumber);
				++buildNumber;
			}
		}
		
		for (var indx:Number = buildNumber; indx <= MAX_BUILDS; ++indx)
		{
			Build.ClearArchive(Build.BUILD_PREFIX, archive, indx);
		}
	}
	
	private function LoadBuilds():Void
	{
		m_builds = new Object();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_BUILDS; ++indx)
		{
			var thisBuild:Build = Build.FromArchive(Build.BUILD_PREFIX, indx + 1, archive);
			if (thisBuild != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded build " + thisBuild.GetName() + " ID " + thisBuild.GetID() + " Group " + thisBuild.GetGroup() + " Order " + thisBuild.GetOrder());
				
				if (FindGroupWithID(m_buildGroups, thisBuild.GetGroup()) != null)
				{
					m_builds[thisBuild.GetID()] = thisBuild;
				}
				else
				{
					Build.ClearArchive(Build.BUILD_PREFIX, archive, indx + 1);
				}
			}
		}
	}
	
	private function SaveQuickBuilds():Void
	{
		var archive:Archive = Settings.GetArchive();
		var buildNumber:Number = 1;
		for (var indx:String in m_quickBuilds)
		{
			var thisBuild:Build = m_quickBuilds[indx];
			if (thisBuild != null)
			{
				thisBuild.Save(Build.QUICK_BUILD_PREFIX, archive, buildNumber);
				++buildNumber;
			}
		}
		
		for (var indx:Number = buildNumber; indx <= MAX_BUILDS; ++indx)
		{
			Build.ClearArchive(Build.QUICK_BUILD_PREFIX, archive, indx);
		}
	}
	
	private function LoadQuickBuilds():Void
	{
		m_quickBuilds = new Object();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_BUILDS; ++indx)
		{
			var thisBuild:Build = Build.FromArchive(Build.QUICK_BUILD_PREFIX, indx + 1, archive);
			if (thisBuild != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded build " + thisBuild.GetName() + " ID " + thisBuild.GetID() + " Group " + thisBuild.GetGroup() + " Order " + thisBuild.GetOrder());
				
				if (FindGroupWithID(m_quickBuildGroups, thisBuild.GetGroup()) != null)
				{
					m_quickBuilds[thisBuild.GetID()] = thisBuild;
				}
				else
				{
					Build.ClearArchive(Build.QUICK_BUILD_PREFIX, archive, indx + 1);
				}
			}
		}
	}
	
	private function SaveFavourites():Void
	{
		var archive:Archive = Settings.GetArchive();
		var favNumber:Number = 0;
		for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
		{
			var favourites:Array = m_favourites[indx];
			var favPrefix:String = Favourite.FAVOURITE + "_" + indx;
			for (var i:Number = 0; i < MAX_FAVOURITE_BUTTONS; ++i)
			{
				Favourite.ClearArchive(favPrefix, archive, i);
				
				var thisFav:Favourite = favourites[i];
				if (thisFav != null)
				{
					thisFav.Save(favPrefix, archive, i);
				}
			}
		}
	}
	
	private function LoadFavourites():Void
	{
		m_favourites = new Array();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
		{
			var favourites:Array = new Array();
			var favPrefix:String = Favourite.FAVOURITE + "_" + indx;
			for (var i:Number = 0; i < MAX_FAVOURITE_BUTTONS; ++i)
			{
				var thisFav:Favourite = Favourite.FromArchive(favPrefix, archive, i);
				favourites.push(thisFav);
			}
			
			m_favourites.push(favourites);
		}
	}
	
	private function UpdateFavouriteNames():Void
	{
		for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
		{
			var favourites:Array = m_favourites[indx];
			if (favourites != null)
			{
				for (var i:Number = 0; i < MAX_FAVOURITE_BUTTONS; ++i)
				{
					var thisFav:Favourite = favourites[i];
					if (thisFav != null)
					{
						var deleteFavourite:Boolean = false;
						if (thisFav.GetType() == Favourite.BUILD)
						{
							var thisBuild:Build = m_builds[thisFav.GetID()];
							if (thisBuild == null)
							{
								deleteFavourite = true;
							}
							else
							{
								thisFav.SetName(thisBuild.GetName());
							}
						}
						else if (thisFav.GetType() == Favourite.OUTFIT)
						{
							var thisOutfit:Outfit = m_outfits[thisFav.GetID()];
							if (thisOutfit == null)
							{
								deleteFavourite = true;
							}
							else
							{
								thisFav.SetName(thisOutfit.GetName());
							}
						}
						else if (thisFav.GetType() == Favourite.BUILD)
						{
							var thisBuild:Build = m_quickBuilds[thisFav.GetID()];
							if (thisBuild == null)
							{
								deleteFavourite = true;
							}
							else
							{
								thisFav.SetName(thisBuild.GetName());
							}
						}
						
						if (deleteFavourite == true)
						{
							favourites[i] = null;
						}
					}
				}
			}
		}
	}
	
	private function SaveOutfitGroups():Void
	{
		var archive:Archive = Settings.GetArchive();
		var groupNumber:Number = 1;
		for (var indx:Number = 0; indx < m_outfitGroups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_outfitGroups[indx];
			if (thisGroup != null)
			{
				thisGroup.Save(Outfit.GROUP_PREFIX, archive, groupNumber);
				++groupNumber;
			}
		}
		
		for (var indx:Number = groupNumber; indx <= MAX_GROUPS; ++indx)
		{
			BuildGroup.ClearArchive(Outfit.GROUP_PREFIX, archive, indx);
		}
	}
	
	private function LoadOutfitGroups():Void
	{
		m_outfitGroups = new Array();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_GROUPS; ++indx)
		{
			var thisGroup:BuildGroup = BuildGroup.FromArchive(Outfit.GROUP_PREFIX, archive, indx + 1);
			if (thisGroup != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded outfit group " + thisGroup.GetName());
				m_outfitGroups.push(thisGroup);
			}
		}
	}
	
	private function SaveOutfits():Void
	{
		var archive:Archive = Settings.GetArchive();
		var outfitNumber:Number = 1;
		for (var indx:String in m_outfits)
		{
			var thisOutfit:Outfit = m_outfits[indx];
			if (thisOutfit != null)
			{
				thisOutfit.Save(archive, outfitNumber);
				++outfitNumber;
			}
		}
		
		for (var indx:Number = outfitNumber; indx <= MAX_OUTFITS; ++indx)
		{
			Outfit.ClearArchive(archive, indx);
		}
	}
	
	private function LoadOutfits():Void
	{
		m_outfits = new Object();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_OUTFITS; ++indx)
		{
			var thisOutfit:Outfit = Outfit.FromArchive(indx + 1, archive);
			if (thisOutfit != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded outfit " + thisOutfit.GetName() + " ID " + thisOutfit.GetID() + " Group " + thisOutfit.GetGroup() + " Order " + thisOutfit.GetOrder());
				
				if (FindGroupWithID(m_outfitGroups, thisOutfit.GetGroup()) != null)
				{
					m_outfits[thisOutfit.GetID()] = thisOutfit;
				}
				else
				{
					Outfit.ClearArchive(archive, indx + 1);
				}
			}
		}
	}
	
	private function FindGroupWithID(groups:Array, groupID:String):BuildGroup
	{
		for (var indx:Number = 0; indx < groups.length; ++indx)
		{
			var thisGroup:BuildGroup = groups[indx];
			if (thisGroup != null && thisGroup.GetID() == groupID)
			{
				return thisGroup;
			}
		}
		
		return null;
	}
	
	private function SaveSettings():Void
	{
		if (m_configWindow != null)
		{
			var pt:Object = m_configWindow.GetCoords()
			m_settings[Settings.X] = pt.x;
			m_settings[Settings.Y] = pt.y;
		}
		
		if (m_optionsTab != null)
		{
			m_optionsTab.Save();
		}
		
		var pt:Object = m_icon.GetCoords();
		m_settings[BIcon.ICON_X] = pt.x;
		m_settings[BIcon.ICON_Y] = pt.y;
		m_settings[Settings.CURRENT_BUILD] = Build.GetCurrentBuildID();
		m_settings[Settings.CURRENT_OUTFIT] = Outfit.GetCurrentOutfitID();
		Settings.SetCurrentToggleID(m_settings, Build.GetCurrentToggleID());
		Settings.SetPrevToggleID(m_settings, Build.GetPrevToggleID());
		Settings.Save(m_settingsPrefix, m_settings, m_defaults);
		SaveBuildGroups();
		SaveBuilds();
		SaveQuickBuilds();
		SaveOutfitGroups();
		SaveOutfits();
		SaveFavourites();
	}
	
	private function ConfigClosed():Void
	{
		SaveSettings();
		SetQuickSwitchIcons(false);
		SetFavouriteIcons();
		OverwriteSwapKey(Settings.GetOverrideKey(m_settings));
	}
	
	private function SetQuickSwitchIcons(dragging:Boolean):Void
	{
		var x:Number = m_settings[QuickSwitchIcons.X];
		var y:Number = m_settings[QuickSwitchIcons.Y];
		
		if (m_quickSwitchIcons != null)
		{
			if (dragging == true)
			{
				var pt:Object = m_quickSwitchIcons.GetPostion();
				x = pt.x;
				y = pt.y;
			}
			
			m_quickSwitchIcons.Unload();
		}
		
		if (dragging == true)
		{
			m_quickSwitchIcons = new QuickSwitchIcons("QuickSwitchIcons", m_mc, x, y, dragging, m_quickBuilds, Delegate.create(this, QuickSwitchDragStopped));
		}
		else
		{
			m_quickSwitchIcons = new QuickSwitchIcons("QuickSwitchIcons", m_mc, x, y, dragging, m_quickBuilds, Delegate.create(this, BuildSelected));
		}

		m_quickSwitchIcons.Show();
	}
	
	private function QuickSwitchDragStopped(x:Number, y:Number):Void
	{
		m_settings[QuickSwitchIcons.X] = x;
		m_settings[QuickSwitchIcons.Y] = y;
		SetQuickSwitchIcons(false);
	}
	
	private function SetFavouriteIcons():Void
	{
		if (m_favouriteIcons != null)
		{
			for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
			{
				if (m_favouriteIcons[indx] != null)
				{
					m_favouriteIcons[indx].Unload();
				}
			}
		}
		
		UpdateFavouriteNames();
		
		m_favouriteIcons = new Array();
		for (var indx:Number = 0; indx < MAX_FAVOURITE_BARS; ++indx)
		{
			var x:Number = m_settings[FavouriteBar.X + indx];
			var y:Number = m_settings[FavouriteBar.Y + indx];
			var iconsPerRow:Number = Settings.GetFavouriteIconsPerRow(m_settings, indx);
			var enabled:Boolean = Settings.GetFavouriteBarEnabled(m_settings, indx);
			var favBar:FavouriteBar = new FavouriteBar("FavouritesBar" + indx, m_mc, x, y, 18, MAX_FAVOURITE_BUTTONS, iconsPerRow, false, m_favourites[indx], Delegate.create(this, FavouritePressed));
			m_favouriteIcons.push(favBar);
			favBar.SetVisible(enabled);
		}
	}
	
	public function FavouriteDragStart(barNumber:Number):Void
	{
		m_favouriteIcons[barNumber].EnableDrag(Proxy.createTwoArgs(this, FavouriteDragStopped, barNumber));
	}
	
	private function FavouriteDragStopped(x:Number, y:Number, barNumber:Number):Void
	{
		m_settings[FavouriteBar.X + barNumber] = x;
		m_settings[FavouriteBar.Y + barNumber] = y;
		m_favouriteIcons[barNumber].DisableDrag();
		
		var enabled:Boolean = Settings.GetFavouriteBarEnabled(m_settings, barNumber);
		m_favouriteIcons[barNumber].SetVisible(enabled);
	}
	
	private function FavouritePressed(indx:Number, favourite:Favourite):Void
	{
		if (favourite != null)
		{
			if (favourite.GetType() == Favourite.BUILD)
			{
				var thisBuild:Build = m_builds[favourite.GetID()];
				if (thisBuild != null)
				{
					thisBuild.Apply(m_outfits);
				}
			}
			else if (favourite.GetType() == Favourite.OUTFIT)
			{
				var thisOutfit:Outfit = m_outfits[favourite.GetID()];
				if (thisOutfit != null)
				{
					thisOutfit.Apply();
				}
			}
			else if (favourite.GetType() == Favourite.QUICK)
			{
				var thisBuild:Build = m_quickBuilds[favourite.GetID()];
				if (thisBuild != null)
				{
					thisBuild.Apply(m_outfits);
				}
			}
		}
	}
	
	private function ToggleBuildSelectorVisible():Void
	{
		if (m_configWindow != null && m_configWindow.GetVisible() == true)
		{
			ToggleConfigVisible();
		}
		
		if (m_outfitSelectorWindow != null && m_outfitSelectorWindow.GetVisible() == true)
		{
			ToggleOutfitSelectorVisible();
		}		
		
		var show:Boolean = true;
		if (m_buildSelectorWindow != null)
		{
			if (m_buildSelectorWindow.GetVisible() == true)
			{
				show = false;
			}
			
			m_buildSelectorWindow.Unload();
			m_buildSelectorWindow = null;
		}
		
		if (show == true)
		{
			m_buildSelectorWindow = new BuildSelector(m_mc, "Build Selector", m_buildGroups, m_builds, Delegate.create(this, BuildSelected));
			var icon:MovieClip = m_icon.GetIcon();
			if (_root._xmouse >= icon._x && _root._xmouse <= icon._x + icon._width &&
				_root._ymouse >= icon._y && _root._ymouse <= icon._y + icon._height)
			{
				m_buildSelectorWindow.Show(icon._x + icon._width / 2, icon._y + icon._height, icon._y);
			}
			else
			{
				m_buildSelectorWindow.Show(_root._xmouse + 5, _root._ymouse + 5, _root._ymouse - 5);
			}
		}
	}
	
	private function BuildSelected(thisBuild:Build):Void
	{
		if (thisBuild != null)
		{
			thisBuild.Apply(m_outfits);
		}
	}
	
	private function ToggleOutfitSelectorVisible():Void
	{
		if (m_configWindow != null && m_configWindow.GetVisible() == true)
		{
			ToggleConfigVisible();
		}
		
		if (m_buildSelectorWindow != null && m_buildSelectorWindow.GetVisible() == true)
		{
			ToggleBuildSelectorVisible();
		}
		
		var show:Boolean = true;
		if (m_outfitSelectorWindow != null)
		{
			if (m_outfitSelectorWindow.GetVisible() == true)
			{
				show = false;
			}
			
			m_outfitSelectorWindow.Unload();
			m_outfitSelectorWindow = null;
		}
		
		if (show == true)
		{
			m_outfitSelectorWindow = new OutfitSelector(m_mc, "Outfit Selector", m_outfitGroups, m_outfits, Delegate.create(this, OutfitSelected));
			var icon:MovieClip = m_icon.GetIcon();
			if (_root._xmouse >= icon._x && _root._xmouse <= icon._x + icon._width &&
				_root._ymouse >= icon._y && _root._ymouse <= icon._y + icon._height)
			{
				m_outfitSelectorWindow.Show(icon._x + icon._width / 2, icon._y + icon._height, icon._y);
			}
			else
			{
				m_outfitSelectorWindow.Show(_root._xmouse + 5, _root._ymouse + 5, _root._ymouse - 5);
			}
		}
	}
	
	private function OutfitSelected(thisOutfit:Outfit):Void
	{
		if (thisOutfit != null)
		{
			thisOutfit.Apply();
		}
	}
	
	private function IconRightClick():Void
	{
		if (Settings.GetRightClickOutfit(m_settings) == true)
		{
			ToggleOutfitSelectorVisible();
		}
		else
		{
			ToggleConfigVisible();
		}
	}
	
	private function IconShiftLeftClick():Void
	{
		if (Settings.GetRightClickOutfit(m_settings) != true)
		{
			ToggleOutfitSelectorVisible();
		}
		else
		{
			ToggleConfigVisible();
		}
	}
	
	private function ToggleConfigVisible():Void
	{
		if (m_buildSelectorWindow != null && m_buildSelectorWindow.GetVisible() == true)
		{
			ToggleBuildSelectorVisible();
		}
		
		if (m_outfitSelectorWindow != null && m_outfitSelectorWindow.GetVisible() == true)
		{
			ToggleOutfitSelectorVisible();
		}		
		
		if (m_configWindow == null)
		{
			FeatInterface.BuildFeatList();
		
			m_buildList = new BuildList("BuildList", m_buildGroups, m_builds, m_settings, m_outfits, m_outfitGroups);
			m_quickBuildList = new QuickBuildList("QuickBuildList", m_quickBuildGroups, m_quickBuilds, m_settings, m_builds, m_buildGroups, m_outfits);
			m_outfitList = new OutfitList("OutfitList", m_outfitGroups, m_outfits, m_settings);
			m_favouritesTab = new FavouriteTab("Faves", m_settings, m_favourites, m_buildGroups, m_builds, m_outfitGroups, m_outfits, m_quickBuildGroups, m_quickBuilds, Delegate.create(this, FavouriteDragStart));
			m_optionsTab = new OptionsTab("Options", m_settings, m_buildGroups, m_builds, m_outfitGroups, m_outfits, m_quickBuildGroups, m_quickBuilds, m_buildList, m_outfitList, m_quickBuildList, Delegate.create(this, DragQuickButtons), Delegate.create(this, ApplyOverrideKey));
			m_configWindow = new TabWindow(m_mc, "BooBuilds", m_settings[Settings.X], m_settings[Settings.Y], 350, IconButton.BUTTON_HEIGHT * Controller.MAX_BUTTONS + 6 * (Controller.MAX_BUTTONS + 1), Delegate.create(this, ConfigClosed), "BooBuildsHelp", "https://tswact.wordpress.com/boobuilds/");
			m_configWindow.AddTab("Builds", m_buildList);
			m_configWindow.AddTab("Outfits", m_outfitList);
			m_configWindow.AddTab("Quick", m_quickBuildList);
			m_configWindow.AddTab("Fav's", m_favouritesTab);
			m_configWindow.AddTab("Options", m_optionsTab);
			m_configWindow.SetVisible(true);
		}
		else
		{
			m_configWindow.SetVisible(!m_configWindow.GetVisible());
		}
		
		if (m_configWindow.GetVisible() != true)
		{
			m_buildList.UnloadDialogs();
			m_outfitList.UnloadDialogs();
			ConfigClosed();
		}
	}
	
	private function ToggleDebugVisible():Void
	{
		DebugWindow.ToggleVisible();
	}	
	
	private function GetPopupHeight(height:Number):Number
	{
		return 12 + (height * MAX_BUTTONS) + ((MAX_BUTTONS - 1) * 3)
	}
	
	private function GetCoords(baseWindow:MovieClip):Object
	{
		var pt:Object = new Object();
		pt.x = 0;
		pt.y = 0;
		if (baseWindow != null)
		{
			baseWindow.localToGlobal(pt);
			m_mc.globalToLocal(pt);
		}
		
		return pt;
	}
	
	private function DragQuickButtons(reset:Boolean):Void
	{
		if (reset == false)
		{
			SetQuickSwitchIcons(true);
		}
		else
		{
			m_settings[QuickSwitchIcons.X] = m_defaults[QuickSwitchIcons.X];
			m_settings[QuickSwitchIcons.Y] = m_defaults[QuickSwitchIcons.Y];
			SetQuickSwitchIcons(false);
		}
	}
	
	private function LoadBuildCmd():Void
	{
		var buildName:String = m_loadBuildDV.GetValue();
		if (buildName != null)
		{
			buildName = StringUtils.Strip(buildName);
		}
		
		if (buildName == null || buildName == "")
		{
			return;
		}

		var buildFound:Boolean = false;
		for (var id:String in m_builds)
		{
			var thisBuild:Build = m_builds[id];
			if (thisBuild != null && thisBuild.GetName() == buildName)
			{
				buildFound = true;
				setTimeout(Delegate.create(this, function() { thisBuild.Apply(this.m_outfits); }), 20);
				break;
			}
		}
		
		if (buildFound == false)
		{
			InfoWindow.LogError("Cannot find build " + buildName);
		}

		m_loadBuildDV.SetValue("");
	}
	
	private function LoadQuickBuildCmd():Void
	{
		var buildName:String = m_loadQuickBuildDV.GetValue();
		if (buildName != null)
		{
			buildName = StringUtils.Strip(buildName);
		}
		
		if (buildName == null || buildName == "")
		{
			return;
		}

		var buildFound:Boolean = false;
		for (var id:String in m_quickBuilds)
		{
			var thisBuild:Build = m_quickBuilds[id];
			if (thisBuild != null && thisBuild.GetName() == buildName)
			{
				buildFound = true;
				setTimeout(Delegate.create(this, function() { thisBuild.Apply(this.m_outfits); }), 20);
				break;
			}
		}
		
		if (buildFound == false)
		{
			InfoWindow.LogError("Cannot find quick build " + buildName);
		}

		m_loadQuickBuildDV.SetValue("");
	}
	
	private function LoadOutfitCmd():Void
	{
		var outfitName:String = m_loadOutfitDV.GetValue();
		if (outfitName != null)
		{
			outfitName = StringUtils.Strip(outfitName);
		}
		
		if (outfitName == null || outfitName == "")
		{
			return;
		}

		var outfitFound:Boolean = false;
		for (var id:String in m_outfits)
		{
			var thisOutfit:Outfit = m_outfits[id];
			if (thisOutfit != null && thisOutfit.GetName() == outfitName)
			{
				outfitFound = true;
				setTimeout(Delegate.create(this, function() { thisOutfit.Apply(); }), 20);
				break;
			}
		}
		
		if (outfitFound == false)
		{
			InfoWindow.LogError("Cannot find outfit " + outfitName);
		}

		m_loadOutfitDV.SetValue("");
	}
	
	private function GetGlobalSize(mc:MovieClip):Object
	{
		var ret:Object = new Object();
		var pt:Object = new Object();
		pt.x = 0;
		pt.y = 0;
		mc.localToGlobal(pt);
		var leftX:Number = pt.x;
		var leftY:Number = pt.y;
		
		pt.x = mc._width;
		pt.y = mc._height;
		mc.localToGlobal(pt);
		
		ret.leftX = leftX;
		ret.leftY = leftY;
		ret.width = mc._width; // pt.x - leftX;
		ret.height = mc._height; // pt.y - leftY;
		return ret;
	}
	
	private function ApplyOverrideKey():Void
	{
		OverwriteSwapKey(Settings.GetOverrideKey(m_settings));
	}
	
	private function OverwriteSwapKey(enabled:Boolean):Void
	{
		var func:String;
		if (enabled == true)
		{
			func = "com.boobuilds.Controller.SwapKeyHandler";
		}
		else
		{
			func = "";
		}
		
		Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_Combat_SwapAlternateWeapons, func, _global.Enums.Hotkey.eHotkeyDown, 0);
	}
	
	private static function SwapKeyHandler(keyCode:Number):Void
	{
		if (m_instance != null)
		{
			m_instance.ToggleBuilds();
		}
	}	

	private function ToggleBuilds()
	{
		var prevID:String = Build.GetPrevToggleID();
		if (prevID != null && prevID.length > 1)
		{
			var builds:Object;
			if (Build.IsQuickBuildID(prevID) == true)
			{
				builds = m_quickBuilds;
			}
			else
			{
				builds = m_builds;
			}
			
			var thisBuild:Build = builds[prevID];
			if (thisBuild != null)
			{
				thisBuild.Apply(m_outfits);
			}
		}
	}
}
