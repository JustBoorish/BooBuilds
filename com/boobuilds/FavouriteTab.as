import com.boobuilds.EditBuildDialog;
import com.boobuilds.EditFavouriteDialog;
import com.boobuilds.Favourite;
import com.boobuilds.FavouriteBar;
import com.boobuilds.Settings;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Checkbox;
import com.boobuildscommon.Colours;
import com.boobuildscommon.ComboBox;
import com.boobuildscommon.Graphics;
import com.boobuildscommon.ITabPane;
import com.boobuildscommon.Proxy;
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
class com.boobuilds.FavouriteTab implements ITabPane
{
	private var m_parent:MovieClip;
	private var m_addonMC:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_favourites:Array;
	private var m_settings:Object;
	private var m_builds:Object;
	private var m_buildGroups:Array;
	private var m_quickBuilds:Object;
	private var m_quickBuildGroups:Array;
	private var m_outfits:Object;
	private var m_outfitGroups:Array;
	private var m_dragFavourites:Function;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_favouriteBar1:FavouriteBar;
	private var m_favouriteBar2:FavouriteBar;
	private var m_bar1Check:Checkbox;
	private var m_bar2Check:Checkbox;
	private var m_bar1Frame:MovieClip;
	private var m_bar2Frame:MovieClip;
	private var m_editFavouriteDialog:EditFavouriteDialog;
	private var m_iconsPerRow1Combo:ComboBox;
	private var m_iconsPerRow2Combo:ComboBox;
	private var m_iconSize1Combo:ComboBox;
	private var m_iconSize2Combo:ComboBox;
	private var m_barX:Number;
	private var m_bar1Y:Number;
	private var m_bar2Y:Number;
	private var m_currentBar:Array;
	private var m_currentIndx:Number;
	
	public function FavouriteTab(title:String, settings:Object, favourites:Array, buildGroups:Array, builds:Object, outfitGroups:Array, outfits:Object, quickBuildGroups:Array, quickBuilds:Object, dragFavourites:Function)
	{
		m_name = title;
		m_settings = settings;
		m_favourites = favourites;
		m_buildGroups = buildGroups;
		m_builds = builds;
		m_outfitGroups = outfitGroups;
		m_outfits = outfits;
		m_quickBuilds = quickBuilds;
		m_quickBuildGroups = quickBuildGroups;
		m_dragFavourites = dragFavourites;
		m_parent = null;
	}
	
	public function CreatePane(addonMC:MovieClip, parent:MovieClip, name:String, x:Number, y:Number, width:Number, height:Number):Void
	{
		m_addonMC = addonMC;
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(name + "ConfigWindow", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_maxHeight = height;
		
		DrawFrame();
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true && m_settings != null)
		{
			InitialiseSettings();
		}

		if (visible == true)
		{
			RedrawBars();
		}
		
		m_frame._visible = visible;
	}
	
	public function Save():Void
	{
		if (m_settings != null)
		{
			Settings.SetFavouriteBarEnabled(m_settings, 0, m_bar1Check.IsChecked());
			Settings.SetFavouriteBarEnabled(m_settings, 1, m_bar2Check.IsChecked());
			Settings.SetFavouriteIconsPerRow(m_settings, 0, Number(m_iconsPerRow1Combo.GetSelectedEntry()));
			Settings.SetFavouriteIconsPerRow(m_settings, 1, Number(m_iconsPerRow2Combo.GetSelectedEntry()));
			Settings.SetFavouriteIconSize(m_settings, 0, Number(m_iconSize1Combo.GetSelectedEntry()));
			Settings.SetFavouriteIconSize(m_settings, 1, Number(m_iconSize2Combo.GetSelectedEntry()));
			ApplyOptions(m_settings);
		}
	}
	
	public static function ApplyOptions(settings:Object):Void
	{
		if (settings != null)
		{
			/*
			if (settings[INVENTORY_THROTTLE] != null)
			{
				InventoryThrottle.SetInventoryThrottleMode(settings[INVENTORY_THROTTLE]);
			}
			
			if (settings[DISMOUNT_PRELOAD] != null)
			{
				Build.SetDismountBeforeBuild(settings[DISMOUNT_PRELOAD] == 1);
			}
			
			if (applyOverride != null)
			{
				applyOverride(Settings.GetOverrideKey(settings));
			}
			*/
		}
	}
	
	public function StartDrag():Void
	{
	}
	
	public function StopDrag():Void
	{
	}
	
