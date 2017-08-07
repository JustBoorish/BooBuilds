import caurina.transitions.Tweener;
import com.boobuilds.DebugWindow;
import com.boobuilds.Graphics;
import com.boobuilds.TreeCheck;
import com.boobuilds.TreePanel;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Utils.Text;
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
class com.boobuilds.TreePanel
{
	private var m_parent:MovieClip;
	private var m_menu:MovieClip;
	private var m_parentMenu:TreePanel;
	private var m_name:String;
	private var m_margin:Number;
	private var m_leftMargin:Number;
	private var m_rightMargin:Number;
	private var m_names:Array;
	private var m_funcs:Array;
	private var m_subMenus:Array;
	private var m_userData:Array;
	private var m_cells:Array;
	private var m_treeChecks:Array;
	private var m_tooltips:Array;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_elementHeight:Number;
	private var m_x:Number;
	private var m_y:Number;
	private var m_textFormat:TextFormat;
	private var m_italicFormat:TextFormat;
	private var m_colors:Array;
	private var m_cellColors:Array;
	private var m_tooltip:TooltipInterface;
	private var m_italics:Array;
	private var m_isBuilt:Boolean;
	private var m_areSubmenusBuilt:Boolean;
	private var m_layer:Number;
	private var m_layoutCallback:Function;
	private var m_contextMenuCallback:Function;
	
	public function TreePanel(parent:MovieClip, name:String, margin:Number, color1:Number, color2:Number, layoutCallback:Function, contextMenuCallback:Function) 
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
		m_layer = 0;
		m_layoutCallback = layoutCallback;
		m_contextMenuCallback = contextMenuCallback;
		
		m_names = new Array();
		m_funcs = new Array();
		m_userData = new Array();
		m_subMenus = new Array();
		m_cells = new Array();
		m_treeChecks = new Array();
		m_cellColors = new Array();
		m_tooltips = new Array();
		m_italics = new Array();
		m_tooltip = null;
		m_isBuilt = false;
		m_areSubmenusBuilt = false;
		m_parentMenu = null;
		m_parent = parent;
		m_menu = m_parent.createEmptyMovieClip("TreePanel_" + m_name, m_parent.getNextHighestDepth());

