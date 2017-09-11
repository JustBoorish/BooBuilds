import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.InfoWindow;
import com.Utils.Text;
import caurina.transitions.Tweener;
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
class com.boobuildscommon.InfoWindow
{
	private static var m_instance:InfoWindow;
	private static var MAX_MSGS:Number = 4;
	
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_errorCount:Number;
	private var m_msgList:Array;
	
	public function InfoWindow(name:String, parent:MovieClip) 
	{
		m_name = name;
		m_parent = parent;
		m_errorCount = 0;
		m_msgList = new Array();
	}

	public static function CreateInstance(parent:MovieClip):InfoWindow
	{
		if (m_instance == null)
		{
			m_instance = new InfoWindow("ErrorWindow", parent);
		}
		
		return m_instance;
	}
	
	public static function LogError(msg:String):Void
	{
		if (m_instance != null)
		{
			m_instance.LogErrorMsg(msg);
		}
	}
	
	public static function LogInfo(msg:String):Void
	{
		if (m_instance != null)
		{
			m_instance.LogInfoMsg(msg);
		}
	}
	
	private function LogInfoMsg(msg:String):Void
	{
		DebugWindow.Log(DebugWindow.Info, msg);
		LogCommonMsg(msg, 0xFFFFFF);
	}
	
	private function LogErrorMsg(msg:String):Void
	{
		DebugWindow.Log(DebugWindow.Error, msg);
		LogCommonMsg(msg, 0xFF0000);
	}
	
	private function LogCommonMsg(text:String, colour:Number):Void
	{
		RemoveOldestMsg();
		
		++m_errorCount;
		var msg:MovieClip = CreateMsg(text, colour);
		msg._visible = true;
		msg._alpha = 100;
		Tweener.addTween(msg, { _alpha:0, time:3, transition:"easeInQuint", onComplete:function() { msg._visible = false; } } );
		
		ShiftMsgsUp(msg._height);
		m_msgList.push(msg);
	}
	
	private function CreateMsg(msg:String, colour:Number):MovieClip
	{
		var error_mc:MovieClip = m_parent.createEmptyMovieClip("ErrorMsg" + m_errorCount, m_parent.getNextHighestDepth());
		
		var textFormat:TextFormat = Graphics.GetLargeBoldTextFormat();
		var labelExtents:Object = Text.GetTextExtent(msg, textFormat, error_mc);
		var textField:TextField = Graphics.DrawText("ErrorMsgText", error_mc, msg, textFormat, 0, 0, labelExtents.width, labelExtents.height);
		textField.textColor = colour;
		
		error_mc._x = Stage.width / 2 - labelExtents.width / 2;
		error_mc._y = Stage.height / 6;
		return error_mc;
	}
	
	private function RemoveOldestMsg():Void
	{
		if (m_msgList.length >= MAX_MSGS)
		{
			var msg:MovieClip = MovieClip(m_msgList.shift());
			if (msg != null)
			{
				Tweener.removeTweens(msg);
				msg.removeMovieClip();
			}
		}
	}
	
	private function ShiftMsgsUp(height:Number):Void
	{
		for (var indx:Number = 0; indx < m_msgList.length; ++indx)
		{
			var msg:MovieClip = MovieClip(m_msgList[indx]);
			if (msg != null)
			{
				msg._y -= height;
			}
		}
	}
}