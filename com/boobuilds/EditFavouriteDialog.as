import com.boobuilds.Build;
import com.boobuilds.BuildSelector;
import com.boobuilds.EditIconDialog;
import com.boobuilds.Favourite;
import com.boobuilds.Outfit;
import com.boobuilds.OutfitSelector;
import com.boobuildscommon.Colours;
import com.boobuildscommon.ComboBox;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.IconButton;
import com.boobuildscommon.MenuPanel;
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
class com.boobuilds.EditFavouriteDialog
{
	private static var NONE:String = "None";
	
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_addonMC:MovieClip;
	private var m_subFrame:MovieClip;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_quickBuilds:Object;
	private var m_quickBuildGroups:Array;
	private var m_callback:Function;
	private var m_type:String;
	private var m_id:String;
	private var m_iconPath:String;
	private var m_colour:String;
	private var m_buildSelector:BuildSelector;
	private var m_outfitSelector:OutfitSelector;
	private var m_modalBase:ModalBase;
	private var m_typeCombo:ComboBox;
	private var m_idLabel:TextField;
	private var m_idX:Number;
	private var m_idY:Number;
	private var m_idButton:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_menu:MenuPanel;
	private var m_colourX:Number;
	private var m_colourY:Number;
	private var m_typeComboX:Number;
	private var m_typeComboY:Number;
	private var m_editIconDialog:EditIconDialog;
	private var m_iconButton:IconButton;
	private var m_frameWidth:Number;
	private var m_frameHeight:Number;
	private var m_iconPaths:Array;
	
	public function EditFavouriteDialog(name:String, parent:MovieClip, addonMC:MovieClip, frameWidth:Number, frameHeight:Number, type:String, id:String, iconPath:String, colour:String, builds:Object, buildGroups:Array, outfits:Object, outfitGroups:Array, quickBuilds:Object, quickBuildGroups:Array) 
	{
		m_name = name;
		m_parent = parent;
		m_addonMC = addonMC;
		m_builds = builds;
		m_buildGroups = buildGroups;
		m_outfits = outfits;
		m_outfitGroups = outfitGroups;
		m_quickBuilds = quickBuilds;
		m_quickBuildGroups = quickBuildGroups;
		m_type = type;
		m_id = id;
		m_iconPath = iconPath;
		m_colour = colour;
		m_frameWidth = frameWidth;
		m_frameHeight = frameHeight;
		
		m_iconPaths = [ "BooBuildsTank", "BooBuildsDPS", "BooBuildsHeals", "BooBuildsBlood", "BooBuildsChaos", "BooBuildsEle", "BooBuildsFist", "BooBuildsHammer", "BooBuildsPistol",
		"BooBuildsRifle", "BooBuildsShotgun", "BooBuildsSword", "BooBuildsNoSign", "BooBuildsHelp", "BooBuildsWarning", "BooBuildsOne", "BooBuildsTwo", "BooBuildsThree", "BooBuildsFour", 
		"BooBuildsFive", "BooBuildsSix", "BooBuildsSeven", "BooBuildsEight", "BooBuildsNine", "BooBuildsTen", "BooBuildsEleven", "BooBuildsTwelve" ];

		
		if (m_type == null)
		{
			m_type = NONE;
		}
		
		m_modalBase = new ModalBase(name, parent, Delegate.create(this, DrawControls), frameWidth, frameHeight, frameWidth * 0.85, frameHeight * 0.8);
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
		ClearSelectors();
		m_modalBase.Hide();
	}
		
	public function Unload():Void
	{
		Hide();
		m_typeCombo.Unload();
		m_menu.Unload();
		m_modalBase.Unload();
	}
	
	private function ClearSelectors():Void
	{
		if (m_buildSelector != null)
		{
			m_buildSelector.Unload();
			m_buildSelector = null;
		}
		
		if (m_outfitSelector != null)
		{
			m_outfitSelector.Unload();
			m_outfitSelector = null;
		}
	}
	
