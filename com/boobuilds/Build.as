import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemAgent;
import com.GameInterface.CharacterData;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.GearManager;
import com.GameInterface.GearData;
import com.GameInterface.GearDataAbility;
import com.GameInterface.GearDataItem;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Skills;
import com.GameInterface.Spell;
import com.GameInterface.SpellBase;
import com.GameInterface.SpellData;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.StringUtils;
import flash.geom.Point;
import com.boobuilds.Build;
import com.boobuilds.BuildGearManager;
import com.boobuilds.GearItem;
import com.boobuilds.Outfit;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.InfoWindow;
import com.boobuildscommon.IntervalCounter;
import com.boobuildscommon.InventoryThrottle;
import com.boobuildscommon.MountHelper;
import com.boobuildscommon.SubArchive;
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
class com.boobuilds.Build
{
	public static var GROUP_PREFIX:String = "Group";
	public static var BUILD_PREFIX:String = "BUILD";
	public static var QUICK_BUILD_PREFIX:String = "QUICKBUILD";
	public static var ID_PREFIX:String = "ID";
	public static var NAME_PREFIX:String = "Name";
	public static var PARENT_PREFIX:String = "Parent";
	public static var ORDER_PREFIX:String = "Order";
	public static var OUTFIT_PREFIX:String = "Outfit";
	public static var SKILL_PREFIX:String = "Skill";
	public static var PASSIVE_PREFIX:String = "Passive";
	public static var GEAR_PREFIX:String = "Gear";
	public static var WEAPON_PREFIX:String = "Weapon";
	public static var GADGET_INDEX:Number = 7;
	public static var MAX_SKILLS:Number = 6;
	public static var MAX_PASSIVES:Number = 5;
	public static var MAX_GEAR:Number = 8;
	public static var MAX_WEAPONS:Number = 2;
	public static var MAX_AGENTS:Number = 3;
	public static var SEPARATOR:String = "%";
	
	private static var CANT_UNEQUIP_ENG:String = "You cannot unequip abilities that are recharging";
	private static var CANT_UNEQUIP_FR:String = "Vous ne pouvez pas vous déséquiper de pouvoirs en train de se recharger";
	private static var CANT_UNEQUIP_DE:String = "Sie können Kräfte nicht ablegen, während sie aufgeladen werden";
	
	private static var m_buildStillLoading:Boolean = false;
	private static var m_buildLoadingID:Number = -1;
	private static var m_dismountBeforeBuild:Boolean = false;
	private static var m_currentBuildID:String = "";
	private static var m_currentToggleID:String = "";
	private static var m_prevToggleID:String = "";

	private var m_id:String;
	private var m_name:String;
	private var m_group:String;
	private var m_order:Number;
	private var m_outfit:String;
	private var m_skills:Array;
	private var m_passives:Array;
	private var m_gear:Array;
	private var m_weapons:Array;
	private var m_agents:Array;
	private var m_primaryWeaponHidden:Boolean;
	private var m_secondaryWeaponHidden:Boolean;
	private var m_requiredBuildID:String;
	private var m_useGearManager:Boolean;
	private var m_healthPct:Number;
	private var m_healPct:Number;
	private var m_damagePct:Number;
	private var m_unequipPassives:Array;
	private var m_unequipSkillsInterval:IntervalCounter;
	private var m_unequipPassivesInterval:IntervalCounter;
	private var m_gearManagerLoadInterval:IntervalCounter;
	private var m_equipWeaponSlot:Number;
	private var m_equipTalismanSlot:Number;
	private var m_logAfterSkills:Boolean;
	private var m_buildApplyQueue:Array;
	private var m_buildErrorCount:Number;
	private var m_inventoryThrottle:InventoryThrottle;
	private var m_preloadWeapons:Array;
	private var m_postloadWeapons:Array;
	private var m_loadingWeapons:Array;
	private var m_savedSkills:Array;
	private var m_newSkills:Array;
	private var m_unequipErrorSeen:Boolean;
	private var m_outfits:Object;
	private var m_destinationBuild:GearData;
	private var m_destinationAbilities:Object;
	private var m_destinationItems:Object;

