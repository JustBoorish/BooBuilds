import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.DressingRoom;
import com.GameInterface.DressingRoomNode;
import com.GameInterface.GearManager;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.SpellBase;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.StringUtils;
import com.boobuilds.Build;
import com.boobuilds.EditOutfitDialog;
import com.boobuilds.Outfit;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.InfoWindow;
import com.boobuildscommon.IntervalCounter;
import com.boobuildscommon.InventoryThrottle;
import com.boobuildscommon.MountHelper;
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
class com.boobuilds.Outfit
{
	public static var OUTFIT_PREFIX:String = "OUTFIT";
	public static var GROUP_PREFIX:String = "OutfitGroup";
	
	private static var FULL_OUTFIT_SIZE:Number = 12;
	private static var NORMAL_OUTFIT_SIZE:Number = 11;
	private static var WEAPON_SKINS_NODE_ID:Number = 102;

	private static var m_outfitStillLoading:Boolean = false;
	private static var m_outfitLoadingID:Number = -1;
	private static var m_currentOutfitID:String = "";
	
	private var m_id:String;
	private var m_name:String;
	private var m_group:String;
	private var m_order:Number;
	private var m_outfit:Array;
	private var m_weaponSkins:Object;
	private var m_primaryWeaponHidden:Boolean;
	private var m_secondaryWeaponHidden:Boolean;
	private var m_sprintTag:Number;
	private var m_petTag:Number;
	private var m_inventoryThrottle:InventoryThrottle;
	private var m_equipOutfitSlot:Number;
	private var m_outfitErrorCount:Number;
	private var m_applyEndCallback:Function;
	
	public function Outfit(id:String, name:String, order:Number, group:String)
	{
		m_id = id;
		SetName(name);
		m_group = group;
		m_order = order;
		m_outfit = new Array();
		ClearWeaponVisibility();
		ClearSprint();
		ClearPet();
		
		for (var indx:Number = 0; indx < FULL_OUTFIT_SIZE; ++indx)
		{
			m_outfit.push(null);
		}
	}
	
	public function GetSprintTag():Number
	{
		return m_sprintTag;
	}
	
	public function SetSprintTag(newTag:Number):Void
	{
		m_sprintTag = newTag;
	}
	
	public function GetPetTag():Number
	{
		return m_petTag;
	}
	
	public function SetPetTag(newTag:Number):Void
	{
		m_petTag = newTag;
	}
	
	public static function GetCurrentOutfitID():String
	{
		return m_currentOutfitID;
	}

	public static function SetCurrentOutfitID(newID:String):Void
	{
		m_currentOutfitID = newID;
	}

	public function AreWeaponsSet():Boolean
	{
		return m_primaryWeaponHidden != null;
	}
	
	public function AreWeaponSkinsSet():Boolean
	{
		return m_weaponSkins != null;
	}
	
	public function GetSize():Number
	{
		return m_outfit.length;
	}
	
	public function GetItemName(slot:Number):String
	{
		return m_outfit[slot];
	}
	
	public function UpdateFromCurrent():Void
	{
		SetCurrentCostume();
		
		m_primaryWeaponHidden = GearManager.IsPrimaryWeaponHidden();
		m_secondaryWeaponHidden = GearManager.IsSecondaryWeaponHidden();
		AddCurrentWeaponSkins();
	}
	
	public static function FromCurrent(id:String, name:String, order:Number, groupID:String):Outfit
	{
		var ret:Outfit = new Outfit(id, name, order, groupID);
		ret.UpdateFromCurrent();
		return ret;
	}
	
	public static function FromImport(id:String, name:String, order:Number, groupID:String, clothes:Array, primaryHidden:Boolean, secondaryHidden:Boolean):Outfit
	{
		var ret:Outfit = new Outfit(id, name, order, groupID);
		ret.m_outfit = clothes;
		ret.m_primaryWeaponHidden = primaryHidden;
		ret.m_secondaryWeaponHidden = secondaryHidden;		
		return ret;
	}
	
	public function ClearWeaponVisibility():Void
	{
		m_primaryWeaponHidden = null;
		m_secondaryWeaponHidden = null;
	}
	
	public function ClearWeaponSkins():Void
	{
		m_weaponSkins = null;
	}
	
	public function ClearSprint():Void
	{
		m_sprintTag = null;
	}
	
	public function ClearPet():Void
	{
		m_petTag = null;
	}
	
	public function IsFullOutfit():Boolean
	{
		return m_outfit.length == FULL_OUTFIT_SIZE;
	}
	
	public function GetID():String
	{
		return m_id;
	}
	
	public function GetGroup():String
	{
		return m_group;
	}
	
	public function SetGroup(newGroup:String):Void
	{
		m_group = newGroup;
	}
	
	public function GetOrder():Number
	{
		return m_order;
	}
	
	public function SetOrder(newOrder:Number):Void
	{
		m_order = newOrder;
	}
	
	public function GetName():String
	{
		return m_name;
	}
	
