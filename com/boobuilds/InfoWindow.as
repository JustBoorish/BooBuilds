import com.boobuilds.DebugWindow;
import com.boobuilds.InfoWindow;
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
class com.boobuilds.InfoWindow
{
	private static var m_instance:InfoWindow;
	
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_errorCount:Number;
	private var m_lastMsg:MovieClip;
	
	public function InfoWindow(name:String, parent:MovieClip) 
	{
		m_name = name;
		m_parent = parent;
		m_errorCount = 0;
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
	
	private function LogCommonMsg(msg:String, colour:Number):Void
	{
		if (m_lastMsg != null)
		{
			Tweener.removeTweens(m_lastMsg);
			m_lastMsg.removeMovieClip();
		}
		
		++m_errorCount;
		m_lastMsg = CreateMsg(msg, colour);
		m_lastMsg._alpha = 100;
		Tweener.addTween(m_lastMsg, { _alpha:0, time:3, transition:"easeInQuint" } );
	}
	
	private function CreateMsg(msg:String, colour:Number):MovieClip
	{
		var error_mc:MovieClip = m_parent.createEmptyMovieClip("ErrorMsg" + m_errorCount, m_parent.getNextHighestDepth());
		
		var textFormat:TextFormat = new TextFormat();
		textFormat.align = "left";
		textFormat.font = "arial";
		textFormat.size = 20;
		textFormat.color = colour;
		textFormat.bold = true;
			
		var labelExtents:Object = Text.GetTextExtent(msg, textFormat, error_mc);
		var errorText:TextField = error_mc.createTextField("ErrorMsgText", error_mc.getNextHighestDepth(), 0, 0, labelExtents.width, labelExtents.height);
		errorText.embedFonts = true;
		errorText.selectable = false;
		errorText.antiAliasType = "advanced";
		errorText.autoSize = false;
		errorText.border = false;
		errorText.background = false;
		errorText.setNewTextFormat(textFormat);
		errorText.text = msg;		
		
		error_mc._x = Stage.width / 2 - labelExtents.width / 2;
		error_mc._y = Stage.height / 6;
		return error_mc;
	}
}