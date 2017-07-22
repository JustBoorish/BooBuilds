import com.boobuilds.BuildGroup;
import com.boobuilds.Checkbox;
import com.boobuilds.ModalBase;
import com.boobuilds.DebugWindow;
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
class com.boobuilds.EditBuildDialog
{
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_buildName:String;
	private var m_includeWeapons:Boolean;
	private var m_includeTalismans:Boolean;
	private var m_callback:Function;
	private var m_input:TextField;
	private var m_includeWeaponsCheck:Checkbox;
	private var m_includeTalismansCheck:Checkbox;
	
	public function EditBuildDialog(name:String, parent:MovieClip, buildName:String, includeWeapons:Boolean, includeTalismans:Boolean) 
	{
		m_buildName = buildName;
		m_includeWeapons = includeWeapons;
		m_includeTalismans = includeTalismans;
		
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.5);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		Selection.setFocus(m_input);
		Selection.setSelection(m_buildName.length, m_buildName.length);
		m_callback = callback;
		m_modalBase.Show(m_callback);
	}
	
	public function Hide():Void
	{
		Selection.setFocus(null);
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		Selection.setFocus(null);
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		
		var text1:String = "Build name";
		var labelExtents:Object;
		labelExtents = Text.GetTextExtent(text1, m_textFormat, modalMC);
		var line1:TextField = modalMC.createTextField("Line1", modalMC.getNextHighestDepth(), modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		line1.embedFonts = true;
		line1.selectable = false;
		line1.antiAliasType = "advanced";
		line1.autoSize = true;
		line1.border = false;
		line1.background = false;
		line1.setNewTextFormat(m_textFormat);
		line1.text = text1;
		
		var input:TextField = modalMC.createTextField("Input", modalMC.getNextHighestDepth(), 30, line1._y + line1._height + 10, modalMC._width - 60, labelExtents.height + 6);
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

		var checkY:Number = 30 + line1._y + line1._height * 2;
		var checkSize:Number = 13;
		var text:String = "Include weapons";
		var extents:Object = Text.GetTextExtent(text, textFormat, modalMC);
		var includeWeaponsText:TextField = modalMC.createTextField("IncludeWeaponsText", modalMC.getNextHighestDepth(), 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		includeWeaponsText.embedFonts = true;
		includeWeaponsText.selectable = false;
		includeWeaponsText.antiAliasType = "advanced";
		includeWeaponsText.autoSize = true;
		includeWeaponsText.border = false;
		includeWeaponsText.background = false;
		includeWeaponsText.setNewTextFormat(textFormat);
		includeWeaponsText.text = text;
		
		m_includeWeaponsCheck = new Checkbox("IncludeWeaponsCheck", modalMC, 30, checkY, checkSize, null, false);
		
		checkY = 40 + line1._y + line1._height * 3;
		text = "Include talismans";
		extents = Text.GetTextExtent(text, textFormat, modalMC);
		var includeTalismansText:TextField = modalMC.createTextField("IncludeTalismansText", modalMC.getNextHighestDepth(), 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		includeTalismansText.embedFonts = true;
		includeTalismansText.selectable = false;
		includeTalismansText.antiAliasType = "advanced";
		includeTalismansText.autoSize = true;
		includeTalismansText.border = false;
		includeTalismansText.background = false;
		includeTalismansText.setNewTextFormat(textFormat);
		includeTalismansText.text = text;

		m_includeTalismansCheck = new Checkbox("IncludeTalismansCheck", modalMC, 30, checkY, checkSize, null, false);
		
		m_includeWeaponsCheck.SetChecked(m_includeWeapons);
		m_includeTalismansCheck.SetChecked(m_includeTalismans);
	}
	
	private function ButtonPressed(text:String):Void
	{
		var success:Boolean = false;
		if (text == "OK")
		{
			success = true;
		}

		m_modalBase.Hide();
		
		if (m_callback != null)
		{
			DebugWindow.Log(DebugWindow.Info, "Success " + success + " text " + text);
			if (success)
			{
				m_callback(m_input.text, m_includeWeaponsCheck.IsChecked(), m_includeTalismansCheck.IsChecked());
			}
			else
			{
				m_callback(null, false, false);
			}
		}
	}
}