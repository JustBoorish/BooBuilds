import com.Utils.Text;
import com.boobuilds.ModalBase;
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
class com.boobuilds.YesNoDialog
{
	private var m_modalBase:ModalBase;
	private var m_line1:String;
	private var m_line2:String;
	private var m_line3:String;
	private var m_textFormat:TextFormat;
	private var m_callback:Function;
	
	public function YesNoDialog(name:String, parent:MovieClip, line1:String, line2:String, line3:String) 
	{
		m_line1 = line1;
		m_line2 = line2;
		m_line3 = line3;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls));
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("Yes", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("No", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		m_callback = callback;
		m_modalBase.Show(m_callback);
	}
	
	public function Hide():Void
	{
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		var labelExtents:Object;
		if (m_line1 != null)
		{
			labelExtents = Text.GetTextExtent(m_line1, m_textFormat, modalMC);
			var line1:TextField = modalMC.createTextField("Line1", modalMC.getNextHighestDepth(), modalMC._width / 2 - labelExtents.width / 2, labelExtents.height, labelExtents.width, labelExtents.height);
			line1.embedFonts = true;
			line1.selectable = false;
			line1.antiAliasType = "advanced";
			line1.autoSize = true;
			line1.border = false;
			line1.background = false;
			line1.setNewTextFormat(m_textFormat);
			line1.text = m_line1;
		}		
		
		if (m_line2 != null)
		{
			labelExtents = Text.GetTextExtent(m_line2, m_textFormat, modalMC);
			var line2:TextField = modalMC.createTextField("Line2", modalMC.getNextHighestDepth(), modalMC._width / 2 - labelExtents.width / 2, labelExtents.height * 2, labelExtents.width, labelExtents.height);
			line2.embedFonts = true;
			line2.selectable = false;
			line2.antiAliasType = "advanced";
			line2.autoSize = true;
			line2.border = false;
			line2.background = false;
			line2.setNewTextFormat(m_textFormat);
			line2.text = m_line2;
		}
		
		if (m_line3 != null)
		{
			labelExtents = Text.GetTextExtent(m_line3, m_textFormat, modalMC);
			var line3:TextField = modalMC.createTextField("Line3", modalMC.getNextHighestDepth(), modalMC._width / 2 - labelExtents.width / 2, labelExtents.height * 4, labelExtents.width, labelExtents.height);
			line3.embedFonts = true;
			line3.selectable = false;
			line3.antiAliasType = "advanced";
			line3.autoSize = true;
			line3.border = false;
			line3.background = false;
			line3.setNewTextFormat(m_textFormat);
			line3.text = m_line3;
		}
	}
	
	private function ButtonPressed(text:String):Void
	{
		var success:Boolean = false;
		if (text == "Yes" || text == "OK")
		{
			success = true;
		}
		
		m_modalBase.Hide();
		
		if (m_callback != null)
		{
			m_callback(success);
		}
	}
}