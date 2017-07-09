import com.Utils.Archive;
import com.Utils.Colors;
import com.Utils.StringUtils;
import com.boobuilds.Build;
import com.boobuilds.BuildGroup;
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
class com.boobuilds.BuildGroup
{
	public static var COLOUR_PREFIX:String = "Colour";
	public static var RED:String = "Red";
	public static var BLUE:String = "Blue";
	public static var GREEN:String = "Green";
	public static var YELLOW:String = "Yellow";
	public static var ORANGE:String = "Orange";
	public static var PURPLE:String = "Purple";
	public static var GRAY:String = "Gray";
	
	private var m_id:String;
	private var m_name:String;
	private var m_colourName:String;

	public function BuildGroup(id:String, name:String, colourName:String)
	{
		m_id = id;
		m_colourName = colourName;
		SetName(name);
	}

	public static function GetNextID(groups:Array):String
	{
		var lastCount:Number = 0;
		for (var indx:Number = 0; indx < groups.length; ++indx)
		{
			var thisGroup:BuildGroup = groups[indx];
			if (thisGroup != null)
			{
				var thisID:String = thisGroup.GetID();
				var thisCount:Number = Number(thisID.substring(1, thisID.length));
				if (thisCount > lastCount)
				{
					lastCount = thisCount;
				}
			}
		}
		
		lastCount = lastCount + 1;
		return "#" + lastCount;
	}
	
	public function GetID():String
	{
		return m_id;
	}
	
	public function GetName():String
	{
		return m_name;
	}
	
	public function SetName(newName:String):Void
	{
		if (newName == null)
		{
			m_name = "";
		}
		else
		{
			m_name = StringUtils.Strip(newName);
		}
	}
	
	public function GetColourName():String
	{
		return m_colourName;
	}
	
	public function SetColourName(newName:String):Void
	{
		m_colourName = newName;
	}
	
	public static function GetColourArray(colourName:String):Array
	{
		if (colourName == null)
		{
			return [0x2E2E2E, 0x585858];
		}
		
		switch(colourName)
		{
			case RED:
				return [Colors.e_ColorUnusableMissionItemsHighlight, Colors.e_ColorUnusableMissionItemsBackground];
			case BLUE:
				return [Colors.e_ColorMagicSpellHighlight, Colors.e_ColorMagicSpellBackground];
			case GREEN:
				return [Colors.e_ColorHealSpellHighlight, Colors.e_ColorHealSpellBackground];
			case YELLOW:
				return [0xefe80b, 0xc6c107];
			case ORANGE:
				return [Colors.e_ColorMeleeSpellHighlight, Colors.e_ColorMeleeSpellBackground];
			case PURPLE:
				return [Colors.e_ColorPassiveSpellHighlight, Colors.e_ColorPassiveSpellBackground];
			default:
				return [0x2E2E2E, 0x585858];
		}
	}
	
	public function Save(archive:Archive, groupNumber:Number):Void
	{
		var prefix:String = Build.GROUP_PREFIX + groupNumber;
		SetArchiveEntry(prefix, archive, Build.ID_PREFIX, m_id);
		SetArchiveEntry(prefix, archive, Build.NAME_PREFIX, m_name);
		SetArchiveEntry(prefix, archive, BuildGroup.COLOUR_PREFIX, m_colourName);
	}
	
	public static function FromArchive(archive:Archive, groupNumber:Number):BuildGroup
	{
		var ret:BuildGroup = null;
		var prefix:String = Build.GROUP_PREFIX + groupNumber;
		var id:String = GetArchiveEntry(prefix, archive, Build.ID_PREFIX, null);
		if (id != null)
		{
			var name:String = GetArchiveEntry(prefix, archive, Build.NAME_PREFIX, null);
			var colourName:String = GetArchiveEntry(prefix, archive, BuildGroup.COLOUR_PREFIX, null);
			ret = new BuildGroup(id, name, colourName);
		}
		
		return ret;
	}

	public static function ClearArchive(archive:Archive, groupNumber:Number):Void
	{
		var prefix:String = Build.GROUP_PREFIX + groupNumber;
		DeleteArchiveEntry(prefix, archive, Build.ID_PREFIX);
		DeleteArchiveEntry(prefix, archive, Build.NAME_PREFIX);
		DeleteArchiveEntry(prefix, archive, BuildGroup.COLOUR_PREFIX);
	}

	private static function DeleteArchiveEntry(prefix:String, archive:Archive, key:String):Void
	{
		var keyName:String = prefix + "_" + key;
		archive.DeleteEntry(keyName);
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
	
	private static function GetArchiveEntry(prefix:String, archive:Archive, key:String, defaultValue:String):String
	{
		var keyName:String = prefix + "_" + key;
		return archive.FindEntry(keyName, defaultValue);
	}
}