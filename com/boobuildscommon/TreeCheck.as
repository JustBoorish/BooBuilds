import caurina.transitions.Tweener;
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
class com.boobuildscommon.TreeCheck
{
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_unchecked:MovieClip;
	private var m_uncheckedHover:MovieClip;
	private var m_checked:MovieClip;
	private var m_checkedHover:MovieClip;
	private var m_isChecked:Boolean;
	private var m_callback:Function;
	private var m_size:Number;
	
	public function TreeCheck(name:String, parent:MovieClip, x:Number, y:Number, size:Number, callback:Function, isChecked:Boolean)
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
			m_checked._visible = true;
			m_unchecked._visible = false;
		}
		else
		{
			m_checked._visible = false;
			m_unchecked._visible = true;
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
	
	public function StartHover():Void
	{
		Tweener.removeTweens(m_checkedHover);
		Tweener.removeTweens(m_uncheckedHover);
		
		if (m_isChecked == true)
		{
			m_checkedHover._alpha = 100;
			Tweener.addTween(m_checkedHover, { _alpha:0, time:0.5, transition:"linear" } );
		}
		else
		{
			m_uncheckedHover._alpha = 0;
			Tweener.addTween(m_uncheckedHover, { _alpha:100, time:0.5, transition:"linear" } );
		}
	}
	
	public function StopHover():Void
	{
		Tweener.removeTweens(m_checkedHover);
		Tweener.removeTweens(m_uncheckedHover);
		
		if (m_isChecked == true)
		{
			m_checkedHover._alpha = 100;
		}
		else
		{
			m_uncheckedHover._alpha = 0;
		}
	}
	
	private function DrawFrame():Void
	{
		var buttonSide:Number = m_size;
		var unchecked:MovieClip = m_frame.createEmptyMovieClip(m_name + "Button", m_frame.getNextHighestDepth());
		unchecked.lineStyle(1, 0xFFFFFF, 0, true, "none", "square", "round");
		unchecked.beginFill(0xFFFFFF, 0);
		unchecked.moveTo(0, 0);
		unchecked.lineTo(0, buttonSide);
		unchecked.lineTo(buttonSide, buttonSide / 2);
		unchecked.lineTo(0, 0);
		unchecked.endFill();
		unchecked.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		unchecked.moveTo(0, 0);
		unchecked.lineTo(0, buttonSide);
		unchecked.lineTo(buttonSide, buttonSide / 2);
		unchecked.lineTo(0, 0);
		m_unchecked = unchecked;
		
		var checkedMargin:Number = 4;
		var hoverMargin:Number = 1;
		var uncheckedHover:MovieClip = unchecked.createEmptyMovieClip(m_name + "ButtonHover", unchecked.getNextHighestDepth());
		uncheckedHover.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		uncheckedHover.beginFill(0xFFFFFF, 100);
		uncheckedHover.moveTo(0, 0);
		uncheckedHover.lineTo(0, buttonSide);
		uncheckedHover.lineTo(buttonSide, buttonSide / 2);
		uncheckedHover.lineTo(0, 0);
		uncheckedHover.endFill();
		uncheckedHover._alpha = 0;
		m_uncheckedHover = uncheckedHover;
		
		unchecked.onRollOver = Proxy.create(this, StartHover);
		unchecked.onRollOut = Proxy.create(this, StopHover);
		unchecked.onPress = Proxy.create(this, function() { this.StopHover(); this.Toggle(); } );
		
		var checked:MovieClip = m_frame.createEmptyMovieClip(m_name + "Checked", m_frame.getNextHighestDepth());
		checked.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		checked.moveTo(buttonSide, 0);
		checked.lineTo(buttonSide, buttonSide);
		checked.lineTo(0, buttonSide);
		checked.lineTo(buttonSide, 0);
		m_checked = checked;
		
		var checkedHover:MovieClip = checked.createEmptyMovieClip(m_name + "CheckedHover", checked.getNextHighestDepth());
		checkedHover.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		checkedHover.beginFill(0xFFFFFF, 100);
		checkedHover.moveTo(buttonSide, 0);
		checkedHover.lineTo(buttonSide, buttonSide);
		checkedHover.lineTo(0, buttonSide);
		checkedHover.lineTo(buttonSide, 0);
		checkedHover.endFill();
		m_checkedHover = checkedHover;
		
		checkedHover.onRollOver = Proxy.create(this, StartHover);
		checkedHover.onRollOut = Proxy.create(this, StopHover);
		checkedHover.onPress = Proxy.create(this, function() { this.StopHover(); this.Toggle(); } );
		
		SetChecked(m_isChecked);
	}
}