	private function DrawFrame():Void
	{
		var largeTextFormat:TextFormat = Graphics.GetLargeBoldTextFormat();
		var textFormat:TextFormat = Graphics.GetTextFormat();
		var iconsPerRowNames = [ "1", "2", "3", "4", "6", "12" ];
		var iconSizeNames = [ "16", "18", "24", "32", "40", "48" ];

		var favourites:Array = new Array();
		for (var indx:Number = 0; indx < 12; ++indx)
		{
			favourites.push(null);
		}
		
		var y:Number = 20;
		var text:String = "Favourite Bar 1";
		var extents:Object = Text.GetTextExtent(text, largeTextFormat, m_frame);
		Graphics.DrawText("BarTitle1", m_frame, text, largeTextFormat, 25, y, extents.width, extents.height);

		y += 30;
		var checkSize:Number = 10;
		text = "Enable favourite bar";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		m_bar1Check = new Checkbox("Bar1Check", m_frame, 25, y + extents.height / 2 - checkSize / 2, checkSize, Delegate.create(this, Enable1Changed), false);		
		Graphics.DrawText("EnableLabel1", m_frame, text, textFormat, 25 + checkSize + 5, y, extents.width, extents.height);
		
		m_bar1Frame = m_frame.createEmptyMovieClip("Bar1Frame", m_frame.getNextHighestDepth());
		
		var spacing:Number = 35;
		y += spacing;
		m_barX = 7;
		m_bar1Y = y;
		
		y += spacing;
		text = "Icons per row";
		extents = Text.GetTextExtent(text, textFormat, m_bar1Frame);
		Graphics.DrawText("IconsPerRowLabel1", m_bar1Frame, text, textFormat, 25, y, extents.width, extents.height);
		m_iconsPerRow1Combo = new ComboBox(m_bar1Frame, "IconsPerRowCombo1", m_addonMC, 35 + extents.width, y - 5, null, null, iconsPerRowNames.length, "12", iconsPerRowNames);
		
		y += spacing;
		text = "Icon Size";
		extents = Text.GetTextExtent(text, textFormat, m_bar1Frame);
		Graphics.DrawText("IconSizeLabel1", m_bar1Frame, text, textFormat, 25, y, extents.width, extents.height);
		m_iconSize1Combo = new ComboBox(m_bar1Frame, "IconSizeCombo1", m_addonMC, 35 + extents.width, y - 5, null, null, iconSizeNames.length, "18", iconSizeNames);
		
		y += spacing;
		text = "Drag Bar 1";
		extents = Text.GetTextExtent(text, textFormat, m_bar1Frame);
		Graphics.DrawButton("Bar1Drag", m_bar1Frame, text, textFormat, 25, y, extents.width, null, Delegate.create(this, Bar1Drag));
		
		y += spacing;
		text = "Favourite Bar 2";
		extents = Text.GetTextExtent(text, largeTextFormat, m_frame);
		Graphics.DrawText("BarTitle2", m_frame, text, largeTextFormat, 25, y, extents.width, extents.height);
		
		textFormat = Graphics.GetTextFormat();
		text = "Enable favourite bar";
		extents = Text.GetTextExtent(text, textFormat, m_frame);
		y += 30;
		m_bar2Check = new Checkbox("Bar2Check", m_frame, 25, y + extents.height / 2 - checkSize / 2, checkSize, Delegate.create(this, Enable2Changed), false);		
		Graphics.DrawText("EnableLabel2", m_frame, text, textFormat, 25 + checkSize + 5, y, extents.width, extents.height);
		
		m_bar2Frame = m_frame.createEmptyMovieClip("Bar2Frame", m_frame.getNextHighestDepth());
		
		y += spacing;
		m_bar2Y = y;
		
		y += spacing;
		text = "Icons per row";
		extents = Text.GetTextExtent(text, textFormat, m_bar2Frame);
		Graphics.DrawText("IconsPerRowLabel2", m_bar2Frame, text, textFormat, 25, y, extents.width, extents.height);
		m_iconsPerRow2Combo = new ComboBox(m_bar2Frame, "IconsPerRowCombo2", m_addonMC, 35 + extents.width, y - 5, null, null, iconsPerRowNames.length, "12", iconsPerRowNames);
		
		y += spacing;
		text = "Icon Size";
		extents = Text.GetTextExtent(text, textFormat, m_bar2Frame);
		Graphics.DrawText("IconSizeLabel2", m_bar2Frame, text, textFormat, 25, y, extents.width, extents.height);
		m_iconSize2Combo = new ComboBox(m_bar2Frame, "IconSizeCombo2", m_addonMC, 35 + extents.width, y - 5, null, null, iconSizeNames.length, "18", iconSizeNames);
		
		y += spacing;
		text = "Drag Bar 2";
		extents = Text.GetTextExtent(text, textFormat, m_bar2Frame);
		Graphics.DrawButton("Bar2Drag", m_bar2Frame, text, textFormat, 25, y, extents.width, null, Delegate.create(this, Bar2Drag));
		
		InitialiseSettings();
	}
	
