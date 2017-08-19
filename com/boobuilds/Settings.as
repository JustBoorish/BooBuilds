import com.boocommon.DebugWindow;
import com.Utils.Archive;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
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
class com.boobuilds.Settings
{
	public static var CURRENT_BUILD:String = "CurrentBuild";
	public static var CURRENT_OUTFIT:String = "CurrentOutfit";
	public static var Separator:String = "|";
	public static var Enabled:String = "enabled";
	public static var X:String = "x";
	public static var Y:String = "y";
	public static var Width:String = "width";
	public static var Height:String = "height";
	public static var Alpha:String = "alpha";
	public static var Text:String = "text";
	public static var Font:String = "font";
	public static var Size:String = "size";
	public static var Colour:String = "colour";
	public static var Colour2:String = "colour2";
	public static var Delay:String = "delay";
	public static var TimeAdjustment:String = "timeadjust";

	public static var SizeSmall:String = "small";
	public static var SizeMedium:String = "medium";
	public static var SizeLarge:String = "large";
	
	public static var General:String = "General";
	
	private static var Version:String = "VERSION";
	private static var OVERRIDE_KEY:String = "OVERRIDE_KEY";
	private static var PREV_TOGGLE_ID:String = "PREV_TOGGLE_ID";
	private static var CURRENT_TOGGLE_ID:String = "CURRENT_TOGGLE_ID";

	private static var m_version:String = null;
	private static var m_archive:Archive = null;
	private static var m_fontArray:Array = null;

	public static function SetVersion(version:String):Void
	{
		m_version = version;
	}
	
	public static function SetArchive(archive:Archive):Void
	{
		m_archive = archive;
		
		if (m_archive != null)
		{
			m_archive.DeleteEntry(Version);
			m_archive.AddEntry(Version, m_version);
		}
	}
	
	public static function GetArchive():Archive
	{
		if (m_archive == null)
		{
			return new Archive();
		}
		
		return m_archive;
	}
	
	public static function GetFontID(fontName:String):String
	{
		if (fontName == "Arial")
		{
			return "arial";
		}
		if (fontName == "Comic Sans MS")
		{
			return "comicsansms";
		}
		if (fontName == "Tahoma")
		{
			return "tahoma";
		}
		if (fontName == "Times New Roman")
		{
			return "timesnewroman";
		}

		return "arial";
	}
	
	public static function GetFontArray():Array
	{
		if (m_fontArray == null)
		{
			m_fontArray = new Array();
			m_fontArray.push("Arial");
			m_fontArray.push("Comic Sans MS");
			m_fontArray.push("Tahoma");
			m_fontArray.push("Times New Roman");
		}
		
		return m_fontArray;
	}

	public static function GetSkillMap(skillArray:Array, skillMap:Object):Void
	{
		
		for (var featID in FeatInterface.m_FeatList )
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData.m_Name.indexOf("Superfeat") == 0 || featData.m_Name.indexOf("Gluefeat") == 0)
			{
				continue;
			}
			
