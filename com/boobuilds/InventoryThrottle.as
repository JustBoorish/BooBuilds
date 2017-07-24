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
class com.boobuilds.InventoryThrottle
{
	public static var MAX_THROTTLE:Number = 6;
	
	private static var m_inventoryThrottleMode:Number = 0;

	private var m_inventoryUseCounter:Number;
	
	public function InventoryThrottle() 
	{
		m_inventoryUseCounter = 0;
	}
	
	public function DoNextInventoryAction(callback:Function):Void
	{
		var shortTimeout:Number = 20;
		var longTimeout:Number = 2000;
		
		if (m_inventoryThrottleMode == 1)
		{
			shortTimeout = 300;
			longTimeout = 300;
		}
		else if (m_inventoryThrottleMode == 2)
		{
			shortTimeout = 400;
			longTimeout = 400;
		}
		else if (m_inventoryThrottleMode == 3)
		{
			shortTimeout = 500;
			longTimeout = 500;
		}
		else if (m_inventoryThrottleMode == 4)
		{
			shortTimeout = 20;
			longTimeout = 2250;
		}
		else if (m_inventoryThrottleMode == 5)
		{
			shortTimeout = 20;
			longTimeout = 2500;
		}
		else if (m_inventoryThrottleMode == 6)
		{
			shortTimeout = 20;
			longTimeout = 2750;
		}
		
		++m_inventoryUseCounter;
		
		var timeout:Number = shortTimeout;
		if (m_inventoryUseCounter > 5)
		{
			timeout = longTimeout;
			m_inventoryUseCounter = 0;
		}
		
		setTimeout(callback, timeout);
	}
	
	public static function GetInventoryThrottleMode():Number
	{
		return m_inventoryThrottleMode;
	}
	
	public static function SetInventoryThrottleMode(newValue:Number):Void
	{
		m_inventoryThrottleMode = newValue;
	}
}