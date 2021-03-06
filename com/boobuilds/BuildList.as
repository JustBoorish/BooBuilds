import com.Utils.StringUtils;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildWindow;
import com.boobuilds.ChangeGroupDialog;
import com.boobuilds.EditBuildDialog;
import com.boobuilds.EditDialog;
import com.boobuilds.EditGroupDialog;
import com.boobuilds.ExportDialog;
import com.boobuilds.ImportBuildDialog;
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
class com.boobuilds.BuildList implements ITabPane
{
	private var m_addonMC:MovieClip;
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_scrollPane:ScrollPane;
	private var m_buildTree:TreePanel;
	private var m_itemPopup:PopupMenu;
	private var m_groupPopup:PopupMenu;
	private var m_groups:Array;
	private var m_builds:Object;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_currentGroup:BuildGroup;
	private var m_currentBuild:Build;
	private var m_buildWindow:BuildWindow;
	private var m_editDialog:EditDialog;
	private var m_yesNoDialog:YesNoDialog;
	private var m_okDialog:OKDialog;
	private var m_editGroupDialog:EditGroupDialog;
	private var m_editBuildDialog:EditBuildDialog;
	private var m_importBuildDialog:ImportBuildDialog;
	private var m_exportBuildDialog:ExportDialog;
	private var m_changeGroupDialog:ChangeGroupDialog
	private var m_settings:Object;
	private var m_forceRedraw:Boolean;
	private var m_parentWidth:Number;
	private var m_parentHeight:Number;
	
	public function BuildList(name:String, groups:Array, builds:Object, settings:Object, outfits:Object, outfitGroups:Array)
	{
		m_name = name;
		m_groups = groups;
		m_builds = builds;
		m_outfits = outfits;
		m_outfitGroups = outfitGroups;
		m_settings = settings;
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
		
		m_itemPopup = new PopupMenu(m_addonMC, "BuildItemPopup", 6);
		m_itemPopup.AddItem("Use", Delegate.create(this, ApplyBuild));
		m_itemPopup.AddItem("Inspect", Delegate.create(this, InspectBuild));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Export", Delegate.create(this, ExportBuild));
		m_itemPopup.AddItem("Rename", Delegate.create(this, RenameBuild));
		m_itemPopup.AddItem("Update", Delegate.create(this, UpdateBuild));
		m_itemPopup.AddItem("Change group", Delegate.create(this, ChangeGroup));
		m_itemPopup.AddItem("Move Up", Delegate.create(this, MoveBuildUp));
		m_itemPopup.AddItem("Move Down", Delegate.create(this, MoveBuildDown));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Delete", Delegate.create(this, DeleteBuild));
		m_itemPopup.Rebuild();
		m_itemPopup.SetCoords(Stage.width / 2, Stage.height / 2);
		
		m_groupPopup = new PopupMenu(m_addonMC, "BuildGroupPopup", 6);
		m_groupPopup.AddItem("Create build", Delegate.create(this, CreateCurrentBuild));
		m_groupPopup.AddSeparator();
		m_groupPopup.AddItem("Import build", Delegate.create(this, ImportBuild));
		m_groupPopup.AddItem("Edit", Delegate.create(this, EditGroup));
		m_groupPopup.AddSeparator();
		m_groupPopup.AddItem("Add new group above", Delegate.create(this, AddGroupAbove));
		m_groupPopup.AddItem("Add new group below", Delegate.create(this, AddGroupBelow));
		m_groupPopup.AddSeparator();
		m_groupPopup.AddItem("Delete", Delegate.create(this, DeleteGroup));
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
		var sortedBuilds:Array = Build.GetOrderedBuilds(groupID, m_builds);
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
		
		if (m_editGroupDialog != null)
		{
			m_editGroupDialog.Unload();
			m_editGroupDialog = null;
		}
		
		if (m_editBuildDialog != null)
		{
			m_editBuildDialog.Unload();
			m_editBuildDialog = null;
		}
		
		if (m_importBuildDialog != null)
		{
			m_importBuildDialog.Unload();
			m_importBuildDialog = null;
		}
		
		if (m_exportBuildDialog != null)
		{
			m_exportBuildDialog.Unload();
			m_exportBuildDialog = null;
		}
		
		if (m_changeGroupDialog != null)
		{
			m_changeGroupDialog.Unload();
			m_changeGroupDialog = null;
		}

		if (m_buildWindow != null)
		{
			m_buildWindow.Unload();
			m_buildWindow = null;
		}	
	}
	
