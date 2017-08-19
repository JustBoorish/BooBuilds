import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
import com.boocommon.DebugWindow;
import com.boocommon.Graphics;
import com.boocommon.IntervalCounter;
import com.boocommon.MenuPanel;
import caurina.transitions.Tweener;
import org.sitedaniel.utils.Proxy;
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
class com.boobuilds.QuickSwitchIcons
{
	public static var X:String = "QUICK_X";
	public static var Y:String = "QUICK_Y";
	
	private static var DPS_ID:String = "#1";
	private static var HEALS_ID:String = "#2";
	private static var TANK_ID:String = "#3";
	
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_quickBuilds:Object;
	private var m_callback:Function;
	private var m_frame:MovieClip;
	private var m_tankIcon:MovieClip;
	private var m_healsIcon:MovieClip;
	private var m_dpsIcon:MovieClip;
	private var m_tankBuilds:Array;
	private var m_dpsBuilds:Array;
	private var m_healBuilds:Array;
	private var m_interval:IntervalCounter;
	private var m_menu:MenuPanel;
	private var m_x:Number;
	private var m_y:Number;
	private var m_dragging:Boolean;
	private var m_isDragging:Boolean;
	private var m_dragFrame:MovieClip;
	
	public function QuickSwitchIcons(name:String, parent:MovieClip, x:Number, y:Number, dragging:Boolean, quickBuilds:Object, callback:Function) 
	{
		m_name = name;
		m_parent = parent;
		m_quickBuilds = quickBuilds;
		m_callback = callback;
		m_x = x;
		m_y = y;
		m_dragging = dragging;
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_isDragging = false;
		
		SetGroupArrays();
		DrawControls();
	}
	
	public function Show():Void
	{
		if (m_x >= 0)
		{
			CompleteShow();
		}
		else
		{
			if (m_interval != null)
			{
				m_interval.Stop();
			}
			
			m_interval = new IntervalCounter("QuickSwitchPosition", IntervalCounter.WAIT_MILLIS, 250, Delegate.create(this, IsAbilityBarVisible), Delegate.create(this, CompleteShow), null, true); 
		}
	}
	
	public function Unload():Void
	{
		ClearMenu();
		m_frame.removeMovieClip();
	}
	
	public function GetPostion():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	private function IsAbilityBarVisible():Boolean
	{
		var ret:Boolean = false;
		if (_root["abilitybar"] != null && _root["abilitybar"]["m_MainBar"] != null)
		{
			ret = true;
		}
		
		return ret;
	}
	
	private function CompleteShow():Void
	{
		if (m_x >= 0)
		{
			m_frame._x = m_x;
			m_frame._y = m_y;
		}
		else if (_root["abilitybar"] != null && _root["abilitybar"]["m_MainBar"] != null)
		{
			var abilityBar:MovieClip = _root["abilitybar"]["m_MainBar"];
			var pt:Object = new Object();
			pt.x = abilityBar._x;
			pt.y = abilityBar._y + abilityBar._height;
			abilityBar.localToGlobal(pt);
			m_parent.globalToLocal(pt);
			m_frame._x = pt.x - m_frame._width - 5;
			m_frame._y = pt.y - m_frame._height - 5;
		}
		else
		{
			var pt:Object = new Object();
			pt.x = Stage.width / 2 - Stage.width / 5
			pt.y = Stage.height;
			m_parent.globalToLocal(pt);
			m_frame._x = pt.x - m_frame._width;
			m_frame._y = pt.y - m_frame._height - 5;
		}
		
		m_frame._visible = true;
	}
	
	private function SetGroupArrays():Void
	{
		m_tankBuilds = new Array();
		m_dpsBuilds = new Array();
		m_healBuilds = new Array();
		
		if (m_quickBuilds != null)
		{
			for (var indx in m_quickBuilds)
			{
				var thisBuild:Build = m_quickBuilds[indx];
				if (thisBuild != null)
				{
					if (thisBuild.GetGroup() == DPS_ID)
					{
						m_dpsBuilds.push(thisBuild);
					}
					else if (thisBuild.GetGroup() == HEALS_ID)
					{
						m_healBuilds.push(thisBuild);
					}
					else if (thisBuild.GetGroup() == TANK_ID)
					{
						m_tankBuilds.push(thisBuild);
					}
				}
			}
		}
	}
	
	public function DrawButton(name:String, parent:MovieClip, iconTag:String, x:Number, y:Number, width:Number, callback:Function):MovieClip
	{
		var icon:MovieClip = m_frame.attachMovie(iconTag, name, m_frame.getNextHighestDepth());
		var oldWidth:Number = icon._width;
		icon._width = width;
		icon._height = width;

		if (m_dragging != true)
		{
			var iconHover:MovieClip = icon.createEmptyMovieClip(name + "Hover", icon.getNextHighestDepth());
			Graphics.DrawFilledRoundedRectangle(iconHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, oldWidth, oldWidth);
			iconHover._x = 0;
			iconHover._y = 0;
			iconHover._alpha = 0;

			icon.onRollOver = function() { iconHover._alpha = 0; Tweener.addTween(iconHover, { _alpha:40, time:0.5, transition:"linear" } ); };
			icon.onRollOut = function() { Tweener.removeTweens(iconHover); iconHover._alpha = 0; };
			icon.onPress = function() { Tweener.removeTweens(iconHover); iconHover._alpha = 0; callback(); };
		}
		
		icon._x = x;
		icon._y = y;
		
		return icon;
	}
	
