import com.boobuilds.ITabPane;
import com.boobuilds.Checkbox;
import com.Utils.Text;
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
class com.boobuilds.CreateTab implements ITabPane
{
	public static var IGNORE_AEGISBAR:String = "Ignore_AegisBar";
	public static var IGNORE_AEGISHUD:String = "Ignore_AegisHUD";
	
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_settings:Object;
	private var m_ignoreAegisHUD:Checkbox;
	private var m_ignoreAegisBar:Checkbox;
	
	public function CreateTab(title:String, settings:Object)
	{
		m_name = title;
		m_parent = null;
		m_settings = settings;
	}
	
	public function CreatePane(addonMC:MovieClip, parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number):Void
	{
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(name + "GeneralConfigWindow", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_margin = 6;
		m_maxHeight = height;
		
		DrawFrame();
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	public function Save():Void
	{
		if (m_settings != null)
		{
			m_settings[IGNORE_AEGISBAR] = m_ignoreAegisBar.IsChecked();
			m_settings[IGNORE_AEGISHUD] = m_ignoreAegisHUD.IsChecked();
		}
	}
	
	public function StartDrag():Void
	{
	}
	
	public function StopDrag():Void
	{
	}
	
	private function DrawFrame():Void
	{
		var textFormat:TextFormat = new TextFormat();
		textFormat.align = "left";
		textFormat.font = "tahoma";
		textFormat.size = 14;
		textFormat.color = 0xFFFFFF;
		textFormat.bold = false;

		var checkSize:Number = 13;
		var text:String = "Ignore Aegis Bar";
		var extents:Object = Text.GetTextExtent(text, textFormat, m_frame);
		var ignoreAegisBarText:TextField = m_frame.createTextField("IgnoreBarText", m_frame.getNextHighestDepth(), 25 + checkSize, 20 + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		ignoreAegisBarText.embedFonts = true;
		ignoreAegisBarText.selectable = false;
		ignoreAegisBarText.antiAliasType = "advanced";
		ignoreAegisBarText.autoSize = true;
		ignoreAegisBarText.border = false;
		ignoreAegisBarText.background = false;
		ignoreAegisBarText.setNewTextFormat(textFormat);
		ignoreAegisBarText.text = text;
		
		text = "Ignore AegisHUD";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		var ignoreAegisHUDText:TextField = m_frame.createTextField("IgnoreBarText", m_frame.getNextHighestDepth(), 25 + checkSize, 50 + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		ignoreAegisHUDText.embedFonts = true;
		ignoreAegisHUDText.selectable = false;
		ignoreAegisHUDText.antiAliasType = "advanced";
		ignoreAegisHUDText.autoSize = true;
		ignoreAegisHUDText.border = false;
		ignoreAegisHUDText.background = false;
		ignoreAegisHUDText.setNewTextFormat(textFormat);
		ignoreAegisHUDText.text = text;

		m_ignoreAegisBar = new Checkbox("Ignore Aegis Bar", m_frame, 20, 20, checkSize, null, false);
		m_ignoreAegisHUD = new Checkbox("Ignore AegisHUD", m_frame, 20, 50, checkSize, null, false);
		
		if (m_settings != null)
		{
			if (m_settings[IGNORE_AEGISBAR] == true)
			{
				m_ignoreAegisBar.SetChecked(true);
			}
			
			if (m_settings[IGNORE_AEGISHUD] == true)
			{
				m_ignoreAegisHUD.SetChecked(true);
			}
		}
	}
}