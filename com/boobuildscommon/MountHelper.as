import com.boobuildscommon.InfoWindow;
import com.boobuildscommon.IntervalCounter;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Game.Character;
import com.GameInterface.SpellBase;
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
class com.boobuildscommon.MountHelper
{
	private static var m_interval:IntervalCounter = null;
	
	public function MountHelper() 
	{
	}

	public static function Mount(tag:Number):Void
	{
		Dismount(function(a:Boolean) { MountHelper.MountComplete(a, tag); });
	}
	
	public static function Dismount(continueCallback:Function):Void
	{
		if (IsSprinting() != true)
		{
			if (continueCallback != null)
			{
				continueCallback();
			}
		}
		else
		{
			SpellBase.SummonMountFromTag();
			ClearInterval();
			if (continueCallback != null)
			{
				ClearInterval();
				m_interval = new IntervalCounter("Dismount", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, DismountCheck, function(a:Boolean) { MountHelper.DismountComplete(a, continueCallback); } , null, IntervalCounter.COMPLETE_ON_ERROR);
			}
		}
	}
	
	private static function DismountCheck():Boolean
	{
		if (IsSprinting() != true)
		{
			return true;
		}
		
		return false;
	}
	
	private static function DismountComplete(isError:Boolean, continueCallback:Function):Void
	{
		ClearInterval();
		if (continueCallback != null)
		{
			continueCallback(isError);
		}
	}
	
	private static function MountComplete(isError:Boolean, tag:Number):Void
	{
		if (isError == true && IsSprinting() == true)
		{
			InfoWindow.LogError("Failed to dismount");
		}
		else
		{
			if (tag == null || tag == 0)
			{
				SpellBase.SummonMountFromTag();
			}
			else
			{
				SpellBase.SummonMountFromTag(tag);
			}
		}
	}
	
	private static function ClearInterval():Void
	{
		if (m_interval != null)
		{
			m_interval.Stop();
			m_interval = null;
		}
	}
	
	public static function IsSprinting():Boolean
	{
		var SPRINT_BUFFS:Array = [7481588, 7758936, 7758937, 7758938, 9114480, 9115262];
		for (var i:Number = 0; i < SPRINT_BUFFS.length; i++)
		{
			var buff:BuffData = Character.GetClientCharacter().m_InvisibleBuffList[SPRINT_BUFFS[i]];
			if (buff != undefined)
			{
				return true;
			}
		}
		
		return false;
	}
}