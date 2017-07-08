import com.boobuilds.Build;
import com.boobuilds.DebugWindow;
import com.boobuilds.InfoWindow;
import com.boobuilds.GearItem;
import com.Utils.Archive;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Spell;
import com.GameInterface.SpellBase;
import com.GameInterface.SpellData;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.ID32;
import mx.utils.Delegate;
import com.Utils.StringUtils;
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
class com.boobuilds.Build
{
	public static var GROUP_PREFIX:String = "Group";
	public static var BUILD_PREFIX:String = "BUILD";
	public static var ID_PREFIX:String = "ID";
	public static var NAME_PREFIX:String = "Name";
	public static var PARENT_PREFIX:String = "Parent";
	public static var ORDER_PREFIX:String = "Order";
	public static var SKILL_PREFIX:String = "Skill";
	public static var PASSIVE_PREFIX:String = "Passive";
	public static var GEAR_PREFIX:String = "Gear";
	public static var WEAPON_PREFIX:String = "Weapon";
	public static var COSTUME_PREFIX:String = "Costume";
	public static var MAX_SKILLS:Number = 6;
	public static var MAX_PASSIVES:Number = 5;
	public static var MAX_GEAR:Number = 8;
	public static var MAX_WEAPONS:Number = 2;
	public static var MAX_COSTUME:Number = 9;
	private static var SEPARATOR = "%";
	
	private static var m_disableWeapons:Boolean = false;
	private static var m_disableTalismans:Boolean = false;

	private var m_id:String;
	private var m_name:String;
	private var m_group:String;
	private var m_parent:Build;
	private var m_order:Number;
	private var m_skills:Array;
	private var m_passives:Array;
	private var m_gear:Array;
	private var m_weapons:Array;
	private var m_costume:Array;
	private var m_unequipPassives:Array;
	private var m_unequipSkillsInterval:Number;
	private var m_unequipSkillsCounter:Number;
	private var m_unequipPassivesInterval:Number;
	private var m_unequipPassivesCounter:Number;
	private var m_equipWeaponsInterval:Number;
	private var m_equipWeaponsCounter:Number;
	private var m_equipWeaponItem:GearItem;
	private var m_equipWeaponSlot:Number;
	private var m_equipTalismansInterval:Number;
	private var m_equipTalismansCounter:Number;
	private var m_equipTalismanItem:GearItem;
	private var m_equipTalismanSlot:Number;
	private var m_logAfterSkills:Boolean;
	private var m_logAfterWeapons:Boolean;

	public function Build(id:String, name:String, parent:Build, order:Number, group:String)
	{
		m_id = id;
		m_name = name;
		m_parent = parent;
		m_group = group;
		m_order = order;
		m_skills = new Array();
		m_passives = new Array();
		m_gear = new Array();
		m_weapons = new Array();
		m_costume = new Array();
		m_unequipSkillsInterval = -1;
		m_unequipPassivesInterval = -1;
		m_equipWeaponsInterval = -1;
		InitialiseArray(m_skills, MAX_SKILLS);
		InitialiseArray(m_passives, MAX_PASSIVES);
		InitialiseArray(m_gear, MAX_GEAR);
		InitialiseArray(m_weapons, MAX_WEAPONS);
		InitialiseArray(m_costume, MAX_COSTUME);
	}

