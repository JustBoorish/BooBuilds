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
import com.boobuilds.Build;
import com.boobuilds.GearItem;
import com.boobuildscommon.Checkbox;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.IconButton;
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
class com.boobuilds.BuildDisplay
{
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_frame:MovieClip;
	private var m_textFormat:TextFormat;
	private var m_showCheckboxes:Boolean;
	private var m_buttonWidth:Number;
	private var m_buttonHeight:Number;
	private var m_maxWidth:Number;
	private var m_maxHeight:Number;
	private var m_checkSize:Number;
	private var m_margin:Number;
	private var m_titleHeight:Number;
	private var m_skillIcons:Array;
	private var m_skillChecks:Array;
	private var m_passiveIcons:Array;
	private var m_passiveChecks:Array;
	private var m_gearIcons:Array;
	private var m_gearChecks:Array;
	private var m_weaponIcons:Array;
	private var m_weaponChecks:Array;
	
	public function BuildDisplay(name:String, parent:MovieClip, textFormat:TextFormat, x:Number, y:Number, showCheckboxes:Boolean)
	{
		m_name = name;
		m_parent = parent;
		m_showCheckboxes = showCheckboxes;
		m_frame = m_parent.createEmptyMovieClip(name, m_parent.getNextHighestDepth());
		m_textFormat = textFormat;
	
		m_checkSize = 13;
		m_buttonWidth = 32;
		m_buttonHeight = m_buttonWidth;
		m_margin = 6;
		var maxRows:Number = 4;
		m_maxWidth = m_buttonWidth * (Build.MAX_GEAR + 1) + (Build.MAX_GEAR + 3) * m_margin + 30;
		m_maxHeight = m_buttonHeight * maxRows + (maxRows + 1) * m_margin;
		
		m_skillIcons = new Array();
		m_skillChecks = new Array();
		CreateIcons(Build.SKILL_PREFIX, Build.MAX_SKILLS, m_margin, m_skillIcons, m_skillChecks);
		
		var rowHeight:Number = m_buttonHeight;
		if (m_showCheckboxes == true)
		{
			rowHeight += m_checkSize + m_margin;
		}
		
		var row:Number = 1;
		m_passiveIcons = new Array();
		m_passiveChecks = new Array();
		CreateIcons(Build.PASSIVE_PREFIX, Build.MAX_PASSIVES, m_margin * (row + 1) + rowHeight * row, m_passiveIcons, m_passiveChecks);
		
		++row;
		m_weaponIcons = new Array();
		m_weaponChecks = new Array();
		CreateIcons(Build.WEAPON_PREFIX, Build.MAX_WEAPONS, m_margin * (row + 1) + rowHeight * row, m_weaponIcons, m_weaponChecks);
		
		++row;
		m_gearIcons = new Array();
		m_gearChecks = new Array();
		CreateIcons(Build.GEAR_PREFIX, Build.MAX_GEAR, m_margin * (row + 1) + rowHeight * row, m_gearIcons, m_gearChecks);
		
		m_frame._x = x;
		m_frame._y = y;
	}

	public function Unload():Void
	{
		ClearIcons();
		m_frame.removeMovieClip();
	}
	
