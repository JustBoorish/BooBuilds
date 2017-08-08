//Imports
import com.boobuilds.BIcon;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildList;
import com.boobuilds.BuildSelector;
import com.boobuilds.Controller;
import com.boobuilds.DebugWindow;
import com.boobuilds.InfoWindow;
import com.boobuilds.GearItem;
import com.boobuilds.OptionsTab;
import com.boobuilds.Outfit;
import com.boobuilds.Localisation;
import com.boobuilds.OutfitList;
import com.boobuilds.OutfitSelector;
import com.boobuilds.Settings;
import com.boobuilds.SkillMenu;
import com.boobuilds.TabWindow;
import com.boobuilds.BuildWindow;
import com.boobuilds.PopupMenu;
import com.boobuilds.ScrollPane;
import com.boobuilds.TreeCheck;
import com.boobuilds.TreePanel;
import com.GameInterface.ProjectUtils;
import com.GameInterface.DistributedValue;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Log;
import com.GameInterface.Lore;
import com.Utils.Archive;
import com.Utils.Signal;
import com.Utils.StringUtils;
import mx.utils.Delegate;
import org.sitedaniel.utils.Proxy;

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
	public static var VERSION = "1.6";
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
	public static var MAX_BUILDS:Number = 200;
	public static var MAX_OUTFITS:Number = 200;
	
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
	private var m_buildSelectorWindow:BuildSelector;
	private var m_outfitSelectorWindow:OutfitSelector;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_redrawInterval:Number;
	private var m_redrawCount:Number;
	private var m_loadBuildDV:DistributedValue;
	private var m_loadOutfitDV:DistributedValue;
	
	//On Load
	function onLoad():Void
	{
		Settings.SetVersion(VERSION);
		
		m_mc = this;
		m_info = InfoWindow.CreateInstance(m_mc);
		
		m_clientCharacter = Character.GetClientCharacter();
		
		if (m_debug == null)
		{
			if (m_clientCharacter.GetName() == "Boorish" || m_clientCharacter.GetName() == "Boor" || m_clientCharacter.GetName() == "BoorGirl")
			{
				m_debug = new DebugWindow(m_mc, DebugWindow.Debug);
			}
			else
			{
				m_debug = new DebugWindow(m_mc, DebugWindow.Info);
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
		m_loadOutfitDV = DistributedValue.Create("BooBuilds_LoadOutfit");
		m_loadOutfitDV.SetValue("");
	}
	
	function OnModuleActivated(config:Archive):Void
	{
		Settings.SetVersion(VERSION);
		Settings.SetArchive(config);
		
		m_loadBuildDV.SignalChanged.Connect(LoadBuildCmd, this);
		m_loadOutfitDV.SignalChanged.Connect(LoadOutfitCmd, this);
		
		if (Character.GetClientCharacter().GetName() != m_characterName)
		{
			DebugWindow.Log(DebugWindow.Debug, "BooBuilds OnModuleActivated: " + config.toString());
			if (m_configWindow != null)
			{
				m_configWindow.SetVisible(false);
				m_configWindow.Unload();
			}
			
			m_settings = Settings.Load(m_settingsPrefix, m_defaults);
			OptionsTab.ApplyOptions(m_settings);
			LoadBuildGroups();
			LoadBuilds();
			LoadOutfitGroups();
			LoadOutfits();
			
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

			m_icon = new BIcon(m_mc, _root["boobuilds\\boobuilds"].BooBuildsIcon, VERSION, Delegate.create(this, ToggleBuildSelectorVisible), Delegate.create(this, ToggleConfigVisible), Delegate.create(this, ToggleOutfitSelectorVisible), Delegate.create(this, ToggleDebugVisible), m_settings[BIcon.ICON_X], m_settings[BIcon.ICON_Y]);
			
			FeatInterface.BuildFeatList();
		}
	}
		
	function OnModuleDeactivated():Archive
	{
		SaveSettings();
		m_loadBuildDV.SignalChanged.Disconnect(LoadBuildCmd, this);
		m_loadOutfitDV.SignalChanged.Disconnect(LoadOutfitCmd, this);
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
		m_defaults[OptionsTab.USE_SECOND_DUPLICATE] = 0;
	}
	
	private function SetDefaultBuildGroups():Void
	{
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Solo", BuildGroup.PURPLE));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "DPS", BuildGroup.RED));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Heals", BuildGroup.GREEN));
		m_buildGroups.push(new BuildGroup(BuildGroup.GetNextID(m_buildGroups), "Tank", BuildGroup.BLUE));
	}
	
	private function SetDefaultOutfitGroups():Void
	{
		m_outfitGroups.push(new BuildGroup(BuildGroup.GetNextID(m_outfitGroups), "Solo", BuildGroup.PURPLE));
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
	
	private function SaveBuilds():Void
	{
		var archive:Archive = Settings.GetArchive();
		var buildNumber:Number = 1;
		for (var indx:String in m_builds)
		{
			var thisBuild:Build = m_builds[indx];
			if (thisBuild != null)
			{
				thisBuild.Save(archive, buildNumber);
				++buildNumber;
			}
		}
		
		for (var indx:Number = buildNumber; indx <= MAX_BUILDS; ++indx)
		{
			Build.ClearArchive(archive, indx);
		}
	}
	
	private function LoadBuilds():Void
	{
		m_builds = new Object();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_BUILDS; ++indx)
		{
			var thisBuild:Build = Build.FromArchive(indx + 1, archive);
			if (thisBuild != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Loaded build " + thisBuild.GetName() + " ID " + thisBuild.GetID() + " Group " + thisBuild.GetGroup() + " Order " + thisBuild.GetOrder());
				
				if (FindGroupWithID(m_buildGroups, thisBuild.GetGroup()) != null)
				{
					m_builds[thisBuild.GetID()] = thisBuild;
				}
				else
				{
					Build.ClearArchive(archive, indx + 1);
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
		Settings.Save(m_settingsPrefix, m_settings, m_defaults);
		SaveBuildGroups();
		SaveBuilds();
		SaveOutfitGroups();
		SaveOutfits();
	}
	
	private function ConfigClosed():Void
	{
		SaveSettings();
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
				m_buildSelectorWindow.Show(icon._x + icon._width / 2, icon._y + icon._height);
			}
			else
			{
				m_buildSelectorWindow.Show(_root._xmouse + 5, _root._ymouse + 5);
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
				m_outfitSelectorWindow.Show(icon._x + icon._width / 2, icon._y + icon._height);
			}
			else
			{
				m_outfitSelectorWindow.Show(_root._xmouse + 5, _root._ymouse + 5);
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
			m_outfitList = new OutfitList("OutfitList", m_outfitGroups, m_outfits, m_settings);
			m_optionsTab = new OptionsTab("Options", m_settings, m_buildGroups, m_builds, m_outfitGroups, m_outfits, m_buildList, m_outfitList);
			m_configWindow = new TabWindow(m_mc, "BooBuilds", m_settings[Settings.X], m_settings[Settings.Y], 300, Delegate.create(this, ConfigClosed), "BooBuildsHelp");
			m_configWindow.AddTab("Builds", m_buildList);
			m_configWindow.AddTab("Outfits", m_outfitList);
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
				setTimeout(Delegate.create(this, function() { thisBuild.Apply(this.m_cooldownMonitor, this.m_outfits); }), 20);
				break;
			}
		}
		
		if (buildFound == false)
		{
			InfoWindow.LogError("Cannot find build " + buildName);
		}

		m_loadBuildDV.SetValue("");
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
		for (var id:String in m_builds)
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
}
