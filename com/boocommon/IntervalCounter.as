import com.boocommon.DebugWindow;
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
class com.boocommon.IntervalCounter
{
	public static var WAIT_MILLIS:Number = 20;
	public static var MAX_ITERATIONS:Number = 100;
	public static var COMPLETE_ON_ERROR:Boolean = true;
	public static var NO_COMPLETE_ON_ERROR:Boolean = false;
	
	private var m_name:String;
	private var m_waitMillis:Number;
	private var m_maxIterations:Number;
	private var m_checkFunc:Function;
	private var m_completionFunc:Function;
	private var m_errorFunc:Function;
	private var m_completeOnError:Boolean;
	private var m_intervalID:Number;
	private var m_intervalCount:Number;
	
	public function IntervalCounter(name:String, waitMillis:Number, maxIterations:Number, checkFunc:Function, completionFunc:Function, errorFunc:Function, completeOnError:Boolean) 
	{
		m_name = name;
		m_waitMillis = waitMillis;
		m_maxIterations = maxIterations;
		m_checkFunc = checkFunc;
		m_completionFunc = completionFunc;
		m_errorFunc = errorFunc;
		m_completeOnError = completeOnError;
		m_intervalCount = 0;
		m_intervalID = -1;
		
		var totalTime:Number = m_maxIterations * m_waitMillis;
		if (totalTime < 1)
		{
			DebugWindow.Log(DebugWindow.Error, "Negative duration for interval counter " + m_name + " " + m_maxIterations + " " + m_waitMillis);
		}
		else if (totalTime > 3600 * 5)
		{
			DebugWindow.Log(DebugWindow.Error, "Duration too long for interval counter " + m_name + " " + m_maxIterations + " " + m_waitMillis);
		}
		else if (m_checkFunc == null)
		{
			DebugWindow.Log(DebugWindow.Error, "Null check function in interval wrapper" + m_name);
		}
		else
		{
			m_intervalID = setInterval(Delegate.create(this, CheckWrapper), m_waitMillis);
		}
	}
	
	public function Stop():Void
	{
		if (m_intervalID != -1)
		{
			clearInterval(m_intervalID);
		}
		
		m_intervalID = -1;
		m_intervalCount = 0;
	}
	
	private function CheckWrapper():Void
	{
		++m_intervalCount;
		if (m_intervalCount > m_maxIterations)
		{
			Stop();
			DebugWindow.Log(DebugWindow.Error, "Interval wrapper count exceeded " + m_name + " " + m_maxIterations + " " + m_waitMillis);
			if (m_errorFunc != null)
			{
				m_errorFunc();
			}
			
			if (m_completeOnError == COMPLETE_ON_ERROR)
			{
				if (m_completionFunc != null)
				{
					m_completionFunc(true);
				}				
			}
		}
		else
		{
			var stopCounter:Boolean = m_checkFunc();
			if (stopCounter == true)
			{
				Stop();
				if (m_completionFunc != null)
				{
					m_completionFunc(false);
				}
			}
		}
	}
}