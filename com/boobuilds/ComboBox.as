import com.boobuilds.DebugWindow;
import com.boobuilds.ScrollPane;
import com.Utils.Text;
import caurina.transitions.Tweener;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
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
class com.boobuilds.ComboBox
{
	private var m_parent:MovieClip;
	private var m_combo:MovieClip;
	private var m_list:MovieClip;
	private var m_button:MovieClip;
	private var m_buttonText:TextField;
	private var m_name:String;
	private var m_textFormat:TextFormat;
	private var m_colors:Array;
	private var m_names:Array;
	private var m_cells:Array;
	private var m_masks:Array;
	private var m_scroll:ScrollPane;
	private var m_selectedName:String;
	private var m_entryHeight:Number;
	private var m_elementHeight:Number;
	private var m_maxWidth:Number;
	private var m_margin:Number;
	private var m_leftMargin:Number;
	private var m_rightMargin:Number;
	
	public function ComboBox(parent:MovieClip, name:String, addonMC:MovieClip, x:Number, y:Number, color1:Number, color2:Number, entryHeight:Number, selectedName:String, names:Array) 
	{
		if (color1 != null && color2 != null)
		{
			m_colors = [color1, color2]
		}
		else
		{
			m_colors = [0x2E2E2E, 0x585858]
		}
		
		m_name = name;
		m_parent = parent;
		m_entryHeight = entryHeight;
		m_selectedName = selectedName;
		m_combo = m_parent.createEmptyMovieClip("ComboBox_" + m_name, m_parent.getNextHighestDepth());
		m_list = addonMC.createEmptyMovieClip("ComboBoxPopup_" + m_name, addonMC.getNextHighestDepth());
		m_combo._x = x;
		m_combo._y = y;

		m_textFormat = new TextFormat();
		m_textFormat.align = "left";
		m_textFormat.font = "arial";
		m_textFormat.size = 14;
		m_textFormat.color = 0xFFFFFF;
		m_textFormat.bold = true;
		
		m_margin = 4;
		m_leftMargin = 2;
		m_rightMargin = 2;
		
		m_names = names;
		m_cells = new Array();
		m_masks = new Array();
		
		Draw();
	}
	
	public function GetSelectedEntry():String
	{
		return m_selectedName;
	}
	
	public function HidePopup():Void
	{
		m_scroll.SetVisible(false);
	}
	public function SetVisible(visible:Boolean):Void
	{
		HidePopup();
		
		if (visible != true)
		{
			m_combo._visible = false;
		}
		else
		{
			m_combo._visible = true;
		}
	}
	
	public function Unload():Void
	{
		m_combo.removeMovieClip();
		m_list.removeMovieClip();
	}
	
	public function Draw():Void
	{
		SetTextExtents();
		DrawButton(m_selectedName);
		
		for (var indx:Number = 0; indx < m_names.length; ++indx)
		{
			DrawComboEntry(indx);
		}
		
		m_scroll = new ScrollPane(m_combo, "Scroll_" + m_name, m_button._x, m_button._y + m_button._height, m_button._width, m_elementHeight * m_entryHeight, 0x262626);
		m_scroll.SetContent(m_list, m_list._height);
	}
	
