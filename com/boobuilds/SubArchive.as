import com.Utils.Archive;
import com.boobuilds.DebugWindow;
import com.boobuilds.SubArchive;
import com.Utils.StringUtils;
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
 * 
 * This code is based on the icon handling from BooDecks by Aedani, original code by Viper.  Thanks to Aedani and Viper.
 */
class com.boobuilds.SubArchive extends Archive
{
	private static var TAG:String = "~SUBARC~";
	private static var SEPARATOR:String = "|";
	
	private var m_id:String;
	
	public function SubArchive(id:String) 
	{
		m_id = id;
	}
	
	public function GetID():String
	{
		return m_id;
	}
	
	public function ToString():String
	{
        var text:String = TAG + SEPARATOR + m_id + SEPARATOR;

        for (var name:String in m_Dictionary)
        {
			text += name + SEPARATOR + m_Dictionary[name].toString() + SEPARATOR;
        }
		
        return text;
	}
	
	public static function FromString(inString:String):SubArchive
	{
		var items:Array = SplitArrayString(inString, SEPARATOR, true);
		if (items != null && items.length > 1 && items[0] == TAG)
		{
			var ret:SubArchive = new SubArchive(items[1]);
			for (var indx:Number = 2; indx < items.length; indx += 2)
			{
				ret.AddEntry(items[indx], items[indx + 1]);
			}
			
			return ret;
		}
		
		return null;
	}
	
	public static function FromStringArray(inString:String):Array
	{
		var items:Array = SplitArrayString(inString, TAG, true);
		if (items != null && items.length > 0)
		{
			var ret:Array = new Array();
			for (var indx:Number = 0; indx < items.length; ++indx)
			{
				var thisArc:SubArchive = SubArchive.FromString(TAG + items[indx]);
				ret.push(thisArc);
			}
			
			return ret;
		}
		else
		{
			return null;
		}
	}
	
	public static function SplitArrayString(inString:String, separator:String, ignoreBlanks:Boolean):Array
	{
		var tmpItems:Array = inString.split(separator);
		var items:Array = new Array();
		for (var i:Number = 0; i < tmpItems.length; ++i)
		{
			var thisItem:String = StringUtils.Strip(tmpItems[i]);
			if (thisItem != "" || ignoreBlanks != true)
			{
				items.push(thisItem);
			}
		}
		
		return items;
	}
}