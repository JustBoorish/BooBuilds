import com.boobuilds.BuildGroup;
import com.boobuilds.Checkbox;
import com.boobuilds.ComboBox;
import com.boobuilds.Graphics;
import com.boobuilds.ModalBase;
import com.boobuilds.DebugWindow;
import com.GameInterface.Utils;
import com.Utils.Text;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.LoreNode;
import mx.utils.Delegate;
import org.sitedaniel.utils.Proxy;
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
class com.boobuilds.ManageDuplicatesDialog
{
	private var m_addonMC:MovieClip;
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_slotNames:Array;
	private var m_slotValues:Array;
	private var m_includeWeapons:Boolean;
	private var m_callback:Function;
	private var m_checks:Array;
	
	public function ManageDuplicatesDialog(name:String, parent:MovieClip, addonMC:MovieClip, slotNames:Array, slotValues:Array) 
	{
		m_slotNames = slotNames;
		m_slotValues = slotValues;
		
		m_addonMC = addonMC;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.75, 0.75);
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
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		var text:String = "Duplicate Items";
		if (m_slotNames.length == 0)
		{
			text = "No duplicate items";
		}
		
		var extents:Object = Text.GetTextExtent(text, m_textFormat, modalMC);
		Graphics.DrawText("TitleText", modalMC, text, m_textFormat, 60, 20, extents.width, extents.height);
		
		m_checks = new Array();
		for (var indx:Number = 0; indx < m_slotNames.length; ++indx)
		{
			DrawLine(modalMC, indx);
		}
	}
	
	private function DrawLine(modalMC:MovieClip, row:Number):Void
	{
		var checkSize:Number = 13;
		var text:String = m_slotNames[row];
		var extents:Object = Text.GetTextExtent(text, m_textFormat, modalMC);
		var checkY:Number = 50 + extents.height * row + 5 * row;
		Graphics.DrawText("CheckText" + row, modalMC, text, m_textFormat, 35 + checkSize, checkY + checkSize / 2 - extents.height / 2, extents.width, extents.height);
		
		var check:Checkbox = new Checkbox("Check" + row, modalMC, 30, checkY, checkSize, Delegate.create(this, function(a:Boolean) { this.m_slotValues[row] = a; }), false);
		check.SetChecked(m_slotValues[row]);
		m_checks.push(check);
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
				m_callback(m_slotNames, m_slotValues);
			}
			else
			{
				m_callback(null, null);
			}
		}
	}	
}