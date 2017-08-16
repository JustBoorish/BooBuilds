import com.Utils.Text;
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
class com.boobuilds.ExportDialog
{
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_input:TextField;
	private var m_title:String;
	private var m_exportString:String;
	
	public function ExportDialog(name:String, parent:MovieClip, title:String, exportString:String) 
	{
		m_exportString = exportString;
		m_title = title;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.6, 0.8);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 2, y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show():Void
	{
		Selection.setFocus(m_input);
		Selection.setSelection(0, m_exportString.length);
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
		var text:String = m_title;
		labelExtents = Text.GetTextExtent(text, m_textFormat, modalMC);
		Graphics.DrawText("Line1", modalMC, text, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
		
		text = "Press Ctrl+C to copy and press OK";
		labelExtents = Text.GetTextExtent(text, m_textFormat, modalMC);
		var line2:TextField = Graphics.DrawText("Line2", modalMC, text, m_textFormat, modalMC._width / 2 - labelExtents.width / 2, labelExtents.height * 2, labelExtents.width, labelExtents.height);
		
		var input:TextField = modalMC.createTextField("ExportInput", modalMC.getNextHighestDepth(), 30, line2._y + line2._height + 10, modalMC._width - 60, labelExtents.height * 7 + 6);
		input.type = "input";
		input.embedFonts = true;
		input.selectable = true;
		input.antiAliasType = "advanced";
		input.autoSize = false;
		input.border = true;
		input.background = false;
		input.setNewTextFormat(m_textFormat);
		input.text = m_exportString;
		input.borderColor = 0x585858;
		input.background = true;
		input.backgroundColor = 0x2E2E2E;
		input.wordWrap = true;
		m_input = input;
	}
	
	private function ButtonPressed(text:String):Void
	{
		m_modalBase.Hide();
	}
}