import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.Tooltip;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Log;
import mx.utils.Delegate;
import com.boobuilds.DebugWindow;
import com.boobuilds.IntervalCounter;

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
 * 
 * This code is based on the icon handling from BooDecks by Aedani, original code by Viper.  Thanks to Aedani and Viper.
 */
class com.boobuilds.BIcon
{
	public static var ICON_X:String = "ICON_X";
	public static var ICON_Y:String = "ICON_Y";
	private var m_parent:MovieClip;
	private var m_icon:MovieClip;
	private var m_tooltip:TooltipInterface;
	private var m_toggleLeftVisibleFunc:Function;
	private var m_toggleRightVisibleFunc:Function;
	private var m_toggleShiftLeftVisibleFunc:Function;
	private var m_ctrlToggleVisibleFunc:Function;
	private var m_version:String;
	private var m_dragging:Boolean;
	private var m_x:Number;
	private var m_y:Number;

	/* VTIO */

	// The two distributed values used for monitoring when VTIO is loaded and the open/close state of your option window.
	private var m_VTIOIsLoadedMonitor:DistributedValue;

	// Variables for checking if the compass is there
	private var m_CompassCheckTimer:IntervalCounter;

	// The add-on information string, separated into 5 segments.
	// First is the add-on name as it will appear in the Add-on Manager list.
	// Second is the developer name (your name).
	// Third is the current version number, choose any format you like.
	// Fourth is the distributed value used to open/close your option window. Can be undefined if you have no options.
	// Fifth is the path to your icon as seen in-game using Ctrl + Shift + F2 (the debug window). Can be undefined if you have no icon (this also means your add-on won't be slotable).
	private var VTIOAddonInfo_s:String;
	
	public function BIcon(parent:MovieClip, icon:MovieClip, version:String, toggleLeftVisibleFunc:Function, toggleRightVisibleFunc:Function, toggleShiftLeftVisibleFunc:Function, ctrlToggleVisibleFunc:Function, x:Number, y:Number)
	{
		if (icon == null)
		{
			DebugWindow.Log(DebugWindow.Debug, "Icon null");
		}
		m_parent = parent;
		m_icon = icon;
		m_version = version;
		m_toggleLeftVisibleFunc = toggleLeftVisibleFunc;
		m_toggleRightVisibleFunc = toggleRightVisibleFunc;
		m_toggleShiftLeftVisibleFunc = toggleShiftLeftVisibleFunc;
		m_ctrlToggleVisibleFunc = ctrlToggleVisibleFunc;
		m_dragging = false;
		
		if (x < 0 || x > Stage.width - 18)
		{
			m_x = -1;
		}
		else
		{
			m_x = x;
		}
		
		if (y < 0 || y > Stage.height - 18)
		{
			m_y = -1;
		}
		else
		{
			m_y = y;
		}
		
		VTIOAddonInfo_s = "BooBuilds|Boorish|" + m_version + "|VTIO_BooBuilds|_root.boobuilds\\boobuilds.BooBuildsIcon";

		onLoad();
	}
	
	public function GetIcon():MovieClip
	{
		return m_icon;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		if (!m_VTIOIsLoadedMonitor.GetValue())
		{
			pt.x = m_icon._x;
			pt.y = m_icon._y;
		}
		else
		{
			pt.x = -1;
			pt.y = -1;
		}
		
		return pt;
	}
	
	private function onLoad():Void
	{
		// Setting up the VTIO loaded monitor.
		m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
		m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);

		// Setting up your icon.
		m_icon._width = 18;
		m_icon._height = 18;
		m_icon.onMousePress = Delegate.create(this, onMousePress);
		m_icon.onRelease = Delegate.create(this, onRelease);
		m_icon.onRollOver = Delegate.create(this, onRollover);
		m_icon.onRollOut = Delegate.create(this, onRollout);
		
		if (m_x == -1 || m_y == -1)
		{
			m_CompassCheckTimer = new IntervalCounter("IconPosition", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, PositionIcon), Delegate.create(this, PositionOnCompassMissing), null, IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			m_icon._x = m_x;
			m_icon._y = m_y;
		}

		// Check if VTIO is loaded (if it loaded before this add-on was).
		SlotCheckVTIOIsLoaded();
	}

	private function onMousePress(buttonIndex:Number, clickCount:Number):Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
		DistributedValue.SetDValue("VTIO_BooBuilds", !DistributedValue.GetDValue("VTIO_BooBuilds"));
		if (buttonIndex == 1)
		{
			if (Key.isDown(Key.SHIFT))
			{
				m_toggleShiftLeftVisibleFunc();
			}
			else
			{
				m_toggleLeftVisibleFunc();
			}
		}
		else
		{
			if (Key.isDown(Key.CONTROL))
			{
				m_ctrlToggleVisibleFunc();
			}
			else
			{
				if (Key.isDown(Key.SHIFT) && !m_VTIOIsLoadedMonitor.GetValue())
				{
					m_dragging = true;
					m_icon.startDrag();
				}
				else
				{
					m_toggleRightVisibleFunc();
				}
			}
		}
	}
	
	private function onRelease():Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
		if (m_dragging == true)
		{
			m_dragging = false;
			m_icon.stopDrag();
			
		}
	}
	
	private function onRollover():Void
	{
		if (m_dragging != true)
		{
			if (m_tooltip != undefined) m_tooltip.Close();
			var tooltipData:TooltipData = new TooltipData();
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>BooBuilds v" + m_version + " by Boorish</b></font>");
			tooltipData.AddAttributeSplitter();
			tooltipData.AddAttribute("", "");
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Left click to choose a build</font>");
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Shift+Left click to choose an outfit</font>");
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Right click to edit builds and outfits</font>");
			tooltipData.m_Padding = 4;
			tooltipData.m_MaxWidth = 210;
			m_tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 0, tooltipData);
		}
	}
	
	private function onRollout():Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
	}

	// The compass check function.
	private function PositionIcon():Boolean
	{
		var finish:Boolean = false;
		if (m_dragging == true)
		{
			finish = true;
		}
		else
		{
			if (_root.compass != undefined && _root.compass._x != undefined && _root.compass._x > 0) {
				var myPoint:Object = new Object();
				myPoint.x = _root.compass._x - 245;
				myPoint.y = _root.compass._y + 0;
				_root.localToGlobal(myPoint);
				_root.boobuilds.globalToLocal(myPoint);
				m_icon._x = myPoint.x;
				m_icon._y = myPoint.y;
				finish = true;
			}
		}
		
		return finish;
	}
	
	private function PositionOnCompassMissing(isError:Boolean):Void
	{
		if (isError == true)
		{
			m_icon._x = Stage.width / 4 + 55;
			m_icon._y = 2;
		}
	}

	// The function that checks if VTIO is actually loaded and if it is sends the add-on information defined earlier.
	// This function will also get called if VTIO loads after your add-on. Make sure not to remove the check for seeing if the value is actually true.
	private function SlotCheckVTIOIsLoaded():Void
	{
		if (m_VTIOIsLoadedMonitor.GetValue())
		{
			DistributedValue.SetDValue("VTIO_RegisterAddon", VTIOAddonInfo_s);
		}
	}
	
}