	public static function GetNextID(builds:Object):String
	{
		var lastCount:Number = 0;
		for (var indx:String in builds)
		{
			var thisBuild:Build = builds[indx];
			if (thisBuild != null)
			{
				var thisID:String = thisBuild.GetID();
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
	
	public static function GetNextOrder(groupID:String, builds:Object):Number
	{
		var lastCount:Number = 0;
		for (var indx:String in builds)
		{
			var thisBuild:Build = builds[indx];
			if (thisBuild != null && thisBuild.GetGroup() == groupID)
			{
				var thisCount:Number = thisBuild.GetOrder();
				if (thisCount > lastCount)
				{
					lastCount = thisCount;
				}
			}
		}
		
		lastCount = lastCount + 1;
		return lastCount;
	}
	
	public static function GetOrderedBuilds(groupID:String, builds:Object):Array
	{
		var tempBuilds:Array = new Array();
		for (var indx:String in builds)
		{
			var thisBuild:Build = builds[indx];
			if (thisBuild != null && thisBuild.GetGroup() == groupID)
			{
				var tempObj:Object = new Object();
				tempObj["order"] = thisBuild.GetOrder();
				tempObj["build"] = thisBuild;
				tempBuilds.push(tempObj);
			}
		}
		
		tempBuilds.sortOn("order", Array.NUMERIC);
		
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < tempBuilds.length; ++indx)
		{
			ret.push(tempBuilds[indx]["build"]);
		}
		
		return ret;
	}
	
	public static function FindOrderBelow(order:Number, groupID:String, builds:Object):Build
	{
		var ret:Build = null;
		var lastCount:Number = 0;
		for (var indx:String in builds)
		{
			var thisBuild:Build = builds[indx];
			if (thisBuild != null && thisBuild.GetGroup() == groupID)
			{
				var thisCount:Number = thisBuild.GetOrder();
				if (thisCount > lastCount && thisCount < order)
				{
					lastCount = thisCount;
					ret = thisBuild;
				}
			}
		}
		
		return ret;
	}
	
	public static function FindOrderAbove(order:Number, groupID:String, builds:Object):Build
	{
		var ret:Build = null;
		var lastCount:Number = 999999;
		for (var indx:String in builds)
		{
			var thisBuild:Build = builds[indx];
			if (thisBuild != null && thisBuild.GetGroup() == groupID)
			{
				var thisCount:Number = thisBuild.GetOrder();
				if (thisCount < lastCount && thisCount > order)
				{
					lastCount = thisCount;
					ret = thisBuild;
				}
			}
		}
		
		return ret;
	}
	
	public static function SwapOrders(build1:Build, build2:Build):Void
	{
		if (build1 != null && build2 != null && build1.GetGroup() == build2.GetGroup())
		{
			var temp:Number = build1.GetOrder();
			build1.SetOrder(build2.GetOrder());
			build2.SetOrder(temp);
		}
	}
	
	public static function SetWeaponsDisabled(newValue:Boolean):Void
	{
		m_disableWeapons = newValue;
	}
	
	public static function SetTalismansDisabled(newValue:Boolean):Void
	{
		m_disableTalismans = newValue;
	}
	
	public function GetID():String
	{
		return m_id;
	}
	
	public function GetGroup():String
	{
		return m_group;
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
		m_name = newName;
	}

	public function Apply():Void
	{
		if (Character.GetClientCharacter().IsInCombat() != true)
		{
			var doWeapons:Boolean = false;
			var doTalismans:Boolean = false;
			if (m_disableWeapons != true)
			{
				var weaponCount:Number = 0;
				for (var indx:Number = 0; indx < m_weapons.length; ++indx)
				{
					if (GetWeapon(indx) != null)
					{
						++weaponCount;
					}
				}
				
				if (weaponCount > 0 && EquippedWeaponsAreSame() != true)
				{
					if (AvailableBagSpace() < 2)
					{
						InfoWindow.LogError("You must have two free bag slots to equip this build!");
						return;
					}
					
					doWeapons = true;
				}
			}
			
			if (m_disableTalismans != true)
			{
				doTalismans = true;
				var talismanCount:Number = 0;
				for (var indx:Number = 0; indx < m_gear.length; ++indx)
				{
					if (GetGear(indx) != null)
					{
						++talismanCount;
					}
				}
				
				if (talismanCount < 1)
				{
					doTalismans = false;
				}
			}
			
			ApplyPassives();
			
			if (doWeapons == true && doTalismans == true)
			{
				m_logAfterSkills = false;
				m_logAfterWeapons = true;
				ApplySkills();
				ApplyWeapons();
				ApplyTalismans();
			}
			else if (doWeapons == false && doTalismans == true)
			{
				m_logAfterSkills = false;
				m_logAfterWeapons = false;
				ApplySkills();
				ApplyTalismans();
			}
			else if (doWeapons == true && doTalismans == false)
			{
				m_logAfterSkills = false;
				m_logAfterWeapons = true;
				ApplySkills();
				ApplyWeapons();
			}
			else
			{
				m_logAfterSkills = true;
				ApplySkills();
			}
		}
		else
		{
			InfoWindow.LogError("Cannot load a build while in combat");
		}
	}
	
	public function Refresh():Void
	{
		if (m_parent != null)
		{
			RefreshAll(this, this);
		}
	}

	private static function RefreshAll(from:Build, to:Build):Void
	{
		for (var i:Number = 0; i < MAX_SKILLS; ++i)
		{
			to.SetSkill(i, from.GetSkill(i));
		}
		
		for (var i:Number = 0; i < MAX_PASSIVES; ++i)
		{
			to.SetPassive(i, from.GetPassive(i));
		}
		
		for (var i:Number = 0; i < MAX_GEAR; ++i)
		{
			to.SetGear(i, from.GetGear(i));
		}
		
		for (var i:Number = 0; i < MAX_WEAPONS; ++i)
		{
			to.SetWeapon(i, from.GetWeapon(i));
		}
		
		for (var i:Number = 0; i < MAX_COSTUME; ++i)
		{
			to.SetCostume(i, from.GetCostume(i));
		}
	}
	
	public function ClearSkills():Void
	{
		for (var i:Number = 0; i < MAX_SKILLS; ++i)
		{
			SetSkill(i, null);
		}
	}
	
	public function ClearPassives():Void
	{
		for (var i:Number = 0; i < MAX_PASSIVES; ++i)
		{
			SetPassive(i, null);
		}
	}
	
	public function ClearGear():Void
	{
		for (var i:Number = 0; i < MAX_GEAR; ++i)
		{
			SetGear(i, null);
		}
	}
	
	public function ClearWeapons():Void
	{
		for (var i:Number = 0; i < MAX_WEAPONS; ++i)
		{
			SetWeapon(i, null);
		}
	}
	
	public function ClearCostume():Void
	{
		for (var i:Number = 0; i < MAX_COSTUME; ++i)
		{
			SetCostume(i, null);
		}
	}
	
	public function SetSkill(indx:Number, skillId:Number):Void
	{
		if (indx >= 0 && indx < MAX_SKILLS)
		{
			if (m_parent == null || m_parent.GetSkill(indx) != skillId)
			{
				m_skills[indx] = skillId;
			}
			else
			{
				m_skills[indx] = null;
			}
		}
	}
	
	public function SetPassive(indx:Number, skillId:Number):Void
	{
		if (indx >= 0 && indx < MAX_PASSIVES)
		{
			if (m_parent == null || m_parent.GetPassive(indx) != skillId)
			{
				m_passives[indx] = skillId;
			}
			else
			{
				m_passives[indx] = null;
			}
		}
	}
	
	public function SetGear(indx:Number, item:GearItem):Void
	{
		if (indx >= 0 && indx < MAX_GEAR)
		{
			if (m_parent == null || item == null)
			{
				m_gear[indx] = item;
			}
			else
			{
				var parentItem:GearItem = m_parent.GetGear(indx);
				if (parentItem == null)
				{
					m_gear[indx] = item;
				}
				else if (parentItem.toString() != item.toString())
				{
					m_gear[indx] = item;					
				}
				else
				{
					m_gear[indx] = null;
				}
			}
		}
	}
	
	public function SetWeapon(indx:Number, item:GearItem):Void
	{
		if (indx >= 0 && indx < MAX_WEAPONS)
		{
			if (m_parent == null || item == null)
			{
				m_weapons[indx] = item;
			}
			else
			{
				var parentItem:GearItem = m_parent.GetWeapon(indx);
				if (parentItem == null)
				{
					m_weapons[indx] = item;
				}
				else if (parentItem.toString() != item.toString())
				{
					m_weapons[indx] = item;					
				}
				else
				{
					m_weapons[indx] = null;
				}
			}
		}
	}
	
	public function SetCostume(indx:Number, item:GearItem):Void
	{
		if (indx >= 0 && indx < MAX_COSTUME)
		{
			if (m_parent == null || item == null)
			{
				m_costume[indx] = item;
			}
			else
			{
				var parentItem:GearItem = m_parent.GetCostume(indx);
				if (parentItem == null)
				{
					m_costume[indx] = item;
				}
				else if (parentItem.toString() != item.toString())
				{
					m_costume[indx] = item;					
				}
				else
				{
					m_costume[indx] = null;
				}
			}
		}
	}
	
	public function GetSkill(indx:Number):Number
	{
		if (indx >= 0 && indx < MAX_SKILLS)
		{
			if (m_skills[indx] != null)
			{
				return m_skills[indx];
			}
			else if (m_parent != null)
			{
				return m_parent.GetSkill(indx);
			}
		}
		
		return null;
	}
	
	public function GetPassive(indx:Number):Number
	{
		if (indx >= 0 && indx < MAX_PASSIVES)
		{
			if (m_passives[indx] != null)
			{
				return m_passives[indx];
			}
			else if (m_parent != null)
			{
				return m_parent.GetPassive(indx);
			}
		}
		
		return null;
	}
	
	public function GetGear(indx:Number):GearItem
	{
		if (indx >= 0 && indx < MAX_GEAR)
		{
			if (m_gear[indx] != null)
			{
				return m_gear[indx];
			}
			else if (m_parent != null)
			{
				return m_parent.GetGear(indx);
			}
		}
		
		return null;
	}
	
	public function GetWeapon(indx:Number):GearItem
	{
		if (indx >= 0 && indx < MAX_WEAPONS)
		{
			if (m_weapons[indx] != null)
			{
				return m_weapons[indx];
			}
			else if (m_parent != null)
			{
				return m_parent.GetWeapon(indx);
			}
		}
		
		return null;
	}
	
	public function GetCostume(indx:Number):GearItem
	{
		if (indx >= 0 && indx < MAX_COSTUME)
		{
			if (m_costume[indx] != null)
			{
				return m_costume[indx];
			}
			else if (m_parent != null)
			{
				return m_parent.GetCostume(indx);
			}
		}
		
		return null;
	}
	
	public function IsSkillSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_SKILLS)
		{
			return m_skills[indx] != null;
		}
		
		return false;
	}
	
