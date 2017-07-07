import com.Utils.Signal;
import GUI.TradePost.Views.PostalServiceView;
import org.aswing.ASFont;
import org.aswing.AttachIcon;
import org.aswing.Icon;
import org.aswing.JTextArea;
import org.aswing.JScrollPane;
import org.aswing.JFrame;
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
class com.boobuilds.DebugWindow
{
	private var m_debug:MovieClip;
	private var m_textArea:JTextArea;
	private var m_scrollPane:JScrollPane;
	private var m_window:JFrame;
	private var m_logLevel:Number;
	private var m_text:String;
	
	public var SignalLog:Signal;
	public static var Trace:Number = 1;
	public static var Debug:Number = 2;
	public static var Info:Number = 3;
	public static var Warning:Number = 4;
	public static var Error:Number = 5;
	
	public function DebugWindow(parent, logLevel:Number) 
	{
		if (_global["boodebug"] == undefined)
		{
			m_logLevel = logLevel;
			
			m_debug = parent.createEmptyMovieClip("boodebug", parent.getNextHighestDepth());
			m_debug._visible = false;
			m_debug._x = 0;
			m_debug._y = 25;
			m_debug._alpha = 60;
			
			var w:Number = 625;
			var h:Number = 320;
			/*m_debug.lineStyle(1,0xFFFFFF,0);
			m_debug.moveTo(-w,-h);
			m_debug.lineTo(w,-h);
			m_debug.lineTo(w,h);
			m_debug.lineTo(-w,h);
			m_debug.lineTo(-w,-h);
			m_debug.endFill();*/

			var font:ASFont = new ASFont("Arial", 12, false, false, false, false);
			m_textArea = new JTextArea();
			m_textArea.setEditable(false);
			m_textArea.setFont(font);
			
			m_scrollPane = new JScrollPane(m_textArea);
			m_window = new JFrame(m_debug, "Boo Debug", false);
			m_window.setContentPane(m_scrollPane);
			m_window.setSize(w, h);
			m_window.show();
			
			
			m_text = "";
			
			SignalLog = new Signal();
			SignalLog.Connect(SignalEmitted, this);
			
			_global["boodebug"] = new Object();
			_global.boodebug.logsignal = SignalLog;
			
			_global.boodebug.setvisible = Delegate.create(this, SetDebugVisible);
			_global.boodebug.getvisible = Delegate.create(this, GetDebugVisible);
		}
	}

	public static function Log(level:Object, str:String):Void
	{
		if (_global["boodebug"] != undefined && _global.boodebug["logsignal"] != undefined)
		{
			if (typeof(level) == "number")
			{
				_global.boodebug.logsignal.Emit(level, str);
			}
			else
			{
				_global.boodebug.logsignal.Emit(Debug, level);
			}
		}
	}
	
	public static function SetVisible(visible:Boolean):Void
	{
		if (_global["boodebug"] != undefined && _global.boodebug["setvisible"] != undefined)
		{
			_global.boodebug.setvisible(visible);
		}
	}
	
	public static function ToggleVisible():Void
	{
		if (_global["boodebug"] != undefined && _global.boodebug["setvisible"] != undefined)
		{
			_global.boodebug.setvisible(!_global.boodebug.getvisible());
		}
	}
	
	private function SignalEmitted(logLevel:Number, str:String):Void
	{
		if (logLevel >= m_logLevel)
		{
			m_text = GetDate() + "  " + str + "\n" + m_text.substring(0, 10000);
			m_textArea.setText(m_text);
		}
	}
	
	private function SetDebugVisible(visible:Boolean):Void
	{
		m_debug._visible = visible;
		m_window.setVisible(visible);
	}
	
	private function GetDebugVisible():Boolean
	{
		return m_debug._visible && m_window.isVisible();
	}
	
	private function GetDate():String
	{
		var d:Date = new Date();
		return AddZero(d.getHours()) + ":" + AddZero(d.getMinutes()) + ":" + AddZero(d.getSeconds());
	}
	
	private function AddZero(inVal:Number):String
	{
		if (inVal < 10)
		{
			return "0" + inVal.toString();
		}
		else
		{
			return inVal.toString();
		}
	}
}