			var skillName:String = Trim(featData.m_Name);
			if (skillMap[skillName] == null)
			{
				skillMap[skillName] = featData.m_IconID;
				skillArray.push(skillName);
			}
		}
		
		skillArray.sort();
	}
	
	public static function Trim(inStr:String):String
	{
		if (inStr == null)
		{
			return "";
		}
		
		var ret:String = inStr;
		while (ret.charAt(ret.length - 1) == " ")
		{
			ret = ret.substr(0, ret.length - 1);
		}
		
		return ret;
	}
	
	public static function SizeToFontSize(inSize:String):Number
	{
		if (inSize == SizeSmall)
		{
			return 12;
		}
		else if (inSize == SizeMedium)
		{
			return 16;
		}
		else if (inSize = SizeLarge)
		{
			return 24;
		}
		
		return 12;
	}
	
	public static function GetArrayFromString(inArrayString:String):Array
	{
		if (inArrayString.indexOf("|") == -1)
		{
			var ret:Array = new Array();
			ret.push(inArrayString);
			return ret;
		}
		else
		{
			return inArrayString.split("|");
		}
	}
	
	public static function GetArrayString(inArray:Array):String
	{
		var arrayString:String = "";
		for (var i:Number = 0; i < inArray.length; i++)
		{
			if (i > 0)
			{
				arrayString = arrayString + "|";
			}
			
			arrayString = arrayString + inArray[i];
		}
		
		return arrayString;
	}

	public static function Save(prefix:String, settings:Object, defaults:Object):Void
	{
		if (m_archive == null)
		{
			DebugWindow.Log(DebugWindow.Error, "Settings.Save archive was null");
			return;
		}
		
		for (var prop in settings)
		{
			if (prop != undefined && settings[prop] != undefined && settings[prop] != null && settings[prop] != "null" && settings[prop] != defaults[prop])
			{
				var entryName:String = GetFullName(prefix, prop);
				m_archive.DeleteEntry(entryName);
				m_archive.AddEntry(entryName, settings[prop]);
				//DebugWindow.Log(DebugWindow.Debug, "Settings.Save Set " + entryName + "=" + settings[prop] + " default=" + defaults[prop]);
			}
			else
			{
				m_archive.DeleteEntry(GetFullName(prefix, prop));
				//DebugWindow.Log(DebugWindow.Debug, "Settings.Save Delete " + GetFullName(prefix, prop));
			}
		}
	}
	
	public static function Load(prefix:String, defaults:Object):Object
	{
		var settings:Object = new Object();
		
		for (var prop in defaults)
		{
			if (prop != undefined)
			{
				if (m_archive != null)
				{
					settings[prop] = m_archive.FindEntry(GetFullName(prefix, prop));
				}
			}
			
			if (settings[prop] == undefined)
			{
				if (defaults[prop] != null)
				{
					settings[prop] = defaults[prop];
					//DebugWindow.Log(DebugWindow.Debug, "Settings.Load Default " + GetFullName(prefix, prop) + "=" + settings[prop]);
				}
			}
			else if (settings[prop] == defaults[prop])
			{
				if (m_archive != null)
				{
					m_archive.DeleteEntry(GetFullName(prefix, prop));
					//DebugWindow.Log(DebugWindow.Debug, "Settings.Load Delete " + GetFullName(prefix, prop));
				}
			}
			else
			{
				//DebugWindow.Log(DebugWindow.Debug, "Settings.Load Get " + GetFullName(prefix, prop) + "=" + settings[prop]);
			}
		}
		
		return settings;
	}
	
	private static function GetFullName(prefix:String, name:String):String
	{
		return prefix + Separator + name;
	}
	
	public static function GetOverrideKey(settings:Object):Boolean
	{
		if (settings != null)
		{
			if (settings[OVERRIDE_KEY] == 1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		return false;
	}
	
	public static function SetOverrideKey(settings:Object, newValue:Boolean):Void
	{
		if (settings != null)
		{
			if (newValue == true)
			{
				settings[OVERRIDE_KEY] = 1;
			}
			else
			{
				settings[OVERRIDE_KEY] = 0;
			}
		}
	}	
	
	public static function GetPrevToggleID(settings:Object):String
	{
		if (settings != null)
		{
			return settings[PREV_TOGGLE_ID];
		}
		
		return "";
	}
	
	public static function SetPrevToggleID(settings:Object, newValue:String):Void
	{
		if (settings != null)
		{
			settings[PREV_TOGGLE_ID] = newValue;
		}
	}	
	
	public static function GetCurrentToggleID(settings:Object):String
	{
		if (settings != null)
		{
			return settings[CURRENT_TOGGLE_ID];
		}
		
		return "";
	}
	
	public static function SetCurrentToggleID(settings:Object, newValue:String):Void
	{
		if (settings != null)
		{
			settings[CURRENT_TOGGLE_ID] = newValue;
		}
	}	
}