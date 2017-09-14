import com.boobuilds.Build;
import com.boobuilds.BuildDisplay;
import com.boobuilds.BuildGroup;
import com.boobuilds.BuildSelector;
import com.boobuildscommon.Colours;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.ModalBase;
import com.Utils.Text;
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
class com.boobuilds.EditQuickBuildDialog
{
	private var m_modalBase:ModalBase;
	private var m_parent:MovieClip;
	private var m_addonMC:MovieClip;
	private var m_name:String;
	private var m_build:Build;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_display:BuildDisplay;
	private var m_callback:Function;
	private var m_input:TextField;
	private var m_buildID:String;
	private var m_buildButton:MovieClip;
	private var m_removeBuildButton:MovieClip;
	private var m_buildSelector:BuildSelector;
	private var m_textFormat:TextFormat;
	private var m_buildX:Number;
	private var m_buildY:Number;
	private var m_previousBuild:Build;
	
	public function EditQuickBuildDialog(name:String, parent:MovieClip, addonMC:MovieClip, frameWidth:Number, frameHeight:Number, build:Build, builds:Object, buildGroups:Array, previousBuild:Build) 
	{
		m_name = name;
		m_parent = parent;
		m_addonMC = addonMC;
		m_build = build;
		m_builds = builds;
		m_buildGroups = buildGroups;
		m_previousBuild = previousBuild;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.97, frameHeight * 0.85);
		
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}

	public function Show(callback:Function):Void
	{
		if (m_buildSelector != null)
		{
			m_buildSelector.Unload();
			m_buildSelector = null;
		}
		
		m_callback = callback;
		m_modalBase.Show();
	}
	
	public function Hide():Void
	{
		if (m_buildSelector != null)
		{
			m_buildSelector.Unload();
			m_buildSelector = null;
		}
		
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		Hide();
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		
		var text1:String = "Build name";
		var labelExtents:Object = Text.GetTextExtent(text1, textFormat, modalMC);
		Graphics.DrawText("Line1", modalMC, text1, textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		
		var input:TextField = modalMC.createTextField("Input", modalMC.getNextHighestDepth(), 30, labelExtents.height * 2 + 10, modalMC._width - 60, labelExtents.height + 6);
		input.type = "input";
		input.embedFonts = true;
		input.selectable = true;
		input.antiAliasType = "advanced";
		input.autoSize = false;
		input.border = true;
		input.background = false;
		input.setNewTextFormat(textFormat);
		input.text = m_build.GetName();
		input.borderColor = 0x585858;
		input.background = true;
		input.backgroundColor = 0x2E2E2E;
		input.wordWrap = false;
		input.maxChars = 40;
		m_input = input;

		var y:Number = m_input._y + m_input._height + 20;
		var selectorText:String = "Requires build";
		var selectorExtents:Object = Text.GetTextExtent(selectorText, textFormat, modalMC);
		Graphics.DrawText("Build Line", modalMC, selectorText, textFormat, 30, y, selectorExtents.width, selectorExtents.height);

		m_buildX = selectorExtents.width + 40;
		m_buildY = y;
		DrawBuildButton(modalMC);
		
		y += selectorExtents.height + 40;
		m_display = new BuildDisplay("Inspect", modalMC, textFormat, 0, y, true);
		m_display.SetBuild(m_build);
		if (m_previousBuild != null)
		{
			for (var indx:Number = 0; indx < Build.MAX_SKILLS; ++indx)
			{
				m_display.SetSkillChecked(indx, m_previousBuild.IsSkillSet(indx));
			}
			
			for (var indx:Number = 0; indx < Build.MAX_PASSIVES; ++indx)
			{
				m_display.SetPassiveChecked(indx, m_previousBuild.IsPassiveSet(indx));
			}
			
			for (var indx:Number = 0; indx < Build.MAX_WEAPONS; ++indx)
			{
				m_display.SetWeaponChecked(indx, m_previousBuild.IsWeaponSet(indx));
			}
			
			for (var indx:Number = 0; indx < Build.MAX_GEAR; ++indx)
			{
				m_display.SetGearChecked(indx, m_previousBuild.IsGearSet(indx));
			}
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
				m_callback(m_input.text, m_display.GetSkillChecks(), m_display.GetPassiveChecks(), m_display.GetWeaponChecks(), m_display.GetGearChecks(), m_buildID);
			}
			else
			{
				m_callback(null, null, null, null, null, null);
			}
		}
	}
	private function DrawBuildButton(modalMC:MovieClip):Void
	{
		var colours:Array = Colours.GetDefaultColourArray();
		var buildSet:Boolean = false;
		var text:String = "None";
		if (m_buildID != null)
		{
			var thisBuild:Build = m_builds[m_buildID];
			if (thisBuild != null)
			{
				text = thisBuild.GetName();
				buildSet = true;
				
				for (var indx:Number = 0; indx < m_buildGroups.length; ++indx)
				{
					var thisGroup:BuildGroup = m_buildGroups[indx];
					if (thisGroup.GetID() == thisBuild.GetGroup())
					{
						colours = Colours.GetColourArray(thisGroup.GetColourName());
					}
				}
			}
			else
			{
				m_buildID = null;
			}
		}
		
		if (m_buildButton != null)
		{
			m_buildButton.removeMovieClip();
		}
		
		if (m_removeBuildButton != null)
		{
			m_removeBuildButton.removeMovieClip();
		}
		
		var extents:Object = Text.GetTextExtent(text, m_textFormat, modalMC);
		m_buildButton = Graphics.DrawButton("BuildButton", modalMC, text, m_textFormat, m_buildX, m_buildY, extents.width, colours, Delegate.create(this, BuildPressed));

		if (buildSet == true)
		{
			text = "Clear Build";
			extents = Text.GetTextExtent(text, m_textFormat, modalMC);
			m_removeBuildButton = Graphics.DrawButton("ClearBuildButton", modalMC, text, m_textFormat, m_buildX, m_buildY + extents.height + 10, extents.width, Colours.GetDefaultColourArray(), Delegate.create(this, OutfitClearPressed));
		}
	}
	
	private function BuildPressed(text:String):Void
	{
		if (m_buildSelector != null)
		{
			m_buildSelector.Unload();
			m_buildSelector = null;
		}
		else
		{
			m_buildSelector = new BuildSelector(m_addonMC, "Build Selector", m_buildGroups, m_builds, Delegate.create(this, BuildSelected));
			var pt:Object = { x:m_buildButton._width / 2, y:m_buildButton._height / 2 };
			m_buildButton.localToGlobal(pt);
			m_addonMC.globalToLocal(pt);
			m_buildSelector.Show(pt.x, pt.y, pt.y);
		}
	}
	
	private function OutfitClearPressed():Void
	{
		m_buildID = null;
		DrawBuildButton(m_modalBase.GetMovieClip());
	}
	
	private function BuildSelected(thisBuild:Build):Void
	{
		if (thisBuild != null)
		{
			m_buildID = thisBuild.GetID();
			DrawBuildButton(m_modalBase.GetMovieClip());
		}
	}	
}