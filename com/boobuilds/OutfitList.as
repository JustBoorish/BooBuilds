import com.boobuilds.Outfit;
import com.boobuilds.BuildGroup;
import com.boobuilds.CooldownMonitor;
import com.boobuilds.DebugWindow;
import com.boobuilds.EditDialog;
import com.boobuilds.EditOutfitDialog;
import com.boobuilds.EditGroupDialog;
import com.boobuilds.InfoWindow;
import com.boobuilds.ITabPane;
import com.boobuilds.ImportOutfitDialog;
import com.boobuilds.ModalBase;
import com.boobuilds.PopupMenu;
import com.boobuilds.TreePanel;
import com.boobuilds.ScrollPane;
import com.boobuilds.YesNoDialog;
import com.boobuilds.OKDialog;
import com.boobuilds.OptionsTab;
import com.GameInterface.Game.Character;
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
class com.boobuilds.OutfitList implements ITabPane
{
	private var m_addonMC:MovieClip;
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_scrollPane:ScrollPane;
	private var m_outfitTree:TreePanel;
	private var m_itemPopup:PopupMenu;
	private var m_groupPopup:PopupMenu;
	private var m_groups:Array;
	private var m_outfits:Object;
	private var m_currentGroup:BuildGroup;
	private var m_currentOutfit:Outfit;
	private var m_editDialog:EditDialog;
	private var m_yesNoDialog:YesNoDialog;
	private var m_okDialog:OKDialog;
	private var m_editGroupDialog:EditGroupDialog;
	private var m_editOutfitDialog:EditOutfitDialog;
	private var m_importOutfitDialog:ImportOutfitDialog;
	private var m_settings:Object;
	private var m_cooldownMonitor:CooldownMonitor;
	
	public function OutfitList(name:String, groups:Array, outfits:Object, settings:Object, cdMon:CooldownMonitor)
	{
		m_name = name;
		m_groups = groups;
		m_outfits = outfits;
		m_settings = settings;
		m_cooldownMonitor = cdMon;
	}

	public function CreatePane(addonMC:MovieClip, parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number):Void
	{
		m_parent = parent;
		m_name = name;
		m_addonMC = addonMC;
		m_scrollPane = new ScrollPane(m_parent, m_name + "Scroll", x, y, width, height);
		
		m_itemPopup = new PopupMenu(m_addonMC, "Popup", 6);
		m_itemPopup.AddItem("Use", Delegate.create(this, ApplyOutfit));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Export", Delegate.create(this, ExportOutfit));
		m_itemPopup.AddItem("Rename", Delegate.create(this, RenameOutfit));
		m_itemPopup.AddItem("Update", Delegate.create(this, UpdateOutfit));
		m_itemPopup.AddItem("Move Up", Delegate.create(this, MoveOutfitUp));
		m_itemPopup.AddItem("Move Down", Delegate.create(this, MoveOutfitDown));
		m_itemPopup.AddSeparator();
		m_itemPopup.AddItem("Delete", Delegate.create(this, DeleteOutfit));
		m_itemPopup.Rebuild();
		m_itemPopup.SetCoords(Stage.width / 2, Stage.height / 2);
		
		m_groupPopup = new PopupMenu(m_addonMC, "Popup", 6);
		m_groupPopup.AddItem("Create outfit", Delegate.create(this, CreateCurrentOutfit));
		m_groupPopup.AddSeparator();
		m_groupPopup.AddItem("Import outfit", Delegate.create(this, ImportOutfit));
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

	public function DrawList():Void
	{
		var openSubMenus:Object = new Object();
		if (m_outfitTree != null)
		{
			for (var indx:Number = 0; indx < m_outfitTree.GetNumSubMenus(); ++indx)
			{
				if (m_outfitTree.IsSubMenuOpen(indx))
				{
					openSubMenus[m_outfitTree.GetSubMenuName(indx)] = true;
				}
			}
			
			m_outfitTree.Unload();
		}
		
		var margin:Number = 3;
		var callback:Function = Delegate.create(this, function(a:TreePanel) { this.m_scrollPane.Resize(a.GetHeight()); } );
		m_outfitTree = new TreePanel(m_scrollPane.GetMovieClip(), m_name + "Tree", margin, null, null, callback, Delegate.create(this, ContextMenu));
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null)
			{
				DebugWindow.Log(DebugWindow.Info, "Adding group " + thisGroup.GetName());
				var colours:Array = BuildGroup.GetColourArray(thisGroup.GetColourName());
				var subTree:TreePanel = new TreePanel(m_outfitTree.GetMovieClip(), "subTree" + thisGroup.GetName(), margin, colours[0], colours[1], callback, Delegate.create(this, ContextMenu));
				OutfitSubMenu(subTree, thisGroup.GetID());
				m_outfitTree.AddSubMenu(thisGroup.GetName(), thisGroup.GetID(), subTree, colours[0], colours[1]);
				DebugWindow.Log(DebugWindow.Info, "Added group " + thisGroup.GetName());
			}
		}
		
