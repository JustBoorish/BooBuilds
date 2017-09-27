import caurina.transitions.Tweener;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.MenuPanel;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Proxy;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
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
class com.boobuildscommon.MenuPanel
{
	private var m_parent:MovieClip;
	private var m_menu:MovieClip;
	private var m_name:String;
	private var m_margin:Number;
	private var m_leftMargin:Number;
	private var m_rightMargin:Number;
	private var m_names:Array;
	private var m_funcs:Array;
	private var m_subMenus:Array;
	private var m_cells:Array;
	private var m_hiddenCells:Array;
	private var m_tooltips:Array;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_elementHeight:Number;
	private var m_x:Number;
	private var m_y:Number;
	private var m_subMenuShown:Number;
	private var m_textFormat:TextFormat;
	private var m_italicFormat:TextFormat;
	private var m_colors:Array;
	private var m_cellColors:Array;
	private var m_tooltip:TooltipInterface;
	private var m_italics:Array;
	private var m_isBuilt:Boolean;
	private var m_areSubmenusBuilt:Boolean;
	
	public function MenuPanel(parent:MovieClip, name:String, margin:Number, color1:Number, color2:Number) 
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
		m_leftMargin = 10;
		m_rightMargin = 30;
		
		m_names = new Array();
		m_funcs = new Array();
		m_subMenus = new Array();
		m_cells = new Array();
		m_hiddenCells = new Array();
		m_cellColors = new Array();
		m_tooltips = new Array();
		m_italics = new Array();
		m_subMenuShown = null;
		m_tooltip = null;
		m_isBuilt = false;
		m_areSubmenusBuilt = false;
		m_parent = parent;
		m_menu = m_parent.createEmptyMovieClip("menuPanel_" + m_name, m_parent.getNextHighestDepth());