	private function ApplyBuild(buildID:String):Void
	{
		var thisBuild:Build = m_builds[buildID];
		if (thisBuild != null)
		{
			thisBuild.Apply(m_outfits);
		}
	}
	
	private function InspectBuild(buildID:String):Void
	{
		var thisBuild:Build = m_builds[buildID];
		if (thisBuild != null)
		{
			UnloadDialogs();
			
			m_buildWindow = new BuildWindow("Build: " + thisBuild.GetName(), m_parent, m_parentWidth, m_parentHeight, thisBuild);
			m_buildWindow.SetVisible(true);
		}
	}
	
	private function MoveBuildUp(buildID:String):Void
	{
		var thisBuild:Build = m_builds[buildID];
		if (thisBuild != null)
		{
			var swapBuild:Build = Build.FindOrderBelow(thisBuild.GetOrder(), thisBuild.GetGroup(), m_builds);
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
		var thisBuild:Build = m_builds[buildID];
		if (thisBuild != null)
		{
			var swapBuild:Build = Build.FindOrderAbove(thisBuild.GetOrder(), thisBuild.GetGroup(), m_builds);
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
	
	private function ExportBuild(buildID:String):Void
	{
		m_currentBuild = m_builds[buildID];
		if (m_currentBuild != null)
		{
			UnloadDialogs();
			m_exportBuildDialog = new ExportDialog("ExportBuild", m_parent, m_parentWidth, m_parentHeight, "Export " + m_currentBuild.GetName(), m_currentBuild.toExportString());
			m_exportBuildDialog.Show();
		}
	}
	
	private function ImportBuild(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			m_importBuildDialog = new ImportBuildDialog("ImportBuild", m_parent, m_parentWidth, m_parentHeight);
			m_importBuildDialog.Show(Delegate.create(this, ImportBuildCB));
		}
	}
	
	private function ImportBuildCB(newName:String, buildString:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "build");
			if (nameValid == true && buildString != null && buildString != "" && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_builds)
				{
					var thisBuild:Build = m_builds[indx];
					if (thisBuild != null && thisBuild.GetName() == newName && m_currentGroup.GetID() == thisBuild.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					var newID:String = Build.GetNextID(m_builds);
					var newOrder:Number = Build.GetNextOrder(m_currentGroup.GetID(), m_builds);
					var newBuild:Build = Build.FromString(newID, newName, newOrder, m_currentGroup.GetID(), buildString);
					if (newBuild != null)
					{
						m_builds[newID] = newBuild;
						DrawList();
					}
					else
					{
						InfoWindow.LogError("Import failed.  Build string corrupt!");				
					}
				}
				else
				{
					InfoWindow.LogError("Import failed.  A build with this name already exists in this build group");				
				}
			}
		}
		
		m_currentGroup = null;
	}
	
	private function RenameBuild(buildID:String):Void
	{
		m_currentBuild = m_builds[buildID];
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
				for (var indx:String in m_builds)
				{
					var tempBuild:Build = m_builds[indx];
					if (tempBuild != null && tempBuild.GetName() == newName && tempBuild.GetGroup() == m_currentBuild.GetGroup())
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					Build.RenameBuild(m_currentBuild, newName);
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
		m_currentBuild = m_builds[buildID];
		if (m_currentBuild != null)
		{
			UnloadDialogs();
			
			var includeSkills:Boolean = true;
			if (m_currentBuild.AreSkillsEmpty())
			{
				includeSkills = false;
			}
			
			var includePassives:Boolean = true;
			if (m_currentBuild.ArePassivesEmpty())
			{
				includePassives = false;
			}
			
			var includeWeapons:Boolean = true;
			if (m_currentBuild.AreWeaponsEmpty())
			{
				includeWeapons = false;
			}
			
			var includeTalismans:Boolean = true;
			if (m_currentBuild.AreGearEmpty())
			{
				includeTalismans = false;
			}
			
			var includeGadget:Boolean = true;
			if (m_currentBuild.IsGadgetEmpty())
			{
				includeGadget = false;
			}
			
			var includeAnimaAllocation:Boolean = true;
			if (m_currentBuild.GetDamagePct() == null)
			{
				includeAnimaAllocation = false;
			}
			
			var includeAgents:Boolean = true;
			if (m_currentBuild.AreAgentsEmpty() == null)
			{
				includeAgents = false;
			}
			
			m_editBuildDialog = new EditBuildDialog("UpdateBuild", m_parent, m_addonMC, m_parentWidth, m_parentHeight, m_currentBuild.GetName(), includeSkills, includePassives, includeWeapons, includeTalismans, includeGadget, includeAnimaAllocation, includeAgents, m_currentBuild.GetOutfitID(), m_outfits, m_outfitGroups, m_currentBuild.GetUseGearManager());
			m_editBuildDialog.Show(Delegate.create(this, UpdateBuildCB));
		}
	}
	
	private function UpdateBuildCB(inName:String, includeSkills:Boolean, includePassives:Boolean, includeWeapons:Boolean, includeTalismans:Boolean, includeGadget:Boolean, includeAnimaAllocation:Boolean, includeAgents:Boolean, useGearManager:Boolean, outfitID:String):Void
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
					for (var indx:String in m_builds)
					{
						var thisBuild:Build = m_builds[indx];
						if (thisBuild != null && thisBuild.GetName() == newName && m_currentBuild.GetGroup() == thisBuild.GetGroup())
						{
							duplicateFound = true;
						}
					}
				}
				
