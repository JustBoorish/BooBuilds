import com.boobuilds.MenuPanel;
import com.boobuilds.TreePanel;
import com.boobuilds.BuildGroup;
import com.boobuilds.Build;
import org.sitedaniel.utils.Proxy;
import mx.utils.Delegate;
import com.GameInterface.Game.Character;

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
class com.boobuilds.BuildSelector
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_menu:MenuPanel;
	private var m_groups:Array;
	private var m_builds:Object;
	
	public function BuildSelector(parent:MovieClip, name:String, groups:Array, builds:Object) 
	{
		m_parent = parent;
		m_name = name;
		m_groups = groups;
		m_builds = builds;
		
		m_frame = parent.createEmptyMovieClip(name + "Frame", parent.getNextHighestDepth());
		BuildMenu();
	}
	
	public function Show(x:Number, y:Number):Void
	{
		var pt:Object = m_menu.GetDimensions(x, y, true, 0, 0, Stage.width, Stage.height);
		m_menu.Rebuild();
		m_menu.RebuildSubmenus();
		m_menu.SetVisible(true);
	}
	
	public function GetVisible():Boolean
	{
		return m_menu.GetVisible();
	}
	
	public function Unload()
	{
		m_frame._visible = false;
		m_frame.removeMovieClip();
	}
	
	private function BuildMenu():Void
	{
		m_menu = new MenuPanel(m_frame, "Builds", 4);

		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null)
			{
				var colours:Array = BuildGroup.GetColourArray(thisGroup.GetColourName());
				var subMenu:MenuPanel = BuildSubMenu(thisGroup.GetID(), colours);
				if (subMenu != null)
				{
					m_menu.AddSubMenu(thisGroup.GetName(), subMenu, colours[0], colours[1]);
				}
			}
		}
		
		m_menu.SetVisible(false);
	}
	
	private function BuildSubMenu(groupID:String, colours:Array):MenuPanel
	{
		var subMenu:MenuPanel = null;
		var sortedBuilds:Array = Build.GetOrderedBuilds(groupID, m_builds);
		
		if (sortedBuilds.length > 0)
		{
			subMenu = new MenuPanel(m_frame, m_name + groupID, 4);
			for (var indx:Number = 0; indx < sortedBuilds.length; ++indx)
			{
				var thisBuild:Build = sortedBuilds[indx];
				if (thisBuild != null && thisBuild.GetGroup() == groupID)
				{
					subMenu.AddItem(thisBuild.GetName(), Proxy.create(this, BuildCallback, thisBuild.GetID()), colours[0], colours[1]);
				}
			}
		}
		
		return subMenu;
	}
	
	private function BuildCallback(buildID:String):Void
	{
		var thisBuild:Build = m_builds[buildID];
		if (thisBuild != null)
		{
			thisBuild.Apply();
		}
		
		m_menu.SetVisible(false);
	}
}