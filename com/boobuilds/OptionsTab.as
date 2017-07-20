import com.Utils.Archive;
import com.boobuilds.ITabPane;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boobuilds.Checkbox;
import com.boobuilds.DebugWindow;
import com.boobuilds.InventoryThrottle;
import com.boobuilds.MenuPanel;
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
	public static var INVENTORY_THROTTLE:String = "INVENTORY_THROTTLE";
	
	private static var THROTTLE_MODE0:String = "Default";
	private static var THROTTLE_MODE1:String = "Slow";
	private static var THROTTLE_MODE2:String = "Slower";
	private static var THROTTLE_MODE3:String = "Slowest";
	
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_settings:Object;
	private var m_menu:MenuPanel;
	private var m_throttleX:Number;
	private var m_throttleY:Number;
	private var m_throttleMode:String;
	
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
			m_throttleMode = GetThrottleMode();
			RebuildMenu();
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
			SetThrottleMode();
			ApplyOptions(m_settings);
		}
	}
	
	public static function ApplyOptions(settings:Object):Void
	{
		if (settings != null)
		{
			if (settings[INVENTORY_THROTTLE] != null)
			{
				InventoryThrottle.SetInventoryThrottleMode(settings[INVENTORY_THROTTLE]);
			}
		}
	}
	
	public function StartDrag():Void
	{
	}
	
	public function StopDrag():Void
	{
	}
	
	private function GetThrottleMode():String
	{
		var throttleMode:Number = 0;
		if (m_settings != null)
		{
			if (m_settings[INVENTORY_THROTTLE] != null)
			{
				var tempMode:Number = m_settings[INVENTORY_THROTTLE];
				if (tempMode > 0 && tempMode < 4)
				{
					throttleMode = tempMode;
				}
			}
		}
		
		switch (throttleMode)
		{
			case 0:
				return THROTTLE_MODE0;
			case 1:
				return THROTTLE_MODE1;
			case 2:
				return THROTTLE_MODE2;
			case 3:
				return THROTTLE_MODE3;
			default:
				return THROTTLE_MODE0;
		}
	}
	
	private function SetThrottleMode():Void
	{
		if (m_settings != null)
		{
			var throttleMode:Number = 0;
			if (m_throttleMode == THROTTLE_MODE1)
			{
				throttleMode = 1;
			}
			else if (m_throttleMode == THROTTLE_MODE2)
			{
				throttleMode = 2;
			}
			else if (m_throttleMode == THROTTLE_MODE3)
			{
				throttleMode = 3;
			}
			
			m_settings[INVENTORY_THROTTLE] = throttleMode;
		}
	}
	
	private function DrawFrame():Void
	{
		var textFormat:TextFormat = new TextFormat();
		textFormat.align = "left";
		textFormat.font = "tahoma";
		textFormat.size = 14;
		textFormat.color = 0xFFFFFF;
		textFormat.bold = false;

		var text:String = "Throttle";
		var extents:Object = Text.GetTextExtent(text, textFormat, m_frame);
		var throttleModeText:TextField = m_frame.createTextField("DisableTalismansText", m_frame.getNextHighestDepth(), 25, 30, extents.width, extents.height);
		throttleModeText.embedFonts = true;
		throttleModeText.selectable = false;
		throttleModeText.antiAliasType = "advanced";
		throttleModeText.autoSize = true;
		throttleModeText.border = false;
		throttleModeText.background = false;
		throttleModeText.setNewTextFormat(textFormat);
		throttleModeText.text = text;

		BuildMenu(m_frame, 40 + extents.width, 30);
	}
	
	private function BuildMenu(modalMC:MovieClip, x:Number, y:Number):Void
	{
		m_throttleX = x;
		m_throttleY = y;
		var colours:Array = BuildGroup.GetColourArray(BuildGroup.GRAY);
		m_menu = new MenuPanel(modalMC, "ThrottleMenu", 4, colours[0], colours[1]);
		var subMenu:MenuPanel = new MenuPanel(modalMC, "ThrottlePanel", 4, colours[0], colours[1]);
		AddItem(subMenu, THROTTLE_MODE0, colours);
		AddItem(subMenu, THROTTLE_MODE1, colours);
		AddItem(subMenu, THROTTLE_MODE2, colours);
		AddItem(subMenu, THROTTLE_MODE3, colours);
		m_menu.AddSubMenu(m_throttleMode, subMenu, colours[0], colours[1]);
		
		var pt:Object = m_menu.GetDimensions(x, y, true, 0, 0, modalMC.width, modalMC.height);
		m_menu.Rebuild();
		m_menu.RebuildSubmenus();
		m_menu.SetVisible(true);
	}
	
	private function AddItem(subMenu:MenuPanel, name:String, colours:Array):Void
	{
		subMenu.AddItem(name, Delegate.create(this, ThrottleChanged), colours[0], colours[1]);
	}
	
	private function ThrottleChanged(throttleName:String):Void
	{
		m_throttleMode = throttleName;
		setTimeout(Delegate.create(this, RebuildMenu), 10);
	}
	
	private function RebuildMenu():Void
	{
		m_menu.Unload();
		BuildMenu(m_frame, m_throttleX, m_throttleY);
		Save();
	}
}