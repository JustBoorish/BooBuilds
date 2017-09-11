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
class com.boobuildscommon.Colours
{
	public static var RED:String = "Red";
	public static var BLUE:String = "Blue";
	public static var AQUA:String = "Aqua";
	public static var GREEN:String = "Green";
	public static var YELLOW:String = "Yellow";
	public static var ORANGE:String = "Orange";
	public static var PURPLE:String = "Purple";
	public static var GREY:String = "Grey";
	
	public static function GetColourArray(colourName:String):Array
	{
		if (colourName == null)
		{
			return [0x2E2E2E, 0x585858];
		}
		
		switch(colourName)
		{
			case RED:
				return [com.Utils.Colors.e_ColorUnusableMissionItemsHighlight, com.Utils.Colors.e_ColorUnusableMissionItemsBackground];
			case BLUE:
				return [com.Utils.Colors.e_ColorMagicSpellHighlight, com.Utils.Colors.e_ColorMagicSpellBackground];
			case AQUA:
				return [0x17e5f3, 0x008ed0];
			case GREEN:
				return [com.Utils.Colors.e_ColorHealSpellHighlight, com.Utils.Colors.e_ColorHealSpellBackground];
			case YELLOW:
				return [0xefe80b, 0xc6c107];
			case ORANGE:
				return [com.Utils.Colors.e_ColorMeleeSpellHighlight, com.Utils.Colors.e_ColorMeleeSpellBackground];
			case PURPLE:
				return [com.Utils.Colors.e_ColorPassiveSpellHighlight, com.Utils.Colors.e_ColorPassiveSpellBackground];
			default:
				return [0x2E2E2E, 0x585858];
		}
	}
	
	public static function GetColourNames():Array
	{
		return [ RED, BLUE, AQUA, GREEN, YELLOW, ORANGE, PURPLE, GREY ];
	}
	
	public static function GetDefaultColourName():String
	{
		return GREY;
	}
	
	public static function GetDefaultColourArray():Array
	{
		return GetColourArray(GetDefaultColourName());
	}
}
