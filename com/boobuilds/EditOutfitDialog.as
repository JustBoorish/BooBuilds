import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.LoreNode;
import com.Utils.Text;
import com.boobuilds.BuildGroup;
import com.boobuildscommon.Checkbox;
import com.boobuildscommon.Colours;
import com.boobuildscommon.ComboBox;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.ModalBase;
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
class com.boobuilds.EditOutfitDialog
{
	private var m_addonMC:MovieClip;
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_outfitName:String;
	private var m_includeWeapons:Boolean;
	private var m_includeWeaponSkins:Boolean;
	private var m_callback:Function;
	private var m_input:TextField;
	private var m_sprintCombo:ComboBox;
	private var m_sprintX:Number;
	private var m_sprintY:Number;
	private var m_sprintTag:Number;
	private var m_petCombo:ComboBox;
	private var m_petX:Number;
	private var m_petY:Number;
	private var m_petTag:Number;
	private var m_includeWeaponsCheck:Checkbox;
	private var m_includeWeaponSkinsCheck:Checkbox;
	
	public function EditOutfitDialog(name:String, parent:MovieClip, addonMC:MovieClip, frameWidth:Number, frameHeight:Number, outfitName:String, includeWeapons:Boolean, includeWeaponSkins:Boolean, sprintTag:Number, petTag:Number) 
	{
		m_outfitName = outfitName;
		m_includeWeapons = includeWeapons;
		m_includeWeaponSkins = includeWeaponSkins;
		m_sprintTag = sprintTag;
		m_petTag = petTag;
		
		m_addonMC = addonMC;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.75, frameHeight * 0.75);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		Selection.setFocus(m_input);
		Selection.setSelection(m_outfitName.length, m_outfitName.length);
		m_sprintCombo.HidePopup();
		m_petCombo.HidePopup();
		m_callback = callback;
		m_modalBase.Show(m_callback);
	}
	
	public function Hide():Void
	{
		Selection.setFocus(null);
		m_sprintCombo.HidePopup();
		m_petCombo.HidePopup();
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		Selection.setFocus(null);
		m_sprintCombo.Unload();
		m_petCombo.Unload();
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		
		var text1:String = "Outfit name";
		var labelExtents:Object;
		labelExtents = Text.GetTextExtent(text1, m_textFormat, modalMC);
		var line1:TextField = Graphics.DrawText("Line1", modalMC, text1, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		
		var input:TextField = modalMC.createTextField("Input", modalMC.getNextHighestDepth(), 30, line1._y + line1._height + 10, modalMC._width - 60, labelExtents.height + 6);
		input.type = "input";
		input.embedFonts = true;
		input.selectable = true;
		input.antiAliasType = "advanced";
		input.autoSize = false;
		input.border = true;
		input.background = false;
		input.setNewTextFormat(m_textFormat);
		input.text = m_outfitName;
		input.borderColor = 0x585858;
		input.background = true;
		input.backgroundColor = 0x2E2E2E;
		input.wordWrap = false;
		input.maxChars = 40;
		m_input = input;

		var checkY:Number = 30 + line1._y + line1._height * 2;
		var checkSize:Number = 13;
		var text:String = "Include weapon visibility";
		var extents:Object = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeWeaponsText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		
		m_includeWeaponsCheck = new Checkbox("IncludeWeaponsCheck", modalMC, 30, checkY, checkSize, null, m_includeWeapons);
	
		checkY += extents.height + 10;
		text = "Include weapon skins";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeWeaponSkinsText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		
		m_includeWeaponSkinsCheck = new Checkbox("IncludeWeaponSkinsCheck", modalMC, 30, checkY, checkSize, null, m_includeWeaponSkins);
	
		checkY += extents.height + 15;
		text = "Sprint";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeSprintText", modalMC, text, m_textFormat, 30, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		
		m_sprintX = 35 + extents.width;
		m_sprintY = checkY - 5;
		BuildSprintCombo(modalMC, m_sprintX, m_sprintY);
		
		checkY += extents.height + 15;
		text = "Pet";
		Graphics.DrawText("IncludePetText", modalMC, text, m_textFormat, 30, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		
		m_petX = 35 + extents.width;
		m_petY = checkY - 5;
		BuildPetCombo(modalMC, m_petX, m_petY);
	}
	
	private function BuildSprintCombo(modalMC:MovieClip, x:Number, y:Number):Void
	{
		var ownedNodes:Array = GetSprintData();
		var names:Array = new Array();
		names.push("None");
		for (var indx:Number = 0; indx < ownedNodes.length; ++indx)
		{
			var node:LoreNode = LoreNode(ownedNodes[indx]);
			names.push(node.m_Name);
		}
		
		var colours:Array = Colours.GetColourArray(Colours.GetDefaultColourName());
		m_sprintCombo = new ComboBox(modalMC, "Sprint", m_addonMC, x, y, colours[0], colours[1], 6, GetSprintFromTag(m_sprintTag), names);
	}
	
	private function BuildPetCombo(modalMC:MovieClip, x:Number, y:Number):Void
	{
		var ownedNodes:Array = GetPetData();
		var names:Array = new Array();
		names.push("None");
		for (var indx:Number = 0; indx < ownedNodes.length; ++indx)
		{
			var node:LoreNode = LoreNode(ownedNodes[indx]);
			names.push(node.m_Name);
		}
		
		var colours:Array = Colours.GetColourArray(Colours.GetDefaultColourName());
		m_petCombo = new ComboBox(modalMC, "Pet", m_addonMC, x, y, colours[0], colours[1], 4, GetPetFromTag(m_petTag), names);
	}
	
	private function ButtonPressed(text:String):Void
	{
		var success:Boolean = false;
		if (text == "OK")
		{
			success = true;
		}

		Hide();
		
		if (m_callback != null)
		{
			if (success)
			{
				m_callback(m_input.text, m_includeWeaponsCheck.IsChecked(), m_includeWeaponSkinsCheck.IsChecked(), GetTagFromSprintName(m_sprintCombo.GetSelectedEntry()), GetTagFromPetName(m_petCombo.GetSelectedEntry()));
			}
			else
			{
				m_callback(null, false, false, null, null);
			}
		}
	}
	
	public static function GetSprintFromTag(sprintTag:Number):String
	{
		var ret:String = "None";
		
		if (sprintTag != null)
		{
			var nodes:Array = GetSprintData();
			for (var indx:Number = 0; indx < nodes.length; ++indx)
			{
				var node:LoreNode = LoreNode(nodes[indx]);
				if (node != null && node.m_Id == sprintTag)
				{
					ret = node.m_Name;
					break;
				}
			}
		}
		
		return ret;
	}
	
	private function GetTagFromSprintName(sprintName:String):Number
	{
		var ret:Number = null;
		if (sprintName != null)
		{
			var nodes:Array = GetSprintData();
			for (var indx:Number = 0; indx < nodes.length; ++indx)
			{
				var node:LoreNode = LoreNode(nodes[indx]);
				if (node != null && node.m_Name == sprintName)
				{
					ret = node.m_Id;
					break;
				}
			}
		}
		
		return ret;
	}
	
	private static function GetSprintData():Array
	{
		var allNodes:Array = Lore.GetMountTree().m_Children;
		allNodes.sortOn("m_Name");
		var ownedNodes:Array = new Array();
		for (var i = 0; i < allNodes.length; i++)
		{
			//if (Utils.GetGameTweak("HideMount_" + allNodes[i].m_Id) == 0)
			//{
				if (!LoreBase.IsLocked(allNodes[i].m_Id))
				{
					ownedNodes.push(allNodes[i]);
				}
			//}
		}
		
		return ownedNodes;
	}
	
	public static function GetPetFromTag(petTag:Number):String
	{
		var ret:String = "None";
		
		if (petTag != null)
		{
			var nodes:Array = GetPetData();
			for (var indx:Number = 0; indx < nodes.length; ++indx)
			{
				var node:LoreNode = LoreNode(nodes[indx]);
				if (node != null && node.m_Id == petTag)
				{
					ret = node.m_Name;
					break;
				}
			}
		}
		
		return ret;
	}
	
	private function GetTagFromPetName(petName:String):Number
	{
		var ret:Number = null;
		if (petName != null)
		{
			var nodes:Array = GetPetData();
			for (var indx:Number = 0; indx < nodes.length; ++indx)
			{
				var node:LoreNode = LoreNode(nodes[indx]);
				if (node != null && node.m_Name == petName)
				{
					ret = node.m_Id;
					break;
				}
			}
		}
		
		return ret;
	}
	
	private static function GetPetData():Array
	{
		var allNodes:Array = Lore.GetPetTree().m_Children;
		allNodes.sortOn("m_Name");
		var ownedNodes:Array = new Array();
		for (var i = 0; i < allNodes.length; i++)
		{
			//if (Utils.GetGameTweak("HideMount_" + allNodes[i].m_Id) == 0)
			//{
				if (!LoreBase.IsLocked(allNodes[i].m_Id))
				{
					ownedNodes.push(allNodes[i]);
				}
			//}
		}
		
		return ownedNodes;
	}
}