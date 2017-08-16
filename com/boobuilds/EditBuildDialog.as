import com.Utils.Text;
import com.boobuilds.BuildGroup;
import com.boobuilds.Outfit;
import com.boobuilds.OutfitSelector;
import com.boocommon.Checkbox;
import com.boocommon.Graphics;
import com.boocommon.ModalBase;
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
class com.boobuilds.EditBuildDialog
{
	private var m_modalBase:ModalBase;
	private var m_addonMC:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_buildName:String;
	private var m_includeSkills:Boolean;
	private var m_includePassives:Boolean;
	private var m_includeWeapons:Boolean;
	private var m_includeTalismans:Boolean;
	private var m_includeGadget:Boolean;
	private var m_callback:Function;
	private var m_input:TextField;
	private var m_includeSkillsCheck:Checkbox;
	private var m_includePassivesCheck:Checkbox;
	private var m_includeWeaponsCheck:Checkbox;
	private var m_includeTalismansCheck:Checkbox;
	private var m_includeGadgetCheck:Checkbox;
	private var m_outfitID:String;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_outfitX:Number;
	private var m_outfitY:Number;
	private var m_outfitButton:MovieClip;
	private var m_removeOutfitButton:MovieClip;
	private var m_outfitSelector:OutfitSelector;
	
	public function EditBuildDialog(name:String, parent:MovieClip, addonMC:MovieClip, buildName:String, includeSkills:Boolean, includePassives:Boolean, includeWeapons:Boolean, includeTalismans:Boolean, includeGadget:Boolean, outfitID:String, outfits:Object, outfitGroups:Array) 
	{
		m_addonMC = addonMC;
		m_buildName = buildName;
		m_includeSkills = includeSkills;
		m_includePassives = includePassives;
		m_includeWeapons = includeWeapons;
		m_includeTalismans = includeTalismans;
		m_includeGadget = includeGadget;
		m_outfitID = outfitID;
		m_outfits = outfits;
		m_outfitGroups = outfitGroups;
		
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.6, 0.85);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		if (m_outfitSelector != null)
		{
			m_outfitSelector.Unload();
			m_outfitSelector = null;
		}
		
