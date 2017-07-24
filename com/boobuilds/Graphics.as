import com.boobuilds.DebugWindow;
import caurina.transitions.Tweener;
import com.Utils.Text;
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
class com.boobuilds.Graphics
{
	private static var m_radius:Number = 4;
	private static var m_margin:Number = 3;
	
	public function Graphics() 
	{
	}
	
	public static function GetTextFormat():TextFormat
	{
		var textFormat:TextFormat = new TextFormat();
		textFormat.align = "left";
		textFormat.font = "tahoma";
		textFormat.size = 14;
		textFormat.color = 0xFFFFFF;
		textFormat.bold = false;
		return textFormat;
	}
	
	public static function GetItalicTextFormat():TextFormat
	{
		var textFormat:TextFormat = GetTextFormat();
		textFormat.italic = true;
		return textFormat;
	}
	
	public static function DrawButton(name:String, parent:MovieClip, text:String, textFormat:TextFormat, x:Number, y:Number, width:Number, inColours:Array, callback:Function):MovieClip
	{
		var colours:Array = [0x2E2E2E, 0x585858]
		var elementHeight:Number;
		var elementWidth:Number;
		
		if (inColours != null && inColours.length == 2)
		{
			colours = inColours;
		}
		
		var menuCell:MovieClip = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		
		var extents:Object = Text.GetTextExtent(text, textFormat, parent);
		elementHeight = extents.height + m_margin * 2;
		if (width == null)
		{
			elementWidth = extents.width + m_margin * 2;
		}
		else
		{
			elementWidth = width + m_margin * 2;
		}
		
		DrawGradientFilledRoundedRectangle(menuCell, 0x000000, 0, colours, 0, 0, elementWidth, elementHeight);
		
		var menuMask:MovieClip = parent.createEmptyMovieClip(name + "Mask", parent.getNextHighestDepth());
		DrawFilledRoundedRectangle(menuMask, 0x000000, 0, 0x000000, 100, 0, 0, elementWidth, elementHeight);
		menuCell.setMask(menuMask);
		
		var menuHover:MovieClip = menuCell.createEmptyMovieClip(name + "Hover", menuCell.getNextHighestDepth());
		DrawFilledRoundedRectangle(menuHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, elementWidth, elementHeight);
		menuHover._alpha = 0;

		var labelExtents:Object = Text.GetTextExtent(text, textFormat, menuCell);
		var menuText:TextField = DrawText(name + "Text", menuCell, text, textFormat, elementWidth / 2 - labelExtents.width / 2, Math.round(elementHeight / 2 - labelExtents.height / 2), labelExtents.width, labelExtents.height);

		menuCell.onRollOver = function() { menuHover._alpha = 0; Tweener.addTween(menuHover, { _alpha:40, time:0.5, transition:"linear" } ); };
		menuCell.onRollOut = function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; };
		menuCell.onPress = function() { Tweener.removeTweens(menuHover); menuHover._alpha = 0; callback(); };
		
		menuCell._x = x;
		menuCell._y = y;
		menuMask._x = menuCell._x;
		menuMask._y = menuCell._y;
		
		return menuCell;
	}
	
	public static function DrawText(name:String, parent:MovieClip, text:String, textFormat:TextFormat, x:Number, y:Number, width:Number, height:Number):TextField
	{
		var textField:TextField = parent.createTextField(name, parent.getNextHighestDepth(), x, y, width, height);
		textField.embedFonts = true;
		textField.selectable = false;
		textField.antiAliasType = "advanced";
		textField.autoSize = true;
		textField.border = false;
		textField.background = false;
		textField.setNewTextFormat(textFormat);
		textField.text = text;
		return textField;
	}
	
	public static function DrawRectangle(mc:MovieClip, lineColour:Number, lineWidth:Number, x:Number, y:Number, width:Number, height:Number):Void
	{
		mc.lineStyle(lineWidth, lineColour, 100, true, "none", "square", "round");
		mc.moveTo(x, y);
		mc.lineTo(x + width, y);
		mc.lineTo(x + width, y + height);
		mc.lineTo(x, y + height);
		mc.lineTo(x, y);
	}
	
	public static function DrawFilledRectangle(mc:MovieClip, lineColour:Number, lineWidth:Number, fillColour:Number, fillAlpha:Number, x:Number, y:Number, width:Number, height:Number):Void
	{
		mc.lineStyle(lineWidth, lineColour, 100, true, "none", "square", "round");
		mc.beginFill(fillColour, fillAlpha);
		mc.moveTo(x, y);
		mc.lineTo(x + width, y);
		mc.lineTo(x + width, y + height);
		mc.lineTo(x, y + height);
		mc.lineTo(x, y);
		mc.endFill();
	}
	
	public static function DrawRoundedRectangle(mc:MovieClip, lineColour:Number, lineWidth:Number, x:Number, y:Number, width:Number, height:Number):Void
	{
		mc.lineStyle(lineWidth, lineColour, 100, true, "none", "square", "round");
		mc.moveTo(x + m_radius, y);
		mc.lineTo(x + (width-m_radius), y);
		mc.curveTo(x + width, y, x + width, y + m_radius);
		mc.lineTo(x + width, y + (height - m_radius));
		mc.curveTo(x + width, y + height, x + (width - m_radius), y + height);
		mc.lineTo(x + m_radius, y + height);
		mc.curveTo(x, y + height, x, y + (height - m_radius));
		mc.lineTo(x, y + m_radius);
		mc.curveTo(x, y, x + m_radius, y);
	}
	
	public static function DrawFilledRoundedRectangle(mc:MovieClip, lineColour:Number, lineWidth:Number, fillColour:Number, fillAlpha:Number, x:Number, y:Number, width:Number, height:Number):Void
	{
		mc.lineStyle(lineWidth, lineColour, 100, true, "none", "square", "round");
		mc.beginFill(fillColour, fillAlpha);
		mc.moveTo(x + m_radius, y);
		mc.lineTo(x + (width-m_radius), y);
		mc.curveTo(x + width, y, x + width, y + m_radius);
		mc.lineTo(x + width, y + (height - m_radius));
		mc.curveTo(x + width, y + height, x + (width - m_radius), y + height);
		mc.lineTo(x + m_radius, y + height);
		mc.curveTo(x, y + height, x, y + (height - m_radius));
		mc.lineTo(x, y + m_radius);
		mc.curveTo(x, y, x + m_radius, y);
		mc.endFill();
	}
	
	public static function DrawGradientFilledRoundedRectangle(mc:MovieClip, lineColour:Number, lineWidth:Number, fillColours:Array, x:Number, y:Number, width:Number, height:Number):Void
	{
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		
		matrix.createGradientBox(width, height, 90 / 180 * Math.PI, 0, 0);
		mc.lineStyle(lineWidth, lineColour, 100, true, "none", "square", "round");
		mc.beginGradientFill("linear", fillColours, alphas, ratios, matrix);
		mc.moveTo(x + m_radius, y);
		mc.lineTo(x + (width-m_radius), y);
		mc.curveTo(x + width, y, x + width, y + m_radius);
		mc.lineTo(x + width, y + (height - m_radius));
		mc.curveTo(x + width, y + height, x + (width - m_radius), y + height);
		mc.lineTo(x + m_radius, y + height);
		mc.curveTo(x, y + height, x, y + (height - m_radius));
		mc.lineTo(x, y + m_radius);
		mc.curveTo(x, y, x + m_radius, y);
		mc.endFill();
	}
}