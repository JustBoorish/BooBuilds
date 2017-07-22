import com.Utils.Archive;
import com.boobuilds.ITabPane;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildList;
import com.boobuilds.Checkbox;
import com.boobuilds.Controller;
import com.boobuilds.DebugWindow;
import com.boobuilds.ExportDialog;
import com.boobuilds.Graphics;
import com.boobuilds.InfoWindow;
import com.boobuilds.InventoryThrottle;
import com.boobuilds.MenuPanel;
import com.boobuilds.Outfit;
import com.boobuilds.OutfitList;
import com.boobuilds.RestoreDialog;
import com.Utils.Text;
import com.boobuilds.SubArchive;
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
	public static var INVENTORY_THROTTLE:String = "INVENTORY_THROTTLE";
	
	private static var THROTTLE_MODE0:String = "Default";
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
	private var m_throttleMode:String;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_exportDialog:ExportDialog;
	private var m_restoreDialog:RestoreDialog;
	private var m_buildList:BuildList;
	private var m_outfitList:OutfitList;
	
	public function OptionsTab(title:String, settings:Object, buildGroups:Array, builds:Object, outfitGroups:Array, outfits:Object, buildList:BuildList, outfitList:OutfitList)
	{
		m_name = title;
		m_settings = settings;
		m_buildGroups = buildGroups;
		m_builds = builds;
		m_outfitGroups = outfitGroups;
		m_outfits = outfits;
		m_buildList = buildList;
		m_outfitList = outfitList;
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
			m_throttleMode = GetThrottleMode();
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
			SetThrottleMode();
			ApplyOptions(m_settings);
		}
	}
	
	public static function ApplyOptions(settings:Object):Void
	{
		if (settings != null)
		{
			if (settings[INVENTORY_THROTTLE] != null)
			{
				InventoryThrottle.SetInventoryThrottleMode(settings[INVENTORY_THROTTLE]);
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
				if (tempMode > 0 && tempMode < 4)
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
	
	private function SetThrottleMode():Void
	{
		if (m_settings != null)
		{
			var throttleMode:Number = 0;
			if (m_throttleMode == THROTTLE_MODE1)
			{
				throttleMode = 1;
			}
			else if (m_throttleMode == THROTTLE_MODE2)
			{
				throttleMode = 2;
			}
			else if (m_throttleMode == THROTTLE_MODE3)
			{
				throttleMode = 3;
			}
			
			m_settings[INVENTORY_THROTTLE] = throttleMode;
		}
	}
	
	private function DrawFrame():Void
	{
		var textFormat:TextFormat = Graphics.GetTextFormat();

		var text:String = "Throttle";
		var extents:Object = Text.GetTextExtent(text, textFormat, m_frame);
		var throttleModeText:TextField = Graphics.DrawText("ThrottleText", m_frame, text, textFormat, 25, 30, extents.width, extents.height);

		BuildMenu(m_frame, 40 + extents.width, 30);

		text = "Backup";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		Graphics.DrawButton("Backup", m_frame, text, textFormat, 25, 30 + 2 * extents.height, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, ShowBackupDialog));

		text = "Restore";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		Graphics.DrawButton("Restore", m_frame, text, textFormat, 25, 40 + 3 * extents.height, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, ShowRestoreDialog));
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
		m_menu.AddSubMenu(m_throttleMode, subMenu, colours[0], colours[1]);
		
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
		m_throttleMode = throttleName;
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
			RestoreBackupString(restoreString, overwrite);
		}
	}
	
	private function RestoreBackupString(backupString:String, overwrite:Boolean):Void
	{
		var archives:Array = SubArchive.FromStringArray(backupString);
		if (archives == null || archives.length != 5)
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
			var thisBuild:Build = Build.FromArchive(indx + 1, thisArchive);
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
			CreateOutfitString();
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
				thisBuild.Save(archive, buildNumber);
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
}