	public function IsPassiveSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_PASSIVES)
		{
			return m_passives[indx] != null;
		}
		
		return false;
	}
	
	public function IsGearSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_GEAR)
		{
			return m_gear[indx] != null;
		}
		
		return false;
	}
	
	public function IsWeaponSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_WEAPONS)
		{
			return m_weapons[indx] != null;
		}
		
		return false;
	}
	
	public function IsCostumeSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_COSTUME)
		{
			return m_costume[indx] != null;
		}
		
		return false;
	}
	
	private static function GetArrayString(prefix:String, array:Array):String
	{
		var ret:String = "";
		if (prefix != null)
		{
			ret = "-" + SEPARATOR + prefix + SEPARATOR;
		}
		
		var found:Boolean = false;
		for (var i:Number = 0; i < array.length; ++i)
		{
			if (array[i] == null)
			{
				ret = ret + "-" + SEPARATOR + "undefined" + SEPARATOR;
			}
			else
			{
				found = true;
				ret = ret + "-" + SEPARATOR + array[i] + SEPARATOR;
			}
		}
		
		if (found == true)
		{
			return ret;
		}
		else
		{
			return "";
		}
	}
	
	private static function GetArrayGearItemString(prefix:String, array:Array):String
	{
		var ret:String = "";
		if (prefix != null)
		{
			ret = "-" + SEPARATOR + prefix + SEPARATOR;
		}
		
		var found:Boolean = false;
		for (var i:Number = 0; i < array.length; ++i)
		{
			if (array[i] == null)
			{
				ret = ret + "-" + SEPARATOR + "undefined" + SEPARATOR;
			}
			else
			{
				found = true;
				ret = ret + "-" + SEPARATOR + array[i].toString() + SEPARATOR;
			}
		}
		
		if (found == true)
		{
			return ret;
		}
		else
		{
			return "";
		}
	}
	
	public function toExportString():String
	{
		var ret:String = "BD" + SEPARATOR + "-" + SEPARATOR + "VER" + SEPARATOR + "-" + SEPARATOR + "1.0" + SEPARATOR;
		ret = ret + GetArrayString("SK", m_skills);
		ret = ret + GetArrayString("PS", m_passives);
		return ret;
	}
	
	public function toString():String
	{
		var ret:String = toExportString();
		ret = ret + GetArrayGearItemString("GR", m_gear);
		ret = ret + GetArrayGearItemString("WP", m_weapons);
		ret = ret + GetArrayGearItemString("CO", m_costume);
		return ret;
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
	
	private static function DeleteArchiveEntry(prefix:String, archive:Archive, key:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
	}
	
	public function Save(archive:Archive, buildNumber:Number):Void
	{
		var prefix:String = BUILD_PREFIX + buildNumber;
		SetArchiveEntry(prefix, archive, ID_PREFIX, m_id);
		SetArchiveEntry(prefix, archive, NAME_PREFIX, m_name);
		if (m_parent != null)
		{
			SetArchiveEntry(prefix, archive, PARENT_PREFIX, m_parent.GetName());
		}
		else
		{
			SetArchiveEntry(prefix, archive, PARENT_PREFIX, null);
		}
		
		SetArchiveEntry(prefix, archive, GROUP_PREFIX, m_group);
		SetArchiveEntry(prefix, archive, ORDER_PREFIX, String(m_order));
		
		var bdString:String = toString();
		SetArchiveEntry(prefix, archive, BUILD_PREFIX, bdString);
	}
	
	public static function ClearArchive(archive:Archive, buildNumber:Number):Void
	{
		var prefix:String = BUILD_PREFIX + buildNumber;
		DeleteArchiveEntry(prefix, archive, ID_PREFIX);
		DeleteArchiveEntry(prefix, archive, NAME_PREFIX);
		DeleteArchiveEntry(prefix, archive, PARENT_PREFIX);
		DeleteArchiveEntry(prefix, archive, GROUP_PREFIX);
		DeleteArchiveEntry(prefix, archive, BUILD_PREFIX);
	}
	
	private static function SplitBuildString(buildString:String):Array
	{
		var tmpBuildItems:Array = buildString.split(SEPARATOR);
		var buildItems:Array = new Array();
		for (var i:Number = 0; i < tmpBuildItems.length; ++i)
		{
			var thisItem:String = StringUtils.Strip(tmpBuildItems[i]);
			if (thisItem != "-")
			{
				buildItems.push(thisItem);
			}
		}
		
		return buildItems;
	}

	private function SetSkillsFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_SKILLS; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var id:Number = Number(buildItems[indx]);
				if (id != null)
				{
					SetSkill(i, id);
				}
			}
		}
	}
	
	private function SetPassivesFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_PASSIVES; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var id:Number = Number(buildItems[indx]);
				if (id != null)
				{
					SetPassive(i, id);
				}
			}
		}
	}
	
	private function SetGearFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_GEAR; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var item:GearItem = GearItem.FromString(buildItems[indx]);
				if (item != null)
				{
					SetGear(i, item);
				}
			}
		}
	}
	
	private function SetWeaponsFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_WEAPONS; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var item:GearItem = GearItem.FromString(buildItems[indx]);
				if (item != null)
				{
					SetWeapon(i, item);
				}
			}
		}
	}
	
	private function SetCostumeFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_COSTUME; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var item:GearItem = GearItem.FromString(buildItems[indx]);
				if (item != null)
				{
					SetCostume(i, item);
				}
			}
		}
	}
	
	private static function FromBDArray(id:String, name:String, parent:Build, order:Number, groupID:String, buildItems:Array):Build
	{
		var ret:Build = new Build(id, name, parent, order, groupID);
		var version:String = null;
		var i:Number = 1;
		while (i < buildItems.length)
		{
			switch(buildItems[i])
			{
				case "VER":
					version = buildItems[i + 1];
					i += 2;
					break;
				case "SK":
					ret.SetSkillsFromArray(i + 1, buildItems);
					i += MAX_SKILLS + 1;
					break;
				case "PS":
					ret.SetPassivesFromArray(i + 1, buildItems);
					i += MAX_PASSIVES + 1;
					break;
				case "GR":
					ret.SetGearFromArray(i + 1, buildItems);
					i += MAX_GEAR + 1;
					break;
				case "WP":
					ret.SetWeaponsFromArray(i + 1, buildItems);
					i += MAX_WEAPONS + 1;
					break;
				case "CO":
					ret.SetCostumeFromArray(i + 1, buildItems);
					i += MAX_COSTUME + 1;
					break;
				default:
					i += 1;
			}
		}
		
		return ret;
	}
	
	public static function FromString(id:String, name:String, parent:Build, order:Number, groupID:String, buildString:String):Build
	{
		var ret:Build = null;
		var buildItems:Array = SplitBuildString(buildString);
		if (buildItems.length > 0)
		{
			if (buildItems[0] == "BD")
			{
				ret = FromBDArray(id, name, parent, order, groupID, buildItems);
			}
		}
		
		return ret;
	}
	
	private static function GetArchiveEntry(prefix:String, archive:Archive, key:String, defaultValue:String):String
	{
		var keyName:String = prefix + "_" + key;
		return archive.FindEntry(keyName, defaultValue);
	}
	
	public static function ParentFromArchive(buildNumber:Number, archive:Archive):String
	{
		var prefix:String = BUILD_PREFIX + buildNumber;
		return GetArchiveEntry(prefix, archive, PARENT_PREFIX, null);
	}
	
	public static function FromArchive(buildNumber:Number, archive:Archive, parentBuild:Build):Build
	{
		var ret:Build = null;
		var prefix:String = BUILD_PREFIX + buildNumber;
		var id:String = GetArchiveEntry(prefix, archive, ID_PREFIX, null);
		if (id != null)
		{
			var name:String = GetArchiveEntry(prefix, archive, NAME_PREFIX, null);
			var group:String = GetArchiveEntry(prefix, archive, GROUP_PREFIX, null);
			var order:String = GetArchiveEntry(prefix, archive, ORDER_PREFIX, "-1");
			var bdString:String = GetArchiveEntry(prefix, archive, BUILD_PREFIX, null);
			ret = Build.FromString(id, name, parentBuild, Number(order), group, bdString);
		}
		
		return ret;
	}
	
	private function GetFeatId(spellId:Number):Number
	{
		for (var featId in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featId];
			if (featData.m_Spell == spellId)
			{
				return featData.m_Id;
			}
		}
		
		return null;
	}
	
	public function SetCurrentSkills():Void
	{
		for (var i:Number = 0; i < MAX_SKILLS; ++i)
		{
			var shortcutData:ShortcutData = Shortcut.m_ShortcutList[GetSkillSlotID(i)];
			if (shortcutData != null)
			{
				SetSkill(i, GetFeatId(shortcutData.m_SpellId));
			}
			else
			{
				SetSkill(i, null);
			}
		}
	}
	
	private function GetSkillSlotID(indx:Number):Number
	{
		var positions:Array = [_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 2, 
								_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 4, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 5,
								_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 1, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 3 ];
		return positions[indx];
	}
	
	public function SetCurrentPassives():Void
	{
		for (var i:Number = 0; i < MAX_PASSIVES; ++i)
		{
			var passiveID:Number = Spell.GetPassiveAbility(i);
			var shortcutData:SpellData = Spell.m_PassivesList[passiveID];
			if (shortcutData != null)
			{
				SetPassive(i, GetFeatId(shortcutData.m_Id));
			}
			else
			{
				SetPassive(i, null);
			}
		}
	}
	
	private function GetGearSlotID(indx:Number):Number
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Chakra_7, _global.Enums.ItemEquipLocation.e_Chakra_4, _global.Enums.ItemEquipLocation.e_Chakra_5, _global.Enums.ItemEquipLocation.e_Chakra_6,
								_global.Enums.ItemEquipLocation.e_Chakra_1, _global.Enums.ItemEquipLocation.e_Chakra_2, _global.Enums.ItemEquipLocation.e_Chakra_3, _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1];
		return positions[indx];
	}
	
	private function SetCurrentGear():Void
	{
		var inventoryID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);
		for ( var i:Number = 0 ; i < MAX_GEAR; ++i )
		{
			SetGear(i, null);
			
			var item:InventoryItem = inventory.GetItemAt(GetGearSlotID(i));
			if (item != null)
			{
				var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(inventoryID, GetGearSlotID(i));
				var gear:GearItem = GearItem.GetGearItem(item, tooltipData);
				if (gear != null)
				{
					SetGear(i, gear);
				}
			}
		}		
	}
	
	public function SetCurrentWeapons():Void
	{
		var inventoryID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			SetWeapon(i, null);
			
			var item:InventoryItem = inventory.GetItemAt(GetWeaponSlotID(i));
			if (item != null)
			{
				var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(inventoryID, GetWeaponSlotID(i));
				var gear:GearItem = GearItem.GetGearItem(item, tooltipData);
				if (gear != null)
				{
					SetWeapon(i, gear);
				}
			}
		}
		
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			if (GetWeapon(i) == null)
			{
				ClearWeapons();
				break;
			}
		}
	}
	
	private function SetCurrentCostume():Void
	{
		var inventoryID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_Hat, _global.Enums.ItemEquipLocation.e_Wear_Face,
								_global.Enums.ItemEquipLocation.e_Wear_Neck, _global.Enums.ItemEquipLocation.e_Wear_Back,
								_global.Enums.ItemEquipLocation.e_Wear_Chest, _global.Enums.ItemEquipLocation.e_Wear_Hands,
								_global.Enums.ItemEquipLocation.e_Wear_Legs, _global.Enums.ItemEquipLocation.e_Wear_Feet,
								_global.Enums.ItemEquipLocation.e_Wear_FullOutfit];