	private function InitialiseSettings():Void
	{
		m_bar1Check.SetChecked(Settings.GetFavouriteBarEnabled(m_settings, 0));
		m_bar2Check.SetChecked(Settings.GetFavouriteBarEnabled(m_settings, 1));
		
		Enable1Changed(Settings.GetFavouriteBarEnabled(m_settings, 0));
		Enable2Changed(Settings.GetFavouriteBarEnabled(m_settings, 1));
		
		m_iconsPerRow1Combo.SetSelectedEntry(String(Settings.GetFavouriteIconsPerRow(m_settings, 0)));
		m_iconsPerRow2Combo.SetSelectedEntry(String(Settings.GetFavouriteIconsPerRow(m_settings, 1)));
		m_iconSize1Combo.SetSelectedEntry(String(Settings.GetFavouriteIconSize(m_settings, 0)));
		m_iconSize2Combo.SetSelectedEntry(String(Settings.GetFavouriteIconSize(m_settings, 1)));
	}
	
	private function Enable1Changed(newValue:Boolean):Void
	{
		m_favouriteBar1.SetVisible(newValue);
		m_bar1Frame._visible = newValue;
		m_iconsPerRow1Combo.SetVisible(newValue);
		m_iconSize1Combo.SetVisible(newValue);
	}
	
	private function Enable2Changed(newValue:Boolean):Void
	{
		m_favouriteBar2.SetVisible(newValue);
		m_bar2Frame._visible = newValue;
		m_iconsPerRow2Combo.SetVisible(newValue);
		m_iconSize2Combo.SetVisible(newValue);
	}
	
	private function Bar1Drag():Void
	{
		if (m_dragFavourites != null)
		{
			m_dragFavourites(0);
		}
	}
	
	private function Bar2Drag():Void
	{
		if (m_dragFavourites != null)
		{
			m_dragFavourites(1);
		}
	}
	
	private function RedrawBars():Void
	{
		if (m_favouriteBar1 != null)
		{
			m_favouriteBar1.Unload();
		}
		
		if (m_favouriteBar2 != null)
		{
			m_favouriteBar2.Unload();
		}
		
		m_favouriteBar1 = new FavouriteBar("Bar1", m_bar1Frame, m_barX, m_bar1Y, 20, 12, 12, true, m_favourites[0], Proxy.createTwoArgs(this, EditFavourite, 0));
		m_favouriteBar2 = new FavouriteBar("Bar2", m_bar2Frame, m_barX, m_bar2Y, 20, 12, 12, true, m_favourites[1], Proxy.createTwoArgs(this, EditFavourite, 1));			
	}
	
	private function EditFavourite(indx:Number, inFavourite:Favourite, barNumber:Number):Void
	{
		var favourite:Favourite = inFavourite;
		if (favourite == null)
		{
			favourite = new Favourite(Favourite.BUILD, null, null, Colours.GetDefaultColourName());
		}
		
		if (m_editFavouriteDialog != null)
		{
			m_editFavouriteDialog.Unload();
		}
		
		m_currentBar = m_favourites[barNumber];
		m_currentIndx = indx;

		m_editFavouriteDialog = new EditFavouriteDialog("EditFavourite", m_frame, m_addonMC, m_maxWidth, m_maxHeight, favourite.GetType(), favourite.GetID(), favourite.GetIconPath(), favourite.GetColour(), m_builds, m_buildGroups, m_outfits, m_outfitGroups, m_quickBuilds, m_quickBuildGroups);
		m_editFavouriteDialog.Show(Delegate.create(this, EditFavouriteCB));
	}
	
	private function EditFavouriteCB(success:Boolean, type:String, id:String, iconPath:String, colour:String, buildName:String):Void
	{
		m_editFavouriteDialog.Hide();
		if (m_currentBar != null)
		{
			if (success == true)
			{
				if (type == null)
				{
					m_currentBar[m_currentIndx] = null;
				}
				else
				{
					var thisFavourite:Favourite = new Favourite(type, id, iconPath, colour);
					thisFavourite.SetName(buildName);
					m_currentBar[m_currentIndx] = thisFavourite;
				}
				
				RedrawBars();
			}
		}
	}
}