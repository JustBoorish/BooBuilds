import com.boobuildscommon.IconButton;
import com.boobuildscommon.Proxy;
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
class com.boobuildscommon.IconSelector
{
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_icons:Array;
	private var m_callback:Function;
	
	public function IconSelector(name:String, parent:MovieClip, x:Number, y:Number, iconSize:Number, iconsPerRow:Number, iconPaths:Array, callback:Function) 
	{
		m_name = name;
		m_parent = parent;
		m_callback = callback;
		
		DrawControls(x, y, iconSize, iconsPerRow, iconPaths);
	}
	
	public function Unload():Void
	{
		if (m_icons != null)
		{
			for (var indx:Number = 0; indx < m_icons.length; ++indx)
			{
				var icon:IconButton = m_icons[indx];
				icon.Unload();
			}
			
			m_icons = null;
		}
	}
	
	private function DrawControls(x:Number, y:Number, iconSize:Number, iconsPerRow:Number, iconPaths:Array):Void
	{
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_frame._x = x;
		m_frame._y = y;
		
		var frameColours:Array = [0xe6c016, 0xdda316];
		var margin:Number = 5;
		m_icons = new Array();
		var row:Number = 0;
		var col:Number = 0;
		for (var indx:Number = 0; indx < iconPaths.length; ++indx)
		{
			var icon:IconButton = new IconButton("Icon" + row + "x" + col, m_frame, (iconSize + margin) * col, (iconSize + margin) * row, iconSize, iconSize, null, frameColours, Proxy.create(this, IconPressed, iconPaths[indx]), IconButton.NONE, IconButton.NONE, null);
			icon.SetIcon(null, iconPaths[indx], 0, false, frameColours, null, null);
			m_icons.push(icon);
			
			++col;
			if (col >= iconsPerRow)
			{
				col = 0;
				++row;
			}
		}
	}
	
	private function IconPressed(iconPath:String):Void
	{
		if (m_callback != null)
		{
			m_callback(iconPath);
		}
	}
}