import caurina.transitions.Tweener;
import com.boobuilds.Build;
import com.boocommon.Checkbox;
import com.boocommon.DebugWindow;
import com.boobuilds.Controller;
import com.boobuilds.GearItem;
import com.boobuilds.GearSelector;
import com.boocommon.IconButton;
import com.boobuilds.Localisation;
import com.boobuilds.SkillMenu;
import com.boocommon.TabStrip;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Text;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
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
class com.boobuilds.BuildWindow
{
	private static var DefaultCostumeIcons:Array = ["BooDecksHat", "BooDecksGlasses", "", "BooDecksCoat", "BooDecksShirt", "", "BooDecksTrousers", "", "BooDecksUniform"];
	private static var CHECKBOX:String = "Checkbox";
	private static var ICONS:String = "Icons";
	
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_frame:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_buttonWidth:Number;
	private var m_buttonHeight:Number;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_titleHeight:Number;
	private var m_icons:Object;
	private var m_gearSelector:GearSelector;
	
	public function BuildWindow(name:String, parent:MovieClip) 
	{
		m_name = name;
		m_parent = parent;
		m_frame = m_parent.createEmptyMovieClip(name, m_parent.getNextHighestDepth());
		m_icons = new Object();
		m_gearSelector = null;

		m_textFormat = new TextFormat();
		m_textFormat.align = "left";
		m_textFormat.font = "tahoma";
		m_textFormat.size = 14;
		m_textFormat.color = 0xFFFFFF;
		m_textFormat.bold = false;

		m_buttonWidth = 32;
		m_buttonHeight = m_buttonWidth;
		m_margin = 6;
		m_titleHeight = 30;
		var maxRows:Number = 4;
		m_maxWidth = m_buttonWidth * (Build.MAX_GEAR + 1) + (Build.MAX_GEAR + 3) * m_margin + 30;
		m_maxHeight = m_buttonHeight * maxRows + (maxRows + 1) * m_margin + m_titleHeight;
		DrawFrame();
		
		CreateIcons(Build.SKILL_PREFIX, Build.MAX_SKILLS, m_titleHeight + m_margin);
		var row:Number = 1;
		CreateIcons(Build.PASSIVE_PREFIX, Build.MAX_PASSIVES, m_titleHeight + m_margin * (row + 1) + m_buttonHeight * row);
		++row;
		CreateIcons(Build.WEAPON_PREFIX, Build.MAX_WEAPONS, m_titleHeight + m_margin * (row + 1) + m_buttonHeight * row);
		++row;
		CreateIcons(Build.GEAR_PREFIX, Build.MAX_GEAR, m_titleHeight + m_margin * (row + 1) + m_buttonHeight * row);
		//++row;
		//CreateIcons(Build.COSTUME_PREFIX, Build.MAX_COSTUME - 1, m_titleHeight + m_margin * (row + 1) + m_buttonHeight * row);
	}

	public function SetCenterCoords(x:Number, y:Number):Void
	{
		m_frame._x = x - m_frame._width / 2;
		m_frame._y = y - m_frame._height / 2;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		m_frame._visible = visible;
		if (m_gearSelector != null)
		{
			m_gearSelector.Unload();
			m_gearSelector = null;
		}
	}
	
	public function Unload():Void
	{
		SetVisible(false);
		m_frame.removeMovieClip();
	}
	
