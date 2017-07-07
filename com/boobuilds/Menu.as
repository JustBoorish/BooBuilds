import com.boobuilds.MenuPanel;
import com.boobuilds.DebugWindow;
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
class com.boobuilds.Menu
{
	private var m_parent:MovieClip;
	private var m_menu:MovieClip;
	private var m_name:String;
	private var m_panel:MenuPanel;
	private var m_subPanel1:MenuPanel;
	private var m_subPanel2:MenuPanel;
	private var m_subPanel3:MenuPanel;
	
	public function Menu(parent:MovieClip, name:String)
	{
		m_name = name;
		m_parent = parent;
		m_menu = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_panel = new MenuPanel(m_menu, m_name + "1", 4);
		m_subPanel1 = new MenuPanel(m_menu, m_name + "2", 4);
		m_subPanel2 = new MenuPanel(m_menu, m_name + "3", 4);
		m_subPanel3 = new MenuPanel(m_menu, m_name + "4", 4);
		
		AddItem(m_subPanel2, "One");
		AddItem(m_subPanel3, "One");
		AddItem(m_subPanel3, "Two");
		
		m_subPanel1.AddSubMenu("One", m_subPanel2);
		AddItem(m_subPanel1, "Two");
		AddItem(m_subPanel1, "Three");
		AddItem(m_subPanel1, "Four");
		m_subPanel1.AddSubMenu("Five", m_subPanel3);
		
		AddItem(m_panel, "One");
		m_panel.AddSubMenu("Two", m_subPanel1);
		AddItem(m_panel, "Three");
		AddItem(m_panel, "Four");
		AddItem(m_panel, "Five");
		var pt:Object = m_panel.GetDimensions(0, 100, true, 0, 0, 2560, 1600);
		m_panel.Rebuild();
		m_panel.SetVisible(true);
	}
	
	private function AddItem(panel:MenuPanel, value:String):Void
	{
		panel.AddItem(value, Proxy.create(this, doNothing, value));
	}
	
	private function doNothing(value:String):Void
	{
		DebugWindow.Log("Pressed " + value);
	}
}