import com.boobuilds.DebugWindow;
import com.Utils.Signal;
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
class com.boobuilds.InventoryThrottle
{
	private static var MUST_WAIT_ENG:String = "You must wait a little while before you can perform that action again";
	private static var MUST_WAIT_FR:String = "Vous devez attendre un peu avant d'entreprendre à nouveau cette action";
	private static var MUST_WAIT_DE:String = "Sie müssen ein wenig warten, bevor Sie das erneut machen können";
	
	private static var m_inventoryThrottleMode:Number = 0;

	private var m_actionCallback:Function;
	private var m_checkCallback:Function;
	private var m_completionCallback:Function;
	private var m_errorCallback:Function;
	private var m_intervalID:Number;
	private var m_checkCounter:Number;
	private var m_throttleErrorSeen:Boolean;
	
	public function InventoryThrottle() 
	{
		m_intervalID = -1;
		m_checkCounter = 0;
		m_throttleErrorSeen = false;
	}
	
	public function Cleanup():Void
	{
		EndLoad();
	}
	
	public function StartLoad():Void
	{
		com.GameInterface.Chat.SignalShowFIFOMessage.Connect(FIFOMessageHandler, this);
	}
	
	public function EndLoad():Void
	{
		com.GameInterface.Chat.SignalShowFIFOMessage.Disconnect(FIFOMessageHandler, this);
		StopCheck();
	}
	
	public function DoNextInventoryAction(actionCallback:Function, checkCallback:Function, completionCallback:Function, errorCallback:Function):Void
	{
		StopCheck();
		
		m_actionCallback = actionCallback;
		m_checkCallback = checkCallback;
		m_completionCallback = completionCallback;
		m_errorCallback = errorCallback;
		
		var timeout:Number = 20;
		
		if (m_inventoryThrottleMode == 1)
		{
			timeout = 300;
		}
		else if (m_inventoryThrottleMode == 2)
		{
			timeout = 400;
		}
		else if (m_inventoryThrottleMode == 3)
		{
			timeout = 500;
		}

		setTimeout(Delegate.create(this, ActionWrapper), timeout);
	}

	private function FIFOMessageHandler(text:String, mode:Number):Void
	{
		if (text != null && (text.indexOf(MUST_WAIT_ENG, 0) == 0 || text.indexOf(MUST_WAIT_FR, 0) == 0 || text.indexOf(MUST_WAIT_DE) == 0))
		{
			m_throttleErrorSeen = true;
		}
	}
	
	private function ActionWrapper():Void
	{
		if (m_intervalID != -1)
		{
			StopCheck();
			m_errorCallback();
		}
		
		if (m_actionCallback != null)
		{
			var moveOn:Boolean = m_actionCallback();
			if (moveOn == true)
			{
				if (m_completionCallback != null)
				{
					m_completionCallback();
				}
			}
			else
			{
				if (m_checkCallback != null)
				{
					m_checkCounter = 0;
					m_intervalID = setInterval(Delegate.create(this, CheckWrapper), 20);
				}
			}
		}
	}
	
	private function CheckWrapper():Void
	{
		var moveOn:Boolean = false;
		++m_checkCounter;
		if (m_checkCallback != null)
		{
			moveOn = m_checkCallback();
			if (moveOn == true)
			{
				StopCheck();
			}
		}
		
		if (moveOn != true)
		{
			if (m_throttleErrorSeen == true)
			{
				StopCheck();
				setTimeout(Delegate.create(this, ActionWrapper), 500);
			}
			else if (m_checkCounter > 100)
			{
				moveOn = true;
				StopCheck();
				if (m_errorCallback != null)
				{
					m_errorCallback();
				}
			}
		}
		
		if (moveOn == true)
		{
			StopCheck();
			if (m_completionCallback != null)
			{
				m_completionCallback();
			}
		}
	}
	
	private function StopCheck():Void
	{
		if (m_intervalID != -1)
		{
			clearInterval(m_intervalID);
		}
		
		m_intervalID = -1;
		m_checkCounter = 0;
		m_throttleErrorSeen = false;
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