	private function SetTextExtents():Void
	{
		m_elementHeight = 0;
		m_maxWidth = 0;

		for (var i:Number = 0; i < m_names.length; ++i)
		{
			var extents:Object = Text.GetTextExtent(m_names[i], m_textFormat, m_list);
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
	
	private function DrawComboEntry(indx:Number):Void
	{
		var radius:Number = 4;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var name:String = m_names[indx]
		
		matrix.createGradientBox(m_maxWidth, m_elementHeight, 90 / 180 * Math.PI, 0, 0);
		var menuCell:MovieClip = m_list.createEmptyMovieClip(name, m_list.getNextHighestDepth());
		menuCell._x = 0;
		menuCell._y = (indx * m_elementHeight) + (indx * m_margin);
		menuCell.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuCell.beginGradientFill("linear", m_colors, alphas, ratios, matrix);
		menuCell.moveTo(radius, 0);
		menuCell.lineTo((m_maxWidth-radius), 0);
		menuCell.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		menuCell.lineTo(m_maxWidth, (m_elementHeight-radius));
		menuCell.curveTo(m_maxWidth, m_elementHeight, (m_maxWidth-radius), m_elementHeight);
		menuCell.lineTo(radius, m_elementHeight);
		menuCell.curveTo(0, m_elementHeight, 0, (m_elementHeight-radius));
		menuCell.lineTo(0, radius);
		menuCell.curveTo(0, 0, radius, 0);
		menuCell.endFill();
		
		var menuMask:MovieClip = m_list.createEmptyMovieClip(name + "Mask", m_list.getNextHighestDepth());
		menuMask._x = 0;
		menuMask._y = (indx * m_elementHeight) + (indx * m_margin);
		menuMask.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuMask.beginFill(0x000000, 100);
		menuMask.moveTo(radius, 0);
		menuMask.lineTo(m_maxWidth, 0);
		menuMask.lineTo(m_maxWidth, m_elementHeight);
		menuMask.lineTo(radius, m_elementHeight);
		menuMask.curveTo(0, m_elementHeight, 0, (m_elementHeight-radius));
		menuMask.lineTo(0, radius);
		menuMask.curveTo(0, 0, radius, 0);
		menuMask.endFill();
		menuCell.setMask(menuMask);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(name + "Hover", m_list.getNextHighestDepth());
		menuHover._x = 0;
		menuHover._y = 0;
		menuHover.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuHover.beginFill(0xFFFFFF, 70);
		menuHover.moveTo(radius, 0);
		menuHover.lineTo((m_maxWidth-radius), 0);
		menuHover.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		menuHover.lineTo(m_maxWidth, (m_elementHeight-radius));
		menuHover.curveTo(m_maxWidth, m_elementHeight, (m_maxWidth-radius), m_elementHeight);
		menuHover.lineTo(radius, m_elementHeight);
		menuHover.curveTo(0, m_elementHeight, 0, (m_elementHeight-radius));
		menuHover.lineTo(0, radius);
		menuHover.curveTo(0, 0, radius, 0);
		menuHover.endFill();
		menuHover._alpha = 0;

		var labelExtents:Object = Text.GetTextExtent(name, m_textFormat, menuCell);
		var menuText:TextField = menuCell.createTextField(name + "MenuText", menuCell.getNextHighestDepth(), m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		menuText.embedFonts = true;
		menuText.selectable = false;
		menuText.antiAliasType = "advanced";
		menuText.autoSize = true;
		menuText.border = false;
		menuText.background = false;
		menuText.setNewTextFormat(m_textFormat);
		menuText.text = name;
		
		menuCell.onRollOver = Proxy.create(this, function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); } );
		menuCell.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; } );
		menuCell.onPress = Proxy.create(this, function(i:Number) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; this.CellPressed(i); }, indx);
		
		m_cells.push(menuCell);
		m_masks.push(menuMask);
	}
	
	private function CellPressed(indx:Number):Void
	{
		if (m_names[indx] != null)
		{
			m_scroll.SetVisible(false);
			ChangeButtonText(m_names[indx]);
			m_selectedName = m_names[indx];
		}
	}
	
	private function DrawButton(text:String):Void
	{
		var radius:Number = 4;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var elementHeight:Number;
		var elementWidth:Number;
		var margin:Number = 3;
		
		var menuCell:MovieClip = m_combo.createEmptyMovieClip(text, m_combo.getNextHighestDepth());
		
		elementHeight = m_elementHeight;
		elementWidth = m_maxWidth;
		
		matrix.createGradientBox(elementWidth, elementHeight, 90 / 180 * Math.PI, 0, 0);
		menuCell.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuCell.beginGradientFill("linear", m_colors, alphas, ratios, matrix);
		menuCell.moveTo(radius, 0);
		menuCell.lineTo((elementWidth-radius), 0);
		menuCell.curveTo(elementWidth, 0, elementWidth, radius);
		menuCell.lineTo(elementWidth, (elementHeight-radius));
		menuCell.curveTo(elementWidth, elementHeight, (elementWidth-radius), elementHeight);
		menuCell.lineTo(radius, elementHeight);
		menuCell.curveTo(0, elementHeight, 0, (elementHeight-radius));
		menuCell.lineTo(0, radius);
		menuCell.curveTo(0, 0, radius, 0);
		menuCell.endFill();
		
		var menuMask:MovieClip = m_combo.createEmptyMovieClip(text + "Mask", m_combo.getNextHighestDepth());
		menuMask.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuMask.beginFill(0x000000, 100);
		menuMask.moveTo(radius, 0);
		menuMask.lineTo(elementWidth, 0);
		menuMask.lineTo(elementWidth, elementHeight);
		menuMask.lineTo(radius, elementHeight);
		menuMask.curveTo(0, elementHeight, 0, (elementHeight-radius));
		menuMask.lineTo(0, radius);
		menuMask.curveTo(0, 0, radius, 0);
		menuMask.endFill();
		menuCell.setMask(menuMask);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(text + "Hover", menuCell.getNextHighestDepth());
		menuHover._x = 0;
		menuHover._y = 0;
		menuHover.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuHover.beginFill(0xFFFFFF, 70);
		menuHover.moveTo(radius, 0);
		menuHover.lineTo((elementWidth-radius), 0);
		menuHover.curveTo(elementWidth, 0, elementWidth, radius);
		menuHover.lineTo(elementWidth, (elementHeight-radius));
		menuHover.curveTo(elementWidth, elementHeight, (elementWidth-radius), elementHeight);
		menuHover.lineTo(radius, elementHeight);
		menuHover.curveTo(0, elementHeight, 0, (elementHeight-radius));
		menuHover.lineTo(0, radius);
		menuHover.curveTo(0, 0, radius, 0);
		menuHover.endFill();
		menuHover._alpha = 0;

		menuCell.onRollOver = Proxy.create(this, function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); } );
		menuCell.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; } );
		menuCell.onPress = Proxy.create(this, function(i:String) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; this.ButtonPressed(); }, text);
		
		m_button = menuCell;
		
		ChangeButtonText(text);
	}
	
	private function ChangeButtonText(text:String):Void
	{
		if (m_buttonText != null)
		{
			m_buttonText.removeTextField();
		}
		
		var labelExtents:Object = Text.GetTextExtent(text, m_textFormat, m_button);
		var menuText:TextField = m_button.createTextField(text + "ButtonText", m_button.getNextHighestDepth(), m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		menuText.embedFonts = true;
		menuText.selectable = false;
		menuText.antiAliasType = "advanced";
		menuText.autoSize = true;
		menuText.border = false;
		menuText.background = false;
		menuText.setNewTextFormat(m_textFormat);
		menuText.text = text;
		
		m_buttonText = menuText;
	}
	
	private function ButtonPressed():Void
	{
		if (m_scroll.GetVisible() == false)
		{
			m_scroll.SetVisible(true);
		}
		else
		{
			m_scroll.SetVisible(false);
		}
	}
}