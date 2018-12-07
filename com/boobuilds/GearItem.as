import com.boobuildscommon.DebugWindow;
import com.boobuilds.GearItem;
import com.boobuilds.Localisation;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.Utils;
import com.Utils.ID32;
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
class com.boobuilds.GearItem
{
	private var m_Name:String;
	private var m_prefix:String;
	private var m_suffix:String;
	private var m_defaultPosition:Number;
	private var m_iconPath:String;
	private var m_numPips:Number;
	
	public function GearItem(name:String, defaultPosition:Number, prefix:String, suffix:String, numPips:Number, iconPath:String)
	{
		m_Name = name;
		m_defaultPosition = defaultPosition;
		m_prefix = prefix;
		m_suffix = suffix;
		m_iconPath = iconPath;
		m_numPips = numPips;
	}
	
	public function toString():String
	{
		return m_Name + "~" + m_defaultPosition + "~" + m_prefix + "~" + m_suffix + "~" + m_numPips + "~" + m_iconPath;
	}
	
	public function GetName():String
	{
		return m_Name;
	}
	
	public function GetPrefix():String
	{
		return m_prefix;
	}
	
	public function GetSuffix():String
	{
		return m_suffix;
	}
	
	public function GetIconPath():String
	{
		return m_iconPath;
	}
	
	public function GetNumPips():Number
	{
		return m_numPips;
	}
	
	public static function FromString(str:String):GearItem
	{
		var ret:GearItem = null;
		
		if (str != null)
		{
			var parts:Array = str.split("~");
			if (parts.length == 5)
			{
				ret = new GearItem(parts[0], Number(parts[1]), parts[2], parts[3], parts[4], null);
			}
			else if (parts.length == 6)
			{
				ret = new GearItem(parts[0], Number(parts[1]), parts[2], parts[3], parts[4], parts[5]);
			}
		}
		
		return ret;
	}
	
	public static function GetGearItem(item:InventoryItem, tooltip:TooltipData, defaultIconPath:String):GearItem
	{
		if (tooltip == null)
		{
			return null;
		}
		
		var ret:Object = new Object();
		ret.m_Suffix = "";
		ret.m_Prefix = "";
		ret.m_Name = item.m_Name;
		ret.m_defaultPosition = item.m_DefaultPosition;
		ret.m_numPips = item.m_Pips;
		if (item.m_Icon == null || item.m_Icon.m_Instance == 0)
		{
			ret.m_iconPath = defaultIconPath;
		}
		else
		{
			ret.m_iconPath = Utils.CreateResourceString(item.m_Icon);
		}
		
		if (tooltip.m_SuffixData != null)
		{
			var signetStr:String = tooltip.m_SuffixData.m_Title;
			if (signetStr.indexOf(Localisation.Signet) == 0)
			{
				ret.m_Suffix = signetStr;
			}
		}
		
		if (tooltip.m_PrefixData != null)
		{
			var glyphStr:String = tooltip.m_PrefixData.m_Title;
			if (Localisation.GetLocalisation() != "fr")
			{
				if (glyphStr.lastIndexOf(Localisation.Glyph) == glyphStr.length - Localisation.Glyph.length)
				{
					ret.m_Prefix = glyphStr;
				}
			}
			else
			{
				if (glyphStr.indexOf(Localisation.Glyph) == 0)
				{
					ret.m_Prefix = glyphStr;
				}
			}
		}
		return new GearItem(ret.m_Name, ret.m_defaultPosition, ret.m_Prefix, ret.m_Suffix, ret.m_numPips, ret.m_iconPath);
	}
	
	public static function FindGearItem(inventory:Inventory, inItem:GearItem, dontCheckBound:Boolean):Number
	{
		var exactItems:Array = new Array();
		var closeItems:Array = new Array();
		
		var maxItems:Number = inventory.GetMaxItems();
		for (var i:Number = 0; i < maxItems; ++i)
		{
			var item:InventoryItem = inventory.GetItemAt(i);
			if (item != null && (dontCheckBound == true || item.m_IsBoundToPlayer == true) && DefaultPositionMatches(item.m_DefaultPosition, inItem.m_defaultPosition))
			{
				if (item.m_Name == inItem.m_Name && item.m_Pips == inItem.m_numPips)
				{
					exactItems.push(i);
				}
				else if (item.m_Name.indexOf(inItem.m_Name) > -1)
				{
					closeItems.push(i);
				}
			}
		}
		
		if (exactItems.length > 0)
		{
			return exactItems[0];
		}

		var twoMatches:Array = new Array();
		var oneMatch:Array = new Array();
		for (var i:Number = 0; i < closeItems.length; ++i)
		{
			var gItem:GearItem = GetGearItem(inventory.GetItemAt(closeItems[i]), TooltipDataProvider.GetInventoryItemTooltip(inventory.m_InventoryID, closeItems[i]));
			if (gItem.m_Name == inItem.m_Name && gItem.m_prefix == inItem.m_prefix)
			{
				twoMatches.push(closeItems[i]);
			}
			else if (gItem.m_Name == inItem.m_Name && gItem.m_suffix == inItem.m_suffix)
			{
				twoMatches.push(closeItems[i]);
			}
			else if (gItem.m_Name == inItem.m_Name)
			{
				oneMatch.push(closeItems[i]);
			}
		}

		if (twoMatches.length == 1)
		{
			return twoMatches[0];
		}
		
		if (twoMatches.length == 0 && oneMatch.length == 1)
		{
			return oneMatch[0];
		}
		
		return -1;
	}
	
