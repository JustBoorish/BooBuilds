import com.boobuilds.ModalBase;
import com.boobuilds.DebugWindow;;
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
class com.boobuilds.ImportBuildDialog
{
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_callback:Function;
	private var m_nameInput:TextField;
	private var m_buildInput:TextField;
	
	public function ImportBuildDialog(name:String, parent:MovieClip) 
	{
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.4);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		Selection.setFocus(m_nameInput);
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
		
		var input:TextField = modalMC.createTextField("NameInput", modalMC.getNextHighestDepth(), 30, line1._y + line1._height + 10, modalMC._width - 60, labelExtents.height + 6);
		input.type = "input";
		input.embedFonts = true;
		input.selectable = true;
		input.antiAliasType = "advanced";
		input.autoSize = false;
		input.border = true;
		input.background = false;
		input.setNewTextFormat(m_textFormat);
		input.text = "";
		input.borderColor = 0x585858;
		input.background = true;
		input.backgroundColor = 0x2E2E2E;
		input.wordWrap = false;
		input.maxChars = 40;
		m_nameInput = input;
		
		var text2:String = "Build export string";
		labelExtents = Text.GetTextExtent(text2, m_textFormat, modalMC);
		var line2:TextField = modalMC.createTextField("Label", modalMC.getNextHighestDepth(), 30, labelExtents.height * 4, labelExtents.width, labelExtents.height);
		line2.embedFonts = true;
		line2.selectable = false;
		line2.antiAliasType = "advanced";
		line2.autoSize = true;
		line2.border = false;
		line2.background = false;
		line2.setNewTextFormat(m_textFormat);
		line2.text = text2;
		
		var input2:TextField = modalMC.createTextField("Input", modalMC.getNextHighestDepth(), 30, line2._y + line2._height + 10, modalMC._width - 60, labelExtents.height + 6);
		input2.type = "input";
		input2.embedFonts = true;
		input2.selectable = true;
		input2.antiAliasType = "advanced";
		input2.autoSize = false;
		input2.border = true;
		input2.background = false;
		input2.setNewTextFormat(m_textFormat);
		input2.text = "";
		input2.borderColor = 0x585858;
		input2.background = true;
		input2.backgroundColor = 0x2E2E2E;
		input2.wordWrap = false;
		input2.maxChars = 4096;
		m_buildInput = input2;
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
				m_callback(m_nameInput.text, m_buildInput.text);
			}
			else
			{
				m_callback(null, null);
			}
		}
	}
}