	public function SetName(newName:String):Void
	{
		if (newName == null)
		{
			m_name = "";
		}
		else
		{
			m_name = StringUtils.Strip(newName);
		}		
	}
	
	public static function GetNextID(outfits:Object):String
	{
		var lastCount:Number = 0;
		for (var indx:String in outfits)
		{
			var thisOutfit:Outfit = outfits[indx];
			if (thisOutfit != null)
			{
				var thisID:String = thisOutfit.GetID();
				var thisCount:Number = Number(thisID.substring(1, thisID.length));
				if (thisCount > lastCount)
				{
					lastCount = thisCount;
				}
			}
		}
		
		lastCount = lastCount + 1;
		return "#" + lastCount;
	}
	
	public static function GetNextOrder(groupID:String, outfits:Object):Number
	{
		var lastCount:Number = 0;
		for (var indx:String in outfits)
		{
			var thisOutfit:Outfit = outfits[indx];
			if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
			{
				var thisCount:Number = thisOutfit.GetOrder();
				if (thisCount > lastCount)
				{
					lastCount = thisCount;
				}
			}
		}
		
		lastCount = lastCount + 1;
		return lastCount;
	}
	
	public static function ReorderOutfits(groupID:String, outfits:Object):Void
	{
		var ordered:Array = GetOrderedOutfits(groupID, outfits);
		if (ordered != null)
		{
			for (var indx:Number = 0; indx < ordered.length; ++indx)
			{
				var thisOutfit:Outfit = ordered[indx];
				thisOutfit.SetOrder(indx + 1);
			}
		}
	}
	
	public static function GetOrderedOutfits(groupID:String, outfits:Object):Array
	{
		var tempOutfits:Array = new Array();
		for (var indx:String in outfits)
		{
			var thisOutfit:Outfit = outfits[indx];
			if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
			{
				var tempObj:Object = new Object();
				tempObj["order"] = thisOutfit.GetOrder();
				tempObj["outfit"] = thisOutfit;
				tempOutfits.push(tempObj);
			}
		}
		
		tempOutfits.sortOn("order", Array.NUMERIC);
		
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < tempOutfits.length; ++indx)
		{
			ret.push(tempOutfits[indx]["outfit"]);
		}
		
