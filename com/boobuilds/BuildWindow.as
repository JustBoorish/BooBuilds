import com.boobuilds.Build;
import com.boobuilds.BuildDisplay;
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
class com.boobuilds.BuildWindow
{
	private var m_modalBase:ModalBase;
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_display:BuildDisplay;
	private var m_build:Build;
	
	public function BuildWindow(name:String, parent:MovieClip, frameWidth:Number, frameHeight:Number, build:Build) 
	{
		m_name = name;
		m_parent = parent;
		m_build = build;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.97, frameHeight * 0.55);
		
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
		var x:Number = modalMC._width / 2;
		var y:Number = modalMC._height - 10;
		m_modalBase.DrawButton("OK", x, y, Delegate.create(this, ButtonPressed));
	}

	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			m_modalBase.Show();
		}
		else
		{
			m_modalBase.Hide();
		}
	}
	
	public function Unload():Void
	{
		SetVisible(false);
		m_modalBase.Unload();
		m_display.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		var boldTextFormat:TextFormat = Graphics.GetBoldTextFormat();
		var extents:Object = Text.GetTextExtent(m_build.GetName(), boldTextFormat, modalMC);
		Graphics.DrawText("Title", modalMC, m_build.GetName(), boldTextFormat, modalMC._width / 2 - extents.width / 2, 5, extents.width, extents.height);
		
		if (m_build.GetDamagePct() != null)
		{
			var aaString:String = "Damage: " + m_build.GetDamagePct() + "%  Health: " + m_build.GetHealthPct() + "%  Heal: " + m_build.GetHealPct() + "%";
			var aaExtents:Object = Text.GetTextExtent(aaString, textFormat, modalMC);
			Graphics.DrawText("AA", modalMC, aaString, textFormat, modalMC._width / 2 - aaExtents.width / 2, 15 + extents.height, aaExtents.width, aaExtents.height);
		}
		
		m_display = new BuildDisplay("Inspect", modalMC, textFormat, 0, 40 + extents.height, false);
		m_display.SetBuild(m_build);
	}
	
	private function ButtonPressed():Void
	{
		m_modalBase.Hide();
	}
}