				if (duplicateFound == false)
				{
					m_currentBuild.SetUseGearManager(useGearManager);
					Build.RenameBuild(m_currentBuild, newName);
					Build.UpdateBuild(m_currentBuild);
					
					if (m_currentBuild.GetUseGearManager() != true)
					{
						if (includeSkills != true)
						{
							m_currentBuild.ClearSkills();
						}
						if (includePassives != true)
						{
							m_currentBuild.ClearPassives();
						}
						if (includeWeapons != true)
						{
							m_currentBuild.ClearWeapons();
						}
						if (includeTalismans != true)
						{
							m_currentBuild.ClearGear();
						}
						if (includeGadget != true)
						{
							m_currentBuild.ClearGadget();
						}
						if (includeAnimaAllocation != true)
						{
							m_currentBuild.ClearAnimaAllocation();
						}
						if (includeAgents != true)
						{
							m_currentBuild.ClearAgents();
						}
					}
					
					if (outfitID != null && m_outfits[outfitID] != null)
					{
						m_currentBuild.SetOutfitID(outfitID);
					}
					else
					{
						m_currentBuild.SetOutfitID(null);
					}
					
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
		m_currentBuild = m_builds[buildID];
		if (m_currentBuild != null)
		{
			Build.DeleteBuild(m_builds, m_currentBuild);
			DrawList();
		}
	}
	
	private function ChangeGroup(outfitID:String):Void
	{
		m_currentBuild = m_builds[outfitID];
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
					for (var indx:String in m_builds)
					{
						var thisBuild:Build = m_builds[indx];
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
	
	private function DeleteGroup(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			if (m_groups.length > 1)
			{
				m_yesNoDialog = new YesNoDialog("DeleteGroup", m_parent, m_parentWidth, m_parentHeight, "Deleting this group will", "remove all its builds", "Are you sure?");
				m_yesNoDialog.Show(Delegate.create(this, DeleteGroupCB));
			}
			else
			{
				m_okDialog = new OKDialog("DeleteGroup", m_parent, m_parentWidth, m_parentHeight, "You cannot delete the", "final group", "");
				m_okDialog.Show();
			}
		}
	}
	
	private function DeleteGroupCB(yes:Boolean):Void
	{
		if (yes == true && m_currentGroup != null)
		{
			var thisGroup:BuildGroup = null;
			var toDelete:Number = -1;
			for (var indx:Number = 0; indx < m_groups.length; ++indx)
			{
				thisGroup = m_groups[indx];
				if (thisGroup != null && thisGroup.GetID() == m_currentGroup.GetID())
				{
					toDelete = indx;
					break;
				}
			}
			
			if (toDelete != -1)
			{
				m_groups.splice(toDelete, 1);
				for (var thisID:String in m_builds)
				{
					var thisBuild:Build = m_builds[thisID];
					if (thisBuild != null && thisBuild.GetGroup() == thisGroup.GetID())
					{
						Build.DeleteBuild(m_builds, thisBuild);
					}
				}
				
				DrawList();
			}
		}
			
		m_currentGroup = null;
	}
	
	private function CreateCurrentBuild(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			
			m_editBuildDialog = new EditBuildDialog("CreateBuild", m_parent, m_addonMC, m_parentWidth, m_parentHeight, "", true, true, true, true, true, true, true, null, m_outfits, m_outfitGroups, false);
			m_editBuildDialog.Show(Delegate.create(this, CreateCurrentBuildCB));
		}
	}
	
