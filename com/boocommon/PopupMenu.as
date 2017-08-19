import caurina.transitions.Tweener;
import com.boocommon.DebugWindow;
import com.boocommon.Graphics;
import com.boocommon.TreeCheck;
import com.boocommon.PopupMenu;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Utils.Text;
import org.sitedaniel.utils.Proxy;
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
class com.boocommon.PopupMenu
{
	private var SEPARATOR:String = "__Separator__";
	private var m_parent:MovieClip;
	private var m_menu:MovieClip;
	private var m_parentMenu:PopupMenu;
	private var m_name:String;
	private var m_margin:Number;
	private var m_names:Array;
	private var m_funcs:Array;
	private var m_cells:Array;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_elementHeight:Number;
	private var m_x:Number;
	private var m_y:Number;
	private var m_textFormat:TextFormat;
	private var m_colors:Array;
	private var m_userData:Object;
	
	public function PopupMenu(parent:MovieClip, name:String, margin:Number, color1:Number, color2:Number) 
	{
		if (color1 != null && color2 != null)
		{
			m_colors = [color1, color2]
		}
		else
		{
			m_colors = [0x2E2E2E, 0x585858]
		}
		
		m_margin = margin;
		m_name = name;
		
		m_names = new Array();
		m_funcs = new Array();
		m_cells = new Array();
		m_parent = parent;
		m_menu = m_parent.createEmptyMovieClip("PopupMenu_" + m_name, m_parent.getNextHighestDepth());
		m_menu._visible = false;

		m_textFormat = Graphics.GetBoldTextFormat();
	}
	
	public function SetUserData(o:Object):Void
	{
		m_userData = o;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_menu._x;
		pt.y = m_menu._y;
		return pt;
	}
	
	public function SetCoords(x:Number, y:Number):Void
	{
		m_menu._x = x;
		m_menu._y = y;
	}
	
	public function AddItem(name:String, callback:Function):Void
	{
		m_names.push(name);
		m_funcs.push(callback);
	}
	
	public function AddSeparator():Void
	{
		m_names.push(SEPARATOR);
		m_funcs.push(null);
	}
	
	public function Rebuild():Void
	{
		m_cells = new Array();
	
		SetTextExtents(m_textFormat);
		
		DrawFrame();
		
		for (var i:Number = 0; i < m_names.length; ++i)
		{
			DrawEntry(i);
		}
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			Mouse.addListener(this);
		}
		else
		{
			Mouse.removeListener(this);
		}
		
		m_menu._visible = visible;
	}
	
	public function GetVisible():Boolean
	{
		return m_menu._visible;
	}
	
	public function ToggleVisible():Void
	{
		SetVisible(!GetVisible());
	}

	private function CellPressed(indx:Number):Void
	{		
		SetVisible(false);
		
		if (m_funcs[indx] != null)
		{
			m_funcs[indx](m_userData);
		}
	}
	
	private function SetTextExtents(myTextFormat:TextFormat):Void
	{
		m_elementHeight = 0;
		m_maxWidth = 0;

		for (var i:Number = 0; i < m_names.length; ++i)
		{
			var extents:Object = Text.GetTextExtent(m_names[i], myTextFormat, m_menu);
			if (extents.width > m_maxWidth)
			{
				m_maxWidth = extents.width;
			}
			
			if (extents.height > m_elementHeight)
			{
				m_elementHeight = extents.height;
			}
		}
		
		m_maxWidth += m_margin * 2;
		m_maxHeight = m_elementHeight * m_names.length + m_margin * 2;
	}
	
	private function onMouseDown():Void
	{
		if (!m_menu.hitTest(_root._xmouse, _root._ymouse, false))
		{
			SetVisible(false);
		}		
	}
	
	private function DrawFrame():Void
	{		
		Graphics.DrawGradientFilledRoundedRectangle(m_menu, 0xFFFFFF, 2, m_colors, 0, 0, m_maxWidth, m_maxHeight);
	}
	
	private function DrawEntry(indx:Number):Void
	{
		var y:Number = (indx * m_elementHeight) + m_margin;
		var menuCell:MovieClip = m_menu.createEmptyMovieClip(m_names[indx], m_menu.getNextHighestDepth());
		Graphics.DrawFilledRectangle(menuCell, 0x000000, 0, 0x000000, 100, 2, 0, m_maxWidth - 4, m_elementHeight);
		menuCell._x = 0;
		menuCell._y = y;
		menuCell._alpha = 0;
		
		if (m_names[indx] == SEPARATOR)
		{
			var menuSep:MovieClip = m_menu.createEmptyMovieClip("Sep_" + indx, m_menu.getNextHighestDepth());
			menuSep._x = 0;
			menuSep._y = y + Math.round(m_elementHeight / 2 - 2)
			menuSep.lineStyle(3, 0xffffff, 60, true, "none", "round", "round");
			menuSep.beginFill(0xffffff, 60);
			menuSep.moveTo(m_margin, 0);
			menuSep.lineTo(m_maxWidth - m_margin, 0);
			menuSep.endFill();
		}
		else
		{
			var labelExtents:Object = Text.GetTextExtent(m_names[indx], m_textFormat, m_menu);
			var menuText:TextField = Graphics.DrawText(m_names[indx] + "MenuText", m_menu, m_names[indx], m_textFormat, m_margin, y + Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);

			menuCell.onRollOver = Proxy.create(this, function() { menuCell._alpha = 0; Tweener.addTween(menuCell, { _alpha:100, time:0.2, transition:"linear" } ); } );
			menuCell.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(menuCell); menuCell._alpha = 0; } );
			menuCell.onPress = Proxy.create(this, function(i:Number) { Tweener.removeTweens(menuCell); menuCell._alpha = 0; this.CellPressed(i); }, indx);
		}
		
		m_cells.push(menuCell);
	}
}