		m_textFormat = Graphics.GetBoldTextFormat()
		m_italicFormat = Graphics.GetItalicTextFormat();
	}
	
	public function Unload():Void
	{
		m_menu._visible = false;
		m_menu.removeMovieClip();
	}
	
	public function GetMovieClip():MovieClip
	{
		return m_menu;
	}
	
	public function GetHeight():Number
	{
		return FindRoot().GetPanelHeight();
	}
	
	public function GetNumSubMenus():Number
	{
		return m_subMenus.length;
	}
	
	public function IsSubMenuOpen(indx:Number):Boolean
	{
		return m_subMenus[indx].GetVisible();
	}
	
	public function GetSubMenuName(indx:Number):String
	{
		return m_subMenus[indx].m_name;
	}
	
	private function GetPanelHeight():Number
	{
		var height:Number = m_elementHeight * m_cells.length;
		for (var i:Number = 0; i < m_cells.length; ++i)
		{
			if (m_subMenus[i] != null && m_subMenus[i].GetVisible() == true)
			{
				height += m_subMenus[i].GetPanelHeight();
			}
		}
		
		return height;
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
	
	private function addEntry(name:String, callback:Function, userData:String, subMenu:TreePanel, color1:Number, color2:Number, tooltip:TooltipData, isItalic:Boolean):Void
	{
		m_names.push(name);
		m_funcs.push(callback);
		m_userData.push(userData);
		m_subMenus.push(subMenu);
		m_tooltips.push(tooltip);
		m_italics.push(isItalic);
		if (color1 != null && color2 != null)
		{
			m_cellColors.push([color1, color2]);
		}
		else
		{
			m_cellColors.push([m_colors[0], m_colors[1]]);
		}
	}
	
	public function AddItem(name:String, callback:Function, userData:String, color1:Number, color2:Number, tooltip:TooltipData, isItalic:Boolean):Number
	{
		addEntry(name, callback, userData, null, color1, color2, tooltip, isItalic);
		return m_names.length - 1;
	}
	
	public function AddSubMenu(name:String, userData:String, subMenu:TreePanel, color1:Number, color2:Number):Number
	{
		subMenu.SetVisible(false);
		subMenu.m_layer = m_layer + 1;
		subMenu.m_parentMenu = this;
		addEntry(name, null, userData, subMenu, color1, color2, null, false);
		return m_names.length - 1;
	}
	
	public function Rebuild():Void
	{
		if (m_isBuilt != true)
		{
			m_cells = new Array();
			m_treeChecks = new Array();
		
			SetTextExtents(m_textFormat);
			
			for (var i:Number = 0; i < m_names.length; ++i)
			{
				DrawEntry(i);
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
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			Rebuild();
			RebuildSubmenus();
		}
		else
		{
			CloseTooltip();
			
			for (var i:Number = 0; i < m_subMenus.length; ++i)
			{
				if (m_subMenus[i] != null)
				{
					m_subMenus[i].SetVisible(false);
					m_treeChecks[i].SetChecked(false);
				}
			}
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

	public function ToggleSubMenu(indx:Number):Void
	{
		// show the sub menu
		m_treeChecks[indx].Toggle();
		m_subMenus[indx].ToggleVisible();
		Layout();
	}
	
	private function CellPressed(indx:Number, buttonIndx:Number):Void
	{
		if (buttonIndx == 1)
		{
			if (m_subMenus[indx] != null)
			{
				ToggleSubMenu(indx);
			}
			else if (m_funcs[indx] != null)
			{
				m_funcs[indx](m_userData[indx]);
			}
		}
		else if (buttonIndx == 2)
		{
			if (m_contextMenuCallback != null)
			{
				m_contextMenuCallback(m_userData[indx], m_subMenus[indx] != null);
			}
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
	
	private function FindRoot():TreePanel
	{
		var root:TreePanel = this;
		while (root.m_parentMenu != null)
		{
			root = root.m_parentMenu;
		}
		
		return root;
	}
	
	private function RecalculatePositions(baseY:Number):Number
	{
		if (m_parentMenu != null)
		{
			m_menu._x = m_layer * m_leftMargin + m_parentMenu.m_menu._x;
		}
		
		m_menu._y = baseY;
		
		var y:Number = 0;
		for (var i:Number = 0; i < m_cells.length; ++i)
		{
			m_cells[i]._y = y;
			y += m_elementHeight;
			
			if (m_subMenus[i] != null && m_subMenus[i].GetVisible() == true)
			{
				var subHeight:Number = m_subMenus[i].RecalculatePositions(y + baseY);
				y += subHeight;
			}
		}
		
		return y;
	}
	
	public function Layout():Void
	{
		var root:TreePanel = FindRoot();
		var rootY:Number = root.m_menu._y;
		root.RecalculatePositions(0);
		root.m_menu._y = rootY;
		if (m_layoutCallback != null)
		{
			m_layoutCallback(this);
		}
	}
	
	private function DrawEntry(indx:Number):Void
	{
		var menuCell:MovieClip = m_menu.createEmptyMovieClip(m_names[indx], m_menu.getNextHighestDepth());
		Graphics.DrawGradientFilledRoundedRectangle(menuCell, 0x000000, 0, m_cellColors[indx], 0, 0, m_maxWidth, m_elementHeight);
		menuCell._x = 0;
		menuCell._y = (indx * m_elementHeight);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(m_names[indx] + "Hover", menuCell.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, m_maxWidth, m_elementHeight);
		menuHover._x = 0;
		menuHover._y = 0;
		menuHover._alpha = 0;

		if (m_italics[indx] == true)
		{
			var labelExtents:Object = Text.GetTextExtent(m_names[indx], m_italicFormat, menuCell);
			Graphics.DrawText(m_names[indx] + "MenuText", menuCell, m_names[indx], m_italicFormat, m_leftMargin + m_margin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		}
		else
		{
			var labelExtents:Object = Text.GetTextExtent(m_names[indx], m_textFormat, menuCell);
			Graphics.DrawText(m_names[indx] + "MenuText", menuCell, m_names[indx], m_textFormat, m_leftMargin + m_margin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		}

		var treeCheck:TreeCheck = null;
		if (m_subMenus[indx] != null)
		{
			var checkSize:Number = 6;
			treeCheck = new TreeCheck(m_names[indx] + "MenuText", menuCell, m_margin, m_elementHeight / 2 - checkSize / 2, checkSize, null, false);
		}
		
		menuCell.onRollOver = Proxy.create(this, function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); if (treeCheck != null) { treeCheck.StartHover(); } this.ShowTooltip(indx); } );
		menuCell.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; if (treeCheck != null) { treeCheck.StopHover(); } this.CloseTooltip(); } );
		//menuCell.onPress = Proxy.create(this, function(i:Number) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; if (treeCheck != null) { treeCheck.StopHover(); } this.CellPressed(i); }, indx);
		menuCell.onMousePress = Delegate.create(this, function(buttonIndx:Number) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; if (treeCheck != null) { treeCheck.StopHover(); } this.CellPressed(indx, buttonIndx); });
		
		m_treeChecks.push(treeCheck);
		m_cells.push(menuCell);
	}
}
