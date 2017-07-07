//Imports
import com.boobuilds.BIcon;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildList;
import com.boobuilds.BuildSelector;
import com.boobuilds.ButtonPopup;
import com.boobuilds.Controller;
import com.boobuilds.DebugWindow;
import com.boobuilds.InfoWindow;
import com.boobuilds.GearItem;
import com.boobuilds.CreateTab;
import com.boobuilds.Localisation;
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
import mx.utils.Delegate;
import org.sitedaniel.utils.Proxy;
import org.aswing.ASWingUtils;
import org.aswing.JTextComponent;

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
	
	private var m_version:String = "1.1";
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
	private var m_selectorWindow:BuildSelector;
	private var m_builds:Object;
	private var m_groups:Array;
	private var m_redrawInterval:Number;
	private var m_redrawCount:Number;
	private var m_loadBuildDV:DistributedValue;
	
	//On Load
	function onLoad():Void
	{
		ASWingUtils.setRootMovieClip(this);
		JTextComponent.setDefaultRegainTextFocusEnabled(false);
		Settings.SetVersion(m_version);
		
		m_mc = this;
		m_info = InfoWindow.CreateInstance(m_mc);
		
		m_clientCharacter = Character.GetClientCharacter();
		
		if (m_debug == null)
		{
			if (m_clientCharacter.GetName() == "Boorish" || m_clientCharacter.GetName() == "Marvvin")
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
}
	
	function OnModuleActivated(config:Archive):Void
	{
		Settings.SetVersion(m_version);
		Settings.SetArchive(config);
		
		m_loadBuildDV.SignalChanged.Connect(LoadBuildCmd, this);
		
		if (Character.GetClientCharacter().GetName() != m_characterName)
		{
			DebugWindow.Log(DebugWindow.Debug, "BooBuilds OnModuleActivated: " + config.toString());
			if (m_clientCharacter != null)
			{
				m_clientCharacter.SignalToggleCombat.Disconnect(ToggleCombat, this);
			}
			
			if (m_configWindow != null)
			{
				m_configWindow.SetVisible(false);
				m_configWindow.Unload();
			}
			
			m_settings = Settings.Load(m_settingsPrefix, m_defaults);
			LoadBuildGroups();
			LoadBuilds();
			
			if (m_groups.length == 0)
			{
				SetDefaultGroups();
			}
			
			m_clientCharacter = Character.GetClientCharacter();
			m_characterName = m_clientCharacter.GetName();
			m_clientCharacter.SignalToggleCombat.Connect(ToggleCombat, this);
			DebugWindow.Log(DebugWindow.Info, "BooBuilds OnModuleActivated: connect " + m_characterName);

			m_icon = new BIcon(m_mc, _root["boobuilds\\boobuilds"].BooBuildsIcon, m_version, Delegate.create(this, ToggleSelectorVisible), Delegate.create(this, ToggleConfigVisible), Delegate.create(this, ToggleDebugVisible), m_settings[BIcon.ICON_X], m_settings[BIcon.ICON_Y]);
			
			FeatInterface.BuildFeatList();
		}
	}
		
	function OnModuleDeactivated():Archive
	{
		SaveSettings();
		m_loadBuildDV.SignalChanged.Disconnect(LoadBuildCmd, this);
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
	}
	
	private function SetDefaultGroups():Void
	{
		m_groups.push(new BuildGroup(BuildGroup.GetNextID(m_groups), "Solo", BuildGroup.PURPLE));
		m_groups.push(new BuildGroup(BuildGroup.GetNextID(m_groups), "DPS", BuildGroup.RED));
		m_groups.push(new BuildGroup(BuildGroup.GetNextID(m_groups), "Heals", BuildGroup.GREEN));
		m_groups.push(new BuildGroup(BuildGroup.GetNextID(m_groups), "Tank", BuildGroup.BLUE));
	}
	
	private function SaveBuildGroups():Void
	{
		var archive:Archive = Settings.GetArchive();
		var groupNumber:Number = 1;
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null)
			{
				thisGroup.Save(archive, groupNumber);
				++groupNumber;
			}
		}
		
		for (var indx:Number = groupNumber; indx <= MAX_GROUPS; ++indx)
		{
			BuildGroup.ClearArchive(archive, indx);
		}
	}
	
	private function LoadBuildGroups():Void
	{
		m_groups = new Array();
		var archive:Archive = Settings.GetArchive();
		for (var indx:Number = 0; indx < MAX_GROUPS; ++indx)
		{
			var thisGroup:BuildGroup = BuildGroup.FromArchive(archive, indx + 1);
			if (thisGroup != null)
			{
				DebugWindow.Log(DebugWindow.Info, "Loaded group " + thisGroup.GetName());
				m_groups.push(thisGroup);
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
				DebugWindow.Log(DebugWindow.Info, "Loaded build " + thisBuild.GetName() + " ID " + thisBuild.GetID() + " Group " + thisBuild.GetGroup() + " Order " + thisBuild.GetOrder());
				
				if (FindGroupWithID(thisBuild.GetGroup()) != null)
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
	
	private function FindGroupWithID(groupID:String):BuildGroup
	{
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
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
		
		var pt:Object = m_icon.GetCoords();
		m_settings[BIcon.ICON_X] = pt.x;
		m_settings[BIcon.ICON_Y] = pt.y;
		SaveBuildGroups();
		SaveBuilds();
	}
	
	private function ConfigClosed():Void
	{
		SaveSettings();
	}
	
	private function ToggleSelectorVisible():Void
	{
		if (m_configWindow != null && m_configWindow.GetVisible() == true)
		{
			ToggleConfigVisible();
		}
		
		var show:Boolean = true;
		if (m_selectorWindow != null)
		{
			if (m_selectorWindow.GetVisible() == true)
			{
				show = false;
			}
			
			m_selectorWindow.Unload();
			m_selectorWindow = null;
		}
		
		if (show == true)
		{
			m_selectorWindow = new BuildSelector(m_mc, "Build Selector", m_groups, m_builds);
			var icon:MovieClip = m_icon.GetIcon();
			if (_root._xmouse >= icon._x && _root._xmouse <= icon._x + icon._width &&
				_root._ymouse >= icon._y && _root._ymouse <= icon._y + icon._height)
			{
				m_selectorWindow.Show(icon._x + icon._width / 2, icon._y + icon._height);
			}
			else
			{
				m_selectorWindow.Show(_root._xmouse + 5, _root._ymouse + 5);
			}
		}
	}
	
	private function ToggleConfigVisible():Void
	{
		FeatInterface.BuildFeatList();
		
		if (m_selectorWindow != null && m_selectorWindow.GetVisible() == true)
		{
			ToggleSelectorVisible();
		}
		
		if (m_configWindow == null)
		{
			//var createTab:CreateTab = new CreateTab("CreateDelete", m_settings);
			var buildList:BuildList = new BuildList("BuildList", m_groups, m_builds);
			m_configWindow = new TabWindow(m_mc, "BooBuilds", m_settings[Settings.X], m_settings[Settings.Y], 300, Delegate.create(this, ConfigClosed));
			m_configWindow.AddTab("Builds", buildList);
			//m_configWindow.AddTab("Create / Delete", createTab);
			m_configWindow.SetVisible(true);
		}
		else
		{
			m_configWindow.ToggleVisible();
		}
		
		if (m_configWindow.GetVisible() != true)
		{
			ConfigClosed();
		}
	}
	
	private function ToggleDebugVisible():Void
	{
		DebugWindow.ToggleVisible();
		
		/*
		var buildWindow:BuildWindow = new BuildWindow("buildy", m_mc);
		buildWindow.SetCoords(Stage.width / 2, Stage.height / 2);
		buildWindow.SetBuild(Build.FromCurrent("current", null));
		*/
		/*
		var popup:PopupMenu = new PopupMenu(m_mc, "Popup", 6);
		popup.AddItem("Use");
		popup.AddItem("Edit");
		popup.AddItem("Export");
		popup.AddItem("Move");
		popup.Rebuild();
		popup.SetCoords(Stage.width / 2, Stage.height / 2);
		popup.SetVisible(true);
		*/
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
		if (Character.GetClientCharacter().IsInCombat() != true)
		{
			var buildName:String = m_loadBuildDV.GetValue();
			
			for (var id:String in m_builds)
			{
				var thisBuild:Build = m_builds[id];
				if (thisBuild != null)
				{
					setTimeout(Delegate.create(this, function() { thisBuild.Apply(); }), 20);
				}
			}
		}

		m_loadBuildDV.SetValue("");
	}
	
	private function ToggleCombat(inCombat:Boolean):Void
	{
		if (inCombat == true)
		{
		}
		else
		{
		}
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