		m_textFormat = Graphics.GetBoldTextFormat();
		m_italicFormat = Graphics.GetItalicTextFormat();
	}
	
	public function GetMovieClip():MovieClip
	{
		return m_menu;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_menu._x;
		pt.y = m_menu._y;
		return pt;
	}
	
	public function Unload():Void
	{
		for (var i:Number = 0; i < m_names.length; ++i)
		{
			if (m_subMenus[i] != null)
			{
				m_subMenus[i].Unload();
			}
		}

		SetVisible(false);
		m_menu.removeMovieClip();
	}
	
	private function addEntry(name:String, callback:Function, subMenu:MenuPanel, color1:Number, color2:Number, tooltip:TooltipData, isItalic:Boolean):Void
	{
		m_names.push(name);
		m_funcs.push(callback);
		m_subMenus.push(subMenu);
		m_tooltips.push(tooltip);
		m_italics.push(isItalic);
		m_hiddenCells.push(false);
		if (color1 != null && color2 != null)
		{
			m_cellColors.push([color1, color2]);
		}
		else
		{
			m_cellColors.push([m_colors[0], m_colors[1]]);
		}
	}
	
	public function AddItem(name:String, callback:Function, color1:Number, color2:Number, tooltip:TooltipData, isItalic:Boolean):Number
	{
		addEntry(name, callback, null, color1, color2, tooltip, isItalic);
		return m_names.length - 1;
	}
	
	public function AddSubMenu(name:String, subMenu:MenuPanel, color1:Number, color2:Number):Number
	{
		subMenu.SetVisible(false);
		addEntry(name, null, subMenu, color1, color2, null, false);
		return m_names.length - 1;
	}
	
	public function Rebuild():Void
	{
		if (m_isBuilt != true)
		{
			ClearCells();
			m_cells = new Array();
		
			var row:Number = 0;
			var col:Number = 0;
			for (var i:Number = 0; i < m_names.length; ++i)
			{
				var y:Number = (row * m_elementHeight) + (row * m_margin);
				if (y + m_elementHeight >= Stage.height)
				{
					row = 0;
					++col;
				}
				
				DrawEntry(i, row, col);
				++row;
			}
			
			m_isBuilt = true;
		}
	}
	
	public function RebuildSubmenus():Void
	{
		if (m_areSubmenusBuilt != true)
		{
			for (var i:Number = 0; i < m_names.length; ++i)
			{
				if (m_subMenus[i] != null)
				{
					m_subMenus[i].Rebuild();
				}
			}
			
			m_areSubmenusBuilt = true;
		}
	}
	
	private function ClearCells():Void
	{
		if (m_cells != null)
		{
			for (var indx:Number = 0; indx < m_cells.length; ++indx)
			{
				if (m_cells[indx] != null)
				{
					m_cells[indx].removeMovieClip();
					m_cells[indx] = null;
				}
			}
		}
		
		m_cells = new Array();
	}
	
	public function GetVisible():Boolean
	{
		return m_menu._visible;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			RebuildSubmenus();
			m_subMenuShown = null;
			for (var i:Number = 0; i < m_cells.length; ++i)
			{
				m_cells[i]._alpha = 100;
				m_cells[i]._visible = !m_hiddenCells[i];
			}
		}
		else
		{
			CloseTooltip();
			
			if (m_subMenuShown != null)
			{
				m_subMenus[m_subMenuShown].SetVisible(false);
			}
		}
		
		m_menu._visible = visible;
	}
	
	public function SetCellHidden(indx:Number, hidden:Boolean):Void
	{
		if (indx >= 0 && indx < m_hiddenCells.length)
		{
			m_hiddenCells[indx] = hidden;
		}
	}
	
	private function ResetSizes():Void
	{
		SetTextExtents(m_textFormat);
		m_maxHeight = m_elementHeight * m_names.length + m_margin * (m_names.length - 1);
	}
	
	private function SetXY(x:Number, y:Number, topMenu:Boolean, minX:Number, minY:Number, maxX:Number, maxY:Number):Void
	{
		if (topMenu == true)
		{
			m_x = x;
			m_y = y;
		}
		else
		{
			if (x + m_maxWidth > maxX)
			{
				m_x = maxX - m_maxWidth;
			}
			else
			{
				m_x = x;
			}
			
			var entries:Number = m_names.length;
			if (entries < 3)
			{
				m_y = y;
			}
			else if (entries % 2 == 1)
			{
				var count:Number = (entries - 1) / 2;
				m_y = y - (count * m_elementHeight) - (count * m_margin);
			}
			else
			{
				var count:Number = (entries - 2) / 2;
				m_y = y - (count * m_elementHeight) - (count * m_margin);
			}
			
			if (m_y + m_maxHeight > maxY)
			{
				m_y = maxY - m_maxHeight;
			}
			
			if (m_y < minY)
			{
				m_y = minY;
			}
		}
		
		m_menu._x = m_x;
		m_menu._y = m_y;
	}
	
	public function GetDimensions(x:Number, y:Number, topMenu:Boolean, minX:Number, minY:Number, maxX:Number, maxY:Number):Object
	{
		ResetSizes();
		
		SetXY(x, y, topMenu, minX, minY, maxX, maxY);
		
		var pt:Object = new Object();
		pt.x = m_x;
		pt.y = m_y;
		pt.maxX = pt.x + m_maxWidth;
		pt.maxY = pt.y + m_maxHeight;

		for (var i:Number = 0; i < m_names.length; ++i)
		{
			if (m_subMenus[i] != null)
			{
				var innerY:Number;
				if (i == 0)
				{
					innerY = pt.y;
				}
				else
				{
					innerY = pt.y + (m_elementHeight * i) + (m_margin * i);
				}
				
				var innerPt:Object = m_subMenus[i].GetDimensions(pt.x + 30, innerY, false, minX, minY, maxX, maxY);
				if (innerPt.maxX > pt.maxX)
				{
					pt.maxX = innerPt.maxX;
				}
				
				if (innerPt.maxY > pt.maxY)
				{
					pt.maxY = innerPt.maxY;
				}
			}
		}
		
		return pt;
	}

	public function GetGlobalTopBottom():Object
	{
		var pt:Object = new Object();
		pt.x = 0;
		pt.y = m_menu._y;
		m_parent.localToGlobal(pt);
		pt.maxY = pt.y + m_menu._height;
		return pt;
	}
	
	private function ShowSubMenu(indx:Number):Void
	{
		for (var i:Number = 0; i < m_cells.length; ++i)
		{
			m_cells[i]._alpha = 60;
		}
		
		// show the sub menu
		m_subMenuShown = indx;
		m_subMenus[indx].SetVisible(true);
	}
	
	private function CellPressed(indx:Number):Void
	{
		if (m_subMenuShown != null)
		{
			m_subMenus[m_subMenuShown].SetVisible(false);
			SetVisible(true);
		}
		else if (m_subMenus[indx] != null)
		{
			ShowSubMenu(indx);
		}
		else if (m_funcs[indx] != null)
		{
			m_funcs[indx](m_names[indx]);
		}
	}
	
	private function ShowTooltip(indx:Number):Void
	{
        CloseTooltip();
		if (m_tooltips[indx] != null)
		{
			m_tooltip = TooltipManager.GetInstance().ShowTooltip( m_cells[indx], TooltipInterface.e_OrientationVertical, 0.2, m_tooltips[indx] );
		}
	}
	
	private function CloseTooltip():Void
	{
		if (m_tooltip != null)
		{
			m_tooltip.Close();
			m_tooltip = null;
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
		
		m_elementHeight += m_margin * 2;
		m_maxWidth += m_leftMargin + m_rightMargin;
	}
	
	private function DrawEntry(indx:Number, row:Number, col:Number):Void
	{
		var y:Number = (row * m_elementHeight) + (row * m_margin);
		var menuCell:MovieClip = m_menu.createEmptyMovieClip(m_names[indx], m_menu.getNextHighestDepth());
		Graphics.DrawGradientFilledRoundedRectangle(menuCell, 0x000000, 0, m_cellColors[indx], 0, 0, m_maxWidth, m_elementHeight);
		menuCell._x = col * (m_maxWidth + m_margin * 2);
		menuCell._y = y;
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(m_names[indx] + "Hover", menuCell.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, m_maxWidth, m_elementHeight);
		menuHover._x = 0;
		menuHover._y = 0;
		menuHover._alpha = 0;

		if (m_italics[indx] == true)
		{
			var labelExtents:Object = Text.GetTextExtent(m_names[indx], m_italicFormat, menuCell);
			Graphics.DrawText(m_names[indx] + "MenuText", menuCell, m_names[indx], m_italicFormat, m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		}
		else
		{
			var labelExtents:Object = Text.GetTextExtent(m_names[indx], m_textFormat, menuCell);
			Graphics.DrawText(m_names[indx] + "MenuText", menuCell, m_names[indx], m_textFormat, m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		}
		
		if (m_subMenus[indx] != null)
		{
			var menuButton:MovieClip = menuCell.createEmptyMovieClip(m_names[indx] + "Button", menuCell.getNextHighestDepth());
			var buttonSize:Number = 4;
			menuButton._x = menuCell._width - (m_rightMargin / 2); 
			menuButton._y = m_elementHeight / 2 - (buttonSize / 2);
			menuButton.lineStyle(0, 0xFFFFFF, 100, true, "none", "square", "round");
			menuButton.beginFill(0xFFFFFF, 100);
			menuButton.moveTo(0, 0);
			menuButton.lineTo(buttonSize, buttonSize / 2);
			menuButton.lineTo(0, buttonSize);
			menuButton.lineTo(0, 0);
			menuButton.endFill();
		}
		
		menuCell.onRollOver = Delegate.create(this, function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); this.ShowTooltip(indx); } );
		menuCell.onRollOut = Delegate.create(this, function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; this.CloseTooltip(); } );
		menuCell.onPress = Proxy.create(this, function(i:Number) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; this.CellPressed(i); }, indx);

		m_cells.push(menuCell);
	}
}