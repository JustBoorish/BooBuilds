import com.boobuilds.DebugWindow;
import com.boobuilds.Graphics;
import caurina.transitions.Tweener;
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Text;
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
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_input:TextField;
	private var m_drawFrameCallback:Function;
	
	public function ModalBase(name:String, parent:MovieClip, drawFrameCallback:Function, frameHeight:Number, frameWidth:Number) 
	{
		m_drawFrameCallback = drawFrameCallback;
		
		var width:Number = parent._width;
		var height:Number = parent._height;
		m_blocker = parent.createEmptyMovieClip("modalBlocker", parent.getNextHighestDepth());
		Graphics.DrawFilledRoundedRectangle(m_blocker, 0x000000, 0, 0x000000, 60, 0, 0, width, height);

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
	
	public function Show():Void
	{
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
		Graphics.DrawFilledRoundedRectangle(m_modal, 0xffffff, 2, 0x000000, 60, 0, 0, m_maxWidth, m_maxHeight);
		
		if (m_drawFrameCallback != null)
		{
			m_drawFrameCallback(m_modal, m_textFormat);
		}
	}
	
	public function DrawButton(text:String, x:Number, y:Number, callback:Function):MovieClip
	{
		var colors:Array = [0x2E2E2E, 0x585858];
		var elementWidth:Number;
		var elementHeight:Number;
		var margin:Number = 3;
		
		var extents:Object = Text.GetTextExtent("Cancel", m_textFormat, m_modal);
		elementWidth = extents.width + margin * 2;
		elementHeight = extents.height + margin * 2;
		
		return Graphics.DrawButton(text + "Button", m_modal, text, m_textFormat, x - elementWidth / 2, y - elementHeight, elementWidth, colors, Proxy.create(this, function(i) { if (callback != null) callback(i); }, text));
	}
}