import com.boobuilds.DebugWindow;
import caurina.transitions.Tweener;
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Text;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import mx.utils.Delegate;
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
class com.boobuilds.ModalBase
{
	private var m_blocker:MovieClip;
	private var m_modal:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_button1:MovieClip;
	private var m_button2:MovieClip;
	private var m_callback:Function;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_input:TextField;
	private var m_drawFrameCallback:Function;
	
	public function ModalBase(name:String, parent:MovieClip, drawFrameCallback:Function, frameHeight:Number, frameWidth:Number) 
	{
		m_drawFrameCallback = drawFrameCallback;
		
		var radius:Number = 8;
		var width:Number = parent._width;
		var height:Number = parent._height;
		m_blocker = parent.createEmptyMovieClip("modalBlocker", parent.getNextHighestDepth());
		m_blocker.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		m_blocker.beginFill(0x000000, 60);
		m_blocker.moveTo(radius, 0);
		m_blocker.lineTo((width-radius), 0);
		m_blocker.curveTo(width, 0, width, radius);
		m_blocker.lineTo(width, (height-radius));
		m_blocker.curveTo(width, height, (width-radius), height);
		m_blocker.lineTo(radius, height);
		m_blocker.curveTo(0, height, 0, (height-radius));
		m_blocker.lineTo(0, radius);
		m_blocker.curveTo(0, 0, radius, 0);
		m_blocker.endFill();

		// Trap Mouse Events
		m_blocker.onPress = Delegate.create(this, NullEvent);
		m_blocker.onRelease = Delegate.create(this, NullEvent);
		m_blocker.onMouseDown = Delegate.create(this, NullEvent);
		m_blocker.onMouseUp = Delegate.create(this, NullEvent);
		m_blocker.onRollOver = Delegate.create(this, NullEvent);
		m_blocker.onRollOut = Delegate.create(this, NullEvent);
		m_blocker._visible = false;
		
		if (frameWidth == null)
		{
			m_maxWidth = parent._width * 0.65;
		}
		else
		{
			m_maxWidth = parent._width * frameWidth;
		}
		
		if (frameHeight == null)
		{
			m_maxHeight = parent._height * 0.3;
		}
		else
		{
			m_maxHeight = parent._height * frameHeight;
		}
		m_modal = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		m_textFormat = new TextFormat();
		m_textFormat.align = "left";
		m_textFormat.font = "tahoma";
		m_textFormat.size = 14;
		m_textFormat.color = 0xFFFFFF;
		m_textFormat.bold = false;

		DrawFrame();
		
		m_modal._x = width / 2 - m_modal._width / 2;
		m_modal._y = height / 2 - m_modal._height / 2;
		m_modal._visible = false;
	}
	
	public function GetMovieClip():MovieClip
	{
		return m_modal;
	}
	
	public function Show(callback:Function):Void
	{
		m_callback = callback;
		m_blocker._visible = true;
		m_modal._visible = true;
	}
	
	public function Hide():Void
	{
		m_blocker._visible = false;
		m_modal._visible = false;
	}
	
	public function Unload():Void
	{
		Hide();
		m_modal.removeMovieClip();
		m_blocker.removeMovieClip();
	}
	
	private function NullEvent():Void
	{
	}
	
	private function DrawFrame():Void
	{
		var radius:Number = 8;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		
		//matrix.createGradientBox(m_maxWidth, m_maxHeight, 90 / 180 * Math.PI, 0, 0);
		var configWindow:MovieClip = m_modal;
		configWindow.lineStyle(2, 0xffffff, 100, true, "none", "square", "round");
		configWindow.beginFill(0x000000, 60);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((m_maxWidth-radius), 0);
		configWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		configWindow.lineTo(m_maxWidth, (m_maxHeight-radius));
		configWindow.curveTo(m_maxWidth, m_maxHeight, (m_maxWidth-radius), m_maxHeight);
		configWindow.lineTo(radius, m_maxHeight);
		configWindow.curveTo(0, m_maxHeight, 0, (m_maxHeight-radius));
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		if (m_drawFrameCallback != null)
		{
			m_drawFrameCallback(m_modal, m_textFormat);
		}
	}
	
	public function DrawButton(text:String, x:Number, y:Number, callback:Function):MovieClip
	{
		var radius:Number = 4;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var colors:Array = [0x2E2E2E, 0x585858]
		var elementHeight:Number;
		var elementWidth:Number;
		var margin:Number = 3;
		
		var menuCell:MovieClip = m_modal.createEmptyMovieClip(text, m_modal.getNextHighestDepth());
		
		var extents:Object = Text.GetTextExtent("Cancel", m_textFormat, m_modal);
		elementHeight = extents.height + margin * 2;
		elementWidth = extents.width + margin * 2;
		
		matrix.createGradientBox(elementWidth, elementHeight, 90 / 180 * Math.PI, 0, 0);
		menuCell.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		menuCell.beginGradientFill("linear", colors, alphas, ratios, matrix);
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
		
		var menuMask:MovieClip = m_modal.createEmptyMovieClip(text + "Mask", m_modal.getNextHighestDepth());
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

		var labelExtents:Object = Text.GetTextExtent(text, m_textFormat, menuCell);
		var menuText:TextField = menuCell.createTextField(text + "MenuText", menuCell.getNextHighestDepth(), elementWidth / 2 - labelExtents.width / 2, Math.round(elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);
		menuText.embedFonts = true;
		menuText.selectable = false;
		menuText.antiAliasType = "advanced";
		menuText.autoSize = true;
		menuText.border = false;
		menuText.background = false;
		menuText.setNewTextFormat(m_textFormat);
		menuText.text = text;

		menuCell.onRollOver = Proxy.create(this, function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); } );
		menuCell.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; } );
		menuCell.onPress = Proxy.create(this, function(i:String) { Tweener.removeTweens(menuHover); menuHover._alpha = 0; callback(i); }, text);
		
		menuCell._x = x - menuCell._width / 2;
		menuCell._y = y - menuCell._height;
		menuMask._x = menuCell._x;
		menuMask._y = menuCell._y;
		
		return menuCell;
	}

	private function ButtonPressed(text:String):Void
	{
		var success:Boolean = false;
		if (text == "Yes" || text == "OK")
		{
			success = true;
		}
		
		m_modal._visible = false;
		m_blocker._visible = false;
		
		if (m_callback != null)
		{
			if (m_input != null)
			{
				DebugWindow.Log(DebugWindow.Info, "Success " + success + " text " + text);
				if (success)
				{
					m_callback(m_input.text);
				}
				else
				{
					m_callback(null);
				}
			}
			else
			{
				m_callback(success);
			}
		}
	}
}