	private function ClearIcons():Void
	{
		var icons:Array = m_skillIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_SKILLS; ++i)
			{
				if (icons[i] != null)
				{
					icons[i].Unload();
				}
			}
		}
		
		icons = m_passiveIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_PASSIVES; ++i)
			{
				if (icons[i] != null)
				{
					icons[i].Unload();
				}
			}
		}
		
		icons = m_gearIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_GEAR; ++i)
			{
				if (icons[i] != null)
				{
					icons[i].Unload();
				}
			}
		}
		
		icons = m_weaponIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_WEAPONS; ++i)
			{
				if (icons[i] != null)
				{
					icons[i].Unload();
				}
			}
		}
	}
	
	public function SetBuild(build:Build):Void
	{
		var icons:Array = m_skillIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_SKILLS; ++i)
			{
				SetSkillIcon(build.GetSkill(i), icons[i]);
			}
		}
		
		icons = m_passiveIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_PASSIVES; ++i)
			{
				SetSkillIcon(build.GetPassive(i), icons[i]);
			}
		}
		
		var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);

		icons = m_gearIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_GEAR; ++i)
			{
				SetGearIcon(build.GetGear(i), charInvId, charInv, bagInvId, bagInv, icons[i]);
			}
		}
		
		icons = m_weaponIcons;
		if (icons != null)
		{
			for (var i:Number = 0; i < Build.MAX_WEAPONS; ++i)
			{
				SetGearIcon(build.GetWeapon(i), charInvId, charInv, bagInvId, bagInv, icons[i]);
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
	
	private function SetGearIcon(gear:GearItem, charInvId:ID32, charInv:Inventory, bagInvId:ID32, bagInv:Inventory, button:IconButton):Void
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
			frameColor = Colors.GetItemRarityColor(item.m_Rarity);			
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
			
			button.SetIcon([colors.highlight, colors.background], Utils.CreateResourceString(item.m_Icon), item.m_Pips, false, frameColors, tooltipData, gear, false);
		}
		else if (gear != null)
		{
			var iconPath:String = gear.GetIconPath();
			button.SetIcon(null, gear.GetIconPath(), 0, false, null, null, gear, false);
		}
	}
	
	private function InternalSetChecked(icons:Array, checks:Array, indx:Number, isChecked:Boolean):Void
	{
		if (icons != null && icons[indx] != null)
		{
			if (checks != null && checks[indx] != null)
			{
				checks[indx].SetChecked(isChecked);
			}

			icons[indx].SetEnabled(isChecked);
		}
	}
	
	private function SetGearChecked(indx:Number, isChecked:Boolean):Void
	{
		InternalSetChecked(m_gearIcons, m_gearChecks, indx, isChecked);
	}
	
	private function SetWeaponChecked(indx:Number, isChecked:Boolean):Void
	{
		InternalSetChecked(m_weaponIcons, m_weaponChecks, indx, isChecked);
	}
	
	private function SetSkillChecked(indx:Number, isChecked:Boolean):Void
	{
		InternalSetChecked(m_skillIcons, m_skillChecks, indx, isChecked);
	}
	
	private function SetPassiveChecked(indx:Number, isChecked:Boolean):Void
	{
		InternalSetChecked(m_passiveIcons, m_passiveChecks, indx, isChecked);
	}
	
	private function GearPressed(indx:Number):Void
	{
		if (m_gearChecks != null && m_gearChecks[indx] != null)
		{
			var isChecked:Boolean = m_gearChecks[indx].IsChecked();
			SetGearChecked(indx, isChecked);
		}
	}
	
	private function WeaponPressed(indx:Number):Void
	{
		if (m_weaponChecks != null && m_weaponChecks[indx] != null)
		{
			var isChecked:Boolean = m_weaponChecks[indx].IsChecked();
			SetWeaponChecked(indx, isChecked);
		}
	}
	
	private function PassivePressed(indx:Number):Void
	{
		if (m_passiveChecks != null && m_passiveChecks[indx] != null)
		{
			var isChecked:Boolean = m_passiveChecks[indx].IsChecked();
			SetPassiveChecked(indx, isChecked);
		}
	}
	
	private function SkillPressed(indx:Number):Void
	{
		if (m_skillChecks != null && m_skillChecks[indx] != null)
		{
			var isChecked:Boolean = m_skillChecks[indx].IsChecked();
			SetSkillChecked(indx, isChecked);
		}
	}
	
	private function IconPressed(prefix:String, indx:Number):Void
	{
		switch(prefix)
		{
			case Build.WEAPON_PREFIX:
				WeaponPressed(indx);
				break;
			case Build.GEAR_PREFIX:
				GearPressed(indx);
				break;
			case Build.PASSIVE_PREFIX:
				PassivePressed(indx);
				break;
			case Build.SKILL_PREFIX:
				SkillPressed(indx);
				break;
			default:
				break;
		}
	}
	
	private function CreateIcons(prefix:String, maxIcons:Number, y:Number, icons:Array, checks:Array):Void
	{
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
			var x:Number = (i + 1) * m_margin + (i + 0) * m_buttonWidth;
				
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

			var callback:Function = null;
			if (m_showCheckboxes == true)
			{
				callback = Proxy.create(this, IconPressed, prefix, i);
			}
			
			var button:IconButton = new IconButton(prefix + i, m_frame, x, y, m_buttonWidth, m_buttonHeight, [color1, color2], [frameColor, frameColor], callback, IconButton.NONE, frameStyle);

			if (m_showCheckboxes == true)
			{
				button.SetEnabled(false);
			}
			else
			{
				button.SetEnabled(true);
			}
			
			icons.push(button);
			
			if (m_showCheckboxes == true)
			{
				var check:Checkbox = new Checkbox(prefix + "Check" + i, m_frame, x + m_buttonWidth / 2 - m_checkSize / 2, y + m_buttonHeight + 1, m_checkSize, callback, false);
				checks.push(check);
			}
		}
	}
	
	public function GetSkillChecks():Array
	{
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < m_skillChecks.length; ++indx)
		{
			if (m_skillChecks[indx] != null)
			{
				ret.push(m_skillChecks[indx].IsChecked());
			}
			else
			{
				ret.push(false);
			}
		}
		
		return ret;
	}
	
	public function GetPassiveChecks():Array
	{
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < m_passiveChecks.length; ++indx)
		{
			if (m_passiveChecks[indx] != null)
			{
				ret.push(m_passiveChecks[indx].IsChecked());
			}
			else
			{
				ret.push(false);
			}
		}
		
		return ret;
	}
	
	public function GetWeaponChecks():Array
	{
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < m_weaponChecks.length; ++indx)
		{
			if (m_weaponChecks[indx] != null)
			{
				ret.push(m_weaponChecks[indx].IsChecked());
			}
			else
			{
				ret.push(false);
			}
		}
		
		return ret;
	}
	
	public function GetGearChecks():Array
	{
		var ret:Array = new Array();
		for (var indx:Number = 0; indx < m_gearChecks.length; ++indx)
		{
			if (m_gearChecks[indx] != null)
			{
				ret.push(m_gearChecks[indx].IsChecked());
			}
			else
			{
				ret.push(false);
			}
		}
		
		return ret;
	}
}