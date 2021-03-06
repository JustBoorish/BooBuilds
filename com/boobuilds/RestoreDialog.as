import com.Utils.Text;
import com.boobuildscommon.Checkbox;
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
class com.boobuilds.RestoreDialog
{
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_callback:Function;
	private var m_input:TextField;
	private var m_overwrite:Checkbox;
	
	public function RestoreDialog(name:String, parent:MovieClip, frameWidth:Number, frameHeight:Number, callback:Function) 
	{
		m_callback = callback;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.8, frameHeight * 0.6);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show():Void
	{
		Selection.setFocus(m_input);
		m_modalBase.Show();
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
		m_textFormat = Graphics.GetTextFormat();
		var labelExtents:Object;
		var text:String = "Paste the saved backup string";
		labelExtents = Text.GetTextExtent(text, m_textFormat, modalMC);
		Graphics.DrawText("Line1", modalMC, text, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		
		text = "into the below box and press OK";
		labelExtents = Text.GetTextExtent(text, m_textFormat, modalMC);
		var line2:TextField = Graphics.DrawText("Line2", modalMC, text, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height * 2, labelExtents.width, labelExtents.height);
		
		var input:TextField = modalMC.createTextField("RestoreInput", modalMC.getNextHighestDepth(), 30, line2._y + line2._height + 10, modalMC._width - 60, labelExtents.height * 7 + 6);
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
		input.wordWrap = true;
		m_input = input;
		
		var checkSize:Number = 10;
		var checkY:Number = m_input._y + m_input._height + 20;
		m_overwrite = new Checkbox("RestoreOverwrite", modalMC, 30, checkY, checkSize, null, false);
		
		text = "Overwrite existing";
		labelExtents = Text.GetTextExtent(text, m_textFormat, modalMC);
		Graphics.DrawText("OverwriteLabel", modalMC, text, m_textFormat, 45, checkY + checkSize / 2 - labelExtents.height / 2, labelExtents.width, labelExtents.height);
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
			if (success)
			{
				m_callback(m_input.text, m_overwrite.IsChecked());
			}
			else
			{
				m_callback(null, false);
			}
		}
	}
}