		Selection.setFocus(m_input);
		Selection.setSelection(m_buildName.length, m_buildName.length);
		m_callback = callback;
		m_modalBase.Show(m_callback);
	}
	
	public function Hide():Void
	{
		Selection.setFocus(null);
		if (m_outfitSelector != null)
		{
			m_outfitSelector.Unload();
			m_outfitSelector = null;
		}
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		Selection.setFocus(null);
		if (m_outfitSelector != null)
		{
			m_outfitSelector.Unload();
			m_outfitSelector = null;
		}
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		
		var text1:String = "Build name";
		var labelExtents:Object;
		labelExtents = Text.GetTextExtent(text1, m_textFormat, modalMC);
		Graphics.DrawText("Line1", modalMC, text1, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		
		var input:TextField = modalMC.createTextField("Input", modalMC.getNextHighestDepth(), 30, labelExtents.height * 2 + 10, modalMC._width - 60, labelExtents.height + 6);
		input.type = "input";
		input.embedFonts = true;
		input.selectable = true;
		input.antiAliasType = "advanced";
		input.autoSize = false;
		input.border = true;
		input.background = false;
		input.setNewTextFormat(m_textFormat);
		input.text = m_buildName;
		input.borderColor = 0x585858;
		input.background = true;
		input.backgroundColor = 0x2E2E2E;
		input.wordWrap = false;
		input.maxChars = 40;
		m_input = input;

		var checkY:Number = 30 + labelExtents.height * 3;
		var checkSize:Number = 13;
		var text:String = "Include skills";
		var extents:Object = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeSkillsText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);		
		m_includeSkillsCheck = new Checkbox("IncludeSkillsCheck", modalMC, 30, checkY, checkSize, null, false);
		
		checkY = 35 + labelExtents.height * 4;
		text = "Include passives";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludePassivesText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		m_includePassivesCheck = new Checkbox("IncludePassivesCheck", modalMC, 30, checkY, checkSize, null, false);
		
		checkY = 40 + labelExtents.height * 5;
		text = "Include weapons";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeWeaponsText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		m_includeWeaponsCheck = new Checkbox("IncludeWeaponsCheck", modalMC, 30, checkY, checkSize, null, false);
		
		checkY = 45 + labelExtents.height * 6;
		text = "Include talismans";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeTalismansText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		m_includeTalismansCheck = new Checkbox("IncludeTalismansCheck", modalMC, 30, checkY, checkSize, null, false);
		
		checkY = 50 + labelExtents.height * 7;
		text = "Include gadget";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("IncludeGadgetText", modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		m_includeGadgetCheck = new Checkbox("IncludeGadgetCheck", modalMC, 30, checkY, checkSize, null, false);
		
		text = "Outfit";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("OutfitText", modalMC, text, m_textFormat, 30, checkY + checkSize * 2, extents.width, extents.height);
		m_outfitX = 30 + extents.width + 10;
		m_outfitY = checkY + checkSize * 2;
		DrawOutfitButton(modalMC);
		
		m_includeSkillsCheck.SetChecked(m_includeSkills);
		m_includePassivesCheck.SetChecked(m_includePassives);
		m_includeWeaponsCheck.SetChecked(m_includeWeapons);
		m_includeTalismansCheck.SetChecked(m_includeTalismans);
		m_includeGadgetCheck.SetChecked(m_includeGadget);
	}
	
	private function DrawOutfitButton(modalMC:MovieClip):Void
	{
		var colours:Array = BuildGroup.GetColourArray(BuildGroup.GRAY);
		var outfitSet:Boolean = false;
		var text:String = "None";
		if (m_outfitID != null)
		{
			var thisOutfit:Outfit = m_outfits[m_outfitID];
			if (thisOutfit != null)
			{
				text = thisOutfit.GetName();
				outfitSet = true;
				
				for (var indx:Number = 0; indx < m_outfitGroups.length; ++indx)
				{
					var thisGroup:BuildGroup = m_outfitGroups[indx];
					if (thisGroup.GetID() == thisOutfit.GetGroup())
					{
						colours = BuildGroup.GetColourArray(thisGroup.GetColourName());
					}
				}
			}
			else
			{
				m_outfitID = null;
			}
		}
		
		if (m_outfitButton != null)
		{
			m_outfitButton.removeMovieClip();
		}
		
		if (m_removeOutfitButton != null)
		{
			m_removeOutfitButton.removeMovieClip();
		}
		
		var extents:Object = Text.GetTextExtent(text, m_textFormat, modalMC);
		m_outfitButton = Graphics.DrawButton("OutfitButton", modalMC, text, m_textFormat, m_outfitX, m_outfitY, extents.width, colours, Delegate.create(this, OutfitPressed));

		if (outfitSet == true)
		{
			text = "Clear Outfit";
			extents = Text.GetTextExtent(text, m_textFormat, modalMC);
			m_removeOutfitButton = Graphics.DrawButton("OutfitButton", modalMC, text, m_textFormat, m_outfitX, m_outfitY + extents.height + 10, extents.width, BuildGroup.GetColourArray(BuildGroup.GRAY), Delegate.create(this, OutfitClearPressed));
		}
	}
	
	private function OutfitPressed(text:String):Void
	{
		if (m_outfitSelector != null)
		{
			m_outfitSelector.Unload();
		}
		
		m_outfitSelector = new OutfitSelector(m_addonMC, "Outfit Selector", m_outfitGroups, m_outfits, Delegate.create(this, OutfitSelected));
		var pt:Object = { x:m_outfitButton._width / 2, y:m_outfitButton._height / 2 };
		m_outfitButton.localToGlobal(pt);
		m_addonMC.globalToLocal(pt);
		m_outfitSelector.Show(pt.x, pt.y);
	}
	
	private function OutfitClearPressed():Void
	{
		m_outfitID = null;
		DrawOutfitButton(m_modalBase.GetMovieClip());
	}
	
	private function OutfitSelected(thisOutfit:Outfit):Void
	{
		if (thisOutfit != null)
		{
			m_outfitID = thisOutfit.GetID();
			DrawOutfitButton(m_modalBase.GetMovieClip());
		}
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
				m_callback(m_input.text, m_includeSkillsCheck.IsChecked(), m_includePassivesCheck.IsChecked(), m_includeWeaponsCheck.IsChecked(), m_includeTalismansCheck.IsChecked(), m_includeGadgetCheck.IsChecked(), m_outfitID);
			}
			else
			{
				m_callback(null, false, false, false, false, false, null);
			}
		}
	}
}