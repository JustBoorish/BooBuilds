import com.Utils.Archive;
import com.boobuilds.ITabPane;
import com.boobuilds.Build;
import com.boobuilds.Checkbox;
import com.boobuilds.DebugWindow;
import com.Utils.Text;
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
class com.boobuilds.OptionsTab implements ITabPane
{
	public static var DISABLE_WEAPONS:String = "WEAPONS_DISABLED";
	public static var DISABLE_TALISMANS:String = "TALISMANS_DISABLED";
	
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_settings:Object;
	private var m_disableWeapons:Checkbox;
	private var m_disableTalismans:Checkbox;
	
	public function OptionsTab(title:String)
	{
		m_name = title;
		m_parent = null;
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
		if (visible == true && m_settings != null)
		{
			if (m_settings[DISABLE_WEAPONS] == 1)
			{
				m_disableWeapons.SetChecked(true);
			}
			
			if (m_settings[DISABLE_TALISMANS] == 1)
			{
				m_disableTalismans.SetChecked(true);
			}
		}
		
		m_frame._visible = visible;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	public function SetSettings(settings:Object):Void
	{
		m_settings = settings;
	}
	
	public function Save():Void
	{
		if (m_settings != null)
		{
			if (m_disableTalismans.IsChecked() == true)
			{
				m_settings[DISABLE_TALISMANS] = 1;
			}
			else
			{
				m_settings[DISABLE_TALISMANS] = 0;
			}
			
			if (m_disableWeapons.IsChecked() == true)
			{
				m_settings[DISABLE_WEAPONS] = 1;
			}
			else
			{
				m_settings[DISABLE_WEAPONS] = 0;
			}
		}
	}
	
	public static function Load(settings:Object):Void
	{
		if (settings != null)
		{
			if (settings[DISABLE_WEAPONS] == 1)
			{
				Build.SetWeaponsDisabled(true);
			}
			else
			{
				Build.SetWeaponsDisabled(false);
			}
			
			if (settings[DISABLE_TALISMANS] == 1)
			{
				Build.SetTalismansDisabled(true);
			}
			else
			{
				Build.SetTalismansDisabled(false);
			}
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
		var text:String = "Disable weapon switching";
		var extents:Object = Text.GetTextExtent(text, textFormat, m_frame);
		var disableWeaponsText:TextField = m_frame.createTextField("DisableWeaponsText", m_frame.getNextHighestDepth(), 25 + checkSize, 20 + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		disableWeaponsText.embedFonts = true;
		disableWeaponsText.selectable = false;
		disableWeaponsText.antiAliasType = "advanced";
		disableWeaponsText.autoSize = true;
		disableWeaponsText.border = false;
		disableWeaponsText.background = false;
		disableWeaponsText.setNewTextFormat(textFormat);
		disableWeaponsText.text = text;
		
		text = "Disable talisman switching";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		var disableTalismansText:TextField = m_frame.createTextField("DisableTalismansText", m_frame.getNextHighestDepth(), 25 + checkSize, 50 + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		disableTalismansText.embedFonts = true;
		disableTalismansText.selectable = false;
		disableTalismansText.antiAliasType = "advanced";
		disableTalismansText.autoSize = true;
		disableTalismansText.border = false;
		disableTalismansText.background = false;
		disableTalismansText.setNewTextFormat(textFormat);
		disableTalismansText.text = text;

		m_disableWeapons = new Checkbox("DisableWeaponsText", m_frame, 20, 20, checkSize, Delegate.create(this, ToggleWeapons), false);
		m_disableTalismans = new Checkbox("DisableTalismansText", m_frame, 20, 50, checkSize, Delegate.create(this, ToggleTalismans), false);
	}
	
	private function ToggleWeapons(isChecked:Boolean):Void
	{
		Build.SetWeaponsDisabled(isChecked);
		Save();
	}
	
	private function ToggleTalismans(isChecked:Boolean):Void
	{
		Build.SetTalismansDisabled(isChecked);
		Save();
	}
}