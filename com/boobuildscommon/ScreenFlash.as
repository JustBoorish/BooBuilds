import com.boobuildscommon.Graphics;
import caurina.transitions.Tweener;
import flash.geom.Matrix;
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
class com.boobuildscommon.ScreenFlash
{
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_pct:Number;
	private var m_colours:Array;
	private var m_frame:MovieClip;
	
	public function ScreenFlash(name:String, parent:MovieClip, pct:Number, colours:Array) 
	{
		m_name = name;
		m_parent = parent;
		m_pct = pct;
		m_colours = colours;
		
		if (Graphics.ColourArrayValid(m_colours) == true)
		{
			DrawFrame();
			SetVisible(false);
		}
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
	}
	
	public function Unload():Void
	{
		m_frame.removeMovieClip();
		m_frame = null;
	}
	
	private function DrawFrame():Void
	{
		var alphas:Array = [100, 0];
		var ratios:Array = [0, 245];
		var alphas2:Array = [100, 0];
		var ratios2:Array = [0, 245];
		
		var xOffset:Number = Stage.width * m_pct / 100;
		var yOffset:Number = Stage.height * m_pct / 100;
		
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		
		var matrix1:Matrix = new Matrix();
		matrix1.createGradientBox(Stage.width, yOffset, Math.PI / 2, 0, 0);
		var top:MovieClip = m_frame.createEmptyMovieClip("Top", m_frame.getNextHighestDepth());
		top.lineStyle(0, m_colours[0], 1, true, "none", "square", "round");
		top.beginGradientFill("linear", m_colours, alphas, ratios, matrix1);
		top.moveTo(0, 0);
		top.lineTo(Stage.width, 0);
		top.lineTo(Stage.width - xOffset, yOffset);
		top.lineTo(xOffset, yOffset);
		top.lineTo(0, 0);
		top.endFill();

		var matrix2:Matrix = new Matrix();
		matrix2.createGradientBox(Stage.width, yOffset, 3 * Math.PI / 2, 0, Stage.height - yOffset);
		var bottom:MovieClip = m_frame.createEmptyMovieClip("Bottom", m_frame.getNextHighestDepth());
		bottom.lineStyle(0, m_colours[0], 1, true, "none", "square", "round");
		bottom.beginGradientFill("linear", m_colours, alphas, ratios, matrix2);
		bottom.moveTo(0, Stage.height);
		bottom.lineTo(Stage.width, Stage.height);
		bottom.lineTo(Stage.width - xOffset, Stage.height - yOffset);
		bottom.lineTo(xOffset, Stage.height - yOffset);
		bottom.lineTo(0, Stage.height);
		bottom.endFill();

		var matrix3:Matrix = new Matrix();
		matrix3.createGradientBox(xOffset, Stage.height, 0, 0, 0);
		var left:MovieClip = m_frame.createEmptyMovieClip("Left", m_frame.getNextHighestDepth());
		left.lineStyle(0, m_colours[0], 1, true, "none", "square", "round");
		left.beginGradientFill("linear", m_colours, alphas, ratios, matrix3);
		left.moveTo(0, 0);
		left.lineTo(0, Stage.height);
		left.lineTo(xOffset, Stage.height - yOffset);
		left.lineTo(xOffset, yOffset);
		left.lineTo(0, 0);
		left.endFill();

		var matrix4:Matrix = new Matrix();
		matrix4.createGradientBox(xOffset, Stage.height, Math.PI, Stage.width - xOffset, 0);
		var right:MovieClip = m_frame.createEmptyMovieClip("Right", m_frame.getNextHighestDepth());
		right.lineStyle(0, m_colours[0], 1, true, "none", "square", "round");
		right.beginGradientFill("linear", m_colours, alphas, ratios, matrix4);
		right.moveTo(Stage.width, 0);
		right.lineTo(Stage.width, Stage.height);
		right.lineTo(Stage.width - xOffset, Stage.height - yOffset);
		right.lineTo(Stage.width - xOffset, yOffset);
		right.lineTo(Stage.width, 0);
		right.endFill();
	}
}