		m_outfitTree.Rebuild();
		m_outfitTree.SetCoords(0, 0);
		
		m_scrollPane.SetContent(m_outfitTree.GetMovieClip(), m_outfitTree.GetHeight());
		
		for (var indx:Number = 0; indx < m_outfitTree.GetNumSubMenus(); ++indx)
		{
			if (openSubMenus[m_outfitTree.GetSubMenuName(indx)] == true)
			{
				m_outfitTree.ToggleSubMenu(indx);
			}
		}
		
		m_outfitTree.Layout();
		m_scrollPane.SetVisible(true);		
	}
	
	public function OutfitSubMenu(subTree:TreePanel, groupID:String):Void
	{
		var sortedOutfits:Array = Outfit.GetOrderedOutfits(groupID, m_outfits);
		DebugWindow.Log(DebugWindow.Debug, "Sorted list = " + sortedOutfits.length);
		for (var indx:Number = 0; indx < sortedOutfits.length; ++indx)
		{
			var thisOutfit:Outfit = sortedOutfits[indx];
			if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
			{
				DebugWindow.Log(DebugWindow.Info, "Added outfit " + thisOutfit.GetName() + " " + thisOutfit.toString());
				subTree.AddItem(thisOutfit.GetName(), Delegate.create(this, ApplyOutfit), thisOutfit.GetID());
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

	private function UnloadDialogs():Void
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
		
		if (m_editOutfitDialog != null)
		{
			m_editOutfitDialog.Unload();
			m_editOutfitDialog = null;
		}
		
		if (m_importOutfitDialog != null)
		{
			m_importOutfitDialog.Unload();
			m_importOutfitDialog = null;
		}
	}
	
	private function ApplyOutfit(outfitID:String):Void
	{
		var thisOutfit:Outfit = m_outfits[outfitID];
		if (thisOutfit != null)
		{
			thisOutfit.Apply(m_cooldownMonitor);
		}
	}
	
	private function MoveOutfitUp(outfitID:String):Void
	{
		var thisOutfit:Outfit = m_outfits[outfitID];
		if (thisOutfit != null)
		{
			var swapOutfit:Outfit = Outfit.FindOrderBelow(thisOutfit.GetOrder(), thisOutfit.GetGroup(), m_outfits);
			if (swapOutfit != null)
			{
				Outfit.SwapOrders(thisOutfit, swapOutfit);
				DrawList();
			}
			else
			{
				InfoWindow.LogError("Cannot move the top outfit in a group upwards");				
			}
		}
	}
	
	private function MoveOutfitDown(outfitID:String):Void
	{
		var thisOutfit:Outfit = m_outfits[outfitID];
		if (thisOutfit != null)
		{
			var swapOutfit:Outfit = Outfit.FindOrderAbove(thisOutfit.GetOrder(), thisOutfit.GetGroup(), m_outfits);
			if (swapOutfit != null)
			{
				Outfit.SwapOrders(thisOutfit, swapOutfit);
				DrawList();
			}
			else
			{
				InfoWindow.LogError("Cannot move the top outfit in a group upwards");				
			}
		}
	}
	
	private function ExportOutfit(outfitID:String):Void
	{
		m_currentOutfit = m_outfits[outfitID];
		if (m_currentOutfit != null)
		{
			UnloadDialogs();
			m_editDialog = new EditDialog("ExportOutfit", m_parent, "Select all the text below", "and press Ctrl+C to copy", m_currentOutfit.GetName(), m_currentOutfit.toString());
			m_editDialog.Show();
		}
	}
	
	private function ImportOutfit(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			m_importOutfitDialog = new ImportOutfitDialog("ImportOutfit", m_parent);
			m_importOutfitDialog.Show(Delegate.create(this, ImportOutfitCB));
		}
	}
	
	private function ImportOutfitCB(newName:String, outfitString:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "outfit");
			if (nameValid == true && outfitString != null && outfitString != "" && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_outfits)
				{
					var thisOutfit:Outfit = m_outfits[indx];
					if (thisOutfit != null && thisOutfit.GetName() == newName && m_currentGroup.GetID() == thisOutfit.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					var newID:String = Outfit.GetNextID(m_outfits);
					var newOrder:Number = Outfit.GetNextOrder(m_currentGroup.GetID(), m_outfits);
					var newOutfit:Outfit = Outfit.FromString(newID, newName, newOrder, m_currentGroup.GetID(), outfitString);
					if (newOutfit != null)
					{
						m_outfits[newID] = newOutfit;
						DrawList();
					}
					else
					{
						InfoWindow.LogError("Import failed.  Outfit string corrupt!");				
					}
				}
				else
				{
					InfoWindow.LogError("Import failed.  A outfit with this name already exists in this outfit group");				
				}
			}
		}
		
		m_currentGroup = null;
	}
	
	private function RenameOutfit(outfitID:String):Void
	{
		m_currentOutfit = m_outfits[outfitID];
		if (m_currentOutfit != null)
		{
			UnloadDialogs();
			m_editDialog = new EditDialog("RenameOutfit", m_parent, null, null, "Outfit name", m_currentOutfit.GetName());
			m_editDialog.Show(Delegate.create(this, RenameOutfitCB));
		}
	}
	
	private function RenameOutfitCB(newName:String):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "outfit");
			if (nameValid == true && m_currentOutfit != null && newName != m_currentOutfit.GetName())
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_outfits)
				{
					var tempOutfit:Outfit = m_outfits[indx];
					if (tempOutfit != null && tempOutfit.GetName() == newName && tempOutfit.GetGroup() == m_currentOutfit.GetGroup())
					{
						duplicateFound = true;
						break;
					}
				}

				if (duplicateFound == false)
				{
					m_currentOutfit.SetName(newName);
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Rename failed. A outfit with this name exists in this outfit group");
				}
			}
		}
		
		m_currentOutfit = null;
	}
	
	private function UpdateOutfit(outfitID:String):Void
	{
		m_currentOutfit = m_outfits[outfitID];
		if (m_currentOutfit != null)
		{
			UnloadDialogs();
			
			var includeWeapons:Boolean = true;
			var includeTalismans:Boolean = true;
			m_editOutfitDialog = new EditOutfitDialog("UpdateOutfit", m_parent, m_currentOutfit.GetName(), includeWeapons, includeTalismans);
			m_editOutfitDialog.Show(Delegate.create(this, UpdateOutfitCB));
		}
	}
	
	private function UpdateOutfitCB(newName:String, includeWeapons:Boolean, includeTalismans:Boolean):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "outfit");
			if (nameValid == true && newName != "" && m_currentOutfit != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_outfits)
				{
					var thisOutfit:Outfit = m_outfits[indx];
					if (thisOutfit != null && thisOutfit.GetName() == newName && m_currentGroup.GetID() == thisOutfit.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					m_currentOutfit.UpdateFromCurrent();
					
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Update outfit failed.  Name already exists");				
				}
			}
		}
		
		m_currentOutfit = null;
	}
	
	private function DeleteOutfit(outfitID:String):Void
	{
		m_currentOutfit = m_outfits[outfitID];
		if (m_currentOutfit != null)
		{
			RemoveOutfit(m_currentOutfit);
			DrawList();
		}
	}
	
	private function RemoveOutfit(outfit:Outfit):Void
	{
		if (outfit != null)
		{
			m_outfits[outfit.GetID()] = null;
		}
	}
	
	private function DeleteGroup(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			if (m_groups.length > 1)
			{
				m_yesNoDialog = new YesNoDialog("DeleteGroup", m_parent, "Deleting this group will", "remove all its outfits", "Are you sure?");
				m_yesNoDialog.Show(Delegate.create(this, DeleteGroupCB));
			}
			else
			{
				m_okDialog = new OKDialog("DeleteGroup", m_parent, "You cannot delete the", "final group", "");
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
				for (var thisID:String in m_outfits)
				{
					var thisOutfit:Outfit = m_outfits[thisID];
					if (thisOutfit != null && thisOutfit.GetGroup() == thisGroup.GetID())
					{
						RemoveOutfit(thisOutfit);
					}
				}
				
				DrawList();
			}
		}
			
		m_currentGroup = null;
	}
	
	private function CreateCurrentOutfit(groupID:String):Void
	{
		m_currentGroup = FindGroupByID(groupID);
		if (m_currentGroup != null)
		{
			UnloadDialogs();
			
			m_editOutfitDialog = new EditOutfitDialog("CreateOutfit", m_parent, "", true, true);
			m_editOutfitDialog.Show(Delegate.create(this, CreateCurrentOutfitCB));
		}
	}
	
	private function CreateCurrentOutfitCB(newName:String, includeWeapons:Boolean, includeTalismans:Boolean):Void
	{
		if (newName != null)
		{
			var nameValid:Boolean = IsValidName(newName, "outfit");
			if (nameValid == true && newName != "" && m_currentGroup != null)
			{
				var duplicateFound:Boolean = false;
				for (var indx:String in m_outfits)
				{
					var thisOutfit:Outfit = m_outfits[indx];
					if (thisOutfit != null && thisOutfit.GetName() == newName && m_currentGroup.GetID() == thisOutfit.GetGroup())
					{
						duplicateFound = true;
					}
				}
				
				if (duplicateFound == false)
				{
					var newID:String = Outfit.GetNextID(m_outfits);
					var newOrder:Number = Outfit.GetNextOrder(m_currentGroup.GetID(), m_outfits);
					DebugWindow.Log(DebugWindow.Debug, "Create outfit " + newID + " " + newName + " " + newOrder + " " + m_currentGroup.GetName() + " " + m_currentGroup.GetID());
					var newOutfit:Outfit = Outfit.FromCurrent(newID, newName, newOrder, m_currentGroup.GetID());
					m_outfits[newID] = newOutfit;
					DrawList();
				}
				else
				{
					InfoWindow.LogError("Create outfit failed.  Name already exists");				
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
			m_editGroupDialog = new EditGroupDialog("EditGroup", m_parent, m_currentGroup.GetName(), m_currentGroup.GetColourName());
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
			m_editGroupDialog = new EditGroupDialog("AddGroupAbove", m_parent, "", BuildGroup.GRAY);
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
			m_editGroupDialog = new EditGroupDialog("AddGroupAbove", m_parent, "", BuildGroup.GRAY);
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