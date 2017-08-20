import com.Utils.Text;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildList;
import com.boobuilds.Controller;
import com.boobuilds.ExportDialog;
import com.boobuilds.Outfit;
import com.boobuilds.OutfitList;
import com.boobuilds.QuickBuildList;
import com.boobuilds.RestoreDialog;
import com.boobuilds.Settings;
import com.boocommon.Checkbox;
import com.boocommon.Graphics;
import com.boocommon.ITabPane;
import com.boocommon.InfoWindow;
import com.boocommon.InventoryThrottle;
import com.boocommon.MenuPanel;
import com.boocommon.SubArchive;
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
class com.boobuilds.OptionsTab implements ITabPane
{
	public static var INVENTORY_THROTTLE:String = "INVENTORY_THROTTLE_MODE";
	public static var DISMOUNT_PRELOAD:String = "DISMOUNT_PRELOAD";
	
	private static var MAX_THROTTLE:Number = 3;
	private static var THROTTLE_MODE0:String = "Fast";
	private static var THROTTLE_MODE1:String = "Slow";
	private static var THROTTLE_MODE2:String = "Slower";
	private static var THROTTLE_MODE3:String = "Slowest";
	
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_settings:Object;
	private var m_menu:MenuPanel;
	private var m_throttleX:Number;
	private var m_throttleY:Number;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_quickBuilds:Object;
	private var m_quickBuildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_exportDialog:ExportDialog;
	private var m_restoreDialog:RestoreDialog;
	private var m_buildList:BuildList;
	private var m_outfitList:OutfitList;
	private var m_quickBuildList:QuickBuildList;
	private var m_dismountCheckbox:Checkbox;
	private var m_overrideCheckbox:Checkbox;
	private var m_dragQuickButtons:Function;
	private var m_applyOverride:Function;
	
	public function OptionsTab(title:String, settings:Object, buildGroups:Array, builds:Object, outfitGroups:Array, outfits:Object, quickBuildGroups:Array, quickBuilds:Object, buildList:BuildList, outfitList:OutfitList, quickBuildList:QuickBuildList, dragQuickButtons:Function, applyOverride:Function)
	{
		m_name = title;
		m_settings = settings;
		m_buildGroups = buildGroups;
		m_builds = builds;
		m_outfitGroups = outfitGroups;
		m_outfits = outfits;
		m_quickBuilds = quickBuilds;
		m_quickBuildGroups = quickBuildGroups;
		m_buildList = buildList;
		m_outfitList = outfitList;
		m_quickBuildList = quickBuildList;
		m_dragQuickButtons = dragQuickButtons;
		m_applyOverride = applyOverride;
		m_parent = null;
	}
	
