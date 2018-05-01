import com.GameInterface.GearData;
import com.GameInterface.GearManager;
import com.GameInterface.InventoryItem;
import com.GameInterface.SpellData;
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
class com.boobuilds.BuildGearManager
{
	public static function CheckGearManagerLoad(destinationBuild:GearData, destinationAbilities:Object, destinationItems:Object):Boolean
	{
		var thisBuild:GearData = GearManager.GetCurrentCharacterBuild();
		if ((thisBuild.m_AbilityArray == null && destinationBuild.m_AbilityArray != null) || (thisBuild.m_AbilityArray != null && destinationBuild.m_AbilityArray == null))
		{
			return false;
		}
		if ((thisBuild.m_ItemArray == null && destinationBuild.m_ItemArray != null) || (thisBuild.m_ItemArray != null && destinationBuild.m_ItemArray == null))
		{
			return false;
		}
		
		if (thisBuild.m_AbilityArray != null)
		{
			if (thisBuild.m_AbilityArray.length != destinationBuild.m_AbilityArray.length)
			{
				return false;
			}
			
			var abilities:Object = new Object();
			for (var indx:Number = 0; indx < thisBuild.m_AbilityArray.length; ++indx)
			{
				abilities[thisBuild.m_AbilityArray[indx].m_Position] = thisBuild.m_AbilityArray[indx].m_SpellData;
			}

			for (var indx in destinationAbilities)
			{
				if (CompareGearAbility(abilities[indx], destinationAbilities[indx]) == false)
				{
					return false;
				}
			}
		}
		
		if (thisBuild.m_ItemArray != null)
		{
			if (thisBuild.m_ItemArray.length != destinationBuild.m_ItemArray.length)
			{
				return false;
			}
			
			var items:Object = new Object();
			for (var indx:Number = 0; indx < thisBuild.m_ItemArray.length; ++indx)
			{
				items[thisBuild.m_ItemArray[indx].m_Position] = thisBuild.m_ItemArray[indx].m_InventoryItem;
			}
			
			for (var indx in destinationItems)
			{
				if (CompareGearItem(items[indx], destinationItems[indx]) == false)
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	private static function CompareGearAbility(ability1:SpellData, ability2:SpellData):Boolean
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
	
	private static function CompareGearItem(item1:InventoryItem, item2:InventoryItem):Boolean
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
	}
}