import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.ScrollPane;
import com.Utils.Text;
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
class com.boobuildscommon.ComboBox
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
	private var m_changedCallback:Function;
	
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

		m_textFormat = Graphics.GetBoldTextFormat();
		
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
	
	public function SetChangedCallback(changed:Function):Void
	{
		m_changedCallback = changed;
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
		
		m_scroll = new ScrollPane(m_combo, "Scroll_" + m_name, m_button._x, m_button._y + m_button._height, m_button._width, m_elementHeight * m_entryHeight, 0x262626, m_elementHeight * m_entryHeight * 0.04);
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
		var name:String = m_names[indx]
		
		var menuCell:MovieClip = m_list.createEmptyMovieClip(name, m_list.getNextHighestDepth());
		Graphics.DrawGradientFilledRoundedRectangle(menuCell, 0x000000, 0, m_colors, 0, 0, m_maxWidth, m_elementHeight);
		menuCell._x = 0;
		menuCell._y = (indx * m_elementHeight) + (indx * m_margin);
		
		var menuMask:MovieClip = m_list.createEmptyMovieClip(name + "Mask", m_list.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuMask, 0x000000, 0, 0x000000, 100, 0, 0, m_maxWidth, m_elementHeight);
		menuMask._x = 0;
		menuMask._y = (indx * m_elementHeight) + (indx * m_margin);
		menuCell.setMask(menuMask);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(name + "Hover", m_list.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, m_maxWidth, m_elementHeight);
		menuHover._x = 0;
		menuHover._y = 0;
		menuHover._alpha = 0;

		var labelExtents:Object = Text.GetTextExtent(name, m_textFormat, menuCell);
		Graphics.DrawText(name + "MenuText", menuCell, name, m_textFormat, m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		
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
			if (m_changedCallback != null)
			{
				m_changedCallback(m_selectedName);
			}
		}
	}
	
	private function DrawButton(text:String):Void
	{
		var elementHeight:Number;
		var elementWidth:Number;
		var margin:Number = 3;
		
		elementHeight = m_elementHeight;
		elementWidth = m_maxWidth;
		
		var menuCell:MovieClip = m_combo.createEmptyMovieClip(text, m_combo.getNextHighestDepth());
		Graphics.DrawGradientFilledRoundedRectangle(menuCell, 0x000000, 0, m_colors, 0, 0, elementWidth, elementHeight);
		
		var menuMask:MovieClip = m_combo.createEmptyMovieClip(text + "Mask", m_combo.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuMask, 0x000000, 0, 0x000000, 100, 0, 0, elementWidth, elementHeight);
		menuCell.setMask(menuMask);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(text + "Hover", menuCell.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(menuHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, elementWidth, elementHeight);
		menuHover._x = 0;
		menuHover._y = 0;
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
		m_buttonText = Graphics.DrawText(text + "ButtonText", m_button, text, m_textFormat, m_leftMargin, Math.round(m_elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);		
	}
	
	private function ButtonPressed():Void
	{
		if (m_scroll.GetVisible() == false)
		{
			m_scroll.Resize(m_list._height);
			m_scroll.SetVisible(true);
		}
		else
		{
			m_scroll.SetVisible(false);
		}
	}
}