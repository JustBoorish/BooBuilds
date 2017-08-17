import com.boobuilds.Build;
import com.boobuilds.BuildDisplay;
import com.boocommon.Graphics;
import com.boocommon.ModalBase;
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
	private var m_name:String;
	private var m_display:BuildDisplay;
	private var m_build:Build;
	private var m_callback:Function;
	private var m_input:TextField;
	
	public function EditQuickBuildDialog(name:String, parent:MovieClip, build:Build) 
	{
		m_name = name;
		m_parent = parent;
		m_build = build;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.75, 0.97);
		
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}

	public function Show(callback:Function):Void
	{
		m_callback = callback;
		m_modalBase.Show();
	}
	
	public function Hide():Void
	{
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		Hide();
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		var text1:String = "Build name";
		var labelExtents:Object;
		labelExtents = Text.GetTextExtent(text1, textFormat, modalMC);
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

		m_display = new BuildDisplay("Inspect", modalMC, textFormat, 0, labelExtents.height * 3 + 40, true);
		m_display.SetBuild(m_build);
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
				m_callback(m_input.text, m_display.GetSkillChecks(), m_display.GetPassiveChecks(), m_display.GetWeaponChecks(), m_display.GetGearChecks());
			}
			else
			{
				m_callback(null, null, null, null, null);
			}
		}
	}
}