		return ret;
	}
	
	public static function FindOrderBelow(order:Number, groupID:String, outfits:Object):Outfit
	{
		var ret:Outfit = null;
		var lastCount:Number = 0;
		for (var indx:String in outfits)
		{
			var thisOutfit:Outfit = outfits[indx];
			if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
			{
				var thisCount:Number = thisOutfit.GetOrder();
				if (thisCount > lastCount && thisCount < order)
				{
					lastCount = thisCount;
					ret = thisOutfit;
				}
			}
		}
		
		return ret;
	}
	
	public static function FindOrderAbove(order:Number, groupID:String, outfits:Object):Outfit
	{
		var ret:Outfit = null;
		var lastCount:Number = 999999;
		for (var indx:String in outfits)
		{
			var thisOutfit:Outfit = outfits[indx];
			if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
			{
				var thisCount:Number = thisOutfit.GetOrder();
				if (thisCount < lastCount && thisCount > order)
				{
					lastCount = thisCount;
					ret = thisOutfit;
				}
			}
		}
		
		return ret;
	}
	
	public static function SwapOrders(outfit1:Outfit, outfit2:Outfit):Void
	{
		if (outfit1 != null && outfit2 != null && outfit1.GetGroup() == outfit2.GetGroup())
		{
			var temp:Number = outfit1.GetOrder();
			outfit1.SetOrder(outfit2.GetOrder());
			outfit2.SetOrder(temp);
		}
	}
	
	private function SetCurrentCostume():Void
	{
		var inventoryID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);

		var fullOutfitItem:InventoryItem = inventory.GetItemAt(GetFullOutfitSlotID(0));
		if (fullOutfitItem != null)
		{
			m_outfit = new Array();
			for (var i:Number = 0 ; i < FULL_OUTFIT_SIZE; ++i)
			{
				var item:InventoryItem = inventory.GetItemAt(GetFullOutfitSlotID(i));
				if (item == null)
				{
					m_outfit.push(null);
				}
				else
				{
					var nodeID:Number = GetEquippedNodeID(item.m_Name, GetFullOutfitNodeID(i));
					if (nodeID != null)
					{
						m_outfit.push(String(nodeID));
					}
					else
					{
						m_outfit.push(item.m_Name);
					}
				}
			}		
		}
		else
		{
			m_outfit = new Array();
			for (var i:Number = 0 ; i < NORMAL_OUTFIT_SIZE; ++i)
			{
				var item:InventoryItem = inventory.GetItemAt(GetNormalSlotID(i));
				if (item == null)
				{
					m_outfit.push(null);
				}
				else
				{
					var nodeID:Number = GetEquippedNodeID(item.m_Name, GetNormalNodeID(i));
					if (nodeID != null)
					{
						m_outfit.push(String(nodeID));
					}
					else
					{
						m_outfit.push(item.m_Name);
					}
				}
			}		
		}
	}
	
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
	
	private function GetNormalNodeID(indx:Number):Number
	{
		var positions:Array = [4, 5, 26, 45, 1, 51, 52, 53, null, null, 125];
		return positions[indx];
	}
	
	private function GetFullOutfitSlotID(indx:Number):Number
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_FullOutfit,
								_global.Enums.ItemEquipLocation.e_Wear_Hat, _global.Enums.ItemEquipLocation.e_Wear_Face,
								_global.Enums.ItemEquipLocation.e_Wear_Neck, _global.Enums.ItemEquipLocation.e_Wear_Back,
								_global.Enums.ItemEquipLocation.e_Wear_Chest, _global.Enums.ItemEquipLocation.e_Wear_Hands,
								_global.Enums.ItemEquipLocation.e_Wear_Legs, _global.Enums.ItemEquipLocation.e_Wear_Feet,
								_global.Enums.ItemEquipLocation.e_Ring_1, _global.Enums.ItemEquipLocation.e_Ring_2,
								_global.Enums.ItemEquipLocation.e_HeadAccessory];
		return positions[indx];
	}
	
	private function GetFullOutfitNodeID(indx:Number):Number
	{
		var positions:Array = [54, 4, 5, 26, 45, 1, 51, 52, 53, null, null, 125];
		return positions[indx];
	}

	private function GetOutfitSize():Number
	{
		if (IsFullOutfit() == true)
		{
			return FULL_OUTFIT_SIZE;
		}
		else
		{
			return NORMAL_OUTFIT_SIZE;
		}
	}
	
	private function GetSlotID(indx:Number):Number
	{
		if (IsFullOutfit() == true)
		{
			return GetFullOutfitSlotID(indx);
		}
		else
		{
			return GetNormalSlotID(indx);
		}
	}
	
	private static function SetArchiveEntry(prefix:String, archive:Archive, key:String, value:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
		if (value != null && value != "null")
		{
			archive.AddEntry(keyName, value);
		}
	}

	public function toString():String
	{
		var ret:String = "CS" + Build.SEPARATOR + "-" + Build.SEPARATOR + "VER" + Build.SEPARATOR + "-" + Build.SEPARATOR + "1.0" + Build.SEPARATOR;
		if (IsFullOutfit() == true)
		{
			ret = ret + Build.GetArrayString("FL", m_outfit);
		}
		else
		{
			ret = ret + Build.GetArrayString("OU", m_outfit);
		}

		
		ret = ret + Build.GetArrayString("WV", [ m_primaryWeaponHidden, m_secondaryWeaponHidden ]);
		ret = ret + Build.GetArrayStringInternal("SP", [ m_sprintTag ], false);
		ret = ret + Build.GetArrayStringInternal("PT", [ m_petTag ], false);
		if (m_weaponSkins != null)
		{
			var tempArray:Array = new Array();
			for (var indx in m_weaponSkins)
			{
				tempArray.push(indx);
				tempArray.push(m_weaponSkins[indx]);
			}
			
			ret = ret + Build.GetArrayStringInternal("WS", tempArray, false);
		}
		
		return ret;
	}

	public static function FromString(id:String, name:String, order:Number, groupID:String, costumeString:String):Outfit
	{
		var ret:Outfit = null;
		var items:Array = Build.SplitArrayString(costumeString);
		if (items.length > 0)
		{
			if (items[0] == "CS")
			{
				ret = FromCSArray(id, name, order, groupID, items);
			}
		}
		
		return ret;
	}
	
	private static function FromCSArray(id:String, name:String, order:Number, groupID:String, items:Array):Outfit
	{
		var ret:Outfit = new Outfit(id, name, order, groupID);
		var version:String = null;
		var i:Number = 1;
		while (i < items.length)
		{
			switch(items[i])
			{
				case "VER":
					version = items[i + 1];
					i += 2;
					break;
				case "OU":
					ret.SetOutfitFromArray(i + 1, items, NORMAL_OUTFIT_SIZE);
					i += NORMAL_OUTFIT_SIZE + 1;
					break;
				case "FO":
					ret.SetOutfitFromFOArray(i + 1, items);
					i += 4 + 1;
					break;
				case "FL":
					ret.SetOutfitFromArray(i + 1, items, FULL_OUTFIT_SIZE);
					i += FULL_OUTFIT_SIZE + 1;
					break;
				case "WV":
					ret.SetWeaponHiddenFromArray(i + 1, items);
					i += Build.MAX_WEAPONS + 1;
					break;
				case "SP":
					ret.SetSprintFromArray(i + 1, items);
					i += 1 + 1;
					break;
				case "PT":
					ret.SetPetFromArray(i + 1, items);
					i += 1 + 1;
					break;
				case "WS":
					i += ret.SetWeaponSkinsFromArray(i + 1, items) + 1;
					break;
				default:
					i += 1;
			}
		}
		
		return ret;
	}
	
	private function SetOutfitFromFOArray(offset:Number, items:Array):Void
	{
		var positions:Array = [0, 1, 2, 11 ];

		m_outfit = new Array();
		for (var i:Number = 0; i < FULL_OUTFIT_SIZE; ++i)
		{
			m_outfit.push(null);
		}
			
		for (var i:Number = 0; i < positions.length; ++i)
		{
			var indx:Number = i + offset;
			if (indx < items.length && items[indx] != "undefined")
			{
				m_outfit[positions[i]] = items[indx];
			}
		}
	}
	
	
	private function SetOutfitFromArray(offset:Number, items:Array, size:Number):Void
	{
		m_outfit = new Array();
		for (var i:Number = 0; i < size; ++i)
		{
			m_outfit.push(null);
			
			var indx:Number = i + offset;
			if (indx < items.length && items[indx] != "undefined")
			{
				m_outfit[i] = items[indx];
			}
		}
	}
	
	private function SetWeaponHiddenFromArray(offset:Number, items:Array):Void
	{
		m_primaryWeaponHidden = null;
		var primaryIndx:Number = 0 + offset;
		if (primaryIndx < items.length && items[primaryIndx] != "undefined")
		{
			var item:Boolean = items[primaryIndx] == "true";
			if (item == true)
			{
				m_primaryWeaponHidden = true;
			}
			else
			{
				m_primaryWeaponHidden = false;
			}			
		}
		
		m_secondaryWeaponHidden = null;
		var secondaryIndx:Number = 1 + offset;
		if (secondaryIndx < items.length && items[secondaryIndx] != "undefined")
		{
			var item:Boolean = items[secondaryIndx] == "true";
			if (item == true)
			{
				m_secondaryWeaponHidden = true;
			}
			else
			{
				m_secondaryWeaponHidden = false;
			}			
		}
	}
	
	private function SetWeaponSkinsFromArray(offset:Number, items:Array):Number
	{
		var size:Number = 0;
		m_weaponSkins = null;
		var indx:Number = 0 + offset;
		while (indx + 1 < items.length && items[indx] != "undefined")
		{
			var notNumber:Boolean = isNaN(Number(items[indx]));
			if (notNumber != true)
			{
				if (m_weaponSkins == null)
				{
					m_weaponSkins = new Object();
				}
				
				size += 2;
				m_weaponSkins[Number(items[indx])] = Number(items[indx + 1]);
				indx += 2;
			}
			else
			{
				break;
			}
		}
		
		return size;
	}
	
	private function SetSprintFromArray(offset:Number, items:Array):Void
	{
		var indx:Number = 0 + offset;
		if (indx < items.length && items[indx] != "undefined")
		{
			var item:Number = Number(items[indx]);
			m_sprintTag = item;
		}
	}
	
	private function SetPetFromArray(offset:Number, items:Array):Void
	{
		var indx:Number = 0 + offset;
		if (indx < items.length && items[indx] != "undefined")
		{
			var item:Number = Number(items[indx]);
			m_petTag = item;
		}
	}
	
	private static function DeleteArchiveEntry(prefix:String, archive:Archive, key:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
	}
	
	private static function GetArchiveEntry(prefix:String, archive:Archive, key:String, defaultValue:String):String
	{
		var keyName:String = prefix + "_" + key;
		return archive.FindEntry(keyName, defaultValue);
	}
	
	public function Save(archive:Archive, orderNumber:Number):Void
	{
		var prefix:String = OUTFIT_PREFIX + orderNumber;
		SetArchiveEntry(prefix, archive, Build.ID_PREFIX, m_id);
		SetArchiveEntry(prefix, archive, Build.NAME_PREFIX, m_name);
		SetArchiveEntry(prefix, archive, Build.GROUP_PREFIX, m_group);
		SetArchiveEntry(prefix, archive, Build.ORDER_PREFIX, String(m_order));
		
		var bdString:String = toString();
		SetArchiveEntry(prefix, archive, OUTFIT_PREFIX, bdString);
	}
	
	public static function ClearArchive(archive:Archive, orderNumber:Number):Void
	{
		var prefix:String = OUTFIT_PREFIX + orderNumber;
		DeleteArchiveEntry(prefix, archive, Build.ID_PREFIX);
		DeleteArchiveEntry(prefix, archive, Build.NAME_PREFIX);
		DeleteArchiveEntry(prefix, archive, Build.GROUP_PREFIX);
		DeleteArchiveEntry(prefix, archive, OUTFIT_PREFIX);
	}
	
	public static function FromArchive(orderNumber:Number, archive:Archive):Outfit
	{
		var ret:Outfit = null;
		var prefix:String = OUTFIT_PREFIX + orderNumber;
		var id:String = GetArchiveEntry(prefix, archive, Build.ID_PREFIX, null);
		if (id != null)
		{
			var name:String = GetArchiveEntry(prefix, archive, Build.NAME_PREFIX, null);
			var group:String = GetArchiveEntry(prefix, archive, Build.GROUP_PREFIX, null);
			var order:String = GetArchiveEntry(prefix, archive, Build.ORDER_PREFIX, "-1");
			var bdString:String = GetArchiveEntry(prefix, archive, OUTFIT_PREFIX, null);
			ret = Outfit.FromString(id, name, Number(order), group, bdString);
		}
		
		return ret;
	}
	
	public function Preview():Void
	{
		if (Outfit.m_outfitStillLoading == true)
		{
			InfoWindow.LogError("Please wait on previous outfit to load");
		}
		else if (Character.GetClientCharacter().IsInCombat() == true)
		{
			InfoWindow.LogError("Cannot preview an outfit while in combat");
		}
		else
		{
			var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
			var wearInv:Inventory = new Inventory(wearInvID);
			var wardrobeInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, Character.GetClientCharacter().GetID().GetInstance());
			var wardrobeInv:Inventory = new Inventory(wardrobeInvId);
			for (var indx:Number = 0; indx < GetOutfitSize(); ++indx)
			{
				PreviewSlot(indx, GetSlotID(indx), m_outfit[indx], wearInv, wardrobeInv);
			}
			
			if (!IsFullOutfit())
			{
				PreviewSlot(0, GetFullOutfitSlotID(0), null, wearInv, wardrobeInv);
			}
		}
	}
	
	private function PreviewSlot(slot:Number, slotID:Number, itemName:String, wearInv:Inventory, wardrobeInv:Inventory)
	{
		var equipped:Boolean = IsSlotCorrect(wearInv, slotID, itemName);
		if (equipped != true)
		{
			if (itemName == null)
			{
				if (IsSlotEmpty(wearInv, slotID) != true)
				{
					// Unequip for preview
					wearInv.PreviewItem(slotID);
				}
			}
			else
			{
				var nodeID:Number = GetNodeID(itemName);
				if (nodeID != null)
				{
					DressingRoom.PreviewNodeItem(nodeID);
				}
				else
				{
					var itemIndx:Number = FindInventoryItem(wardrobeInv, itemName);
					if (itemIndx == null)
					{
						InfoWindow.LogError("Failed to preview " + itemName);
					}
					else
					{
						wardrobeInv.PreviewItem(itemIndx);
					}
				}
			}
		}
	}
	
	public function Apply():Void
	{
		if (Outfit.m_outfitStillLoading == true)
		{
			InfoWindow.LogError("Please wait on previous outfit to load");
		}
		else if (Character.GetClientCharacter().IsInCombat() == true)
		{
			InfoWindow.LogError("Cannot load an outfit while in combat");
		}
		else
		{
			ClearInventoryThrottle();
			ApplyAfterBuild(null);
		}
	}
	
	public function ApplyAfterBuild(endCallback:Function):Void
	{
		m_applyEndCallback = endCallback;
		
		if (Outfit.m_outfitLoadingID != -1)
		{
			clearTimeout(Outfit.m_outfitLoadingID);
		}
		
		Outfit.m_outfitStillLoading = true;
		Outfit.m_outfitLoadingID = setTimeout(Delegate.create(this, function() { Outfit.m_outfitStillLoading = false; Outfit.m_outfitLoadingID = -1; }), 5000);
		m_outfitErrorCount = 0;
		
		m_equipOutfitSlot = -1;
		OutfitSlotCompletionCallback();
		
		if (AreWeaponsSet() == true)
		{
			GearManager.SetPrimaryWeaponHidden(m_primaryWeaponHidden);
			GearManager.SetSecondaryWeaponHidden(m_secondaryWeaponHidden);
		}
	}
	
	private function EquipOutfitSlot():Boolean
	{
		var moveOn:Boolean = false;
		var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var wearInv:Inventory = new Inventory(wearInvID);
		var slotID:Number = GetSlotID(m_equipOutfitSlot);
		var itemName:String = m_outfit[m_equipOutfitSlot];
		var equipped:Boolean = IsSlotCorrect(wearInv, slotID, itemName);
		
		if (equipped == false)
		{
			var nodeID:Number = GetNodeID(itemName);
			if (nodeID != null)
			{
				DebugWindow.Log(DebugWindow.Debug, "Equip node " + nodeID + " " + (nodeID + 1));
				DressingRoom.EquipNode(nodeID);
			}
			else
			{
				var wardrobeInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, Character.GetClientCharacter().GetID().GetInstance());
				var wardrobeInv:Inventory = new Inventory(wardrobeInvId);

				if (itemName != null)
				{
					var inventorySlot:Number = FindInventoryItem(wardrobeInv, itemName);
					if (inventorySlot != null)
					{
						wearInv.AddItem(wardrobeInvId, inventorySlot, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
					}
					else
					{
						InfoWindow.LogError("Couldn't find outfit item " + itemName);
						++m_outfitErrorCount;
						moveOn = true;
					}
				}
				else
				{
					if (slotID == _global.Enums.ItemEquipLocation.e_Wear_Chest || slotID == _global.Enums.ItemEquipLocation.e_Wear_Legs)
					{
						moveOn = true;
					}
					else
					{
						wardrobeInv.AddItem(wearInvID, slotID, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
					}
				}
			}
		}
		else
		{
			moveOn = true;
		}

		return moveOn;
	}

	private function OutfitSlotCheckCallback():Boolean
	{
		var moveOn:Boolean = false;
		var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var wearInv:Inventory = new Inventory(wearInvID);
		var slotID:Number = GetSlotID(m_equipOutfitSlot);
		var itemName:String = m_outfit[m_equipOutfitSlot];
		var equipped:Boolean = IsSlotCorrect(wearInv, slotID, itemName);
		if (equipped == true)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function OutfitSlotCompletionCallback():Void
	{
		ClearInventoryThrottle();
		++m_equipOutfitSlot;
		if (m_equipOutfitSlot < GetOutfitSize())
		{
			m_inventoryThrottle = new InventoryThrottle("Equip outfit", Delegate.create(this, EquipOutfitSlot), Delegate.create(this, OutfitSlotCheckCallback), Delegate.create(this, OutfitSlotCompletionCallback), Delegate.create(this, OutfitSlotErrorCallback), IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			m_inventoryThrottle = new InventoryThrottle("Unequip full outfit", Delegate.create(this, UnequipFullOutfitSlot), Delegate.create(this, UnequipFullOutfitSlotCheckCallback), Delegate.create(this, UnequipFullOutfitSlotCompletionCallback), Delegate.create(this, UnequipFullOutfitSlotErrorCallback), IntervalCounter.COMPLETE_ON_ERROR);
		}
	}
	
	private function OutfitSlotErrorCallback():Void
	{
		var itemName:String = m_outfit[m_equipOutfitSlot];
		if (itemName == null)
		{
			InfoWindow.LogError("Failed to unequip outfit item " + m_equipOutfitSlot);
		}
		else
		{
			var nodeID:Number = GetNodeID(itemName);
			if (nodeID != null)
			{
				InfoWindow.LogError("Failed to equip outfit item " + GetNodeName(nodeID));
			}
			else
			{
				InfoWindow.LogError("Failed to equip outfit item " + itemName);
			}
		}
		
		++m_outfitErrorCount;
	}
	
	private function FindInventoryItem(inv:Inventory, itemName:String):Number
	{
		var ret:Number = null;
		for (var indx:Number = 0; indx < inv.GetMaxItems(); ++indx)
		{
			var tempItem:InventoryItem = inv.GetItemAt(indx);
			if (tempItem != null && itemName == tempItem.m_Name)
			{
				ret = indx;
				break;
			}
		}
		
		return ret;
	}
	
	private function UnequipFullOutfitSlot():Boolean
	{
		var moveOn:Boolean = true;
		if (IsFullOutfit() != true)
		{
			var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
			var wearInv:Inventory = new Inventory(wearInvID);
			var slotID:Number = GetFullOutfitSlotID(0);
			var empty:Boolean = IsSlotEmpty(wearInv, slotID);			
			if (empty == false)
			{
				var wardrobeInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, Character.GetClientCharacter().GetID().GetInstance());
				var wardrobeInv:Inventory = new Inventory(wardrobeInvId);

				wardrobeInv.AddItem(wearInvID, slotID, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
				moveOn = false;
			}
		}

		return moveOn;
	}

	private function UnequipFullOutfitSlotCheckCallback():Boolean
	{
		var moveOn:Boolean = false;
		var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var wearInv:Inventory = new Inventory(wearInvID);
		var slotID:Number = GetFullOutfitSlotID(0);
		var empty:Boolean = IsSlotEmpty(wearInv, slotID);
		if (empty == true)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function UnequipFullOutfitSlotCompletionCallback():Void
	{
		EndOutfitApply();
	}
	
	private function UnequipFullOutfitSlotErrorCallback():Void
	{
		InfoWindow.LogError("Failed to unequip full outfit item");
		++m_outfitErrorCount;
	}
	
	private function ClearInventoryThrottle():Void
	{
		if (m_inventoryThrottle != null)
		{
			m_inventoryThrottle.Cleanup();
			m_inventoryThrottle = null;
		}
	}
	
	private function EndOutfitApply():Void
	{
		ClearInventoryThrottle();
		
		if (m_sprintTag != null)
		{
			var sprintVarName:String = "BooSprint_Name";
			if (DistributedValue.DoesVariableExist(sprintVarName) == true)
			{
				var sprintName:String = EditOutfitDialog.GetSprintFromTag(m_sprintTag);
				if (sprintName != null)
				{
					var dv:DistributedValue = DistributedValue.Create(sprintVarName);
					dv.SetValue(sprintName);
				}
			}
			else
			{
				MountHelper.Mount(m_sprintTag);
			}
		}
		
		var petVarName:String = "BooSprint_Pet";
		if (m_petTag != null)
		{
			if (DistributedValue.DoesVariableExist(petVarName) == true)
			{
				var petName:String = EditOutfitDialog.GetPetFromTag(m_petTag);
				if (petName != null)
				{
					var dv:DistributedValue = DistributedValue.Create(petVarName);
					dv.SetValue(petName);
				}
			}
			else
			{
				SpellBase.SummonPetFromTag(m_petTag);
			}
		}
		else
		{
			if (DistributedValue.DoesVariableExist(petVarName) == true)
			{
				var dv:DistributedValue = DistributedValue.Create(petVarName);
				dv.SetValue("None");
			}
		}
		
		ApplyWeaponSkins();
		
		if (Outfit.m_outfitLoadingID != -1)
		{
			clearTimeout(Outfit.m_outfitLoadingID);
			Outfit.m_outfitLoadingID = -1;
		}
		
		Outfit.m_outfitStillLoading = false;
		
		if (m_outfitErrorCount < 1)
		{
			SetCurrentOutfitID(GetID());
		}
		
		if (m_applyEndCallback != null)
		{
			m_applyEndCallback(m_outfitErrorCount);
		}
		else
		{
			if (m_outfitErrorCount > 0)
			{
				InfoWindow.LogError("Outfit load failed");
			}
			else
			{
				InfoWindow.LogInfo("Outfit loaded");
			}
		}
	}
	
	private function IsSlotCorrect(inventory:Inventory, slotID:Number, itemName:String):Boolean
	{
		if (itemName == null)
		{
			return IsSlotEmpty(inventory, slotID);
		}
		else
		{
			return IsSlotSame(inventory, slotID, itemName);
		}
	}
	
	private function IsSlotEmpty(inventory:Inventory, slotID:Number):Boolean
	{
		var item:InventoryItem = inventory.GetItemAt(slotID);
		return item == null;
	}
	
	private function IsSlotSame(inventory:Inventory, slotID:Number, itemName:String):Boolean
	{
		var nodeID:Number = GetNodeID(itemName);
		if (nodeID == null)
		{
			var item:InventoryItem = inventory.GetItemAt(slotID);
			return item.m_Name == itemName;
		}
		else
		{
			return DressingRoom.NodeEquipped(nodeID);
		}
	}
	
	private static function GetNodeID(itemName:String):Number
	{
		var ret:Number = Number(itemName);
		if (isNaN(ret) == true)
		{
			return null;
		}
		
		return ret;
	}
	
	private static function GetNodeName(nodeID:Number):String
	{
		var ret:String = "Unknown";
		
		if (nodeID != null)
		{
			var parentNode:DressingRoomNode = DressingRoom.GetParent(nodeID);
			if (parentNode != null)
			{
				var childNodes:Array = DressingRoom.GetChildren(parentNode.m_NodeId);
				if (childNodes != null)
				{
					for (var indx:Number = 0; indx < childNodes.length; ++indx)
					{
						var childNode:DressingRoomNode = childNodes[indx];
						if (childNode != null && childNode.m_NodeId == nodeID)
						{
							ret = childNode.m_Name;
							break;
						}
					}
				}
			}
		}
		
		return ret;
	}
	
	public function IsDuplicateItem(slot:Number):Boolean
	{
		var wardrobeInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, Character.GetClientCharacter().GetID().GetInstance());
		var wardrobeInv:Inventory = new Inventory(wardrobeInvId);
		var startIndx:Number = FindInventoryItem(wardrobeInv, m_outfit[slot], false);
		var endIndx:Number = FindInventoryItem(wardrobeInv, m_outfit[slot], true);
		if (startIndx != null && endIndx != null && startIndx != endIndx)
		{
			return true;
		}
		
		var wearInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var wearInv:Inventory = new Inventory(wearInvID);
		endIndx = FindInventoryItem(wearInv, m_outfit[slot], false);
		
		return (startIndx != null) && (endIndx != null);
	}

	private function ApplyWeaponSkins():Void
	{
		if (m_weaponSkins != null)
		{
			for (var indx in m_weaponSkins)
			{
				var id:Number = m_weaponSkins[indx];
				if (id != null)
				{
					if (DressingRoom.NodeEquipped(id) != true)
					{
						DressingRoom.EquipNode(id);
					}
				}
			}
		}
	}
	
	public static function ApplyCurrentOutfitWeaponSkins(outfits:Object):Void
	{
		if (outfits != null && m_currentOutfitID != null && outfits[m_currentOutfitID] != null)
		{
			var thisOutfit:Outfit = outfits[m_currentOutfitID];
			thisOutfit.ApplyWeaponSkins();
		}
	}
	
	public function AddCurrentWeaponSkins():Void
	{
		var parentNodes:Array = DressingRoom.GetChildren(WEAPON_SKINS_NODE_ID);
		if (parentNodes != null)
		{
			for (var indx:Number = 0; indx < parentNodes.length; ++indx)
			{
				var parentNode:DressingRoomNode = parentNodes[indx];
				if (parentNode != null)
				{
					var children:Array = DressingRoom.GetChildren(parentNode.m_NodeId);
					if (children != null)
					{
						for (var indx2:Number = 0; indx2 < children.length; ++indx2)
						{
							var childNode:DressingRoomNode = children[indx2];
							if (childNode != null)
							{
								if (DressingRoom.NodeOwned(childNode.m_NodeId) == true && DressingRoom.NodeEquipped(childNode.m_NodeId) == true)
								{
									if (m_weaponSkins == null)
									{
										m_weaponSkins = new Object();
									}
									
									m_weaponSkins[parentNode.m_NodeId] = childNode.m_NodeId;
									break;
								}
							}
						}
					}
				}
			}
		}
	}
	
	private function GetEquippedNodeID(nodeName:String, parentNodeID:Number):Number
	{
		var ret:Number = GetEquippedNodeIDFromID(parentNodeID);
		if (ret == null)
		{
			ret = GetEquippedNodeIDFromName(nodeName, parentNodeID, null);
		}
		
		return ret;
	}
	
	private function GetEquippedNodeIDFromID(parentNodeID:Number):Number
	{
		var ret:Number = null;
		
		if (parentNodeID != null)
		{
			var childNodes:Array = DressingRoom.GetChildren(parentNodeID);
			if (childNodes != null && childNodes.length > 0)
			{
				for (var indx:Number = 0; indx < childNodes.length; ++indx)
				{
					var childNode:DressingRoomNode = childNodes[indx];
					if (childNode != null)
					{
						ret = GetEquippedNodeIDFromID(childNode.m_NodeId);
						if (ret != null)
						{
							break;
						}
					}
				}
			}
			else
			{
				if (DressingRoom.NodeEquipped(parentNodeID) == true)
				{
					ret = parentNodeID;
				}
			}
		}
		
		return ret;
	}
	
	private function GetEquippedNodeIDFromName(nodeName:String, parentNodeID:Number, parentNode:DressingRoomNode):Number
	{
		var ret:Number = null;
		
		if (parentNodeID != null)
		{
			var childNodes:Array = DressingRoom.GetChildren(parentNodeID);
			if (childNodes != null && childNodes.length > 0)
			{
				for (var indx:Number = 0; indx < childNodes.length; ++indx)
				{
					var childNode:DressingRoomNode = childNodes[indx];
					if (childNode != null)
					{
						ret = GetEquippedNodeIDFromName(nodeName, childNode.m_NodeId, childNode);
						if (ret != null)
						{
							break;
						}
					}
				}
			}
			else
			{
				if (parentNode != null && parentNode.m_Name == nodeName)
				{
					ret = parentNodeID;
				}
			}
		}
		
		return ret;
	}
	
	public static function FindNode(inParentID:Number, nodeName:String):String
	{
		var ret:String = null;
		
		var parentID:Number = inParentID;
		if (parentID == null)
		{
			parentID = DressingRoom.GetRootNodeId();
		}
		
		var topLevel:Array = DressingRoom.GetChildren(parentID);
		for (var indx:Number = 0; indx < topLevel.length; ++indx)
		{
			var childNode:DressingRoomNode = topLevel[indx];
			if (childNode != null)
			{
				var children:Array = DressingRoom.GetChildren(childNode.m_NodeId);
				if (children == null || children.length == 0)
				{
					if (childNode.m_Name == nodeName)
					{
						ret = nodeName;
						if (DressingRoom.NodeEquipped(childNode.m_NodeId) == true)
						{
							ret = ret + " [equipped]";
						}
						else
						{
							ret = ret + " [not equipped]";
						}
					}
				}
				else
				{
					ret = FindNode(childNode.m_NodeId, nodeName);
				}
				
				if (ret != null)
				{
					ret = "[" + childNode.m_NodeId + "] " + ret;
					break;
				}
			}
		}
		
		return ret;
	}

		
	public static function DumpNode(node:DressingRoomNode, level:Number):String
	{
		var ret:String = "";
		
		for (var indx:Number = 0; indx < level; ++indx)
		{
			ret = ret + "  ";
		}

		var topLevel:Array;
		if (node == null)
		{
			var nodeID:Number = DressingRoom.GetRootNodeId();
			ret = ret + "[" + nodeID + "]\n";
			topLevel = DressingRoom.GetChildren(nodeID);
		}
		else
		{
			ret = ret + "[" + node.m_NodeId + "] " + node.m_Name + "\n";
			topLevel = DressingRoom.GetChildren(node.m_NodeId);
		}
		
		for (var indx:Number = 0; indx < topLevel.length; ++indx)
		{
			var childNode:DressingRoomNode = topLevel[indx];
			if (childNode != null)
			{
				ret = ret + DumpNode(childNode, level + 1);
			}
		}
		
		return ret;
	}

}