import com.boobuilds.Build;
import com.boobuilds.BuildDisplay;
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
class com.boobuilds.BuildWindow
{
	private var m_modalBase:ModalBase;
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_display:BuildDisplay;
	
	public function BuildWindow(name:String, parent:MovieClip) 
	{
		m_name = name;
		m_parent = parent;
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls));
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
	}
	
	public function SetBuild(build:Build):Void
	{
		m_display.SetBuild(build);
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_display = new BuildDisplay("Inspect", modalMC, textFormat, 0, 30);
	}
}