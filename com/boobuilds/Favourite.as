import com.Utils.Archive;
import com.boobuilds.Favourite;
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
class com.boobuilds.Favourite
{
	public static var FAVOURITE:String = "FAV";
	public static var BUILD:String = "Build";
	public static var OUTFIT:String = "Outfit";
	public static var QUICK:String = "Quick";
	
	private static var TYPE:String = "TYPE";
	private static var ID:String = "ID";
	private static var ICON_PATH:String = "ICONPATH";
	private static var COLOUR:String = "COLOUR";
	
	private var m_type:String;
	private var m_id:String;
	private var m_iconPath:String;
	private var m_colour:String;
	private var m_name:String;
	
	public function Favourite(thisType:String, thisID:String, thisIconPath:String, thisColour:String) 
	{
		m_type = thisType;
		m_id = thisID;
		m_iconPath = thisIconPath;
		m_colour = thisColour;
		m_name = m_id;
	}
	
	public function GetType():String
	{
		return m_type;
	}
	
	public function GetID():String
	{
		return m_id;
	}
	
	public function GetIconPath():String
	{
		return m_iconPath;
	}
	
	public function GetColour():String
	{
		return m_colour;
	}
	
	public function GetName():String
	{
		return m_name;
	}
	
	public function SetName(newValue:String):Void
	{
		m_name = newValue;
	}
	
	public function Save(prefix:String, archive:Archive, num:Number):Void
	{
		var key:String = prefix + num;
		SetArchiveEntry(key, archive, TYPE, m_type);		
		SetArchiveEntry(key, archive, ID, m_id);
		SetArchiveEntry(key, archive, ICON_PATH, m_iconPath);
		SetArchiveEntry(key, archive, COLOUR, m_colour);
	}
	
	public static function ClearArchive(prefix:String, archive:Archive, num:Number):Void
	{
		var key:String = prefix + num;
		DeleteArchiveEntry(key, archive, TYPE);
		DeleteArchiveEntry(key, archive, ID);
		DeleteArchiveEntry(key, archive, ICON_PATH);
		DeleteArchiveEntry(key, archive, COLOUR);
	}

	public static function FromArchive(prefix:String, archive:Archive, num:Number):Favourite
	{
		var ret:Favourite = null;
		var keyPrefix:String = prefix + num + "_";
		var thisType:String = archive.FindEntry(keyPrefix + TYPE, null);
		if (thisType != null)
		{
			var thisID:String = archive.FindEntry(keyPrefix + ID, null);
			var thisIconPath:String = archive.FindEntry(keyPrefix + ICON_PATH, null);
			var thisColour:String = archive.FindEntry(keyPrefix + COLOUR, null);
			
			if (thisIconPath != null)
			{
				if (thisIconPath == "BooBuildsTank") thisIconPath = "BooBuildsTank2";
				if (thisIconPath == "BooBuildsDPS") thisIconPath = "BooBuildsDPS2";
				if (thisIconPath == "BooBuildsHeals") thisIconPath = "BooBuildsHeals2";
			}
			
			if (thisID != null && thisIconPath != null && thisColour != null)
			{
				ret = new Favourite(thisType, thisID, thisIconPath, thisColour);
			}
		}
		
		return ret;
	}
	
	private static function SetArchiveEntry(prefix:String, archive:Archive, key:String, value:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
		if (value != null && value != "null")
		{
			archive.AddEntry(keyName, value);
		}
	}
	
	private static function DeleteArchiveEntry(prefix:String, archive:Archive, key:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
	}	
}