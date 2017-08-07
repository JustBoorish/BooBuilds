import com.boobuilds.Build;
import com.boobuilds.DebugWindow;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Utils;
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
class com.boobuilds.CooldownMonitor
{
	private static var PLAYER_MAX_ACTIVE_SPELLS:String = "PlayerMaxActiveSpells";
	private static var PLAYER_START_SLOT_SPELLS:String = "PlayerStartSlotSpells";
	private static var PLAYER_START_SLOT_POCKET:String = "PlayerStartSlotPocket";

	private var m_skillCooldownCount:Number;
	private var m_skillCooldownIDs:Array;
	private var m_skillCooldownActive:Array;
	private var m_gadgetOnCooldown:Boolean;
	private var m_gadgetCooldownID:Number;
	
	public function CooldownMonitor() 
	{
		m_skillCooldownCount = 0;
		m_skillCooldownActive = new Array();
		m_skillCooldownIDs = new Array();
		for (var indx:Number = 0; indx < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); ++indx)
		{
			m_skillCooldownActive.push(false);
			m_skillCooldownIDs.push(-1);
		}
		
		m_gadgetOnCooldown = false;
		m_gadgetCooldownID = -1;
		
		Shortcut.SignalCooldownTime.Connect(SlotCooldownTime, this);
	}
	
	public function IsSkillCooldownActive():Boolean
	{
		return m_skillCooldownCount > 0;
	}
	
	public function IsGadgetCooldownActive():Boolean
	{
		return m_gadgetOnCooldown;
	}
	
	private function SkillCooldownStart(slotID:Number, duration:Number):Void
	{
		SkillCooldownComplete(slotID);
		
		m_skillCooldownActive[slotID] = true;
		++m_skillCooldownCount;
		m_skillCooldownIDs[slotID] = setTimeout(Proxy.create(this, SkillCooldownComplete, slotID), duration * 1000);
	}
	
	private function SkillCooldownComplete(slotID:Number):Void
	{
		if (m_skillCooldownIDs[slotID] != -1)
		{
			clearTimeout(m_skillCooldownIDs[slotID]);
		}
		
		m_skillCooldownIDs[slotID] = -1;
		
		if (m_skillCooldownActive[slotID] == true)
		{
			if (m_skillCooldownCount > 0)
			{
				--m_skillCooldownCount;
			}
		}
			
		m_skillCooldownActive[slotID] = false;
	}
	
	private function GadgetCooldownStart(duration:Number):Void
	{
		GadgetCooldownComplete();
		
		m_gadgetOnCooldown = true;
		m_gadgetCooldownID = setTimeout(Proxy.create(this, GadgetCooldownComplete), duration);
	}
	
	private function GadgetCooldownComplete():Void
	{
		if (m_gadgetCooldownID != -1)
		{
			clearTimeout(m_gadgetCooldownID);
		}
		
		m_gadgetCooldownID = -1;
		m_gadgetOnCooldown = false;
	}
	
	private function SlotCooldownTime(itemPos:Number, cooldownStart:Number, cooldownEnd:Number,  cooldownFlags:Number):Void
	{
		var currentTime = com.GameInterface.Utils.GetGameTime();
		var timeLeft = cooldownEnd - currentTime;
		
		if( IsAbilityShortcut(itemPos) )
		{
			var abilitySlot:Number = GetAbilitySlotID(itemPos);
			if (cooldownFlags > 0 && timeLeft > 1)
			{
				if (Build.IsSprinting() != true)
				{
					SkillCooldownStart(abilitySlot, timeLeft);
				}
			}
			else if (cooldownFlags == 0 && timeLeft <= 1)
			{
				SkillCooldownComplete(abilitySlot);
			}
		}
		else if (itemPos == ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET))
		{
			if (timeLeft > 0)
			{
				GadgetCooldownStart(timeLeft);
			}
			else
			{
				GadgetCooldownComplete();
			}
		}
	}
	
	private function IsAbilityShortcut(itemPos:Number):Boolean
	{
		var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
		var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
		var checkSpell:Boolean = (shortcutData)?(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut) : true;
		if ( slotNo >= 0 && slotNo < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) && checkSpell)
		{
			return true;
		}
		return false;
	}

	private function GetAbilitySlotID(itemPos:Number):Number
	{
		var slotID:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
		
		if ( slotID >= 0 && slotID < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS))
		{
			return slotID;
		}
		
		return null;
	}
}