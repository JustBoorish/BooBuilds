import com.boobuildscommon.IconSelector;
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
class com.boobuilds.EditIconDialog
{
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_addonMC:MovieClip;
	private var m_subFrame:MovieClip;
	private var m_callback:Function;
	private var m_modalBase:ModalBase;
	private var m_iconPaths:Array;
	private var m_iconSelector:IconSelector;
	private var m_iconPath:String;
	
	public function EditIconDialog(name:String, parent:MovieClip, addonMC:MovieClip, frameWidth:Number, frameHeight:Number, iconPaths:Array) 
	{
		m_name = name;
		m_parent = parent;
		m_addonMC = addonMC;
		m_iconPaths = iconPaths;
		
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.85, frameHeight * 0.7);
		var modalMC:MovieClip = m_modalBase.GetMovieClip();
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
		if (m_iconSelector != null)
		{
			m_iconSelector.Unload();
		}
		
		m_modalBase.Unload();
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_iconSelector = new IconSelector(m_name, modalMC, 25, 30, 32, 6, m_iconPaths, Delegate.create(this, IconPressed));
	}
	
	private function IconPressed(iconPath:String):Void
	{
		m_iconPath = iconPath;
		
		Hide();
		
		if (m_callback != null)
		{
			m_callback(m_iconPath);
		}
	}
}