	private function DrawControls():Void
	{
		var width:Number = 26;
		var margin:Number = 4;
		var x:Number = 0;
		
		if ((m_dragging == true) || (m_tankBuilds != null && m_tankBuilds.length > 0))
		{
			m_tankIcon = DrawButton("TankIcon", m_frame, "BooBuildsTank", x, 0, width, Delegate.create(this, TankPressed));
			x += width + margin;
		}
		
		if ((m_dragging == true) || (m_healBuilds != null && m_healBuilds.length > 0))
		{
			m_healsIcon = DrawButton("HealsIcon", m_frame, "BooBuildsHeals", x, 0, width, Delegate.create(this, HealPressed));
			x += width + margin;
		}
		
		if ((m_dragging == true) || (m_dpsBuilds != null && m_dpsBuilds.length > 0))
		{
			m_dpsIcon = DrawButton("DPSIcon", m_frame, "BooBuildsDPS", x, 0, width, Delegate.create(this, DPSPressed));
			x += width + margin;
		}
		
		if (m_dragging == true)
		{
			m_dragFrame = m_frame.createEmptyMovieClip("DragFrame", m_frame.getNextHighestDepth());
			Graphics.DrawFilledRoundedRectangle(m_dragFrame, 0xFFFFFF, 0, 0xFFFFFF, 30, 0, 0, m_dpsIcon._x + m_dpsIcon._width, m_dpsIcon._height);
			
			m_dragFrame.onMouseDown = Delegate.create(this, DragStarted);
			m_dragFrame.onRelease = Delegate.create(this, DragStopped);
		}
	}
	
	private function DragStarted():Void
	{
		m_frame.startDrag();
		m_dragging = true;
	}
	
	private function DragStopped():Void
	{
		m_frame.stopDrag();
		m_dragging = false;
		
		if (m_callback != null)
		{
			m_callback(m_frame._x, m_frame._y);
		}
	}
	
	private function TankPressed():Void
	{
		if (m_menu.GetVisible() == true)
		{
			m_menu.SetVisible(false);
		}
		else
		{
			ShowMenu(TANK_ID, BuildGroup.GetColourArray(BuildGroup.BLUE), m_tankIcon);
		}
	}
	
	private function HealPressed():Void
	{
		if (m_menu.GetVisible() == true)
		{
			m_menu.SetVisible(false);
		}
		else
		{
			ShowMenu(HEALS_ID, BuildGroup.GetColourArray(BuildGroup.GREEN), m_healsIcon);
		}
	}
	
	private function DPSPressed():Void
	{
		if (m_menu.GetVisible() == true)
		{
			m_menu.SetVisible(false);
		}
		else
		{
			ShowMenu(DPS_ID, BuildGroup.GetColourArray(BuildGroup.RED), m_dpsIcon);
		}
	}
	
	private function ClearMenu():Void
	{
		if (m_menu != null)
		{
			m_menu.Unload();
			m_menu = null;
		}
	}
	
	private function ShowMenu(groupID:String, colours:Array, icon:MovieClip):Void
	{
		ClearMenu();
		m_menu = new MenuPanel(m_parent, "QuickMenu", 4);
		BuildSingleMenu(groupID, colours, m_menu);

		var dims:Object = m_menu.GetDimensions(0, 0, true, 0, 0, Stage.width, Stage.height);
		var pt:Object = new Object();
		pt.x = icon._width / 2;
		if (m_frame._y > Stage.height / 2)
		{
			pt.y = icon._y;
		}
		else
		{
			pt.y = icon._y + icon._height;
		}
		
		icon.localToGlobal(pt);
		
		if (m_frame._y > Stage.height / 2)
		{
			pt.y = pt.y - (dims.maxY - dims.y);
		}
		
		m_menu.GetDimensions(pt.x, pt.y, true, 0, 0, Stage.width, Stage.height);
		m_menu.Rebuild();
		m_menu.RebuildSubmenus();
		m_menu.SetVisible(true);
	}
	
	private function BuildSingleMenu(groupID:String, colours:Array, menu:MenuPanel):Void
	{
		var sortedBuilds:Array = Build.GetOrderedBuilds(groupID, m_quickBuilds);
		
		if (sortedBuilds.length > 0)
		{
			for (var indx:Number = 0; indx < sortedBuilds.length; ++indx)
			{
				var thisBuild:Build = sortedBuilds[indx];
				if (thisBuild != null && thisBuild.GetGroup() == groupID)
				{
					var add:Boolean = true;
					if (thisBuild.GetRequiredBuildID() != null && thisBuild.GetRequiredBuildID() != Build.GetCurrentBuildID())
					{
						add = false;
					}
					
					if (add == true)
					{
						menu.AddItem(thisBuild.GetName(), Proxy.create(this, BuildCallback, thisBuild.GetID()), colours[0], colours[1]);
					}
				}
			}
		}
	}
	
	private function BuildCallback(buildID:String):Void
	{
		m_menu.SetVisible(false);
			
		var thisBuild:Build = m_quickBuilds[buildID];
		if (thisBuild != null && m_callback != null)
		{
			m_callback(thisBuild);
		}
	}
}