	public function CreatePane(addonMC:MovieClip, parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number):Void
	{
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(name + "GeneralConfigWindow", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_margin = 6;
		m_maxHeight = height;
		
		DrawFrame();
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true && m_settings != null)
		{
			m_dismountCheckbox.SetChecked(m_settings[DISMOUNT_PRELOAD] == 1);
			m_overrideCheckbox.SetChecked(Settings.GetOverrideKey(m_settings));
			
			RebuildMenu();
		}
		
		m_frame._visible = visible;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	public function Save():Void
	{
		if (m_settings != null)
		{
			ApplyOptions(m_settings, m_applyOverride);
		}
	}
	
	public static function ApplyOptions(settings:Object, applyOverride:Function):Void
	{
		if (settings != null)
		{
			if (settings[INVENTORY_THROTTLE] != null)
			{
				InventoryThrottle.SetInventoryThrottleMode(settings[INVENTORY_THROTTLE]);
			}
			
			if (settings[DISMOUNT_PRELOAD] != null)
			{
				Build.SetDismountBeforeBuild(settings[DISMOUNT_PRELOAD] == 1);
			}
			
			if (applyOverride != null)
			{
				applyOverride(Settings.GetOverrideKey(settings));
			}
		}
	}
	
	public function StartDrag():Void
	{
	}
	
	public function StopDrag():Void
	{
	}
	
	private function GetThrottleMode():String
	{
		var throttleMode:Number = 0;
		if (m_settings != null)
		{
			if (m_settings[INVENTORY_THROTTLE] != null)
			{
				var tempMode:Number = m_settings[INVENTORY_THROTTLE];
				if (tempMode > 0 && tempMode <= MAX_THROTTLE)
				{
					throttleMode = tempMode;
				}
			}
		}
		
		switch (throttleMode)
		{
			case 0:
				return THROTTLE_MODE0;
			case 1:
				return THROTTLE_MODE1;
			case 2:
				return THROTTLE_MODE2;
			case 3:
				return THROTTLE_MODE3;
			default:
				return THROTTLE_MODE0;
		}
	}
	
	private function SetThrottleMode(newMode:String):Void
	{
		if (m_settings != null)
		{
			var throttleMode:Number = 0;
			if (newMode == THROTTLE_MODE1)
			{
				throttleMode = 1;
			}
			else if (newMode == THROTTLE_MODE2)
			{
				throttleMode = 2;
			}
			else if (newMode == THROTTLE_MODE3)
			{
				throttleMode = 3;
			}
			
			m_settings[INVENTORY_THROTTLE] = throttleMode;
		}
	}
	
	private function DismountPreloadChanged(newValue:Boolean):Void
	{
		if (m_settings != null)
		{
			m_settings[DISMOUNT_PRELOAD] = newValue;
		}
	}
	
	private function OverrideChanged(newValue:Boolean):Void
	{
		if (m_settings != null)
		{
			Settings.SetOverrideKey(m_settings, newValue);
		}
	}
	
	private function DrawFrame():Void
	{
		var textFormat:TextFormat = Graphics.GetTextFormat();

		var text:String = "Throttle";
		var extents:Object = Text.GetTextExtent(text, textFormat, m_frame);
		var throttleModeText:TextField = Graphics.DrawText("ThrottleText", m_frame, text, textFormat, 25, 30, extents.width, extents.height);

		BuildMenu(m_frame, 40 + extents.width, 30);
		
		var checkSize:Number = 10;
		text = "Dismount before build load";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		var row:Number = 1;
		var y:Number = (40 + 2 * extents.height) * row;
		m_dismountCheckbox = new Checkbox("DismountCheck", m_frame, 25, y + extents.height / 2 - checkSize / 2, checkSize, Delegate.create(this, DismountPreloadChanged), false);		
		Graphics.DrawText("DismountLabel", m_frame, text, textFormat, 25 + checkSize + 5, y, extents.width, extents.height);

		text = "Override swap weapons key";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		row = 2;
		y = 35 + (5 + 2 * extents.height) * row;
		m_overrideCheckbox = new Checkbox("WeaponsCheck", m_frame, 25, y + extents.height / 2 - checkSize / 2, checkSize, Delegate.create(this, OverrideChanged), false);		
		Graphics.DrawText("DismountLabel", m_frame, text, textFormat, 25 + checkSize + 5, y, extents.width, extents.height);

		text = "Restore builds and outfits";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		row = 4;
		y = 35 + (5 + 2 * extents.height) * row;
		Graphics.DrawButton("Restore", m_frame, text, textFormat, 25, y, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, ShowRestoreDialog));
		
		text = "Backup builds and outfits";
		row = 3;
		y = 35 + (5 + 2 * extents.height) * row;
		Graphics.DrawButton("Backup", m_frame, text, textFormat, 25, y, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, ShowBackupDialog));

