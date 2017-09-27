import com.GameInterface.Tooltip.TooltipData;
import com.boobuilds.Favourite;
import com.boobuildscommon.Colours;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.IconButton;
import com.boobuildscommon.Proxy;
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
class com.boobuilds.FavouriteBar
{
	public static var X:String = "FAV_X";
	public static var Y:String = "FAV_Y";
	
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_dragFrame:MovieClip;
	private var m_favourites:Array;
	private var m_iconSize:Number;
	private var m_iconsPerRow:Number;
	private var m_icons:Array;
	private var m_margin:Number = 4;
	private var m_dragCallback:Function;
	private var m_callback:Function;
	
	public function FavouriteBar(name:String, parent:MovieClip, x:Number, y:Number, iconSize:Number, numIcons:Number, iconsPerRow:Number, drawEmpties:Boolean, favourites:Array, callback:Function)
	{
		m_name = name;
		m_parent = parent;
		m_iconSize = iconSize;
		m_iconsPerRow = iconsPerRow;
		m_favourites = favourites;
		m_callback = callback;
		
		DrawControls(numIcons, drawEmpties);
		m_frame._x = x;
		m_frame._y = y;
	}

	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function Unload():Void
	{
		m_frame.removeMovieClip();
		m_frame = null;
	}
	
	public function EnableDrag(dragCallback:Function):Void
	{
		DisableDrag();
		m_dragCallback = dragCallback;
		
		var row:Number = Math.ceil(m_icons.length / m_iconsPerRow);
		m_dragCallback = dragCallback;
		m_dragFrame = m_frame.createEmptyMovieClip(m_name + "DragFrame", m_frame.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(m_dragFrame, 0xFFFFFF, 0, 0xFFFFFF, 30, 0, 0, m_iconsPerRow * (m_iconSize + m_margin) - m_margin, row * (m_iconSize + m_margin));
		
		m_dragFrame.onPress = Delegate.create(this, DragStarted);
		m_dragFrame.onRelease = Delegate.create(this, DragStopped);
		m_dragFrame._visible = true;
		SetVisible(true);
	}
	
	public function DisableDrag():Void
	{
		m_dragCallback = null;
		if (m_dragFrame != null)
		{
			m_dragFrame._visible = false;
			m_dragFrame.removeMovieClip();
			m_dragFrame = null;
		}		
	}
	
	private function DrawControls(numIcons:Number, drawEmpties:Boolean):Void
	{
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_icons = new Array();
		var row:Number = 0;
		var col:Number = 0;
		for (var indx:Number = 0; indx < numIcons; ++indx)
		{
			if (col >= m_iconsPerRow)
			{
				col = 0;
				++row;
			}
			
			DrawButton(indx, row, col, drawEmpties);
			++col;
		}
		
	}
	
	private function DrawButton(indx:Number, row:Number, column:Number, drawEmpties:Boolean):Void
	{
		var favourite:Favourite = m_favourites[indx];
		var x:Number = column * (m_iconSize + m_margin);
		var y:Number = row * (m_iconSize + m_margin);
		var colours:Array = null;
		var tooltipData:TooltipData = null;
		
		if (favourite != null)
		{
			colours = Colours.GetColourArray(favourite.GetColour());
			tooltipData = CreateTooltip(favourite);
		}

		if (favourite != null || drawEmpties == true)
		{
			var emptyTooltipData:TooltipData = null;
			var buttonStyle:Number = IconButton.NONE;
			if (drawEmpties == true && favourite == null)
			{
				buttonStyle = IconButton.PLUS;
				emptyTooltipData = CreateEmptyTooltip();
			}
			
			var icon:IconButton = new IconButton("Icon" + row + "x" + column, m_frame, x, y, m_iconSize, m_iconSize, colours, [0xe6c016, 0xdda316], Proxy.create(this, IconPressed, indx), buttonStyle, IconButton.NONE, emptyTooltipData);
			if (favourite != null)
			{
				icon.SetIcon(null, favourite.GetIconPath(), 0, false, null, tooltipData, null);
			}
		
			m_icons.push(icon);
		}
		else
		{
			m_icons.push(null);
		}
	}
	
	private function CreateTooltip(favourite:Favourite):TooltipData
	{
		var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>" + favourite.GetType() + ":</b></font>");
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'>" + favourite.GetName() + "</font>");
		
		tooltipData.m_Padding = 4;
		tooltipData.m_MaxWidth = 120;
		return tooltipData;
	}

	private function CreateEmptyTooltip():TooltipData
	{
		var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>Click to assign build/outfit</b></font>");
		
		tooltipData.m_Padding = 4;
		tooltipData.m_MaxWidth = 120;
		return tooltipData;
	}

	private function DragStarted():Void
	{
		m_frame.startDrag();
	}
	
	private function DragStopped():Void
	{
		m_frame.stopDrag();
		
		if (m_dragCallback != null)
		{
			m_dragCallback(m_frame._x, m_frame._y);
		}
	}
	
	private function IconPressed(indx:Number):Void
	{
		if (m_callback != null)
		{
			m_callback(indx, m_favourites[indx]);
		}
	}
}