	private function CreateCurrentBuildCB(inName:String, includeSkills:Boolean, includePassives:Boolean, includeWeapons:Boolean, includeTalismans:Boolean, includeGadget:Boolean, includeAnimaAllocation:Boolean, includeAgents:Boolean, useGearManager:Boolean, outfitID:String):Void
	{
		if (inName != null)
		{
			var newName:String = StringUtils.Strip(inName);
			var nameValid:Boolean = IsValidName(newName, "build");
			if (nameValid == true && newName != "" && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_builds)
				{
					var thisBuild:Build = m_builds[indx];
					if (thisBuild != null && thisBuild.GetName() == newName && m_currentGroup.GetID() == thisBuild.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					var newID:String = Build.GetNextID(m_builds);
					var newOrder:Number = Build.GetNextOrder(m_currentGroup.GetID(), m_builds);
					var newBuild:Build = Build.FromCurrent(newID, newName, newOrder, m_currentGroup.GetID());
					newBuild.SetUseGearManager(useGearManager);
					
					if (useGearManager != true)
					{
						if (includeSkills != true)
						{
							newBuild.ClearSkills();
						}
						if (includePassives != true)
						{
							newBuild.ClearPassives();
						}
						if (includeWeapons != true)
						{
							newBuild.ClearWeapons();
						}
						if (includeTalismans != true)
						{
							newBuild.ClearGear();
						}
						if (includeGadget != true)
						{
							newBuild.ClearGadget();
						}
						if (includeAnimaAllocation != true)
						{
							newBuild.ClearAnimaAllocation();
						}
						if (includeAgents != true)
						{
							newBuild.ClearAgents();
						}
					}
					
					if (outfitID != null && m_outfits[outfitID] != null)
					{
						newBuild.SetOutfitID(outfitID);
					}
					
					Build.AddBuild(m_builds, newBuild);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Create build failed.  Name already exists");				
				}
			}
		}
		
		m_currentGroup = null;
	}
	
	private function EditGroup(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			m_editGroupDialog = new EditGroupDialog("EditGroup", m_parent, m_parentWidth, m_parentHeight, m_currentGroup.GetName(), m_currentGroup.GetColourName());
			m_editGroupDialog.Show(Delegate.create(this, EditGroupCB));
		}
	}
	
	private function EditGroupCB(newName:String, newColour:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "group");
			if (nameValid == true && m_currentGroup != null && newColour != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:Number = 0; indx < m_groups.length; ++indx)
				{
					var tempGroup:BuildGroup = m_groups[indx];
					if (tempGroup != null && tempGroup.GetID() != m_currentGroup.GetID() && tempGroup.GetName() == newName)
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					m_currentGroup.SetName(newName);
					m_currentGroup.SetColourName(newColour);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Edit group failed.  Name already exists");				
				}
			}
		}
		
		m_currentGroup = null;
	}
	
	private function AddGroupAbove(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			m_editGroupDialog = new EditGroupDialog("AddGroupAbove", m_parent, m_parentWidth, m_parentHeight, "", Colours.GetDefaultColourName());
			m_editGroupDialog.Show(Delegate.create(this, AddGroupAboveCB));
		}
	}
	
	private function AddGroupAboveCB(newName:String, newColour:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "group");
			if (nameValid == true && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:Number = 0; indx < m_groups.length; ++indx)
				{
					var tempGroup:BuildGroup = m_groups[indx];
					if (tempGroup != null && tempGroup.GetName() == newName)
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					var newID:String = BuildGroup.GetNextID(m_groups);
					var newGroup:BuildGroup = new BuildGroup(newID, newName, newColour);
					var indx:Number = FindGroupIndex(m_currentGroup.GetID());
					m_groups.splice(indx, 0, newGroup);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Add group failed.  Name already exists");				
				}
			}
		}
		
		m_currentGroup = null;
	}
	
	private function AddGroupBelow(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			m_editGroupDialog = new EditGroupDialog("AddGroupAbove", m_parent, m_parentWidth, m_parentHeight, "", Colours.GetDefaultColourName());
			m_editGroupDialog.Show(Delegate.create(this, AddGroupBelowCB));
		}
	}
	
	private function AddGroupBelowCB(newName:String, newColour:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "group");
			if (nameValid == true && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:Number = 0; indx < m_groups.length; ++indx)
				{
					var tempGroup:BuildGroup = m_groups[indx];
					if (tempGroup != null && tempGroup.GetName() == newName)
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					var newID:String = BuildGroup.GetNextID(m_groups);
					var newGroup:BuildGroup = new BuildGroup(newID, newName, newColour);
					var indx:Number = FindGroupIndex(m_currentGroup.GetID());
					m_groups.splice(indx + 1, 0, newGroup);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Add group failed.  Name already exists");				
				}
			}
		}
		
		m_currentGroup = null;
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