	public function SetBuild(build:Build):Void
	{
		var icons:Array = m_icons[GetIconName(Build.SKILL_PREFIX)];
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_SKILLS; ++i)
			{
				SetSkillIcon(build.GetSkill(i), icons[i], i == Build.MAX_SKILLS - 1);
			}
		}
		
		icons = m_icons[GetIconName(Build.PASSIVE_PREFIX)];
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_PASSIVES; ++i)
			{
				SetSkillIcon(build.GetPassive(i), icons[i], false);
			}
		}
		
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);

		icons = m_icons[GetIconName(Build.GEAR_PREFIX)];
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_GEAR; ++i)
			{
				SetGearIcon(build.GetGear(i), charInvId, charInv, bagInvId, bagInv, icons[i], null);
			}
		}
		
		icons = m_icons[GetIconName(Build.WEAPON_PREFIX)];
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_WEAPONS; ++i)
			{
				SetGearIcon(build.GetWeapon(i), charInvId, charInv, bagInvId, bagInv, icons[i], null);
			}
		}
	}
	
	private function SetSkillIcon(featId:Number, button:IconButton):Void
	{
		var feat:FeatData = null;
		if (featId != null)
		{
			feat = FeatInterface.m_FeatList[String(featId)];
		}
		
		if (feat != null)
		{
			var colors:Object = Colors.GetColorlineColors(feat.m_ColorLine);
			var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip(feat.m_Spell);
			var isElite:Boolean = false;
			if (feat.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility || feat.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
			{
				isElite = true;
			}
			
			button.SetIcon([colors.highlight, colors.background], Utils.CreateResourceString(feat.m_IconID), 0, isElite, null, tooltipData, feat);		
		}
		else
		{
			button.DeleteIcon();
		}
	}
	
	private function SetGearIcon(gear:GearItem, charInvId:ID32, charInv:Inventory, bagInvId:ID32, bagInv:Inventory, button:IconButton, costumeIcon:String):Void
	{
		var item:InventoryItem = null;
		var indx:Number = -1;
		var invId:ID32 = null;
		
		if (gear != null)
		{
			var obj:Object = GearItem.FindExactGearItem(charInv, gear, false);
			if (obj != null)
			{
				item = charInv.GetItemAt(obj.indx);
				invId = charInvId;
			}
			else
			{
				obj = GearItem.FindExactGearItem(bagInv, gear, false);
				if (obj != null)
				{
					item = bagInv.GetItemAt(obj.indx);
					invId = bagInvId;
				}
			}
		}

		if (item == null && gear != null)
		{
			DebugWindow.Log(DebugWindow.Info, "Not found: " + gear.toString());
		}
		
		if (item != null)
		{
			DebugWindow.Log(DebugWindow.Info, gear.toString());
			var colors:Object = Colors.GetColorlineColors(item.m_ColorLine);
			var frameColor:Number;
			if (costumeIcon != null)
			{
				frameColor = Colors.e_ColorWhite;
			}
			else
			{
				frameColor = Colors.GetItemRarityColor(item.m_Rarity);
			}
			
			var frameColors:Array = [frameColor, frameColor];
			
			var tooltipData:TooltipData;
			if (item.m_ACGItem != undefined)
			{
				tooltipData = TooltipDataProvider.GetACGItemTooltip(item.m_ACGItem);
			}
			else
			{
				tooltipData = TooltipDataProvider.GetInventoryItemTooltip(invId, indx);
			}
			
			if (item.m_Icon.m_Instance == 0)
			{
				button.SetIcon([colors.highlight, colors.background], costumeIcon, item.m_Pips, false, frameColors, tooltipData, gear, true);
			}
			else
			{
				button.SetIcon([colors.highlight, colors.background], Utils.CreateResourceString(item.m_Icon), item.m_Pips, false, frameColors, tooltipData, gear, false);
			}
		}
		else if (gear != null)
		{
			var iconPath:String = gear.GetIconPath();
			if (iconPath == null || iconPath.substr(iconPath.length - 2, 2) == ":0")
			{
				button.SetIcon(null, costumeIcon, 0, false, null, null, gear, true);
			}
			else
			{
				button.SetIcon(null, gear.GetIconPath(), 0, false, null, null, gear, false);
			}
		}
		else
		{
			button.SetIcon(null, costumeIcon, 0, false, null, null, null, true);
		}
	}
	
	private function CheckPressed(prefix:String):Void
	{
		var check:Checkbox = m_icons[GetCheckName(prefix)];
		if (check != null)
		{
			var enabled:Boolean = check.IsChecked();
			var icons:Array = m_icons[GetIconName(prefix)]
			if (icons != null)
			{
				for (var i:Number = 0; i < icons.length; ++i)
				{
					icons[i].SetEnabled(enabled);
				}
			}
		}
	}
	
	private function ShowSelector(x:Number, y:Number):Void
	{
		if (m_gearSelector != null)
		{
			m_frame.stopDrag();
			m_gearSelector.SetCoords(x, y);
			m_gearSelector.SetVisible(true);
		}
	}
	
	private function CreateSelector(parent:MovieClip, name:String, frameStyle:Number, items:Array, inventories:Array, selectCallback:Function, deleteCallback:Function, emptyCallback:Function)
	{
		if (m_gearSelector != null)
		{
			m_gearSelector.Unload();
			m_gearSelector = null;
		}
		
		var ret:GearSelector = new GearSelector(name, parent, frameStyle, inventories, selectCallback, deleteCallback, emptyCallback);
		for (var i:Number = 0; i < items.length; ++i)
		{
			ret.AddItem(items[i]);
		}
		
		ret.Rebuild();
		m_gearSelector = ret;
	}

	private function GearPressed(indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Chakra_7, _global.Enums.ItemEquipLocation.e_Chakra_4, _global.Enums.ItemEquipLocation.e_Chakra_5, _global.Enums.ItemEquipLocation.e_Chakra_6,
						_global.Enums.ItemEquipLocation.e_Chakra_1, _global.Enums.ItemEquipLocation.e_Chakra_2, _global.Enums.ItemEquipLocation.e_Chakra_3];

		if (indx >= 0 && indx < positions.length)
		{
			var items:Array = GearItem.GetItemList(positions[indx]);
			CreateSelector(m_frame, m_name + "GearSelector", frameStyle, items, [_global.Enums.InvType.e_Type_GC_WeaponContainer, _global.Enums.InvType.e_Type_GC_BackpackContainer]);
			ShowSelector(x, y);
		}
	}
	
	private function WeaponPressed(indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot];

		if (indx >= 0 && indx < positions.length)
		{
			var items:Array = GearItem.GetItemList(positions[indx]);
			CreateSelector(m_frame, m_name + "WeaponSelector", frameStyle, items, [_global.Enums.InvType.e_Type_GC_WeaponContainer, _global.Enums.InvType.e_Type_GC_BackpackContainer], null, null, Delegate.create(this, function() {}));
			ShowSelector(x, y);
		}
	}
	
	private function CostumePressed(indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		var positions:Array = [_global.Enums.ItemEquipLocation.e_Wear_Hat, _global.Enums.ItemEquipLocation.e_Wear_Face,
						_global.Enums.ItemEquipLocation.e_Wear_Neck, _global.Enums.ItemEquipLocation.e_Wear_Back,
						_global.Enums.ItemEquipLocation.e_Wear_Chest, _global.Enums.ItemEquipLocation.e_Wear_Hands,
						_global.Enums.ItemEquipLocation.e_Wear_Legs, _global.Enums.ItemEquipLocation.e_Wear_Feet];

		if (indx >= 0 && indx < positions.length)
		{
			var items:Array = GearItem.GetCostumeList(positions[indx], DefaultCostumeIcons[indx]);
			CreateSelector(m_frame, m_name + "CostumeSelector", frameStyle, items, [_global.Enums.InvType.e_Type_GC_WearInventory, _global.Enums.InvType.e_Type_GC_StaticInventory]);
			ShowSelector(x, y);
		}
	}
	
	private function PassivePressed(indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		
	}
	
	private function SkillPressed(indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		
	}
	
	private function IconPressed(prefix:String, indx:Number, x:Number, y:Number, frameStyle:Number):Void
	{
		DebugWindow.Log("Pressed: " + prefix + " " + indx);
		switch(prefix)
		{
			case Build.WEAPON_PREFIX:
				WeaponPressed(indx, x, y, frameStyle);
				break;
			case Build.GEAR_PREFIX:
				GearPressed(indx, x, y, frameStyle);
				break;
			case Build.PASSIVE_PREFIX:
				PassivePressed(indx, x, y, frameStyle);
				break;
			case Build.SKILL_PREFIX:
				SkillPressed(indx, x, y, frameStyle);
				break;
			default:
				break;
		}
	}
	
	private function GetCheckName(prefix:String):String
	{
		return prefix + "Check";
	}
	
	private function GetIconName(prefix:String):String
	{
		return prefix + "Icon";
	}
	
	private function CreateIcons(prefix:String, maxIcons:Number, y:Number):Void
	{
		var checkSize:Number = 13;
		var checkName:String = GetCheckName(prefix);
		var check:Checkbox = new Checkbox(checkName, m_frame, m_buttonWidth + m_margin - checkSize, y + (m_buttonHeight - checkSize) / 2, checkSize, Proxy.create(this, CheckPressed, prefix));
		check.SetChecked(true)
		check.SetVisible(false);
		m_icons[checkName] = check;
		
		var iconName:String = GetIconName(prefix);
		var icons:Array = new Array();
		var frameStyle:Number = IconButton.NONE;
		var frameColor:Number = 0x000000;
		var color1:Number = null;
		var color2:Number = null;
		switch(prefix)
		{
			case Build.PASSIVE_PREFIX:
				color1 = Colors.e_ColorPassiveSpellHighlight;
				color2 = Colors.e_ColorPassiveSpellBackground;
				frameColor = Colors.e_ColorWhite;
				break;
			case Build.GEAR_PREFIX:
				color1 = Colors.e_ColorTalismanMajorHightlight;
				color2 = Colors.e_ColorTalismanMajorBackground;
				frameColor = Colors.e_ColorBorderItemEpic;
				break;
			case Build.WEAPON_PREFIX:
				color1 = Colors.e_ColorWeaponItemsHightlight;
				color2 = Colors.e_ColorWeaponItemsBackground;
				frameColor = Colors.e_ColorBorderItemEpic;
				break;
			default:
				break;
		}
		
		for (var i:Number = 0; i < maxIcons; ++i)
		{
			var x:Number = (i + 2) * m_margin + (i + 1) * m_buttonWidth;
				
			if (prefix == Build.SKILL_PREFIX)
			{
				if (i < 2)
				{
					color1 = Colors.e_ColorMagicSpellHighlight;
					color2 = Colors.e_ColorMagicSpellBackground;
				}
				else if (i < 4)
				{
					color1 = Colors.e_ColorMeleeSpellHighlight;
					color2 = Colors.e_ColorMeleeSpellHighlight;
				}
				else if (i < 6)
				{
					color1 = Colors.e_ColorRangedSpellHighlight;
					color2 = Colors.e_ColorRangedSpellBackground;
				}
				else
				{
					color1 = Colors.e_ColorHealSpellHighlight;
					color2 = Colors.e_ColorHealSpellBackground;
				}
			}
			else if (prefix == Build.GEAR_PREFIX)
			{
				if (i < 1)
				{
					frameStyle = IconButton.TOPLEFT_CORNER | IconButton.TOPRIGHT_CORNER | IconButton.BOTTOMLEFT_CORNER | IconButton.BOTTOMRIGHT_CORNER;
				}
				else if (i < 2)
				{
					frameStyle = IconButton.TOPLEFT_CORNER;
				}
				else if (i < 3)
				{
					frameStyle = IconButton.TOPLEFT_CORNER | IconButton.TOPRIGHT_CORNER;
				}
				else if (i < 4)
				{
					frameStyle = IconButton.TOPRIGHT_CORNER;
				}
				else if (i < 5)
				{
					frameStyle = IconButton.BOTTOMLEFT_CORNER;
				}
				else if (i < 6)
				{
					frameStyle = IconButton.BOTTOMLEFT_CORNER | IconButton.BOTTOMRIGHT_CORNER;
				}
				else if (i < 7)
				{
					frameStyle = IconButton.TOPLEFT_CORNER | IconButton.BOTTOMRIGHT_CORNER;
				}
			}
			
			var button:IconButton = new IconButton(iconName + i, m_frame, x, y, m_buttonWidth, m_buttonHeight, [color1, color2], [frameColor, frameColor], Proxy.create(this, IconPressed, prefix, i, x, y, frameStyle), IconButton.NONE, frameStyle);
			button.SetEnabled(false);
			icons.push(button);
		}
		
		m_icons[iconName] = icons;
	}
	
	private static function DrawCircle(target_mc:MovieClip, radius:Number, fillColor:Number, fillAlpha:Number):Void {
		var x:Number = radius;
		var y:Number = radius;
		with (target_mc) {
			beginFill(fillColor, fillAlpha); 
			moveTo(x + radius, y);
			curveTo(radius + x, Math.tan(Math.PI / 8) * radius + y, Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
			curveTo(Math.tan(Math.PI / 8) * radius + x, radius + y, x, radius + y);
			curveTo(-Math.tan(Math.PI / 8) * radius + x, radius+ y, -Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
			curveTo(-radius + x, Math.tan(Math.PI / 8) * radius + y, -radius + x, y);
			curveTo(-radius + x, -Math.tan(Math.PI / 8) * radius + y, -Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
			curveTo(-Math.tan(Math.PI / 8) * radius + x, -radius + y, x, -radius + y);
			curveTo(Math.tan(Math.PI / 8) * radius + x, -radius + y, Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
			curveTo(radius + x, -Math.tan(Math.PI / 8) * radius + y, radius + x, y);
			endFill();
		}
	}
	
	private function DrawFrame():Void
	{
		var radius:Number = 8;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		
		var extents:Object = Text.GetTextExtent(m_name, m_textFormat, m_frame);
		
		matrix.createGradientBox(m_maxWidth, m_maxHeight, 90 / 180 * Math.PI, 0, 0);
		var configWindow:MovieClip = m_frame;
		configWindow.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		configWindow.beginFill(0x000000, 60);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((m_maxWidth-radius), 0);
		configWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		configWindow.lineTo(m_maxWidth, (m_maxHeight-radius));
		configWindow.curveTo(m_maxWidth, m_maxHeight, (m_maxWidth-radius), m_maxHeight);
		configWindow.lineTo(radius, m_maxHeight);
		configWindow.curveTo(0, m_maxHeight, 0, (m_maxHeight-radius));
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		var titleHeight:Number = extents.height + 8;
		configWindow.beginFill(0x000000, 100);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((m_maxWidth-radius), 0);
		configWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		configWindow.lineTo(m_maxWidth, titleHeight);
		configWindow.lineTo(0, titleHeight);
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		configWindow.lineStyle(0, 0xFFFFFF, 40, true, "none", "square", "round");
		var auxX:Number = (Build.MAX_SKILLS - 1) * m_buttonWidth + (Build.MAX_SKILLS - 1) * m_margin + m_margin / 2;
		configWindow.moveTo(auxX, m_titleHeight + m_margin);
		configWindow.lineTo(auxX, m_titleHeight + m_buttonHeight + m_margin);
		
		var tabText:TextField = configWindow.createTextField(m_name + "Text", configWindow.getNextHighestDepth(), 20, (titleHeight - extents.height) / 2, extents.width, extents.height);
		tabText.embedFonts = true;
		tabText.selectable = false;
		tabText.antiAliasType = "advanced";
		tabText.autoSize = true;
		tabText.border = false;
		tabText.background = false;
		tabText.setNewTextFormat(m_textFormat);
		tabText.text = m_name;
		
		var dragWindow:MovieClip = configWindow.createEmptyMovieClip(m_name + "DragWindow", configWindow.getNextHighestDepth());
		dragWindow.lineStyle(0, 0x000000, 0, true, "none", "square", "round");
		dragWindow.beginFill(0x000000, 0);
		dragWindow.moveTo(radius, 0);
		dragWindow.lineTo((m_maxWidth-radius), 0);
		dragWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		dragWindow.lineTo(m_maxWidth, (m_maxHeight-radius));
		dragWindow.curveTo(m_maxWidth, m_maxHeight, (m_maxWidth-radius), m_maxHeight);
		dragWindow.lineTo(radius, m_maxHeight);
		dragWindow.curveTo(0, m_maxHeight, 0, (m_maxHeight-radius));
		dragWindow.lineTo(0, radius);
		dragWindow.curveTo(0, 0, radius, 0);
		dragWindow.endFill();
		dragWindow.onPress = Proxy.create(this, function() { configWindow.startDrag(); } );
		dragWindow.onRelease = Proxy.create(this, function() { configWindow.stopDrag(); } );
		
		var buttonRadius:Number = 6.5;
		var buttonBack:MovieClip = configWindow.createEmptyMovieClip(m_name + "ButtonBack", configWindow.getNextHighestDepth());
		DrawCircle(buttonBack, buttonRadius, 0x848484, 100);
		buttonBack._x = m_maxWidth - buttonRadius * 2 - 15;
		buttonBack._y = titleHeight / 2 - buttonRadius;
		
		var buttonHover:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonHover", buttonBack.getNextHighestDepth());
		DrawCircle(buttonHover, buttonRadius, 0xFE2E2E, 80);
		buttonHover._alpha = 0;
		
		buttonBack.onRollOver = Proxy.create(this, function() { buttonHover._alpha = 0; Tweener.addTween(buttonHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
		buttonBack.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; } );
		buttonBack.onPress = Proxy.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; this.SetVisible(false); } );
		
		var crossRadius:Number = 3.5;
		var cross:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonCross", buttonBack.getNextHighestDepth());
		cross.lineStyle(2, 0xFFFFFF, 100, true, "none", "square", "round");
		cross.moveTo(buttonRadius - crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius + crossRadius, buttonRadius + crossRadius);
		cross.moveTo(buttonRadius + crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius - crossRadius, buttonRadius + crossRadius);		
	}
}