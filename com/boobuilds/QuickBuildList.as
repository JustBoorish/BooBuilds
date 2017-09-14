import com.Utils.StringUtils;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildWindow;
import com.boobuilds.ChangeGroupDialog;
import com.boobuilds.EditDialog;
import com.boobuilds.EditQuickBuildDialog;
import com.boobuildscommon.Colours;
import com.boobuildscommon.ITabPane;
import com.boobuildscommon.InfoWindow;
import com.boobuildscommon.OKDialog;
import com.boobuildscommon.PopupMenu;
import com.boobuildscommon.ScrollPane;
import com.boobuildscommon.TreePanel;
import com.boobuildscommon.YesNoDialog;
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
class com.boobuilds.QuickBuildList implements ITabPane
{
	private var m_addonMC:MovieClip;
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_scrollPane:ScrollPane;
	private var m_buildTree:TreePanel;
	private var m_itemPopup:PopupMenu;
	private var m_groupPopup:PopupMenu;
	private var m_groups:Array;
	private var m_outfits:Object;
	private var m_quickBuilds:Object;
	private var m_currentGroup:BuildGroup;
	private var m_currentBuild:Build;
	private var m_buildWindow:BuildWindow;
	private var m_editDialog:EditDialog;
	private var m_yesNoDialog:YesNoDialog;
	private var m_okDialog:OKDialog;
	private var m_editQuickBuildDialog:EditQuickBuildDialog;
	private var m_changeGroupDialog:ChangeGroupDialog
	private var m_settings:Object;
	private var m_forceRedraw:Boolean;
	private var m_parentWidth:Number;
	private var m_parentHeight:Number;
	
	public function QuickBuildList(name:String, groups:Array, quickBuilds:Object, settings:Object, builds:Object, buildGroups:Array, outfits:Object)
	{
		m_name = name;
		m_groups = groups;
		m_quickBuilds = quickBuilds;
		m_builds = builds;
		m_buildGroups = buildGroups;
		m_settings = settings;
		m_outfits = outfits;
		m_forceRedraw = false;
	}

	public function CreatePane(addonMC:MovieClip, parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number):Void
	{
		m_parent = parent;
		m_name = name;
		m_addonMC = addonMC;
		m_parentWidth = parent._width;
		m_parentHeight = parent._height;
		m_scrollPane = new ScrollPane(m_parent, m_name + "Scroll", x, y, width, height, null, m_parentHeight * 0.1);
		
		m_itemPopup = new PopupMenu(m_addonMC, "QuickItemPopup", 6);
		m_itemPopup.AddItem("Use", Delegate.create(this, ApplyBuild));
		m_itemPopup.AddItem("Inspect", Delegate.create(this, InspectBuild));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Rename", Delegate.create(this, RenameBuild));
		m_itemPopup.AddItem("Update", Delegate.create(this, UpdateBuild));
		m_itemPopup.AddItem("Change group", Delegate.create(this, ChangeGroup));
		m_itemPopup.AddItem("Move Up", Delegate.create(this, MoveBuildUp));
		m_itemPopup.AddItem("Move Down", Delegate.create(this, MoveBuildDown));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Delete", Delegate.create(this, DeleteBuild));
		m_itemPopup.Rebuild();
		m_itemPopup.SetCoords(Stage.width / 2, Stage.height / 2);
		
		m_groupPopup = new PopupMenu(m_addonMC, "QuickGroupPopup", 6);
		m_groupPopup.AddItem("Create build", Delegate.create(this, CreateCurrentBuild));
		m_groupPopup.Rebuild();
		m_groupPopup.SetCoords(Stage.width / 2, Stage.height / 2);
		
		DrawList();
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_scrollPane.SetVisible(visible);
		if (visible == true && m_forceRedraw == true)
		{
			m_forceRedraw = false;
			DrawList();
		}
	}
	
	public function GetVisible():Boolean
	{
		return m_scrollPane.GetVisible();
	}
	
