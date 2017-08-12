import com.boobuilds.DebugWindow;
import com.boobuilds.IntervalCounter;
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

	private var m_name:String;
	private var m_actionCallback:Function;
	private var m_checkCallback:Function;
	private var m_completionCallback:Function;
	private var m_errorCallback:Function;
	private var m_completionOnError:Boolean;
	private var m_interval:IntervalCounter;
	private var m_throttleErrorSeen:Boolean;
	private var m_retryID:Number;
	
	public function InventoryThrottle(name:String, actionCallback:Function, checkCallback:Function, completionCallback:Function, errorCallback:Function, completionOnError:Boolean) 
	{
		m_name = name;
		m_actionCallback = actionCallback;
		m_checkCallback = checkCallback;
		m_completionCallback = completionCallback;
		m_errorCallback = errorCallback;
		m_completionOnError = completionOnError;
		m_throttleErrorSeen = false;
		m_retryID = -1;
		
		com.GameInterface.Chat.SignalShowFIFOMessage.Connect(FIFOMessageHandler, this);
		
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

		if (m_actionCallback != null && m_checkCallback != null)
		{
			m_retryID = setTimeout(Delegate.create(this, ActionWrapper), timeout);
		}
	}
	
	public function Cleanup():Void
	{
		StopCheck();
		com.GameInterface.Chat.SignalShowFIFOMessage.Disconnect(FIFOMessageHandler, this);
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
		m_retryID = -1;
		if (m_interval != null)
		{
			StopCheck();
			m_errorCallback();
		}
		else
		{
			var moveOn:Boolean = m_actionCallback();
			if (moveOn == true)
			{
				if (m_completionCallback != null)
				{
					m_completionCallback(false);
				}
			}
			else
			{
				m_interval = new IntervalCounter(m_name, IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, CheckWrapper), m_completionCallback, m_errorCallback, m_completionOnError);
			}
		}
	}
	
	private function CheckWrapper():Boolean
	{
		var moveOn:Boolean = m_checkCallback();
		if (moveOn != true)
		{
			if (m_throttleErrorSeen == true)
			{
				m_throttleErrorSeen = false;
				StopCheck();
				if (m_retryID != -1)
				{
					clearTimeout(m_retryID);
					m_retryID = -1;
					DebugWindow.Log(DebugWindow.Error, "Duplicate retry in inventory throttle " + m_name);
				}
				else
				{
					m_retryID = setTimeout(Delegate.create(this, ActionWrapper), 500);
				}
			}
		}
		
		return moveOn;
	}
	
	private function StopCheck():Void
	{
		m_throttleErrorSeen = false;
		if (m_interval != null)
		{
			m_interval.Stop();
			m_interval = null;
		}
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