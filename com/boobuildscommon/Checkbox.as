import caurina.transitions.Tweener;
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
class com.boobuildscommon.Checkbox
{
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_cross:MovieClip;
	private var m_isChecked:Boolean;
	private var m_callback:Function;
	private var m_size:Number;
	
	public function Checkbox(name:String, parent:MovieClip, x:Number, y:Number, size:Number, callback:Function, isChecked:Boolean)
	{
		m_name = name;
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_frame._x = x;
		m_frame._y = y;
		m_callback = callback;
		m_size = size;
		m_isChecked = isChecked;
		
		DrawFrame();
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
	}
	
	public function IsChecked():Boolean
	{
		return m_isChecked;
	}
	
	public function SetChecked(checked:Boolean):Void
	{
		m_isChecked = checked;
		if (m_isChecked == true)
		{
			m_cross._visible = true;
		}
		else
		{
			m_cross._visible = false;
		}
	}
	
	public function Toggle():Void
	{
		SetChecked(!IsChecked());
		if (m_callback != null)
		{
			m_callback(IsChecked());
		}
	}
	
	private function DrawFrame():Void
	{
		var buttonSide:Number = m_size;
		var buttonBack:MovieClip = m_frame;
		buttonBack.lineStyle(1, 0x000000, 10, true, "none", "square", "round");
		buttonBack.beginFill(0x000000, 10);
		buttonBack.moveTo(1, 1);
		buttonBack.lineTo(buttonSide - 1, 1);
		buttonBack.lineTo(buttonSide - 1, buttonSide - 1);
		buttonBack.lineTo(1, buttonSide - 1);
		buttonBack.lineTo(1, 1);
		buttonBack.endFill();
		buttonBack.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		buttonBack.moveTo(0, 0);
		buttonBack.lineTo(buttonSide, 0);
		buttonBack.lineTo(buttonSide, buttonSide);
		buttonBack.lineTo(0, buttonSide);
		buttonBack.lineTo(0, 0);
		
		var crossMargin:Number = 3;
		var hoverMargin:Number = 1;
		var buttonHover:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonHover", buttonBack.getNextHighestDepth());
		buttonHover.lineStyle(1, 0xFFFFFF, 60, true, "none", "square", "round");
		buttonHover.beginFill(0xFFFFFF, 60);
		buttonHover.moveTo(hoverMargin, hoverMargin);
		buttonHover.lineTo(buttonSide - hoverMargin, hoverMargin);
		buttonHover.lineTo(buttonSide - hoverMargin, buttonSide - hoverMargin);
		buttonHover.lineTo(hoverMargin, buttonSide - hoverMargin);
		buttonHover.lineTo(hoverMargin, hoverMargin);
		buttonHover.endFill();
		buttonHover._alpha = 0;
		
		buttonBack.onRollOver = Delegate.create(this, function() { buttonHover._alpha = 0; Tweener.addTween(buttonHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
		buttonBack.onRollOut = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; } );
		buttonBack.onPress = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; this.Toggle(); } );
		
		var cross:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonCross", buttonBack.getNextHighestDepth());
		cross.lineStyle(2, 0xFFFFFF, 100, true, "none", "square", "round");
		cross.moveTo(crossMargin, crossMargin);
		cross.lineTo(1 + buttonSide - crossMargin, 1 + buttonSide - crossMargin);
		cross.moveTo(1 + buttonSide - crossMargin, crossMargin);
		cross.lineTo(crossMargin, 1 + buttonSide - crossMargin);
		m_cross = cross;
		SetChecked(m_isChecked);
	}
}