	public function Save():Void
	{
		
	}
	
	public function StartDrag():Void
	{
		m_itemPopup.SetVisible(false);
		m_groupPopup.SetVisible(false);
	}
	
	public function StopDrag():Void
	{	
	}

	public function ForceRedraw():Void
	{
		m_forceRedraw = true;
	}

	public function DrawList():Void
	{
		var openSubMenus:Object = new Object();
		if (m_buildTree != null)
		{
			for (var indx:Number = 0; indx < m_buildTree.GetNumSubMenus(); ++indx)
			{
				if (m_buildTree.IsSubMenuOpen(indx))
				{
					openSubMenus[m_buildTree.GetSubMenuName(indx)] = true;
				}
			}
			
			m_buildTree.Unload();
		}
		
		var margin:Number = 3;
		var callback:Function = Delegate.create(this, function(a:TreePanel) { this.m_scrollPane.Resize(a.GetHeight()); } );
		m_buildTree = new TreePanel(m_scrollPane.GetMovieClip(), m_name + "Tree", margin, null, null, callback, Delegate.create(this, ContextMenu));
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null)
			{
				//DebugWindow.Log(DebugWindow.Info, "Adding group " + thisGroup.GetName());
				var colours:Array = Colours.GetColourArray(thisGroup.GetColourName());
				var subTree:TreePanel = new TreePanel(m_buildTree.GetMovieClip(), "subTree" + thisGroup.GetName(), margin, colours[0], colours[1], callback, Delegate.create(this, ContextMenu));
				BuildSubMenu(subTree, thisGroup.GetID());
				m_buildTree.AddSubMenu(thisGroup.GetName(), thisGroup.GetID(), subTree, colours[0], colours[1]);
				//DebugWindow.Log(DebugWindow.Info, "Added group " + thisGroup.GetName());
			}
		}
		
		m_buildTree.Rebuild();
		m_buildTree.SetCoords(0, 0);
		
		m_scrollPane.SetContent(m_buildTree.GetMovieClip(), m_buildTree.GetHeight());
		
		for (var indx:Number = 0; indx < m_buildTree.GetNumSubMenus(); ++indx)
		{
			if (openSubMenus[m_buildTree.GetSubMenuName(indx)] == true)
			{
				m_buildTree.ToggleSubMenu(indx);
			}
		}
		
		m_buildTree.Layout();
		m_scrollPane.SetVisible(true);		
	}
	
	public function BuildSubMenu(subTree:TreePanel, groupID:String):Void
	{
		var sortedBuilds:Array = Build.GetOrderedBuilds(groupID, m_quickBuilds);
		for (var indx:Number = 0; indx < sortedBuilds.length; ++indx)
		{
			var thisBuild:Build = sortedBuilds[indx];
			if (thisBuild != null && thisBuild.GetGroup() == groupID)
			{
				//DebugWindow.Log(DebugWindow.Info, "Added build " + thisBuild.GetName() + " " + thisBuild.toString());
				subTree.AddItem(thisBuild.GetName(), Delegate.create(this, ApplyBuild), thisBuild.GetID());
			}
		}
	}
	
	private function ContextMenu(id:String, isGroup:Boolean):Void
	{
		if (isGroup != true)
		{
			if (m_groupPopup != null)
			{
				m_groupPopup.SetVisible(false);
			}
			
			if (m_itemPopup != null)
			{
				UnloadDialogs();
				m_itemPopup.SetUserData(id);
				m_itemPopup.SetCoords(_root._xmouse, _root._ymouse);
				m_itemPopup.SetVisible(true);
			}
		}
		else
		{
			if (m_itemPopup != null)
			{
				m_itemPopup.SetVisible(false);
			}

			if (m_groupPopup != null)
			{
				UnloadDialogs();
				m_groupPopup.SetUserData(id);
				m_groupPopup.SetCoords(_root._xmouse, _root._ymouse);
				m_groupPopup.SetVisible(true);
			}
		}
	}

	public function UnloadDialogs():Void
	{
		if (m_editDialog != null)
		{
			m_editDialog.Unload();
			m_editDialog = null;
		}
		
		if (m_yesNoDialog != null)
		{
			m_yesNoDialog.Unload();
			m_yesNoDialog = null;
		}
		
		if (m_okDialog != null)
		{
			m_okDialog.Unload();
			m_okDialog = null;
		}
		
		if (m_changeGroupDialog != null)
		{
			m_changeGroupDialog.Unload();
			m_changeGroupDialog = null;
		}
		
		if (m_editQuickBuildDialog != null)
		{
			m_editQuickBuildDialog.Unload();
			m_editQuickBuildDialog = null;
		}
	}
	
	private function ApplyBuild(buildID:String):Void
	{
		var thisBuild:Build = m_quickBuilds[buildID];
		if (thisBuild != null)
		{
			thisBuild.Apply(m_outfits);
		}
	}
	
	private function InspectBuild(buildID:String):Void
	{
		var thisBuild:Build = m_quickBuilds[buildID];
		if (thisBuild != null)
		{
			UnloadDialogs();
			
			m_buildWindow = new BuildWindow("Build: " + thisBuild.GetName(), m_parent, m_parentWidth, m_parentHeight, thisBuild);
			m_buildWindow.SetVisible(true);
		}
	}
	
	private function MoveBuildUp(buildID:String):Void
	{
		var thisBuild:Build = m_quickBuilds[buildID];
		if (thisBuild != null)
		{
			var swapBuild:Build = Build.FindOrderBelow(thisBuild.GetOrder(), thisBuild.GetGroup(), m_quickBuilds);
			if (swapBuild != null)
			{
				Build.SwapOrders(thisBuild, swapBuild);
				DrawList();
			}
			else
			{
				InfoWindow.LogError("Cannot move the top build in a group upwards");				
			}
		}
	}
	
	private function MoveBuildDown(buildID:String):Void
	{
		var thisBuild:Build = m_quickBuilds[buildID];
		if (thisBuild != null)
		{
			var swapBuild:Build = Build.FindOrderAbove(thisBuild.GetOrder(), thisBuild.GetGroup(), m_quickBuilds);
			if (swapBuild != null)
			{
				Build.SwapOrders(thisBuild, swapBuild);
				DrawList();
			}
			else
			{
				InfoWindow.LogError("Cannot move the top build in a group upwards");				
			}
		}
	}
	
	private function RenameBuild(buildID:String):Void
	{
		m_currentBuild = m_quickBuilds[buildID];
		if (m_currentBuild != null)
		{
			UnloadDialogs();
			m_editDialog = new EditDialog("RenameBuild", m_parent, m_parentWidth, m_parentHeight, null, null, "Build name", m_currentBuild.GetName());
			m_editDialog.Show(Delegate.create(this, RenameBuildCB));
		}
	}
	
	private function RenameBuildCB(newName:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "build");
			if (nameValid == true && m_currentBuild != null && newName != m_currentBuild.GetName())
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_quickBuilds)
				{
					var tempBuild:Build = m_quickBuilds[indx];
					if (tempBuild != null && tempBuild.GetName() == newName && tempBuild.GetGroup() == m_currentBuild.GetGroup())
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					m_currentBuild.SetName(newName);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Rename failed. A build with this name exists in this build group");
				}
			}
		}
		
		m_currentBuild = null;
	}
	
	private function UpdateBuild(buildID:String):Void
	{
		m_currentBuild = m_quickBuilds[buildID];
		if (m_currentBuild != null)
		{
			UnloadDialogs();

			var previousBuild:Build = m_currentBuild;
			m_currentBuild = Build.FromCurrent(m_currentBuild.GetID(), m_currentBuild.GetName(), m_currentBuild.GetOrder(), m_currentBuild.GetGroup());
			m_editQuickBuildDialog = new EditQuickBuildDialog("UpdateBuild", m_parent, m_addonMC, m_parentWidth, m_parentHeight, m_currentBuild, m_builds, m_buildGroups, previousBuild);
			m_editQuickBuildDialog.Show(Delegate.create(this, UpdateBuildCB));
		}
	}
	
	private function UpdateBuildCB(inName:String, skillChecks:Array, passiveChecks:Array, weaponsChecks:Array, gearChecks:Array, requiredBuild:String):Void
	{
		if (inName != null)
		{
			var newName:String = StringUtils.Strip(inName);
			var nameValid:Boolean = IsValidName(newName, "build");
			if (nameValid == true && newName != "" && m_currentBuild != null)
			{
				var duplicateFound:Boolean = false;
				if (newName != m_currentBuild.GetName())
				{
					for (var indx:String in m_quickBuilds)
					{
						var thisBuild:Build = m_quickBuilds[indx];
						if (thisBuild != null && thisBuild.GetName() == newName && m_currentBuild.GetGroup() == thisBuild.GetGroup())
						{
							duplicateFound = true;
						}
					}
				}
				
				if (duplicateFound == false)
				{
					m_currentBuild.SetName(newName);
					
					for (var indx:Number = 0; indx < skillChecks.length; ++indx)
					{
						if (skillChecks[indx] != true)
						{
							m_currentBuild.SetSkill(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < passiveChecks.length; ++indx)
					{
						if (passiveChecks[indx] != true)
						{
							m_currentBuild.SetPassive(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < weaponsChecks.length; ++indx)
					{
						if (weaponsChecks[indx] != true)
						{
							m_currentBuild.SetWeapon(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < gearChecks.length; ++indx)
					{
						if (gearChecks[indx] != true)
						{
							m_currentBuild.SetGear(indx, null);
						}
					}
					
					m_currentBuild.SetRequiredBuildID(requiredBuild);					
					m_quickBuilds[m_currentBuild.GetID()] = m_currentBuild;
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Update build failed.  Name already exists");				
				}
			}
		}
		
		m_currentBuild = null;
	}
	
	private function DeleteBuild(buildID:String):Void
	{
		m_currentBuild = m_quickBuilds[buildID];
		if (m_currentBuild != null)
		{
			RemoveBuild(m_currentBuild);
			DrawList();
		}
	}
	
	private function RemoveBuild(build:Build):Void
	{
		if (build != null)
		{
			m_quickBuilds[build.GetID()] = null;
		}
	}
	
	private function ChangeGroup(outfitID:String):Void
	{
		m_currentBuild = m_quickBuilds[outfitID];
		if (m_currentBuild != null)
		{
			m_currentGroup = FindGroupByID(m_currentBuild.GetGroup());
			if (m_currentGroup != null)
			{
				UnloadDialogs();
				
				m_changeGroupDialog = new ChangeGroupDialog("ChangeBuildGroup", m_parent, m_addonMC, m_parentWidth, m_parentHeight, m_currentGroup.GetName(), m_groups);
				m_changeGroupDialog.Show(Delegate.create(this, ChangeGroupCB));
			}
		}
	}
	
	private function ChangeGroupCB(newName:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "group");
			if (nameValid == true && newName != "" && m_currentBuild != null && m_currentGroup != null && newName != m_currentGroup.GetName())
			{
				var newGroup:BuildGroup = null;
				for (var indx:Number = 0; indx < m_groups.length; ++indx)
				{
					if (m_groups[indx] != null && m_groups[indx].GetName() == newName)
					{
						newGroup = m_groups[indx];
						break;
					}
				}
				
				if (newGroup == null)
				{
					InfoWindow.LogError("Failed to find group " + newName);
				}
				else
				{
					var duplicateFound:Boolean = false;
					for (var indx:String in m_quickBuilds)
					{
						var thisBuild:Build = m_quickBuilds[indx];
						if (thisBuild != null && thisBuild.GetName() == m_currentBuild.GetName() && newGroup.GetID() == thisBuild.GetGroup())
						{
							duplicateFound = true;
						}
					}
					
					if (duplicateFound == false)
					{
						m_currentBuild.SetGroup(newGroup.GetID());
						DrawList();
					}
					else
					{
						InfoWindow.LogError("Update outfit group failed.  Name already exists");				
					}
				}
			}
		}
		
		m_currentGroup = null;
		m_currentBuild = null;
	}
	
	private function CreateCurrentBuild(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			
			var newID:String = Build.GetNextQuickID(m_quickBuilds);
			var newOrder:Number = Build.GetNextOrder(m_currentGroup.GetID(), m_quickBuilds);
			m_currentBuild = Build.FromCurrent(newID, "", newOrder, m_currentGroup.GetID());
			m_editQuickBuildDialog = new EditQuickBuildDialog("CreateBuild", m_parent, m_addonMC, m_parentWidth, m_parentHeight, m_currentBuild, m_builds, m_buildGroups, null);
			m_editQuickBuildDialog.Show(Delegate.create(this, CreateCurrentBuildCB));
		}
	}
	
	private function CreateCurrentBuildCB(inName:String, skillChecks:Array, passiveChecks:Array, weaponsChecks:Array, gearChecks:Array, requiredBuild:String):Void
	{
		if (inName != null)
		{
			var newName:String = StringUtils.Strip(inName);
			var nameValid:Boolean = IsValidName(newName, "build");
			if (nameValid == true && newName != "" && m_currentGroup != null && m_currentBuild != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_quickBuilds)
				{
					var thisBuild:Build = m_quickBuilds[indx];
					if (thisBuild != null && thisBuild.GetName() == newName && m_currentGroup.GetID() == thisBuild.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					m_currentBuild.SetName(newName);
					
					for (var indx:Number = 0; indx < skillChecks.length; ++indx)
					{
						if (skillChecks[indx] != true)
						{
							m_currentBuild.SetSkill(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < passiveChecks.length; ++indx)
					{
						if (passiveChecks[indx] != true)
						{
							m_currentBuild.SetPassive(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < weaponsChecks.length; ++indx)
					{
						if (weaponsChecks[indx] != true)
						{
							m_currentBuild.SetWeapon(indx, null);
						}
					}
					
					for (var indx:Number = 0; indx < gearChecks.length; ++indx)
					{
						if (gearChecks[indx] != true)
						{
							m_currentBuild.SetGear(indx, null);
						}
					}
					
					m_currentBuild.SetRequiredBuildID(requiredBuild);
					m_quickBuilds[m_currentBuild.GetID()] = m_currentBuild;
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Create build failed.  Name already exists");				
				}
			}
		}
		
		m_currentGroup = null;
		m_currentBuild = null;
	}
	
	private function FindGroupByID(groupID:String):BuildGroup
	{
		var indx:Number = FindGroupIndex(groupID);
		if (indx > -1)
		{
			return m_groups[indx];
		}
		
		return null;
	}
	
	private function FindGroupIndex(groupID:String):Number
	{
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null && thisGroup.GetID() == groupID)
			{
				return indx;
			}
		}
		
		return -1;
	}
	
	private function IsValidName(newName:String, nameType:String):Boolean
	{
		var valid:Boolean = true;
		
		if (newName == null || StringUtils.Strip(newName) == "")
		{
			InfoWindow.LogError("Cannot have a blank " + nameType + " name");
			return false;
		}
		
		if (IsNameGotChar(newName, nameType, "%") == true)
		{
			valid = false;
		}
		if (IsNameGotChar(newName, nameType, "~") == true)
		{
			valid = false;
		}
		if (IsNameGotChar(newName, nameType, "|") == true)
		{
			valid = false;
		}
		
		return valid;
	}
	
	private function IsNameGotChar(newName:String, nameType:String, charType:String):Boolean
	{
		if (newName.indexOf(charType) != -1)
		{
			InfoWindow.LogError("Cannot have character " + charType + " in " + nameType + " names");
			return true;
		}
		
		return false;
	}
}