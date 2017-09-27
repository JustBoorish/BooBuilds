import com.boobuilds.BuildGroup;
import com.boobuilds.Outfit;
import com.boobuildscommon.Colours;
import com.boobuildscommon.MenuPanel;
import com.boobuildscommon.Proxy;

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
class com.boobuilds.OutfitSelector
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_menu:MenuPanel;
	private var m_groups:Array;
	private var m_outfits:Object;
	private var m_callback:Function;
	
	public function OutfitSelector(parent:MovieClip, name:String, groups:Array, outfits:Object, callback:Function) 
	{
		m_parent = parent;
		m_name = name;
		m_groups = groups;
		m_outfits = outfits;
		m_callback = callback;
		
		m_frame = parent.createEmptyMovieClip(name + "Frame", parent.getNextHighestDepth());
		OutfitMenu();
	}
	
	public function Show(x:Number, bottomY:Number, topY:Number):Void
	{
		var pt:Object = m_menu.GetDimensions(x, bottomY, true, 0, 0, Stage.width, Stage.height);
		if (pt.maxY > Stage.height)
		{
			m_menu.GetDimensions(x, topY - (pt.maxY - pt.y) - 1, true, 0, 0, Stage.width, Stage.height);
		}
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
	
	private function OutfitMenu():Void
	{
		m_menu = new MenuPanel(m_frame, "Outfits", 4);
		var singleGroup:Boolean = IsSingleGroup();

		for (var indx:Number = 0; indx < m_groups.length; ++indx)
		{
			var thisGroup:BuildGroup = m_groups[indx];
			if (thisGroup != null)
			{
				var colours:Array = Colours.GetColourArray(thisGroup.GetColourName());
				if (singleGroup == true)
				{
					OutfitSingleMenu(thisGroup.GetID(), colours, m_menu);
				}
				else
				{
					var subMenu:MenuPanel = OutfitSubMenu(thisGroup.GetID(), colours);
					if (subMenu != null)
					{
						m_menu.AddSubMenu(thisGroup.GetName(), subMenu, colours[0], colours[1]);
					}
				}
			}
		}
		
		m_menu.SetVisible(false);
	}
	
	private function OutfitSubMenu(groupID:String, colours:Array):MenuPanel
	{
		var subMenu:MenuPanel = null;
		var sortedOutfits:Array = Outfit.GetOrderedOutfits(groupID, m_outfits);
		
		if (sortedOutfits.length > 0)
		{
			subMenu = new MenuPanel(m_frame, m_name + groupID, 4);
			for (var indx:Number = 0; indx < sortedOutfits.length; ++indx)
			{
				var thisOutfit:Outfit = sortedOutfits[indx];
				if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
				{
					subMenu.AddItem(thisOutfit.GetName(), Proxy.create(this, OutfitCallback, thisOutfit.GetID()), colours[0], colours[1]);
				}
			}
		}
		
		return subMenu;
	}
	
	private function OutfitSingleMenu(groupID:String, colours:Array, menu:MenuPanel):Void
	{
		var sortedOutfits:Array = Outfit.GetOrderedOutfits(groupID, m_outfits);
		
		if (sortedOutfits.length > 0)
		{
			for (var indx:Number = 0; indx < sortedOutfits.length; ++indx)
			{
				var thisOutfit:Outfit = sortedOutfits[indx];
				if (thisOutfit != null && thisOutfit.GetGroup() == groupID)
				{
					menu.AddItem(thisOutfit.GetName(), Proxy.create(this, OutfitCallback, thisOutfit.GetID()), colours[0], colours[1]);
				}
			}
		}
	}
	
	private function OutfitCallback(outfitID:String):Void
	{		
		m_menu.SetVisible(false);
		
		var thisOutfit:Outfit = m_outfits[outfitID];
		if (thisOutfit != null && m_callback != null)
		{
			m_callback(thisOutfit);
		}
	}
	
	private function IsSingleGroup():Boolean
	{
		var groupID:String = null;
		for (var indx:String in m_outfits)
		{
			var thisOutfit:Outfit = m_outfits[indx];
			if (groupID == null)
			{
				groupID = thisOutfit.GetGroup();
			}
			else
			{
				if (groupID != thisOutfit.GetGroup())
				{
					return false;
				}
			}
		}
		
		return true;
	}
}