/*		        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_FullOutfit] = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Hat]        = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Face]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Neck]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Back]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Chest]      = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Hands]      = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Belt]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Legs]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Feet]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Ring_1]          = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Ring_2]          = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_HeadAccessory]   = undefined;*/

		for ( var i:Number = 0 ; i < positions.length; ++i )
		{
			SetCostume(i, null);
			
			var item:InventoryItem = inventory.GetItemAt(positions[i]);
			if (item != null)
			{
				var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(inventoryID, positions[i]);
				var gear:GearItem = GearItem.GetGearItem(item, tooltipData);
				if (gear != null)
				{
					SetCostume(i, gear);
				}
			}
		}		
	}

	public function UpdateFromCurrent():Void
	{
		SetCurrentSkills();
		SetCurrentPassives();
		SetCurrentGear();
		SetCurrentWeapons();
		//SetCurrentCostume();
	}
	
	public static function FromCurrent(id:String, name:String, parent:Build, order:Number, groupID:String):Build
	{
		var ret:Build = new Build(id, name, parent, order, groupID);
		ret.UpdateFromCurrent();
		return ret;
	}
	
	private static function InitialiseArray(array:Array, size:Number):Void
	{
		for (var i:Number = 0; i < size; ++i)
		{
			array.push(null);
		}
	}
	
	private function ApplySkills():Void
	{
		if (m_unequipSkillsInterval != -1)
		{
			clearInterval(m_unequipSkillsInterval);
			m_unequipSkillsInterval = -1;
		}
		
		// Remove all shortcuts
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			var slotID:Number = GetSkillSlotID(indx);
			Shortcut.RemoveFromShortcutBar(slotID);
		}
		
		m_unequipSkillsCounter = 0;
		m_unequipSkillsInterval = setInterval(Delegate.create(this, ShortRemovedCB), 20);
	}
	
	private function ShortRemovedCB():Void
	{
		++m_unequipSkillsCounter;
		var empty:Boolean = AreShortcutsEmpty();
		if (empty == true)
		{
			clearInterval(m_unequipSkillsInterval);
			m_unequipSkillsCounter = 0;
			m_unequipSkillsInterval = -1;
			
			AddShortcuts();
		}
		else
		{
			if (m_unequipSkillsCounter > 200)
			{
				clearInterval(m_unequipSkillsInterval);
				InfoWindow.LogError("Failed to unequip skills");
			}
		}
	}
	
	private function AreShortcutsEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			var slotID:Number = GetSkillSlotID(indx);
			if (Shortcut.m_ShortcutList[slotID] != null)
			{
				return false;
			}
		}
		
		return true;
	}
	
	private function AddShortcuts():Void
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			var featID:Number = GetSkill(indx);
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != null)
			{
				var spellId:Number = featData.m_Spell;
				var skillName:String = featData.m_Name;
				
				var slotID:Number = GetSkillSlotID(indx);
				Shortcut.AddSpell(slotID, spellId);
			}
		}
		
		if (m_logAfterSkills == true)
		{
			InfoWindow.LogInfo("Build loaded");
		}
	}
	
	private function IsBasicAbility(featData:FeatData):Boolean
	{
		if (featData.m_SpellType == _global.Enums.SpellItemType.eBuilderAbility)
		{
			return true;
		}
		
		return false;
	}
	
	private function ApplyPassives():Void
	{
		if (m_unequipPassivesInterval != -1)
		{
			clearInterval(m_unequipPassivesInterval);
			m_unequipPassivesInterval = -1;
		}
		
		// Remove all passives
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			Spell.UnequipPassiveAbility(indx);
		}
		
		m_unequipPassivesCounter = 0;
		m_unequipPassivesInterval = setInterval(Delegate.create(this, PassiveRemovedCB), 20);
	}
	
	private function PassiveRemovedCB():Void
	{
		++m_unequipPassivesCounter;
		var empty:Boolean = ArePassivesEmpty();
		if (empty == true)
		{
			clearInterval(m_unequipPassivesInterval);
			m_unequipPassivesCounter = 0;
			m_unequipPassivesInterval = -1;
			
			AddPassives();
		}
		else
		{
			if (m_unequipPassivesCounter > 200)
			{
				clearInterval(m_unequipPassivesInterval);
				m_unequipPassivesCounter = 0;
				m_unequipPassivesInterval = -1;
				InfoWindow.LogError("Failed to unequip passives");
			}
		}
	}
	
	private function ArePassivesEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			if (SpellBase.m_PassivesList[indx] != null)
			{
				return false;
			}
		}
		
		return true;
	}
		
	private function AddPassives():Void
	{
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			var featID:Number = GetPassive(indx);
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != null)
			{
				var spellId:Number = featData.m_Spell;
				var skillName:String = featData.m_Name;
				
				Spell.EquipPassiveAbility(indx, spellId);
			}
		}
	}

	private function ApplyWeapons():Void
	{
		if (m_equipWeaponsInterval != -1)
		{
			clearInterval(m_equipWeaponsInterval);
			m_equipWeaponsInterval = -1;
		}
		
		UnequipWeapon(0);
	}
	
	private function UnequipWeapon(slot:Number):Void
	{
		m_equipWeaponSlot = slot;
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		charInv.UseItem(GetWeaponSlotID(m_equipWeaponSlot));
		
		// wait until both weapons are unequipped
		m_equipWeaponsCounter = 0;
		m_equipWeaponsInterval = setInterval(Delegate.create(this, WeaponUnequippedCB), 20);
	}
	
	private function WeaponUnequippedCB():Void
	{
		++m_equipWeaponsCounter;
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		if (charInv.GetItemAt(GetWeaponSlotID(m_equipWeaponSlot)) == null)
		{
			clearInterval(m_equipWeaponsInterval);
			m_equipWeaponsCounter = 0;
			m_equipWeaponsInterval = -1;
			
			if (m_equipWeaponSlot == 0)
			{
				UnequipWeapon(1);
			}
			else
			{
				EquipWeapon(GetWeapon(0), 0);
			}
		}
		else
		{
			if (m_equipWeaponsCounter > 100)
			{
				clearInterval(m_equipWeaponsInterval);
				m_equipWeaponsCounter = 0;
				m_equipWeaponsInterval = -1;
				InfoWindow.LogError("Failed to unequip weapons");
			}
		}
		
	}
	
	private function EquipWeapon(gear:GearItem, slot:Number):Void
	{
		if (gear != null)
		{
			var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
			var bagInv:Inventory = new Inventory(bagInvId);
			var obj:Object = GearItem.FindExactGearItem(bagInv, gear, false);
			if (obj != null)
			{
				var itemSlot:Number = obj.indx;
				var foundItem = obj.item;
				var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
				var charInv:Inventory = new Inventory(charInvId);
				charInv.AddItem(bagInvId, itemSlot, GetWeaponSlotID(slot));
				
				m_equipWeaponItem = GetWeapon(slot);
				m_equipWeaponSlot = slot;
				m_equipWeaponsCounter = 0;
				m_equipWeaponsInterval = setInterval(Delegate.create(this, WeaponEquippedCB), 20);
			}
			else
			{
				InfoWindow.LogError("Couldn't find weapon " + gear.GetName());
			}
		}
	}

	private function WeaponEquippedCB():Void
	{
		++m_equipWeaponsCounter;
		var equipped:Boolean = IsWeaponEquipped(m_equipWeaponItem, m_equipWeaponSlot);
		if (equipped == true)
		{
			clearInterval(m_equipWeaponsInterval);
			m_equipWeaponsCounter = 0;
			m_equipWeaponsInterval = -1;
			
			if (m_equipWeaponSlot == 0)
			{
				EquipWeapon(GetWeapon(1), 1);
			}
			else
			{
		
				if (m_logAfterWeapons == true)
				{
					InfoWindow.LogInfo("Build loaded");
				}
			}
		}
		else
		{
			if (m_equipWeaponsCounter > 100)
			{
				clearInterval(m_equipWeaponsInterval);
				m_equipWeaponsCounter = 0;
				m_equipWeaponsInterval = -1;
				InfoWindow.LogError("Failed to equip weapon " + m_equipWeaponItem.GetName());
			}
		}
		
	}
	
	private function IsWeaponSameType(inItem:InventoryItem, slot:Number):Boolean
	{
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var item:InventoryItem = charInv.GetItemAt(GetWeaponSlotID(1));
		if (item != null && inItem != null && inItem.m_RealType != null && inItem.m_RealType == item.m_RealType)
		{
			return true;
		}
		
		return false;
	}
	
	private function EquippedWeaponsAreSame():Boolean
	{
		if (IsWeaponEquipped(GetWeapon(0), 0) == true && IsWeaponEquipped(GetWeapon(1), 1) == true)
		{
			return true;
		}
		
		return false;
	}
	
	private function IsWeaponEquipped(gear:GearItem, slot:Number):Boolean
	{
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var obj:Object = GearItem.FindExactGearItem(charInv, gear, false);
		if (obj != null && obj.indx == GetWeaponSlotID(slot))
		{
			return true;
		}
		
		return false;
	}
	
	private function GetWeaponSlotID(slot:Number):Number
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot];
		return positions[slot];
	}
	
	private function ApplyTalismans():Void
	{
		if (m_equipTalismansInterval != -1)
		{
			clearInterval(m_equipTalismansInterval);
			m_equipTalismansInterval = -1;
		}
		
		EquipTalisman(GetGear(0), 0);
	}
	
	private function EquipTalisman(gear:GearItem, slot:Number):Void
	{
		var equipped:Boolean = false;
		if (gear != null)
		{
			equipped = IsTalismanEquipped(gear, slot);
		}
		
		if (gear != null && equipped == false)
		{
			var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
			var bagInv:Inventory = new Inventory(bagInvId);
			var obj:Object = GearItem.FindExactGearItem(bagInv, gear, false);
			if (obj != null)
			{
				var itemSlot:Number = obj.indx;
				bagInv.UseItem(itemSlot);
				
				m_equipTalismanItem = GetGear(slot);
				m_equipTalismanSlot = slot;
				m_equipTalismansCounter = 0;
				m_equipTalismansInterval = setInterval(Delegate.create(this, TalismanEquippedCB), 20);
			}
			else
			{
				InfoWindow.LogError("Couldn't find talisman " + gear.GetName());
			}
		}
		else
		{
			if (slot < MAX_GEAR)
			{
				EquipTalisman(GetGear(slot + 1), slot + 1);
			}
			else
			{
				InfoWindow.LogInfo("Build loaded");
			}
		}
	}

	private function TalismanEquippedCB():Void
	{
		++m_equipTalismansCounter;
		var equipped:Boolean = IsTalismanEquipped(m_equipTalismanItem, m_equipTalismanSlot);
		if (equipped == true)
		{
			clearInterval(m_equipTalismansInterval);
			m_equipTalismansCounter = 0;
			m_equipTalismansInterval = -1;
			
			if (m_equipTalismanSlot < MAX_GEAR)
			{
				EquipTalisman(GetGear(m_equipTalismanSlot + 1), m_equipTalismanSlot + 1);
			}
			else
			{
				InfoWindow.LogInfo("Build loaded");
			}
		}
		else
		{
			if (m_equipTalismansCounter > 100)
			{
				clearInterval(m_equipTalismansInterval);
				m_equipTalismansCounter = 0;
				m_equipTalismansInterval = -1;
				InfoWindow.LogError("Failed to equip talisman " + m_equipTalismanItem.GetName());
			}
		}
		
	}
	
	private function IsTalismanEquipped(gear:GearItem, slot:Number):Boolean
	{
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var obj:Object = GearItem.FindExactGearItem(charInv, gear, false);
		if (obj != null && obj.indx == GetGearSlotID(slot))
		{
			return true;
		}
		
		return false;
	}
	
	private function AvailableBagSpace():Number
	{
		var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);
		var bagSlot:Number = bagInv.GetFirstFreeItemSlot();
		if (bagSlot == -1)
		{
			return 0;
		}
		
		var spaces:Number = 1;
		for (var indx:Number = bagSlot + 1; indx < bagInv.GetMaxItems(); ++indx)
		{
			if (bagInv.GetItemAt(indx) == null)
			{
				++spaces;
			}
		}
		
		return spaces;
	}
}