	private function DrawControls(modalMC:MovieClip, textFormat:TextFormat):Void
	{
		m_textFormat = textFormat;
		var x:Number = 25;
		var y:Number = 30;
		
		if (m_typeCombo != null)
		{
			m_typeCombo.Unload();
		}
		
		if (m_idLabel != null)
		{
			m_idLabel.removeTextField();
		}
		
		if (m_idButton != null)
		{
			m_idButton.removeMovieClip();
		}

		if (m_menu != null)
		{
			m_menu.Unload();
		}

		if (m_subFrame != null)
		{
			m_subFrame.removeMovieClip();
		}
		
		var text:String = "Type";
		var extents:Object = Text.GetTextExtent(text, textFormat, modalMC);
		Graphics.DrawText("TypeLabel", modalMC, text, textFormat, x, y, extents.width, extents.height);
		m_typeComboX = x + extents.width + 10;
		m_typeComboY = y - 4;
		m_typeCombo = new ComboBox(modalMC, "TypeCombo", m_addonMC, m_typeComboX, m_typeComboY, null, null, 3, m_type, [ NONE, Favourite.BUILD, Favourite.OUTFIT, Favourite.QUICK ]);
		m_typeCombo.SetChangedCallback(Delegate.create(this, TypeChanged));
		
		m_subFrame = modalMC.createEmptyMovieClip("SubFrame", modalMC.getNextHighestDepth());
		
		y += 50;
		m_idX = x;
		m_idY = y;
		text = m_type;
		if (m_typeCombo != null)
		{
			text = m_typeCombo.GetSelectedEntry();
		}
		
		extents = Text.GetTextExtent(text, m_textFormat, m_subFrame);
		m_idLabel = Graphics.DrawText("Line1", m_subFrame, text, m_textFormat, m_idX, m_idY, extents.width, extents.height);
		text = Favourite.OUTFIT;
		extents = Text.GetTextExtent(text, m_textFormat, m_subFrame);
		var xOffset:Number = extents.width;
		text = GetIDName();
		extents = Text.GetTextExtent(text, m_textFormat, m_subFrame);
		m_idButton = Graphics.DrawButton("IDButton", m_subFrame, text, m_textFormat, m_idX + xOffset + 10, m_idY - 4, extents.width, null, Delegate.create(this, IDButtonPressed));
		
		y += 40;
		m_colourX = x;
		m_colourY = y;
		
		y += 45;
		text = "Icon";
		extents = Text.GetTextExtent(text, textFormat, m_subFrame);
		Graphics.DrawText("IconLabel", m_subFrame, text, textFormat, x, y, extents.width, extents.height);
		m_iconButton = new IconButton("IconButton", m_subFrame, x + extents.width + 10, y - 4, 32, 32, null, null, Delegate.create(this, IconPressed), IconButton.PLUS, IconButton.NONE, null);
		m_iconButton.SetIcon(null, m_iconPath, 0, false, null, null, null);
		
		BuildMenu();
		
		if (m_type == NONE)
		{
			m_subFrame._visible = false;
		}
		else
		{
			m_subFrame._visible = true;
		}
	}
	
	private function RedrawControls():Void
	{
		DrawControls(m_modalBase.GetMovieClip(), m_textFormat);
	}

	private function TypeChanged(newValue:String):Void
	{
		if (newValue != m_type)
		{
			m_type = newValue;
			m_id = null;
			RedrawControls();
		}
	}
	
	private function IDButtonPressed():Void
	{
		ClearSelectors();
		
		var pt:Object = new Object();
		pt.x = m_idButton._width / 2;
		pt.y = m_idButton._height / 2;
		m_idButton.localToGlobal(pt);
		m_addonMC.globalToLocal(pt);
		
		if (m_type == Favourite.BUILD)
		{
			m_buildSelector = new BuildSelector(m_addonMC, "FavBuildSelector", m_buildGroups, m_builds, Delegate.create(this, BuildSelected));
			m_buildSelector.Show(pt.x, pt.y, pt.y);
		}
		else if (m_type == Favourite.OUTFIT)
		{
			m_outfitSelector = new OutfitSelector(m_addonMC, "FavOutfitSelector", m_outfitGroups, m_outfits, Delegate.create(this, OutfitSelected));
			m_outfitSelector.Show(pt.x, pt.y, pt.y);
		}
		else if (m_type == Favourite.QUICK)
		{
			m_buildSelector = new BuildSelector(m_addonMC, "FavBuildSelector", m_quickBuildGroups, m_quickBuilds, Delegate.create(this, QuickBuildSelected));
			m_buildSelector.Show(pt.x, pt.y, pt.y);
		}
	}
	
