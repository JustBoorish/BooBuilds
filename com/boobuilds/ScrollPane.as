import com.boobuilds.DebugWindow;
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
class com.boobuilds.ScrollPane
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_mask:MovieClip;
	private var m_content:MovieClip;
	private var m_contentHeight:Number;
	private var m_scrollButton:MovieClip;
	private var m_ratio:Number;
	
	public function ScrollPane(parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number) 
	{
		m_name = name;
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(name + "ScrollPane", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_maxHeight = height;
		m_content = null;
		m_mask = null;
		m_ratio = 1;
		
		DrawFrame();
		
		var mouseListener:Object = new Object();
		mouseListener.onMouseWheel = Delegate.create(this, MouseWheel);
		Mouse.addListener(mouseListener);
	}
	
	public function GetMovieClip():MovieClip
	{
		return m_frame;
	}
	
	public function SetContent(content:MovieClip, contentHeight:Number):Void
	{
		if (m_mask != null)
		{
			m_mask.removeMovieClip();
		}
		
		m_mask = m_frame.createEmptyMovieClip("Mask", m_frame.getNextHighestDepth() + 200);
		m_mask._x = 1;
		m_mask._y = 1;
		m_mask.lineStyle(0, 0xFFFFFF, 100, true, "none", "square", "round");
		m_mask.beginFill(0xFFFFFF, 100);
		m_mask.moveTo(0, 0);
		m_mask.lineTo(m_maxWidth, 0);
		m_mask.lineTo(m_maxWidth, m_maxHeight);
		m_mask.lineTo(0, m_maxHeight);
		m_mask.lineTo(0, 0);
		m_mask.endFill();
		
		m_content = content;
		m_content.setMask(m_mask);
		m_contentHeight = contentHeight;
		Resize();
	}
	
	public function Resize(newHeight:Number):Void
	{
		m_contentHeight = newHeight;
		var newRatio:Number = m_mask._height / m_contentHeight;
		if (newRatio >= 1)
		{
			newRatio = 1;
		}
		
		if (m_ratio != newRatio)
		{
			m_scrollButton._y = m_scrollButton._y / m_ratio * newRatio;
			m_scrollButton._yscale = 100 * newRatio;
			m_ratio = newRatio;
		}
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	private function MouseWheel(delta:Number):Void
	{
		if (m_frame._visible == true)
		{
			var change:Number = m_maxWidth * (delta / 10);
			m_scrollButton._y -= change;
			if (m_scrollButton._y < 1)
			{
				m_scrollButton._y = 1;
			}
			else if (m_scrollButton._y > m_maxHeight - 1 - m_scrollButton._height)
			{
				m_scrollButton._y = m_maxHeight - 1 - m_scrollButton._height;
			}
		}
	}
	
	private function ScrollMoved():Void
	{
		m_content._y = - ((m_scrollButton._y - 1) / m_maxHeight * m_content._height);
	}
	
	private function DrawFrame():Void
	{
		var areaFrame:MovieClip = m_frame.createEmptyMovieClip("Frame", m_frame.getNextHighestDepth());
		areaFrame.lineStyle(1, 0x000000, 100, true, "none", "square", "round");
		areaFrame.moveTo(0, 0);
		areaFrame.lineTo(m_maxWidth + 2, 0);
		areaFrame.lineTo(m_maxWidth + 2, m_maxHeight + 2);
		areaFrame.lineTo(0, m_maxHeight + 2);
		areaFrame.lineTo(0, 0);
		
		var radius:Number = 5;
		var x:Number = radius;
		var y:Number = radius;
		var scrollBar:MovieClip = m_frame.createEmptyMovieClip("ScrollBar", m_frame.getNextHighestDepth());
		scrollBar.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		scrollBar._x = m_maxWidth + 6;
		scrollBar._y = 0;
		scrollBar.beginFill(0x000000, 100); 
		scrollBar.moveTo(x - radius, y);
		scrollBar.curveTo(-radius + x, -Math.tan(Math.PI / 8) * radius + y, -Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
		scrollBar.curveTo(-Math.tan(Math.PI / 8) * radius + x, -radius + y, x, -radius + y);
		scrollBar.curveTo(Math.tan(Math.PI / 8) * radius + x, -radius + y, Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
		scrollBar.curveTo(radius + x, -Math.tan(Math.PI / 8) * radius + y, radius + x, y);
		y = m_maxHeight - radius;
		scrollBar.lineTo(x + radius, y);
		scrollBar.curveTo(radius + x, Math.tan(Math.PI / 8) * radius + y, Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
		scrollBar.curveTo(Math.tan(Math.PI / 8) * radius + x, radius + y, x, radius + y);
		scrollBar.curveTo(-Math.tan(Math.PI / 8) * radius + x, radius+ y, -Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
		scrollBar.curveTo( -radius + x, Math.tan(Math.PI / 8) * radius + y, -radius + x, y);
		scrollBar.lineTo(x - radius, radius);
		scrollBar.endFill();
		
		radius = 4;
		x = radius;
		y = radius;
		var scrollButton:MovieClip = m_frame.createEmptyMovieClip("ScrollButton", m_frame.getNextHighestDepth());
		scrollButton.lineStyle(1, 0xFFFFFF, 100, true, "none", "square", "round");
		scrollButton._x = m_maxWidth + 7;
		scrollButton._y = 1;
		scrollButton.beginFill(0xFFFFFF, 100); 
		scrollButton.moveTo(x - radius, y);
		scrollButton.curveTo(-radius + x, -Math.tan(Math.PI / 8) * radius + y, -Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
		scrollButton.curveTo(-Math.tan(Math.PI / 8) * radius + x, -radius + y, x, -radius + y);
		scrollButton.curveTo(Math.tan(Math.PI / 8) * radius + x, -radius + y, Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
		scrollButton.curveTo(radius + x, -Math.tan(Math.PI / 8) * radius + y, radius + x, y);
		y = m_maxHeight - radius - 1;
		scrollButton.lineTo(x + radius, y);
		scrollButton.curveTo(radius + x, Math.tan(Math.PI / 8) * radius + y, Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
		scrollButton.curveTo(Math.tan(Math.PI / 8) * radius + x, radius + y, x, radius + y);
		scrollButton.curveTo(-Math.tan(Math.PI / 8) * radius + x, radius+ y, -Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
		scrollButton.curveTo( -radius + x, Math.tan(Math.PI / 8) * radius + y, -radius + x, y);
		scrollButton.lineTo(x - radius, radius);
		scrollButton.endFill();
		m_scrollButton = scrollButton;
		
		scrollButton.onPress = Delegate.create(this, function() { scrollButton.startDrag(false, scrollButton._x, 1, scrollButton._x, this.m_maxHeight - 1 - scrollButton._height); } );
		scrollButton.onRelease = Delegate.create(this, function() { scrollButton.stopDrag(); } );
		scrollButton.onReleaseOutside = Delegate.create(this, function() { scrollButton.stopDrag(); } );
		scrollButton.onEnterFrame = Delegate.create(this, ScrollMoved);
	}
}