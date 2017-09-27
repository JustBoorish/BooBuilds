import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Graphics;
import com.Utils.Text;
import caurina.transitions.Tweener;
import flash.geom.Matrix;
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
class com.boobuildscommon.TabStrip
{
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_strip:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_values:Array;
	private var m_callback:Function;
	private var m_tabHeight:Number;
	private var m_tabWidth:Number;
	private var m_maxHeight:Number;
	private var m_maxWidth:Number;
	private var m_cells:Array;
	private var m_selected:Array;
	private var m_selectedTab:Number;
	
	public function TabStrip(parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number, callback:Function, selectedTab:Number)
	{
		m_parent = parent;
		m_name = name;
		m_callback = callback;
		m_strip = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_strip._x = x;
		m_strip._y = y;
		m_values = new Array();
		m_selected = new Array();
		m_cells = new Array();
		m_tabHeight = 0;
		m_tabWidth = 0;
		m_maxHeight = height;
		m_maxWidth = width;
		m_selectedTab = selectedTab;
		
		m_textFormat = Graphics.GetBoldTextFormat();
	}
	
	public function GetSelectedTab():Number
	{
		return m_selectedTab;
	}
	
	public function AddTab(value:String):Void
	{
		m_values.push(value);
		
		var extents:Object = Text.GetTextExtent(value, m_textFormat, m_strip);
		if (extents.width > m_tabWidth)
		{
			m_tabWidth = extents.width;
		}
		
		if (extents.height > m_tabHeight)
		{
			m_tabHeight = extents.height;
		}
	}
	
	public function Rebuild():Void
	{
		var xMargin:Number = 8;
		var yMargin:Number = 6;
		var radius:Number = 8;
		
		for (var i:Number = 0; i < m_values.length; ++i)
		{
			DrawTab(i, xMargin, yMargin);
		}
		
		var baseLine:MovieClip = m_strip.createEmptyMovieClip(m_name + "Baseline", m_strip.getNextHighestDepth());
		baseLine._y = m_tabHeight + yMargin + 1;
		baseLine._x = 0;
		baseLine.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		baseLine.moveTo(radius, 0);
		baseLine.lineTo(m_maxWidth-radius, 0);
		baseLine.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		baseLine.lineTo(m_maxWidth, m_maxHeight - baseLine._y - radius);
		baseLine.curveTo(m_maxWidth, m_maxHeight - baseLine._y, (m_maxWidth-radius), m_maxHeight - baseLine._y);
		baseLine.lineTo(radius, m_maxHeight - baseLine._y);
		baseLine.curveTo(0, m_maxHeight - baseLine._y, 0, m_maxHeight - baseLine._y - radius);
		baseLine.lineTo(0, radius);
		baseLine.curveTo(0, 0, radius, 0);
	}
	
	private function DrawTab(indx:Number, xMargin:Number, yMargin:Number):Void
	{
		var radius:Number = 2;
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var colors:Array = [0x2E2E2E, 0x585858];
		
		var maxWidth:Number = m_tabWidth + xMargin;
		var maxHeight:Number = m_tabHeight + yMargin;
		matrix.createGradientBox(maxWidth, maxHeight, 90 / 180 * Math.PI, 0, 0);
		var tabCell:MovieClip = m_strip.createEmptyMovieClip(m_values[indx], m_strip.getNextHighestDepth());
		tabCell._x = maxWidth * indx + 3 * indx + 20;
		tabCell._y = 0;
		tabCell.lineStyle(0, 0x000000, 0, true, "none", "square", "round");
		tabCell.beginGradientFill("linear", colors, alphas, ratios, matrix);
		tabCell.moveTo(radius, 0);
		tabCell.lineTo(maxWidth-radius, 0);
		tabCell.curveTo(maxWidth, 0, maxWidth, radius);
		tabCell.lineTo(maxWidth, maxHeight);
		tabCell.lineTo(0, maxHeight);
		tabCell.lineTo(0, radius);
		tabCell.curveTo(0, 0, radius, 0);
		tabCell.endFill();
		m_cells.push(tabCell);

		var tabSelected:MovieClip = tabCell.createEmptyMovieClip(m_values[indx] + "Hover", tabCell.getNextHighestDepth());
		tabSelected._x = 0;
		tabSelected._y = 0;
		tabSelected.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		tabSelected.beginFill(0xFFFFFF, 70);
		tabSelected.moveTo(radius, 0);
		tabSelected.lineTo(maxWidth-radius, 0);
		tabSelected.curveTo(maxWidth, 0, maxWidth, radius);
		tabSelected.lineTo(maxWidth, maxHeight+1);
		tabSelected.lineTo(0, maxHeight+1);
		tabSelected.lineTo(0, radius);
		tabSelected.curveTo(0, 0, radius, 0);
		tabSelected.endFill();
		if (m_selectedTab == indx)
		{
			tabSelected._alpha = 60;
		}
		else
		{
			tabSelected._alpha = 0;
		}
		m_selected.push(tabSelected);
		
		var labelExtents:Object = Text.GetTextExtent(m_values[indx], m_textFormat, tabCell);
		var tabText:TextField = tabCell.createTextField(m_values[indx] + "Text", tabCell.getNextHighestDepth(), Math.round(maxWidth / 2 - labelExtents.width / 2), Math.round(maxHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		tabText.embedFonts = true;
		tabText.selectable = false;
		tabText.antiAliasType = "advanced";
		tabText.autoSize = true;
		tabText.border = false;
		tabText.background = false;
		tabText.setNewTextFormat(m_textFormat);
		tabText.text = m_values[indx];
		
		tabCell.onRollOver = Delegate.create(this, function() { if (this.m_selectedTab != indx) { tabSelected._alpha = 0; Tweener.addTween(tabSelected, { _alpha:40, time:0.5, transition:"linear" } ); } } );
		tabCell.onRollOut = Delegate.create(this, function() { if (this.m_selectedTab != indx) { Tweener.removeTweens(tabSelected); tabSelected._alpha = 0; } } );
		tabCell.onPress = Delegate.create(this, function() { for (var i:Number = 0; i < this.m_selected.length; ++i) { this.m_selected[i]._alpha = 0; } Tweener.removeTweens(tabSelected); tabSelected._alpha = 60; var oldTab:Number = this.m_selectedTab;  this.m_selectedTab = indx; this.m_callback(indx, oldTab); } );
	}
}