	public static function FindExactGearItem(inventory:Inventory, inItem:GearItem, dontCheckBound:Boolean):Object
	{
		var exactItems:Array = new Array();
		var exactIndices:Array = new Array();

		var maxItems:Number = inventory.GetMaxItems();
		for (var i:Number = 0; i < maxItems; ++i)
		{
			var item:InventoryItem = inventory.GetItemAt(i);
			if (IsItemMatching(item, inItem, dontCheckBound) == true)
			{
				exactItems.push(item);
				exactIndices.push(i);
			}
		}
		
		return ChooseBestItem(exactItems, exactIndices);
	}
	
	public static function IsItemMatching(item:InventoryItem, inItem:GearItem, dontCheckBound:Boolean):Boolean
	{
		var ret:Boolean = false;
		if (item != null && (dontCheckBound == true || item.m_IsBoundToPlayer == true))
		{
			var glyph = com.Utils.LDBFormat.LDBGetText(50200,item.m_ACGItem.m_TemplateID1);//Glyph Name
			var signet = "";
			if(item.m_DefaultPosition != 6 && item.m_ACGItem.m_TemplateID2)
			{
				signet = com.Utils.LDBFormat.LDBGetText(50200,item.m_ACGItem.m_TemplateID2);//Signet Name
			}
			
			if (glyph == null)
			{
				glyph = "";
			}
			
			if (signet == null)
			{
				signet = "";
			}
			 
			if (item.m_Name == inItem.GetName() && inItem.GetPrefix() == glyph && inItem.GetSuffix() == signet && item.m_Pips == inItem.GetNumPips())
			{
				ret = true;
			}
		}
		
		return ret;
	}

	private static function ChooseBestItem(exactItems:Array, exactIndices:Array):Object
	{
		if (exactItems.length == 0)
		{
			return null;
		}
		
		var bestRarity:Number = -1;
		var bestXP:Number = -1;
		var bestIndx:Number = null;
		
		for (var indx:Number = 0; indx < exactItems.length; ++indx)
		{
			var item:InventoryItem = exactItems[indx];
			if (item.m_Rarity > bestRarity)
			{
				bestRarity = item.m_Rarity;
				bestXP = item.m_XP;
				bestIndx = indx;
			}
			else if (item.m_Rarity == bestRarity && item.m_XP > bestXP)
			{
				bestXP = item.m_XP;
				bestIndx = indx;
			}
		}
		
		var ret:Object = null;
		if (bestIndx != null)
		{
			ret = new Object();
			ret.indx = exactIndices[bestIndx];
			ret.item = exactItems[bestIndx];
		}
		
		return ret;
	}
	
	private static function DefaultPositionMatches(itemPosition:Number, defaultPosition:Number):Boolean
	{
		var ret:Boolean = false;
		
		if (itemPosition != null && defaultPosition != null)
		{
			if (itemPosition == defaultPosition)
			{
				ret = true;
			}
			else if (itemPosition == _global.Enums.ItemEquipLocation.e_Wear_Back && defaultPosition == _global.Enums.ItemEquipLocation.e_Wear_FullOutfit)
			{
				ret = true;
			}
			else if (itemPosition == _global.Enums.ItemEquipLocation.e_Wear_FullOutfit && defaultPosition == _global.Enums.ItemEquipLocation.e_Wear_Back)
			{
				ret = true;
			}
		}
		
		return ret;
	}	
	
	private static function GetItemsFromInv(itemArray:Array, defaultPosition:Number, defaultIconPath:String, inventoryId:Number, boundOnly:Boolean, doLog:Boolean)
	{
		var inventoryID:ID32 = new ID32(inventoryId, Character.GetClientCharID().GetInstance());
		var inventory:Inventory = new Inventory(inventoryID);
		for ( var i:Number = 0 ; i < inventory.GetMaxItems(); ++i )
		{
			var item:InventoryItem = inventory.GetItemAt(i);			
            if ((boundOnly != true || item.m_IsBoundToPlayer == true) && DefaultPositionMatches(item.m_DefaultPosition, defaultPosition))
            {
				var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(new ID32(inventoryId, Character.GetClientCharID().GetInstance()), i);
				var gear:GearItem = GearItem.GetGearItem(item, tooltipData, defaultIconPath);
				if (doLog == true)
				{
					DebugWindow.Log("Item: " + item.m_Name + " " + gear.toString() + " " + item.m_IsBoundToPlayer + " " + item.m_DefaultPosition);
				}
				
				itemArray.push(gear);
			}
		}
	}
	
	public static function GetItemList(defaultPosition:Number):Array
	{
		var ret:Array = new Array();
		GetItemsFromInv(ret, defaultPosition, "", _global.Enums.InvType.e_Type_GC_WeaponContainer, true);
		GetItemsFromInv(ret, defaultPosition, "", _global.Enums.InvType.e_Type_GC_BackpackContainer, true);
		return ret;
	}
	
	public static function GetCostumeList(defaultPosition:Number, defaultIconPath:String):Array
	{
		var ret:Array = new Array();
		GetItemsFromInv(ret, defaultPosition, defaultIconPath, _global.Enums.InvType.e_Type_GC_WearInventory, false);
		GetItemsFromInv(ret, defaultPosition, defaultIconPath, _global.Enums.InvType.e_Type_GC_StaticInventory, false);
		return ret;
	}
}