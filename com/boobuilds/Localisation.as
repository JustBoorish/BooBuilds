import com.boobuilds.DebugWindow;
import com.Utils.LDBFormat;
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
class com.boobuilds.Localisation
{
	public static var Signet:String = "";
	public static var Glyph:String = "";
	public static var Skills:String = "";
	public static var Passives:String = "";
	public static var Augments:String = "";
	public static var Weapons:String = "";
	public static var Delete:String = "";
	public static var Inherit:String = "";
	public static var IconTooltipDesc:String = "";
	public static var IconTooltipMisc:String = "";
	public static var DeleteIconTooltipDesc:String = "";
	public static var DeleteIconTooltipMisc:String = "";
	
	// English
	private static var Signet_English:String = "Signet";
	private static var Glyph_English:String = "Glyph";
	private static var Skills_English:String = "Skills";
	private static var Passives_English:String = "Passives";
	private static var Augments_English:String = "Augments";
	private static var Weapons_English:String = "Weapons";
	private static var Delete_English:String = "Delete";
	private static var Inherit_English:String = "Inherit";
	private static var IconTooltipDesc_English:String = "Press left button to set skill";
	private static var IconTooltipMisc_English:String = "";
	private static var DeleteIconTooltipDesc_English:String = "Select this button to clear the selected item";
	private static var DeleteIconTooltipMisc_English:String = "";

	// French
	private static var Signet_French:String = "Sceau";
	private static var Glyph_French:String = "Glyphe";
	private static var Skills_French:String = "Compétences";
	private static var Passives_French:String = "Passives";
	private static var Augments_French:String = "Augmentations";
	private static var Weapons_French:String = "Armes";
	private static var Delete_French:String = "Delete";
	private static var Inherit_French:String = "Hériter";
	private static var IconTooltipDesc_French:String = "Pressez le bouton gauche pour mettre la compétence";
	private static var IconTooltipMisc_French:String = "";
	private static var DeleteIconTooltipDesc_French:String = "Choisissez ce bouton pour dégager l'article choisi";
	private static var DeleteIconTooltipMisc_French:String = "";

	// German
	private static var Signet_German:String = "Siegel";
	private static var Glyph_German:String = "Glyph";
	private static var Skills_German:String = "Fähigkeiten";
	private static var Passives_German:String = "Passives";
	private static var Augments_German:String = "Augmente";
	private static var Weapons_German:String = "Waffen";
	private static var Delete_German:String = "Löschen";
	private static var Inherit_German:String = "Erben";
	private static var IconTooltipDesc_German:String = "Drücken Sie linken Knopf, um Fähigkeit zu setzen";
	private static var IconTooltipMisc_German:String = "";
	private static var DeleteIconTooltipDesc_German:String = "Wählen Sie diesen Knopf aus, um die ausgewählte Einzelheit zu klären";
	private static var DeleteIconTooltipMisc_German:String = "";

	public static function SetLocalisation():Void
	{
		var lang:String = LDBFormat.GetCurrentLanguageCode();

		if (lang == "fr")
		{
			SetFrenchLocalisation();
		}
		else if (lang == "de")
		{
			SetGermanLocalisation();
		}
		else
		{
			SetEnglishLocalisation();
		}
	}
	
	private static function SetEnglishLocalisation():Void
	{
		Signet = Signet_English;
		Glyph = Glyph_English;
		Skills = Skills_English;
		Passives = Passives_English;
		Augments = Augments_English;
		Weapons = Weapons_English;
		Delete = Delete_English;
		Inherit = Inherit_English;
		IconTooltipDesc = IconTooltipDesc_English;
		IconTooltipMisc = IconTooltipMisc_English;
		DeleteIconTooltipDesc = DeleteIconTooltipDesc_English;
		DeleteIconTooltipMisc = DeleteIconTooltipMisc_English;
	}

	private static function SetFrenchLocalisation():Void
	{
		Signet = Signet_French;
		Glyph = Glyph_French;
		Skills = Skills_French;
		Passives = Passives_French;
		Augments = Augments_French;
		Weapons = Weapons_French;
		Delete = Delete_French;
		Inherit = Inherit_French;
		IconTooltipDesc = IconTooltipDesc_French;
		IconTooltipMisc = IconTooltipMisc_French;
		DeleteIconTooltipDesc = DeleteIconTooltipDesc_French;
		DeleteIconTooltipMisc = DeleteIconTooltipMisc_French;
	}

	private static function SetGermanLocalisation():Void
	{
		Signet = Signet_German;
		Glyph = Glyph_German;
		Skills = Skills_German;
		Passives = Passives_German;
		Augments = Augments_German;
		Weapons = Weapons_German;
		Delete = Delete_German;
		Inherit = Inherit_German;
		IconTooltipDesc = IconTooltipDesc_German;
		IconTooltipMisc = IconTooltipMisc_German;
		DeleteIconTooltipDesc = DeleteIconTooltipDesc_German;
		DeleteIconTooltipMisc = DeleteIconTooltipMisc_German;
	}
}