		text = "Reset quick buttons";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		row = 6;
		y = 35 + (5 + 2 * extents.height) * row;
		Graphics.DrawButton("QuickButton1", m_frame, text, textFormat, 25, y, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, ResetQuickButtons));
		
		text = "Move quick buttons";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		row = 5;
		y = 35 + (5 + 2 * extents.height) * row;
		Graphics.DrawButton("QuickButton", m_frame, text, textFormat, 25, y, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, DragQuickButtons));
	}
	
	private function BuildMenu(modalMC:MovieClip, x:Number, y:Number):Void
	{
		m_throttleX = x;
		m_throttleY = y;
		var colours:Array = BuildGroup.GetColourArray(BuildGroup.GRAY);
		m_menu = new MenuPanel(modalMC, "ThrottleMenu", 4, colours[0], colours[1]);
		var subMenu:MenuPanel = new MenuPanel(modalMC, "ThrottlePanel", 4, colours[0], colours[1]);
		AddItem(subMenu, THROTTLE_MODE0, colours);
		AddItem(subMenu, THROTTLE_MODE1, colours);
		AddItem(subMenu, THROTTLE_MODE2, colours);
		AddItem(subMenu, THROTTLE_MODE3, colours);
		m_menu.AddSubMenu(GetThrottleMode(), subMenu, colours[0], colours[1]);
		
		var pt:Object = m_menu.GetDimensions(x, y, true, 0, 0, modalMC.width, modalMC.height);
		m_menu.Rebuild();
		m_menu.RebuildSubmenus();
		m_menu.SetVisible(true);
	}
	
	private function AddItem(subMenu:MenuPanel, name:String, colours:Array):Void
	{
		subMenu.AddItem(name, Delegate.create(this, ThrottleChanged), colours[0], colours[1]);
	}
	
	private function ThrottleChanged(throttleName:String):Void
	{
		SetThrottleMode(throttleName);
		setTimeout(Delegate.create(this, RebuildMenu), 10);
	}
	
	private function RebuildMenu():Void
	{
		m_menu.Unload();
		BuildMenu(m_frame, m_throttleX, m_throttleY);
		Save();
	}
	
	private function UnloadDialogs():Void
	{
		if (m_exportDialog != null)
		{
			m_exportDialog.Unload();
			m_exportDialog = null;
		}
		
		if (m_restoreDialog != null)
		{
			m_restoreDialog.Unload();
			m_restoreDialog = null;
		}
	}
	
	private function DragQuickButtons():Void
	{
		if (m_dragQuickButtons != null)
		{
			m_dragQuickButtons(false);
		}
	}
	
	private function ResetQuickButtons():Void
	{
		if (m_dragQuickButtons != null)
		{
			m_dragQuickButtons(true);
		}
	}
	
	private function ShowBackupDialog():Void
	{
		UnloadDialogs();
		
		var backupString:String = CreateBackupString();
		m_exportDialog = new ExportDialog("Backup", m_parent, "Backup builds and outfits", backupString);
		m_exportDialog.Show();
	}
	
	private function ShowRestoreDialog():Void
	{
		UnloadDialogs();
		
		m_restoreDialog = new RestoreDialog("Restore", m_parent, Delegate.create(this, RestoreCallback));
		m_restoreDialog.Show();
	}

	private function RestoreCallback(restoreString:String, overwrite:Boolean):Void
	{
		if (restoreString != null)
		{
			if (IsFashionistaExport(restoreString) == true)
			{
				RestoreFashionistaString(restoreString, overwrite);
			}
			else
			{
				RestoreBackupString(restoreString, overwrite);
			}
		}
	}
	
	private function RestoreBackupString(backupString:String, overwrite:Boolean):Void
	{
		var archives:Array = SubArchive.FromStringArray(backupString);
		if (archives == null || archives.length < 5 || archives.length > 6)
		{
			InfoWindow.LogError("Invalid backup string");
		}
		else
		{
			var thisArchive:SubArchive = archives[1];
			if (thisArchive.GetID() != Build.GROUP_PREFIX)
			{
				InfoWindow.LogError("Build groups missing");
				return;
			}
			
			RestoreGroups(thisArchive, m_buildGroups, Build.GROUP_PREFIX, Controller.MAX_GROUPS, overwrite);
			
			thisArchive = archives[3];
			if (thisArchive.GetID() != Outfit.GROUP_PREFIX)
			{
				InfoWindow.LogError("Outfit groups missing");
				return;
			}
			
			RestoreGroups(thisArchive, m_outfitGroups, Outfit.GROUP_PREFIX, Controller.MAX_GROUPS, overwrite);
			
			RestoreBuilds(archives[2], overwrite);
			RestoreOutfits(archives[4], overwrite);
			for (var indx:Number = 0; indx < m_buildGroups.length; ++indx)
			{
				Build.ReorderBuilds(m_buildGroups[indx].GetID(), m_builds);
			}
			
			for (var indx:Number = 0; indx < m_outfitGroups.length; ++indx)
			{
				Outfit.ReorderOutfits(m_outfitGroups[indx].GetID(), m_outfits);
			}
			
			if (archives[5] != null)
			{
				RestoreQuickBuilds(archives[5], overwrite);
				
				for (var indx:Number = 0; indx < m_quickBuildGroups.length; ++indx)
				{
					Build.ReorderBuilds(m_quickBuildGroups[indx].GetID(), m_quickBuilds);
				}
				
				m_quickBuildList.ForceRedraw();
			}
			
			m_buildList.ForceRedraw();
			m_outfitList.ForceRedraw();
		}
	}

	private function RestoreGroups(thisArchive:SubArchive, groups:Array, groupPrefix:String, maxGroups:Number, overwrite:Boolean):Void
	{
		for (var indx:Number = 0; indx < maxGroups; ++indx)
		{
			var thisGroup:BuildGroup = BuildGroup.FromArchive(groupPrefix, thisArchive, indx + 1);
			if (thisGroup != null)
			{
				var existingGroupIndex:Number = FindGroupIndex(groups, thisGroup.GetID());
				if (existingGroupIndex != null)
				{
					if (overwrite == true)
					{
						var existingGroup:BuildGroup = groups[existingGroupIndex];
						groups[existingGroupIndex] = thisGroup;
					}
				}
				else
				{
					groups.push(thisGroup);
				}
			}
		}
	}
	
	private function RestoreBuilds(thisArchive:SubArchive, overwrite:Boolean):Void
	{
		for (var indx:Number = 0; indx < Controller.MAX_BUILDS; ++indx)
		{
			var thisBuild:Build = Build.FromArchive(Build.BUILD_PREFIX, indx + 1, thisArchive);
			if (thisBuild != null)
			{
				var writeIt:Boolean = false;
				var existingBuild:Build = m_builds[thisBuild.GetID()];
				if (existingBuild != null)
				{
					if (overwrite == true)
					{
						writeIt = true;
					}
				}
				else
				{
					writeIt = true;
				}
				
				if (writeIt == true)
				{
					m_builds[thisBuild.GetID()] = thisBuild;
					var groupIndex:Number = FindGroupIndex(m_buildGroups, thisBuild.GetGroup());
					if (groupIndex == null)
					{
						CreateTempGroup(thisBuild.GetGroup(), m_buildGroups);
					}
				}
			}
		}
	}
	
	private function RestoreQuickBuilds(thisArchive:SubArchive, overwrite:Boolean):Void
	{
		for (var indx:Number = 0; indx < Controller.MAX_BUILDS; ++indx)
		{
			var thisBuild:Build = Build.FromArchive(Build.QUICK_BUILD_PREFIX, indx + 1, thisArchive);
			if (thisBuild != null)
			{
				var writeIt:Boolean = false;
				var existingBuild:Build = m_quickBuilds[thisBuild.GetID()];
				if (existingBuild != null)
				{
					if (overwrite == true)
					{
						writeIt = true;
					}
				}
				else
				{
					writeIt = true;
				}
				
				if (writeIt == true)
				{
					var groupIndex:Number = FindGroupIndex(m_quickBuildGroups, thisBuild.GetGroup());
					if (groupIndex != null)
					{
						m_quickBuilds[thisBuild.GetID()] = thisBuild;
					}
				}
			}
		}
	}
	
	private function RestoreOutfits(thisArchive:SubArchive, overwrite:Boolean):Void
	{
		for (var indx:Number = 0; indx < Controller.MAX_OUTFITS; ++indx)
		{
			var thisOutfit:Outfit = Outfit.FromArchive(indx + 1, thisArchive);
			if (thisOutfit != null)
			{
				var writeIt:Boolean = false;
				var existingOutfit:Build = m_outfits[thisOutfit.GetID()];
				if (existingOutfit != null)
				{
					if (overwrite == true)
					{
						writeIt = true;
					}
				}
				else
				{
					writeIt = true;
				}
				
				if (writeIt == true)
				{
					m_outfits[thisOutfit.GetID()] = thisOutfit;
					var groupIndex:Number = FindGroupIndex(m_outfitGroups, thisOutfit.GetGroup());
					if (groupIndex == null)
					{
						CreateTempGroup(thisOutfit.GetGroup(), m_outfitGroups);
					}
				}
			}
		}
	}
	
	private function FindGroupIndex(groups:Array, groupID:String):Number
	{
		for (var indx:Number = 0; indx < groups.length; ++indx)
		{
			var thisGroup:BuildGroup = groups[indx];
			if (thisGroup != null && thisGroup.GetID() == groupID)
			{
				return indx;
			}
		}
		
		return null;
	}
	
	private function CreateTempGroup(groupID:String, groups:Array):Void
	{
		var thisGroup:BuildGroup = new BuildGroup(groupID, "GROUP" + groupID, BuildGroup.GRAY);
		groups.push(thisGroup);
	}
	
	private function CreateBackupString():String
	{
		var header:SubArchive = new SubArchive("BOOBUILDS");
		header.AddEntry("VERSION", Controller.VERSION);
		return header.ToString() +
			CreateGroupString(m_buildGroups, Build.GROUP_PREFIX) + 
			CreateBuildString() +
			CreateGroupString(m_outfitGroups, Outfit.GROUP_PREFIX) +
			CreateOutfitString() +
			CreateQuickBuildString();
	}
	
	private function CreateGroupString(groups:Array, prefix:String):String
	{
		var archive:SubArchive = new SubArchive(prefix);
		var groupNumber:Number = 1;
		for (var indx:Number = 0; indx < groups.length; ++indx)
		{
			var thisGroup:BuildGroup = groups[indx];
			if (thisGroup != null)
			{
				thisGroup.Save(prefix, archive, groupNumber);
				++groupNumber;
			}
		}
		
		return archive.ToString();
	}
	
	private function CreateBuildString():String
	{
		var archive:SubArchive = new SubArchive(Build.BUILD_PREFIX);
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
		
		return archive.ToString();
	}
	
	private function CreateQuickBuildString():String
	{
		var archive:SubArchive = new SubArchive(Build.QUICK_BUILD_PREFIX);
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
		
		return archive.ToString();
	}
	
	private function CreateOutfitString():String
	{
		var archive:SubArchive = new SubArchive(Outfit.OUTFIT_PREFIX);
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
		
		return archive.ToString();
	}
	
	/*
	private function GetNormalSlotID(indx:Number):Number
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_Hat, _global.Enums.ItemEquipLocation.e_Wear_Face,
								_global.Enums.ItemEquipLocation.e_Wear_Neck, _global.Enums.ItemEquipLocation.e_Wear_Back,
								_global.Enums.ItemEquipLocation.e_Wear_Chest, _global.Enums.ItemEquipLocation.e_Wear_Hands,
								_global.Enums.ItemEquipLocation.e_Wear_Legs, _global.Enums.ItemEquipLocation.e_Wear_Feet,
								_global.Enums.ItemEquipLocation.e_Ring_1, _global.Enums.ItemEquipLocation.e_Ring_2,
								_global.Enums.ItemEquipLocation.e_HeadAccessory];
		return positions[indx];
	}
	
	private function GetFullOutfitSlotID(indx:Number):Number
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_FullOutfit, _global.Enums.ItemEquipLocation.e_Wear_Hat,
								_global.Enums.ItemEquipLocation.e_Wear_Face, _global.Enums.ItemEquipLocation.e_HeadAccessory ];
		return positions[indx];
	}
	
	* */
	
	private function IsFashionistaExport(backupString:String):Boolean
	{
		if (backupString != null && backupString.indexOf("VFA_EXPORT") == 0)
		{
			return true;
		}
		
		return false;
	}
	
	private function RestoreFashionistaString(backupString:String, overwrite:Boolean):Void
	{
		var items:Array = SubArchive.SplitArrayString(backupString, "%", true);
		if (items == null || items.length < 3)
		{
			InfoWindow.LogError("Invalid Fashionista export string");
		}
		else
		{
			if (items[0].indexOf("VFA_EXPORT") != 0)
			{
				InfoWindow.LogError("Invalid Fashionista export string");
				return;
			}
			
			var thisGroup:BuildGroup = null;
			for (var indx:Number = 2; indx < items.length; indx += 2)
			{
				var outfitItems:Array = SubArchive.SplitArrayString(items[indx], "|", false);
				if (outfitItems == null || outfitItems.length != 16)
				{
					InfoWindow.LogError("Ignoring outfit " + outfitItems[0] + " " + outfitItems.length);
				}
				else
				{
					if (thisGroup == null)
					{
						thisGroup = GetFashionistaGroup();
					}
					
					var oldOutfit:Outfit = FindOutfit(thisGroup.GetID(), outfitItems[0]);
					if (oldOutfit == null || overwrite == true)
					{
						var outfitID:String;
						if (oldOutfit == null)
						{
							outfitID = Outfit.GetNextID(m_outfits);
						}
						else
						{
							outfitID = oldOutfit.GetID();
						}
						
						var primaryHidden:Boolean = outfitItems[13] == "true";
						var secondaryHidden:Boolean = outfitItems[14] == "true";
						var clothes:Array = new Array();
						if (outfitItems[10] == "undefined" || outfitItems[10] == "")
						{
							clothes.push(GetClothesItem(outfitItems, 7));
							clothes.push(GetClothesItem(outfitItems, 8));
							clothes.push(GetClothesItem(outfitItems, 6));
							clothes.push(GetClothesItem(outfitItems, 4));
							clothes.push(GetClothesItem(outfitItems, 3));
							clothes.push(GetClothesItem(outfitItems, 5));
							clothes.push(GetClothesItem(outfitItems, 2));
							clothes.push(GetClothesItem(outfitItems, 1));
							clothes.push(null);
							clothes.push(null);
							clothes.push(GetClothesItem(outfitItems, 9));
						}
						else
						{
							clothes.push(GetClothesItem(outfitItems, 10));
							clothes.push(GetClothesItem(outfitItems, 7));
							clothes.push(GetClothesItem(outfitItems, 8));
							clothes.push(GetClothesItem(outfitItems, 6));
							clothes.push(GetClothesItem(outfitItems, 4));
							clothes.push(GetClothesItem(outfitItems, 3));
							clothes.push(GetClothesItem(outfitItems, 5));
							clothes.push(GetClothesItem(outfitItems, 2));
							clothes.push(GetClothesItem(outfitItems, 1));
							clothes.push(null);
							clothes.push(null);
							clothes.push(GetClothesItem(outfitItems, 9));
						}
						
						var thisOutfit:Outfit = Outfit.FromImport(outfitID, outfitItems[0], Outfit.GetNextOrder(thisGroup.GetID(), m_outfits), thisGroup.GetID(), clothes, primaryHidden, secondaryHidden);
						m_outfits[outfitID] = thisOutfit;
					}
				}
			}
			
			Outfit.ReorderOutfits(thisGroup.GetID(), m_outfits);
			m_outfitList.ForceRedraw();
		}
	}
	
	private function GetFashionistaGroup():BuildGroup
	{
		for (var indx:Number = 0; indx < m_outfitGroups.length; ++indx)
		{
			if (m_outfitGroups[indx].GetName() == "Fashionista")
			{
				return m_outfitGroups[indx];
			}
		}
		
		var thisGroup:BuildGroup = new BuildGroup(BuildGroup.GetNextID(m_outfitGroups), "Fashionista", BuildGroup.GRAY);
		m_outfitGroups.push(thisGroup);
		return thisGroup;
	}
	
	private function FindOutfit(groupID:String, name:String):Outfit
	{
		for (var indx:String in m_outfits)
		{
			var outfit:Outfit = m_outfits[indx];
			if (outfit.GetGroup() == groupID && outfit.GetName() == name)
			{
				return outfit;
			}
		}
		
		return null;
	}
	
	private function GetClothesItem(items:Array, indx:Number):String
	{
		if (items[indx] == null || items[indx] == "undefined" || items[indx] == "")
		{
			return null;
		}
		else
		{
			return items[indx];
		}
	}
}