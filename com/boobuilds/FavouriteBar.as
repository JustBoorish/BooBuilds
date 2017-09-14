import com.boobuildscommon.Colours;
import com.boobuildscommon.Graphics
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
class com.boobuilds.FavouriteBar
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_favouriteBuilds:Array;
	private var m_favouriteQuickBuilds:Array;
	private var m_favouriteOutfits:Array;
	private var m_colours:Array;
	private var m_iconsPerRow:Number;
	
	public function FavouriteBar(parent:MovieClip, x:Number, y:Number, favouriteBuilds:Array, favouriteQuickBuilds:Array, favouriteOutfits:Array, colours:Array, iconsPerRow:Number) 
	{
		m_parent = parent;
		m_favouriteBuilds = favouriteBuilds;
		m_favouriteQuickBuilds = favouriteQuickBuilds;
		m_favouriteOutfits = favouriteOutfits;
		m_colours = colours;
		m_iconsPerRow = iconsPerRow;
		
		DrawControls();
	}
	
	private function DrawControls():Void
	{
		m_frame = m_parent.createEmptyMovieClip("FavouritesBar", m_parent.getNextHighestDepth());
	}
	
	private function DrawButton(row:Number, column:Number):Void
	{
		
	}
}