	private function BuildSelected(newValue:Build):Void
	{
		m_id = null;
		if (newValue != null)
		{
			m_id = newValue.GetID();
		}
		
		RedrawControls();
	}
	
	private function OutfitSelected(newValue:Outfit):Void
	{
		m_id = null;
		if (newValue != null)
		{
			m_id = newValue.GetID();
		}
		
		RedrawControls();
	}
	
	private function QuickBuildSelected(newValue:Build):Void
	{
		m_id = null;
		if (newValue != null)
		{
			m_id = newValue.GetID();
		}
		
		RedrawControls();
	}
	
	private function GetIDName():String
	{
		var ret:String = null;
		if (m_id != null)
		{
			if (m_type == Favourite.BUILD)
			{
				var thisBuild:Build = m_builds[m_id];
				if (thisBuild != null)
				{
					ret = thisBuild.GetName();
				}
			}
			else if (m_type == Favourite.OUTFIT)
			{
				var thisOutfit:Outfit = m_outfits[m_id];
				if (thisOutfit != null)
				{
					ret = thisOutfit.GetName();
				}
			}
			else if (m_type == Favourite.BUILD)
			{
				var thisBuild:Build = m_quickBuilds[m_id];
				if (thisBuild != null)
				{
					ret = thisBuild.GetName();
				}
			}
		}
		
		if (ret == null)
		{
			ret = "None";
		}
		
		return ret;
	}
	
	private function BuildMenu():Void
	{
		var colours:Array = Colours.GetColourArray(m_colour);
		m_menu = new MenuPanel(m_subFrame, "Background Colour", 4, colours[0], colours[1]);
		var subMenu:MenuPanel = new MenuPanel(m_subFrame, "Background Colour", 4, colours[0], colours[1]);
		var colourArray:Array = Colours.GetColourNames();
		for (var indx:Number = 0; indx < colourArray.length; ++indx)
		{
			AddItem(subMenu, colourArray[indx]);
		}
		m_menu.AddSubMenu("Background Colour", subMenu, colours[0], colours[1]);
		
		var pt:Object = m_menu.GetDimensions(m_colourX, m_colourY, true, 0, 0, m_subFrame.width, m_subFrame.height);
		m_menu.Rebuild();
		m_menu.RebuildSubmenus();
		m_menu.SetVisible(true);
	}
	
	private function AddItem(subMenu:MenuPanel, colourName:String):Void
	{
		var colours:Array = Colours.GetColourArray(colourName);
		subMenu.AddItem(colourName, Delegate.create(this, ColourChanged), colours[0], colours[1]);
	}
	
	private function ColourChanged(colourName:String):Void
	{
		m_colour = colourName;
		setTimeout(Delegate.create(this, RedrawControls), 10);
	}
	
	private function IconPressed():Void
	{
		if (m_editIconDialog != null)
		{
			m_editIconDialog.Unload();
		}
		
		m_editIconDialog = new EditIconDialog("EditIcon", m_parent, m_addonMC, m_frameWidth, m_frameHeight, m_iconPaths);
		m_editIconDialog.Show(Delegate.create(this, EditIconCB));
	}
	
	private function EditIconCB(iconPath:String):Void
	{
		m_iconPath = iconPath;
		RedrawControls();
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
				var thisType:String = m_type;
				if (thisType == NONE)
				{
					thisType = null;
				}
				
				m_callback(true, m_type, m_id, m_iconPath, m_colour, GetIDName());
			}
			else
			{
				m_callback(false, null, null, null, null, null);
			}
		}
	}
}
