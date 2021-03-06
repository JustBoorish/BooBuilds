import com.Utils.Archive;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.SubArchive;
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
class com.boobuildscommon.SubArchive extends Archive
{
	private static var TAG:String = "~SUBARC~";
	private static var SEPARATOR:String = "|";
	private static var SEPARATOR2:String = "%";
	
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
	
	public static function SetArchiveEntry(prefix:String, archive:Archive, key:String, value:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
		if (value != null && value != "null")
		{
			archive.AddEntry(keyName, value);
		}
	}
	
	public static function DeleteArchiveEntry(prefix:String, archive:Archive, key:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
	}
	
	public static function GetArrayString(prefix:String, array:Array):String
	{
		return GetArrayStringInternal(prefix, array, true);
	}
	
	public static function GetArrayStringInternal(prefix:String, array:Array, ignoreEmpty:Boolean):String
	{
		var ret:String = "";
		if (prefix != null)
		{
			ret = "-" + SEPARATOR2 + prefix + SEPARATOR2;
		}
		
		var found:Boolean = false;
		for (var i:Number = 0; i < array.length; ++i)
		{
			if (array[i] == null)
			{
				ret = ret + "-" + SEPARATOR2 + "undefined" + SEPARATOR2;
			}
			else
			{
				found = true;
				ret = ret + "-" + SEPARATOR2 + array[i] + SEPARATOR2;
			}
		}
		
		if (found == true || ignoreEmpty == false)
		{
			return ret;
		}
		else
		{
			return "";
		}
	}
	
	public static function GetArrayGearItemString(prefix:String, array:Array):String
	{
		var ret:String = "";
		if (prefix != null)
		{
			ret = "-" + SEPARATOR2 + prefix + SEPARATOR2;
		}
		
		var found:Boolean = false;
		for (var i:Number = 0; i < array.length; ++i)
		{
			if (array[i] == null)
			{
				ret = ret + "-" + SEPARATOR2 + "undefined" + SEPARATOR2;
			}
			else
			{
				found = true;
				ret = ret + "-" + SEPARATOR2 + array[i].toString() + SEPARATOR2;
			}
		}
		
		if (found == true)
		{
			return ret;
		}
		else
		{
			return "";
		}
	}	
}