	public function Build(id:String, name:String, order:Number, group:String)
	{
		m_id = id;
		SetName(name);
		m_group = group;
		m_order = order;
		m_skills = new Array();
		m_passives = new Array();
		m_gear = new Array();
		m_weapons = new Array();
		m_agents = new Array();
		m_outfit = null;
		m_primaryWeaponHidden = false;
		m_secondaryWeaponHidden = false;
		m_useGearManager = false;
		m_requiredBuildID = null;
		ClearAnimaAllocation();
		InitialiseArray(m_skills, MAX_SKILLS);
		InitialiseArray(m_passives, MAX_PASSIVES);
		InitialiseArray(m_gear, MAX_GEAR);
		InitialiseArray(m_weapons, MAX_WEAPONS);
		InitialiseArray(m_agents, MAX_AGENTS);
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
				var thisCount:Number;
				if (thisID.indexOf("#") == 0)
				{
					thisCount = Number(thisID.substring(1, thisID.length));
				}
				else
				{
					thisCount = Number(thisID.substring(2, thisID.length));
				}
				if (thisCount > lastCount)
				{
					lastCount = thisCount;
				}
			}
		}
		
		lastCount = lastCount + 1;
		return "#" + lastCount;
	}
	
	public static function GetNextQuickID(builds:Object):String
	{
		return "Q" + GetNextID(builds);
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
	
	public static function ReorderBuilds(groupID:String, builds:Object):Void
	{
		var ordered:Array = GetOrderedBuilds(groupID, builds);
		if (ordered != null)
		{
			for (var indx:Number = 0; indx < ordered.length; ++indx)
			{
				var thisBuild:Build = ordered[indx];
				thisBuild.SetOrder(indx + 1);
			}
		}
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
	
	public static function AddBuild(builds:Object, thisBuild:Build):Void
	{
		if (builds != null && thisBuild != null)
		{
			builds[thisBuild.GetID()] = thisBuild;
			if (thisBuild.GetUseGearManager() == true)
			{
				GearManager.CreateBuild(thisBuild.GetName(), undefined);
			}
		}
	}
	
	public static function UpdateBuild(thisBuild:Build):Void
	{
		if (thisBuild != null)
		{
			thisBuild.UpdateFromCurrent();
			if (thisBuild.GetUseGearManager() == true)
			{
				GearManager.DeleteBuild(thisBuild.GetName());
				GearManager.CreateBuild(thisBuild.GetName(), undefined);
			}
		}
	}
	
	public static function DeleteBuild(builds:Object, thisBuild:Build):Void
	{
		if (builds != null && thisBuild != null)
		{
			builds[thisBuild.GetID()] = null;
			if (thisBuild.GetUseGearManager() == true)
			{
				GearManager.DeleteBuild(thisBuild.GetName());
			}
		}
	}
	
	public static function RenameBuild(thisBuild:Build, newName:String):Void
	{
		if (thisBuild != null)
		{
			var oldName:String = thisBuild.GetName();
			thisBuild.SetName(newName);
			
			if (thisBuild.GetUseGearManager() == true)
			{
				if (GearManagerBuildExists(oldName) == true)
				{
					GearManager.RenameBuild(oldName, newName);
				}
				else
				{
					GearManager.CreateBuild(newName, undefined);
				}
			}
		}
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
	
	public function GetOutfitID():String
	{
		return m_outfit;
	}
	
	public function SetOutfitID(newOutfit:String):Void
	{
		m_outfit = newOutfit;
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
	
	private function SetName(newName:String):Void
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
	
	public function GetRequiredBuildID():String
	{
		return m_requiredBuildID;
	}
	
	public function SetRequiredBuildID(newID:String):Void
	{
		m_requiredBuildID = newID;
	}
	
	public function GetUseGearManager():Boolean
	{
		return m_useGearManager;
	}
	
	public function SetUseGearManager(newValue:Boolean):Void
	{
		if (m_useGearManager == true && newValue != true)
		{
			GearManager.DeleteBuild(m_name);
		}
		
		m_useGearManager = newValue;
	}
	
	public static function IsQuickBuildID(id:String):Boolean
	{
		if (id == null)
		{
			return false;
		}
		
		return id.indexOf("#") == 1;
	}
	
	public function IsQuickBuild():Boolean
	{
		return IsQuickBuildID(m_id);
	}
	
	public static function IsBuildStillLoading():Boolean
	{
		return m_buildStillLoading;
	}
	
	public static function SetDismountBeforeBuild(newValue:Boolean):Void
	{
		m_dismountBeforeBuild = newValue;
	}
	
	public static function GetCurrentBuildID():String
	{
		return m_currentBuildID;
	}

	public static function SetCurrentBuildID(newID:String):Void
	{
		m_currentBuildID = newID;
	}

	public static function GetCurrentToggleID():String
	{
		return m_currentToggleID;
	}

	public static function SetCurrentToggleID(newID:String):Void
	{
		m_currentToggleID = newID;
	}

	public static function GetPrevToggleID():String
	{
		return m_prevToggleID;
	}

	public static function SetPrevToggleID(newID:String):Void
	{
		m_prevToggleID = newID;
	}

	public function GetDamagePct():Number
	{
		return m_damagePct;
	}
	
	public function GetHealthPct():Number
	{
		return m_healthPct;
	}
	
	public function GetHealPct():Number
	{
		return m_healPct;
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
			if (i != GADGET_INDEX)
			{
				SetGear(i, null);
			}
		}
	}
	
	public function ClearGadget():Void
	{
		SetGear(GADGET_INDEX, null);
	}
	
	public function ClearWeapons():Void
	{
		for (var i:Number = 0; i < MAX_WEAPONS; ++i)
		{
			SetWeapon(i, null);
		}
		
		m_primaryWeaponHidden = false;
		m_secondaryWeaponHidden = false;
	}
	
	public function ClearAnimaAllocation():Void
	{
		m_damagePct = null;
		m_healthPct = null;
		m_healPct = null;
	}
	
	public function ClearAgents():Void
	{
		for (var i:Number = 0; i < MAX_AGENTS; ++i)
		{
			SetAgent(i, null);
		}
	}
	
	public function SetSkill(indx:Number, skillId:Number):Void
	{
		if (indx >= 0 && indx < MAX_SKILLS)
		{
			m_skills[indx] = skillId;
		}
	}
	
	public function SetPassive(indx:Number, skillId:Number):Void
	{
		if (indx >= 0 && indx < MAX_PASSIVES)
		{
			m_passives[indx] = skillId;
		}
	}
	
	public function SetGear(indx:Number, item:GearItem):Void
	{
		if (indx >= 0 && indx < MAX_GEAR)
		{
			m_gear[indx] = item;
		}
	}
	
	public function SetWeapon(indx:Number, item:GearItem):Void
	{
		if (indx >= 0 && indx < MAX_WEAPONS)
		{
			m_weapons[indx] = item;
		}
	}
	
	public function SetAgent(indx:Number, item:Number):Void
	{
		if (indx >= 0 && indx < MAX_AGENTS)
		{
			m_agents[indx] = item;
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
		}
		
		return null;
	}
	
	public function GetAgent(indx:Number):Number
	{
		if (indx >= 0 && indx < MAX_AGENTS)
		{
			if (m_agents[indx] != null && m_agents[indx] != 0)
			{
				return m_agents[indx];
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
	
	public function AreSkillsEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			if (m_skills[indx] != null)
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function IsPassiveSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_PASSIVES)
		{
			return m_passives[indx] != null;
		}
		
		return false;
	}
	
	public function ArePassivesEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			if (m_passives[indx] != null)
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function IsGearSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_GEAR)
		{
			return m_gear[indx] != null;
		}
		
		return false;
	}
	
	public function AreGearEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_GEAR; ++indx)
		{
			if (indx != GADGET_INDEX)
			{
				if (m_gear[indx] != null)
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	public function IsGadgetEmpty():Boolean
	{
		return m_gear[GADGET_INDEX] == null;
	}
	
	public function IsWeaponSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_WEAPONS)
		{
			return m_weapons[indx] != null;
		}
		
		return false;
	}
	
	public function AreWeaponsEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_WEAPONS; ++indx)
		{
			if (m_weapons[indx] != null)
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function IsAgentSet(indx:Number):Boolean
	{
		if (indx >= 0 && indx < MAX_AGENTS)
		{
			return m_agents[indx] != null;
		}
		
		return false;
	}
	
	public function AreAgentsEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_AGENTS; ++indx)
		{
			if (m_agents[indx] != null)
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function toExportString():String
	{
		var ret:String = "BD" + SEPARATOR + "-" + SEPARATOR + "VER" + SEPARATOR + "-" + SEPARATOR + "1.0" + SEPARATOR;
		ret = ret + SubArchive.GetArrayString("SK", m_skills);
		ret = ret + SubArchive.GetArrayString("PS", m_passives);
		return ret;
	}
	
	public function toString():String
	{
		var ret:String = toExportString();
		ret = ret + SubArchive.GetArrayGearItemString("GR", m_gear);
		ret = ret + SubArchive.GetArrayGearItemString("WP", m_weapons);
		var tempArray:Array = [ String(m_primaryWeaponHidden), String(m_secondaryWeaponHidden) ];
		ret = ret + SubArchive.GetArrayString("WV", tempArray);
		
		if (m_damagePct != null)
		{
			var aaArray:Array = [ String(m_healthPct), String(m_healPct) ];
			ret = ret + SubArchive.GetArrayString("AA", aaArray);
		}
		
		if (m_requiredBuildID != null)
		{
			ret = ret + SubArchive.GetArrayString("RB", [ m_requiredBuildID ]);
		}
		if (m_useGearManager == true)
		{
			ret = ret + SubArchive.GetArrayString("GM", [ true ]);
		}
		if (AreAgentsEmpty() != true)
		{
			ret = ret + SubArchive.GetArrayString("AG", m_agents);
		}
		return ret;
	}
	
	public function Save(prefix:String, archive:Archive, buildNumber:Number):Void
	{
		var key:String = prefix + buildNumber;
		SubArchive.SetArchiveEntry(key, archive, ID_PREFIX, m_id);
		SubArchive.SetArchiveEntry(key, archive, NAME_PREFIX, m_name);		
		SubArchive.SetArchiveEntry(key, archive, GROUP_PREFIX, m_group);
		SubArchive.SetArchiveEntry(key, archive, ORDER_PREFIX, String(m_order));
		SubArchive.SetArchiveEntry(key, archive, OUTFIT_PREFIX, m_outfit);
		
		var bdString:String = toString();
		SubArchive.SetArchiveEntry(key, archive, BUILD_PREFIX, bdString);
	}
	
	public static function ClearArchive(prefix:String, archive:Archive, buildNumber:Number):Void
	{
		var key:String = prefix + buildNumber;
		SubArchive.DeleteArchiveEntry(key, archive, ID_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, NAME_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, PARENT_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, GROUP_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, ORDER_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, OUTFIT_PREFIX);
		SubArchive.DeleteArchiveEntry(key, archive, BUILD_PREFIX);
	}
	
	public static function SplitArrayString(buildString:String):Array
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
	
	private function SetWeaponHiddenFromArray(offset:Number, buildItems:Array):Void
	{
		var primaryIndx:Number = 0 + offset;
		if (primaryIndx < buildItems.length && buildItems[primaryIndx] != "undefined")
		{
			var item:Boolean = buildItems[primaryIndx] == "true";
			if (item == true)
			{
				m_primaryWeaponHidden = true;
			}
			else
			{
				m_primaryWeaponHidden = false;
			}			
		}
		
		var secondaryIndx:Number = 1 + offset;
		if (secondaryIndx < buildItems.length && buildItems[secondaryIndx] != "undefined")
		{
			var item:Boolean = buildItems[secondaryIndx] == "true";
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
	
	private function SetAnimaAllocationFromArray(offset:Number, buildItems:Array):Void
	{
		ClearAnimaAllocation();
		
		var primaryIndx:Number = 0 + offset;
		if (primaryIndx < buildItems.length && buildItems[primaryIndx] != "undefined")
		{
			var item:Number = Number(buildItems[primaryIndx]);
			if (!isNaN(item))
			{
				m_healthPct = item
			}
		}
		
		var secondaryIndx:Number = 1 + offset;
		if (secondaryIndx < buildItems.length && buildItems[secondaryIndx] != "undefined")
		{
			var item:Number = Number(buildItems[secondaryIndx]);
			if (!isNaN(item))
			{
				m_healPct = item;
			}
		}
		
		if (m_healPct != null && m_healthPct != null)
		{
			m_damagePct = 100 - m_healPct - m_healthPct;
		}
		else
		{
			ClearAnimaAllocation();
		}
	}
	
	private function SetRequiredBuildFromArray(offset:Number, buildItems:Array):Void
	{
		var indx:Number = 0 + offset;
		if (indx < buildItems.length && buildItems[indx] != "undefined")
		{
			m_requiredBuildID = buildItems[indx];
		}
	}
	
	private function SetUseGearManagerFromArray(offset:Number, buildItems:Array):Void
	{
		var indx:Number = 0 + offset;
		if (indx < buildItems.length && buildItems[indx] != "undefined")
		{
			m_useGearManager = buildItems[indx] == "true";
		}
	}
	
	private function SetAgentsFromArray(offset:Number, buildItems:Array):Void
	{
		for (var i:Number = 0; i < MAX_AGENTS; ++i)
		{
			var indx:Number = i + offset;
			if (indx < buildItems.length && buildItems[indx] != "undefined")
			{
				var item:Number = Number(buildItems[indx]);
				if (!isNaN(item))
				{
					SetAgent(i, item);
				}
			}
		}
	}
	
	private static function FromBDArray(id:String, name:String, order:Number, groupID:String, buildItems:Array):Build
	{
		var ret:Build = new Build(id, name, order, groupID);
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
				case "WV":
					ret.SetWeaponHiddenFromArray(i + 1, buildItems);
					i += MAX_WEAPONS + 1;
					break;
				case "AA":
					ret.SetAnimaAllocationFromArray(i + 1, buildItems);
					i += 2 + 1;
					break;
				case "RB":
					ret.SetRequiredBuildFromArray(i + 1, buildItems);
					i += 1;
					break;
				case "GM":
					ret.SetUseGearManagerFromArray(i + 1, buildItems);
					i += 1;
					break;
				case "AG":
					ret.SetAgentsFromArray(i + 1, buildItems);
					i += MAX_AGENTS + 1;
					break;
				default:
					i += 1;
			}
		}
		
		return ret;
	}
	
	public static function FromString(id:String, name:String, order:Number, groupID:String, buildString:String):Build
	{
		var ret:Build = null;
		var buildItems:Array = SplitArrayString(buildString);
		if (buildItems.length > 0)
		{
			if (buildItems[0] == "BD")
			{
				ret = FromBDArray(id, name, order, groupID, buildItems);
			}
		}
		
		return ret;
	}
	
	private static function GetArchiveEntry(prefix:String, archive:Archive, key:String, defaultValue:String):String
	{
		var keyName:String = prefix + "_" + key;
		return archive.FindEntry(keyName, defaultValue);
	}
	
	public static function FromArchive(prefix:String, buildNumber:Number, archive:Archive):Build
	{
		var ret:Build = null;
		var key:String = prefix + buildNumber;
		var id:String = GetArchiveEntry(key, archive, ID_PREFIX, null);
		if (id != null)
		{
			var name:String = GetArchiveEntry(key, archive, NAME_PREFIX, null);
			var group:String = GetArchiveEntry(key, archive, GROUP_PREFIX, null);
			var order:String = GetArchiveEntry(key, archive, ORDER_PREFIX, "-1");
			var outfit:String = GetArchiveEntry(key, archive, OUTFIT_PREFIX, null);
			var bdString:String = GetArchiveEntry(key, archive, BUILD_PREFIX, null);
			ret = Build.FromString(id, name, Number(order), group, bdString);
			ret.SetOutfitID(outfit);
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
	
	public function SetCurrentAnimaAllocation():Void
	{
		var character:Character = Character.GetClientCharacter();
		m_healPct = character.GetStat(_global.Enums.Stat.e_TriangleHealingRatio, 2);
		m_healthPct = character.GetStat(_global.Enums.Stat.e_TriangleHealthRatio, 2);
		m_damagePct = 100 - m_healPct - m_healthPct;
		
	}
	
	public function SetCurrentAgents():Void
	{
		for (var i:Number = 0; i < MAX_AGENTS; ++i)
		{
			var passive:Number = null;
			var spellId:Number = AgentSystem.GetPassiveInSlot(i);
			if (spellId != 0)
			{
				var agent:AgentSystemAgent = AgentSystem.GetAgentForPassiveSlot(i);
				if (agent != null)
				{
					passive = agent.m_AgentId;
				}
			}
			
			m_agents[i] = passive;
		}
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
		var weapons:Array = GetCurrentWeapons();
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			SetWeapon(i, null);
			
			var gear:GearItem = weapons[i];
			if (gear != null)
			{
				SetWeapon(i, gear);
				
				if (i == 0)
				{
					m_primaryWeaponHidden = GearManager.IsPrimaryWeaponHidden();
				}
				else if (i == 1)
				{
					m_secondaryWeaponHidden = GearManager.IsSecondaryWeaponHidden();
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
	
	private function GetCurrentWeapons():Array
	{
		var ret:Array = new Array();
		var inventoryID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			ret.push(null);
			
			var item:InventoryItem = inventory.GetItemAt(GetWeaponSlotID(i));
			if (item != null)
			{
				var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(inventoryID, GetWeaponSlotID(i));
				var gear:GearItem = GearItem.GetGearItem(item, tooltipData);
				if (gear != null)
				{
					ret[i] = gear;
				}
			}
		}
		
		return ret;
	}
	
	public function UpdateFromCurrent():Void
	{
		SetCurrentSkills();
		SetCurrentPassives();
		SetCurrentGear();
		SetCurrentWeapons();
		SetCurrentAnimaAllocation();
		SetCurrentAgents();
	}
	
	public static function FromCurrent(id:String, name:String, order:Number, groupID:String):Build
	{
		var ret:Build = new Build(id, name, order, groupID);
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
	
	public function Apply(outfits:Object):Void
	{
		if (m_buildStillLoading == true)
		{
			InfoWindow.LogError("Please wait on previous build to load");
		}
		else if (Character.GetClientCharacter().IsInCombat() == true)
		{
			InfoWindow.LogError("Cannot load a build while in combat");
		}
		else
		{
			if (Build.m_buildLoadingID != -1)
			{
				clearTimeout(Build.m_buildLoadingID);
			}
			
			Build.m_buildStillLoading = true;
			Build.m_buildLoadingID = setTimeout(Delegate.create(this, function() { Build.m_buildStillLoading = false; Build.m_buildLoadingID = -1; }), 5000);
			m_outfits = outfits;
		
			if (m_dismountBeforeBuild == true)
			{
				MountHelper.Dismount(Delegate.create(this, ContinueAfterDismount));
			}
			else
			{
				ContinueAfterDismount();
			}			
		}
	}
	
	private function PostGearManagerLoad():Void
	{
		var doWeapons:Boolean = false;
		var doTalismans:Boolean = false;
		var weaponCount:Number = 0;
		for (var indx:Number = 0; indx < m_weapons.length; ++indx)
		{
			if (GetWeapon(indx) != null)
			{
				++weaponCount;
			}
		}
		
		if (weaponCount > 0)
		{
			if (EquippedWeaponsAreSame() == true)
			{
				SetWeaponHidden(0);
				SetWeaponHidden(1);
			}
			else
			{
				if (AvailableBagSpace() < weaponCount)
				{
					InfoWindow.LogError("You must have " + weaponCount + " free bag slots to equip this build!");
					return;
				}
				
				doWeapons = true;
			}
		}
		
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
		
		if (m_damagePct != null && m_healthPct != null && m_healPct != null)
		{
			Skills.SetCombatTriangle(m_damagePct, m_healthPct, m_healPct);
		}
		
		ApplyAgents();
		
		m_buildApplyQueue = new Array();
		ClearInventoryThrottle();			
		m_buildErrorCount = 0;
		
		if (m_outfit != null && m_outfits != null && m_outfits[m_outfit] != null)
		{
			var endCallback:Function = Delegate.create(this, function (i:Number) { this.m_buildErrorCount += i; this.ApplyBuildQueue(); } );
			m_buildApplyQueue.push(Delegate.create(this, function() { this.m_outfits[this.m_outfit].ApplyAfterBuild(endCallback); }));
		}
		else
		{
			Outfit.ApplyCurrentOutfitWeaponSkins(m_outfits);
		}
		
		m_buildApplyQueue.push(Delegate.create(this, MoveWeapons));
		
		if (doWeapons == true)
		{
			m_buildApplyQueue.push(Delegate.create(this, ApplyWeapons));
		}
		
		if (doTalismans == true)
		{
			m_buildApplyQueue.push(Delegate.create(this, ApplyTalismans));
		}
		
		CheckSkillsAndContinue();
	}

	private function ContinueAfterDismount():Void
	{
		GetPreloadWeaponLocations();
		LoadFromGearManager();
	}
	
	private function ContinueApply():Void
	{
			ApplyPassives();
			
			if (m_buildApplyQueue.length > 0)
			{
				m_logAfterSkills = false;
				ApplySkills();
				ApplyBuildQueue();
			}
			else
			{
				m_logAfterSkills = true;
				ApplySkills();
			}
	}
	
	private function ApplyBuildQueue():Void
	{
		var finished:Boolean = false;
		if (m_logAfterSkills == true)
		{
			finished = true;
		}
		else if (m_buildApplyQueue == null || m_buildApplyQueue.length < 1)
		{
			finished = true;
		}
		
		if (finished == true)
		{
			EndApply();
		}		
		else
		{
			var nextFunc:Function = Function(m_buildApplyQueue.pop());
			nextFunc();
		}
	}
	
	private function EndApply():Void
	{
		ClearInventoryThrottle();
		ClearBuildLoading();
		m_buildApplyQueue = null;
		
		if (m_buildErrorCount > 0)
		{
			InfoWindow.LogError("Build load failed: " + m_name);
		}
		else
		{
			if (IsQuickBuild() != true)
			{
				SetCurrentBuildID(GetID());
			}
			
			if (GetCurrentToggleID() != m_id)
			{
				SetPrevToggleID(GetCurrentToggleID());
				SetCurrentToggleID(m_id);
			}
			
			if (m_useGearManager == true && CanWriteToGearManager(m_name) == true)
			{
				GearManager.CreateBuild(m_name, undefined);
			}
			
			InfoWindow.LogInfo("Build loaded: " + m_name);
		}
	}
	
	private function ClearBuildLoading():Void
	{
		if (Build.m_buildLoadingID != -1)
		{
			clearTimeout(Build.m_buildLoadingID);
			Build.m_buildLoadingID = -1;
		}
		
		Build.m_buildStillLoading = false;			
	}
	
	private function CheckSkillsAndContinue():Void
	{
		m_savedSkills = new Array();
		m_newSkills = new Array();
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			m_newSkills.push(null);
			if (IsSkillSet(indx) == true)
			{
				var featID:Number = GetSkill(indx);
				var featData:FeatData = FeatInterface.m_FeatList[featID];
				if (featData != null)
				{
					m_newSkills[indx] = featData.m_Spell;
				}
			}
			
			var slotID:Number = GetSkillSlotID(indx);
			var shortcut:ShortcutData = Shortcut.m_ShortcutList[slotID];
			m_savedSkills.push(shortcut);
			
			if (shortcut != null)
			{
				if (shortcut.m_SpellId == m_newSkills[indx])
				{
					m_newSkills[indx] = null;
				}
			}
		}
		
		m_unequipErrorSeen = false;
		com.GameInterface.Chat.SignalShowFIFOMessage.Connect(FIFOMessageHandler, this);
		RemoveSkills();
	}
	
	private function FIFOMessageHandler(text:String, mode:Number):Void
	{
		if (text != null && (text.indexOf(CANT_UNEQUIP_ENG, 0) == 0 || text.indexOf(CANT_UNEQUIP_FR, 0) == 0 || text.indexOf(CANT_UNEQUIP_DE) == 0))
		{
			m_unequipErrorSeen = true;
		}
	}
	
	private function ClearInventoryThrottle():Void
	{
		if (m_inventoryThrottle != null)
		{
			m_inventoryThrottle.Cleanup();
			m_inventoryThrottle = null;
		}
	}
	
	private function RemoveSkills():Void
	{
		if (m_unequipSkillsInterval != null)
		{
			m_unequipSkillsInterval.Stop();
			m_unequipPassivesInterval = null;
		}
		
		// Remove all shortcuts
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			if (m_newSkills[indx] != null)
			{
				var slotID:Number = GetSkillSlotID(indx);
				Shortcut.RemoveFromShortcutBar(slotID);
			}
		}
		
		m_unequipSkillsInterval = new IntervalCounter("Unequip skills", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, ShortRemovedCheck), Delegate.create(this, ShortRemovedComplete), Delegate.create(this, ShortRemovedError), IntervalCounter.NO_COMPLETE_ON_ERROR);
	}
	
	private function ShortRemovedCheck():Boolean
	{
		var moveOn:Boolean = false;
		var empty:Boolean = AreShortcutsEmpty();
		if (empty == true)
		{
			moveOn = true;
		}
		
		if (m_unequipErrorSeen == true)
		{
			moveOn = true;
			InfoWindow.LogError("Cannot load a build when skill is on cooldown");
		}
		
		return moveOn;
	}
	
	private function ShortRemovedComplete():Void
	{
		com.GameInterface.Chat.SignalShowFIFOMessage.Disconnect(FIFOMessageHandler, this);
		
		if (m_unequipErrorSeen == true)
		{
			RestoreSkills();
		}
		else
		{
			ContinueApply();
		}
	}
	
	private function ShortRemovedError():Void
	{
		InfoWindow.LogError("Failed to unequip skills");
		RestoreSkills();
	}
		
	private function RestoreSkills():Void
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			var skill:ShortcutData = m_savedSkills[indx];
			if (skill != null)
			{
				var slotID:Number = GetSkillSlotID(indx);
				Shortcut.AddSpell(slotID, skill.m_SpellId);
			}
		}
		
		ClearBuildLoading();
	}
	
	private function AreShortcutsEmpty():Boolean
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			if (m_newSkills[indx] != null)
			{
				var slotID:Number = GetSkillSlotID(indx);
				if (Shortcut.m_ShortcutList[slotID] != null)
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	private function ApplySkills():Void
	{
		for (var indx:Number = 0; indx < MAX_SKILLS; ++indx)
		{
			if (m_newSkills[indx] != null)
			{
				var slotID:Number = GetSkillSlotID(indx);
				Shortcut.AddSpell(slotID, m_newSkills[indx]);
			}
		}
		
		if (m_logAfterSkills == true)
		{
			ApplyBuildQueue();
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
		if (m_unequipPassivesInterval != null)
		{
			m_unequipPassivesInterval.Stop();
			m_unequipPassivesInterval = null;
		}
		
		// Remove all passives
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			if (IsPassiveSet(indx) == true)
			{
				Spell.UnequipPassiveAbility(indx);
			}
		}
		
		m_unequipPassivesInterval = new IntervalCounter("Unequip passives", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, PassiveRemovedCheck), Delegate.create(this, PassiveRemovedComplete), Delegate.create(this, PassiveRemovedError), IntervalCounter.NO_COMPLETE_ON_ERROR);
	}
	
	private function PassiveRemovedCheck():Boolean
	{
		var moveOn:Boolean = false;
		var empty:Boolean = ArePassivesRemoved();
		if (empty == true)
		{
			moveOn = true;
		}

		return moveOn;
	}
	
	private function PassiveRemovedComplete():Void
	{
		AddPassives();
	}
	
	private function PassiveRemovedError():Void
	{
		InfoWindow.LogError("Failed to unequip passives");
		++m_buildErrorCount;
	}
	
	private function ArePassivesRemoved():Boolean
	{
		for (var indx:Number = 0; indx < MAX_PASSIVES; ++indx)
		{
			if (IsPassiveSet(indx) == true && SpellBase.m_PassivesList[indx] != null)
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
			if (IsPassiveSet(indx) == true)
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
	}
	
	private function ApplyAgents():Void
	{
		if (m_useGearManager != true || GearManagerBuildExists(m_name) != true)
		{
			if (AreAgentsEmpty() != true)
			{
				for (var indx:Number = 0; indx < MAX_AGENTS; ++indx)
				{
					AgentSystem.UnequipPassive(indx);
				}
				
				for (var indx:Number = 0; indx < MAX_AGENTS; ++indx)
				{
					if (IsAgentSet(indx) == true)
					{
						AgentSystem.EquipPassive(GetAgent(indx), indx);
					}
				}
			}
		}
	}

	private function ApplyWeapons():Void
	{
		m_equipWeaponSlot = -1;
		WeaponUnequippedCompletionCallback();
	}
	
	private function UnequipWeapon():Boolean
	{
		if (GetWeapon(m_equipWeaponSlot) == null)
		{
			DebugWindow.Log("Unequip null " + m_equipWeaponSlot);
			return true;
		}
		else
		{
			var weaponSlot:Number = GetWeaponSlotID(m_equipWeaponSlot);			
			var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
			var charInv:Inventory = new Inventory(charInvId);
			charInv.UseItem(weaponSlot);
			return false;
		}
	}
	
	private function WeaponUnequippedCheckCallback():Boolean
	{
		var moveOn:Boolean = false;
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		if (charInv.GetItemAt(GetWeaponSlotID(m_equipWeaponSlot)) == null)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function WeaponUnequippedErrorCallback():Void
	{
		InfoWindow.LogError("Failed to unequip weapons");
		++m_buildErrorCount;
		EndApply();
	}
	
	private function WeaponUnequippedCompletionCallback():Void
	{
		if (m_equipWeaponSlot < 1)
		{
			++m_equipWeaponSlot;
			ClearInventoryThrottle();
			m_inventoryThrottle = new InventoryThrottle("Unequip weapon", Delegate.create(this, UnequipWeapon), Delegate.create(this, WeaponUnequippedCheckCallback), Delegate.create(this, WeaponUnequippedCompletionCallback), Delegate.create(this, WeaponUnequippedErrorCallback), IntervalCounter.NO_COMPLETE_ON_ERROR);
		}
		else
		{
			m_equipWeaponSlot = -1;
			WeaponEquippedCompletionCallback();
		}
	}
	
	private function EquipWeapon():Boolean
	{
		var moveOn:Boolean = false;
		var gear:GearItem = GetWeapon(m_equipWeaponSlot);
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
				charInv.AddItem(bagInvId, itemSlot, GetWeaponSlotID(m_equipWeaponSlot));
				DebugWindow.Log(DebugWindow.Info, "Adding " + gear.GetName());
			}
			else
			{
				InfoWindow.LogError("Couldn't find weapon " + gear.GetName());
				++m_buildErrorCount;
				moveOn = true;
			}
		}
		else
		{
			DebugWindow.Log("Equip null " + m_equipWeaponSlot);
			moveOn = true;
		}
		
		return moveOn;
	}

	private function WeaponEquippedCheckCallback():Boolean
	{
		var moveOn:Boolean = false;
		var gear:GearItem = GetWeapon(m_equipWeaponSlot);
		var equipped:Boolean = IsWeaponEquipped(gear, m_equipWeaponSlot);
		if (equipped == true)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function WeaponEquippedCompletionCallback():Void
	{
		SetWeaponHidden(m_equipWeaponSlot);
		
		if (m_equipWeaponSlot < 1)
		{
			++m_equipWeaponSlot;
			ClearInventoryThrottle();
			m_inventoryThrottle = new InventoryThrottle("Equip weapon", Delegate.create(this, EquipWeapon), Delegate.create(this, WeaponEquippedCheckCallback), Delegate.create(this, WeaponEquippedCompletionCallback), Delegate.create(this, WeaponEquippedErrorCallback), IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			ApplyBuildQueue();
		}
	}
	
	private function WeaponEquippedErrorCallback():Void
	{
		var gear:GearItem = GetWeapon(m_equipWeaponSlot);
		InfoWindow.LogError("Failed to equip weapon " + gear.GetName());
		++m_buildErrorCount;
	}
	
	private function SetWeaponHidden(slot:Number):Void
	{
		if (GetWeapon(slot) != null)
		{
			if (slot == 0 && m_primaryWeaponHidden != null)
			{
				GearManager.SetPrimaryWeaponHidden(m_primaryWeaponHidden);
			}
			
			if (slot == 1 && m_secondaryWeaponHidden != null)
			{
				GearManager.SetSecondaryWeaponHidden(m_secondaryWeaponHidden);
			}
		}
	}
	
	private function MoveWeapons():Void
	{
		GetPostloadWeaponLocations();
		m_equipWeaponSlot = -1;
		MoveWeaponCompletionCallback();
	}
	
	private function MoveWeapon():Boolean
	{
		var moveOn:Boolean = true;
		var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);
		if (m_loadingWeapons[m_equipWeaponSlot] != null && m_postloadWeapons[m_equipWeaponSlot] != null)
		{
			if (m_loadingWeapons[m_equipWeaponSlot].iconBox != null && m_loadingWeapons[m_equipWeaponSlot].point != null)
			{
				var dstIconBox:Object = m_loadingWeapons[m_equipWeaponSlot].iconBox;
				if (dstIconBox.GetItemAtGridPosition(m_loadingWeapons[m_equipWeaponSlot].point) == undefined)
				{
					var srcIconBox:Object = m_postloadWeapons[m_equipWeaponSlot].iconBox;
					if (srcIconBox != null)
					{
						srcIconBox.RemoveItem(m_postloadWeapons[m_equipWeaponSlot].slot);
					}
					
					dstIconBox.AddItemAtGridPosition(m_postloadWeapons[m_equipWeaponSlot].slot, bagInv.GetItemAt(m_postloadWeapons[m_equipWeaponSlot].slot), m_loadingWeapons[m_equipWeaponSlot].point);
				}
			}
			else
			{
				// move the weapon to the freed up slot
				bagInv.AddItem(bagInvId, m_postloadWeapons[m_equipWeaponSlot].slot, m_loadingWeapons[m_equipWeaponSlot].slot);
				moveOn = false;
			}
		}
		
		return moveOn;
	}
	
	private function MoveWeaponCheckCallback():Boolean
	{
		var moveOn:Boolean = false;
		var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);
		var item:InventoryItem = bagInv.GetItemAt(m_loadingWeapons[m_equipWeaponSlot].slot);
		if (GearItem.IsItemMatching(item, m_postloadWeapons[m_equipWeaponSlot].gearItem, false) == true)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function MoveWeaponCompletionCallback():Void
	{
		++m_equipWeaponSlot;
		if (m_buildErrorCount == 0 && m_equipWeaponSlot < m_postloadWeapons.length && m_equipWeaponSlot < m_loadingWeapons.length)
		{
			ClearInventoryThrottle();
			m_inventoryThrottle = new InventoryThrottle("Move weapon", Delegate.create(this, MoveWeapon), Delegate.create(this, MoveWeaponCheckCallback), Delegate.create(this, MoveWeaponCompletionCallback), Delegate.create(this, MoveWeaponErrorCallback), IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			ApplyBuildQueue();
		}
	}
	
	private function MoveWeaponErrorCallback():Void
	{
		DebugWindow.Log(DebugWindow.Info, "Failed to move weapon " + m_equipWeaponSlot);
	}

	private function GetIconBox(bagID:ID32, slot:Number):Object
	{
		var iconBox:Object = null;
		if (_root["backpack2"] != null)
		{
			iconBox = _root["backpack2"].GetIconBoxContainingItemSlot(bagID, slot);
		}
		
		return iconBox;
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
		var weaponOne:Boolean = false;
		if (GetWeapon(0) == null || IsWeaponEquipped(GetWeapon(0), 0) == true)
		{
			weaponOne = true;
		}

		var weaponTwo:Boolean = false;
		if (GetWeapon(1) == null || IsWeaponEquipped(GetWeapon(1), 1) == true)
		{
			weaponTwo = true;
		}

		return weaponOne && weaponTwo;
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
		m_equipTalismanSlot = -1;
		TalismanCompletionCallback();
	}
	
	private function EquipTalisman():Boolean
	{
		var moveOn:Boolean = false;
		var equipped:Boolean = false;
		var gear:GearItem = GetGear(m_equipTalismanSlot);
		if (gear != null)
		{
			equipped = IsTalismanEquipped(gear, m_equipTalismanSlot);
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
			}
			else
			{
				InfoWindow.LogError("Couldn't find talisman " + gear.GetName());
				++m_buildErrorCount;
				moveOn = true;
			}
		}
		else
		{
			moveOn = true;
		}
		
		return moveOn;
	}

	private function TalismanEquippedCallback():Boolean
	{
		var moveOn:Boolean = false;
		var gear:GearItem = GetGear(m_equipTalismanSlot);
		var equipped:Boolean = IsTalismanEquipped(gear, m_equipTalismanSlot);
		if (equipped == true)
		{
			moveOn = true;
		}
		
		return moveOn;
	}
	
	private function TalismanCompletionCallback():Void
	{
		++m_equipTalismanSlot;
		if (m_equipTalismanSlot < MAX_GEAR)
		{
			ClearInventoryThrottle();
			m_inventoryThrottle = new InventoryThrottle("Equip talisman", Delegate.create(this, EquipTalisman), Delegate.create(this, TalismanEquippedCallback), Delegate.create(this, TalismanCompletionCallback), Delegate.create(this, TalismanErrorCallback), IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			ApplyBuildQueue();
		}
	}
	
	private function TalismanErrorCallback():Void
	{
		var gear:GearItem = GetGear(m_equipTalismanSlot);
		InfoWindow.LogError("Failed to equip talisman " + gear.GetName());
		++m_buildErrorCount;
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
	
	public static function GearManagerBuildExists(buildName:String):Boolean
	{
		var ret:Boolean = false;
		var gmBuildNames:Array = GearManager.GetBuildList();
		if (gmBuildNames != null)
		{
			for (var indx:Number = 0; indx < gmBuildNames.length; ++indx)
			{
				if (gmBuildNames[indx] == buildName)
				{
					ret = true;
				}
			}
		}
		
		return ret;
	}
	
	public static function CanWriteToGearManager(buildName:String):Boolean
	{
		var ret:Boolean = GearManagerBuildExists(buildName);
		if (ret != true)
		{
			var usedSlots:Number = 0;
			var gmBuildNames:Array = GearManager.GetBuildList();
			if (gmBuildNames != null)
			{
				usedSlots = gmBuildNames.length;
			}
			
			if (usedSlots < GetGearManagerSlots())
			{
				ret = true;
			}
		}
		
		return ret;
	}
	
	private static function GetGearManagerSlots():Number
	{
        var defaultSlotsAmount:Number = com.GameInterface.Utils.GetGameTweak("FreeGearBuildSlots");
        var additionalSlotsAmount:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_UnlockedGearBuildSlots);
        return defaultSlotsAmount + additionalSlotsAmount;
	}
	
	private function LoadFromGearManager():Void
	{
		if (m_gearManagerLoadInterval != null)
		{
			m_gearManagerLoadInterval.Stop();
			m_gearManagerLoadInterval = null;
		}

		if (m_useGearManager == true && GearManagerBuildExists(m_name) == true)
		{
			m_destinationBuild = GearManager.GetBuild(m_name);
			m_destinationAbilities = new Object();
			if (m_destinationBuild != null && m_destinationBuild.m_AbilityArray != null)
			{
				for (var indx:Number = 0; indx < m_destinationBuild.m_AbilityArray.length; ++indx)
				{
					var thisItem:GearDataAbility = m_destinationBuild.m_AbilityArray[indx];
					m_destinationAbilities[thisItem.m_Position] = thisItem.m_SpellData;
				}
			}
			
			m_destinationItems = new Object();
			if (m_destinationBuild != null && m_destinationBuild.m_ItemArray != null)
			{
				for (var indx:Number = 0; indx < m_destinationBuild.m_ItemArray.length; ++indx)
				{
					var thisItem:GearDataItem = m_destinationBuild.m_ItemArray[indx];
					m_destinationItems[thisItem.m_Position] = thisItem.m_InventoryItem;
				}
			}
			
			DebugWindow.Log(DebugWindow.Debug, "Loading " + m_name);
			GearManager.UseBuild(m_name);
			m_gearManagerLoadInterval = new IntervalCounter("GearManager Load", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, CheckGearManagerLoad), Delegate.create(this, GearManagerLoadComplete), null, IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			GearManagerLoadComplete();
		}
	}

	private function CheckGearManagerLoad():Boolean
	{
		return BuildGearManager.CheckGearManagerLoad(m_destinationBuild, m_destinationAbilities, m_destinationItems);
	}

	private function GearManagerLoadComplete():Void
	{
		PostGearManagerLoad();
	}
	
	/*private function CompareGearAbility(ability1:SpellData, ability2:SpellData):Boolean
	{
		
		if (ability1 == null && ability2 == null)
		{
			return true;
		}
		else
		{
			if (ability1 != null && ability2 != null)
			{
				if (ability1.m_Id == ability2.m_Id)
				{
					return true;
				}
			}
		}
		
		//DebugWindow.Log(DebugWindow.Debug, "Spells different " + ability1.m_Name + " " + ability2.m_Name);
		return false;
	}
	
	private function CompareGearItem(item1:InventoryItem, item2:InventoryItem):Boolean
	{
		if (item1 == null && item2 == null)
		{
			return true;
		}
		else
		{
			if (item1 != null && item2 != null)
			{
				if (item1.m_Name == item2.m_Name && item1.m_Pips == item2.m_Pips)
				{
					return true;
				}
			}
		}
		
		//DebugWindow.Log(DebugWindow.Debug, "Items different " + item1.m_Name + " " + item1.m_Pips + " " + item2.m_Name + " " + item2.m_Pips);
		return false;
	}*/

	private function GetPreloadWeaponLocations():Void
	{
		m_preloadWeapons = new Array();
		var weapons:Array = GetCurrentWeapons();
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			m_preloadWeapons.push(null);
			if (weapons[i] != null)
			{
				m_preloadWeapons[i] = weapons[i];
			}
		}
		
		m_loadingWeapons = new Array();
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			if (GetWeapon(i) != null)
			{
				var weapon:Object = FindWeapon(GetWeapon(i));
				if (weapon != null && weapon.isEquipped != true && weapon.slot != null)
				{
					m_loadingWeapons.push(weapon);
				}
			}
		}
	}
	
	private function GetPostloadWeaponLocations():Void
	{
		m_postloadWeapons = new Array();
		for ( var i:Number = 0 ; i < MAX_WEAPONS; ++i )
		{
			if (m_preloadWeapons[i] != null)
			{
				var weapon:Object = FindWeapon(m_preloadWeapons[i]);
				if (weapon != null && weapon.isEquipped != true && weapon.slot != null)
				{
					weapon.gearItem = m_preloadWeapons[i];
					m_postloadWeapons.push(weapon);
				}
			}
		}
	}
	
	private function FindWeapon(weapon:GearItem):Object
	{
		var ret:Object = new Object();
		var weaponInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance());
		var weaponInv:Inventory = new Inventory(weaponInvID);
		var found:Object = GearItem.FindExactGearItem(weaponInv, weapon, false);
		if (found == null)
		{
			ret.isEquipped = false;
			var bagInvID:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
			var bagInv:Inventory = new Inventory(bagInvID);
			found = GearItem.FindExactGearItem(bagInv, weapon, false);
			if (found != null)
			{
				ret.slot = found.indx;
				var iconBox:Object = GetIconBox(bagInvID, ret.slot);
				if (iconBox != null)
				{
					var pt:Point = iconBox.GetGridPositionFromSlotID(ret.slot);
					if (pt != null)
					{
						ret.iconBox = iconBox;
						ret.point = pt;
					}
				}
			}
		}
		else
		{
			ret.isEquipped = true;
		}
		
		return ret;
	}
}