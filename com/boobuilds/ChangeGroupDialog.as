import com.boobuilds.BuildGroup;
import com.boobuilds.Checkbox;
import com.boobuilds.ComboBox;
import com.boobuilds.Graphics;
import com.boobuilds.ModalBase;
import com.boobuilds.DebugWindow;
import com.Utils.Text;
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
class com.boobuilds.ChangeGroupDialog
{
	private var m_addonMC:MovieClip;
	private var m_modalBase:ModalBase;
	private var m_textFormat:TextFormat;
	private var m_groupName:String;
	private var m_groups:Array;
	private var m_callback:Function;
	private var m_combo:ComboBox;
	
	public function ChangeGroupDialog(name:String, parent:MovieClip, addonMC:MovieClip, groupName:String, groups:Array) 
	{
		m_groupName = groupName;
		m_groups = groups;
		m_addonMC = addonMC;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), 0.5, 0.75);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 4;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", modalMC._width / 4, y, Delegate.create(this, ButtonPressed));
		m_modalBase.DrawButton("Cancel", modalMC._width - (modalMC._width / 4), y, Delegate.create(this, ButtonPressed));
	}
	
	public function Show(callback:Function):Void
	{
		m_callback = callback;
		m_modalBase.Show(m_callback);
	}
	
	public function Hide():Void
	{
		m_combo.HidePopup();
		m_modalBase.Hide();
	}
	
	public function Unload():Void
	{
		m_combo.Unload();
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		
		var text1:String = "New group";
		var labelExtents:Object;
		labelExtents = Text.GetTextExtent(text1, m_textFormat, modalMC);
		Graphics.DrawText("GroupLabel", modalMC, text1, m_textFormat, 30, 20, labelExtents.width, labelExtents.height);
		
		BuildCombo(modalMC, 35 + labelExtents.width, 20);
	}
	
	private function BuildCombo(modalMC:MovieClip, x:Number, y:Number):Void
	{
		var names:Array = new Array();
		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			names.push(m_groups[indx].GetName());
		}
		
		var colours:Array = BuildGroup.GetColourArray(BuildGroup.GRAY);
		m_combo = new ComboBox(modalMC, "GroupCombo", m_addonMC, x, y, colours[0], colours[1], 6, m_groupName, names);
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
				m_callback(m_combo.GetSelectedEntry());
			}
			else
			{
				m_callback(null);
			}
		}
	}
}