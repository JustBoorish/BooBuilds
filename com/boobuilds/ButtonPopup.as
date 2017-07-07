import caurina.transitions.Tweener;
import com.boobuilds.DebugWindow;
import com.boobuilds.GearItem;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Signal;
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
class com.boobuilds.ButtonPopup
{
	public var SignalOpening:Signal;
	private var m_margin:Number;
	private var m_slot:Number;
	private var m_parent:MovieClip;
	private var m_buttonWidth:Number;
	private var m_buttonHeight:Number;
	private var m_main:MovieClip;
	private var m_mainY:Number;
	private var m_button:MovieClip;
	private var m_buttonY:Number;
	private var m_loader:MovieClipLoader;
	private var m_frameWidth:Number;
	private var m_skillCount:Number;
	private var m_buttons:Array;
	private var m_skillToAdd:Object;
	
	public function ButtonPopup(parent:MovieClip, slot:Number, x:Number, yBottom:Number, buttonWidth:Number, buttonHeight:Number) 
	{
		SignalOpening = new Signal();
		m_margin = 3;
		m_skillCount = 0;
		m_slot = slot;
		m_buttonHeight = buttonHeight;
		m_buttonWidth = buttonWidth;
		m_parent = parent;
		m_main = parent.createEmptyMovieClip("buttonPopup_" + slot, parent.getNextHighestDepth());
		m_main._x = x;
		m_main._y = yBottom - 14;
		m_main._visible = false;
		m_skillToAdd = null;
		Shortcut.SignalShortcutAdded.Connect(OnSignalShortcutAdded, this);

		m_button = CreateButton("m_button_" + m_slot, parent);
		m_buttonY = yBottom - 12;
		SetButtonCoords(x + buttonWidth / 2 - 10, m_buttonY);
		m_loader = new MovieClipLoader();
		m_loader.addListener(this);
		m_frameWidth = 2;
		m_buttons = new Array();
	}
	
	private function GetSkillData(skillId:Number):SpellData
	{
		if (skillId != null)
		{
			var featData:FeatData = FeatInterface.m_FeatList[skillId];
			if (featData != null)
			{
				var spellData:SpellData = Spell.GetSpellData(featData.m_Spell);
				if (spellData != null)
				{
					if (Spell.IsActiveSpell(spellData.m_Id))
					{
						return spellData;
					}
					else
					{
						return null;
					}
				}
			}
		}
		
		return null;
	}
	
	private function GetPassiveData(skillId:Number):SpellData
	{
		if (skillId != null)
		{
			var featData:FeatData = FeatInterface.m_FeatList[skillId];
			if (featData != null)
			{
				var spellData:SpellData = Spell.GetSpellData(featData.m_Spell);
				if (spellData != null)
				{
					if (Spell.IsPassiveSpell(spellData.m_Id))
					{
						return spellData;
					}
					else
					{
						return null;
					}
				}
			}
		}
		
		return null;
	}
	
	private function FindFeat(name:String):FeatData
	{
		var found:FeatData = null;
		
		for (var featName:String in FeatInterface.m_FeatList)
		{
			var feat:FeatData = FeatInterface.m_FeatList[featName];
			if (feat.m_Name == name)
			{
				if (feat.m_Trained)
				{
					if (found == null || feat.m_CellIndex > found.m_CellIndex)
					{
						found = feat;
					}
				}
			}
		}
		
		return found;
	}
	
	private function GetAugmentData(skillId:Number):SpellData
	{
		if (skillId != null)
		{
			var featData:FeatData = FeatInterface.m_FeatList[skillId];
			if (featData != null)
			{
				featData = FindFeat(featData.m_Name);
				if (featData != null)
				{
					var spellData:SpellData = Spell.GetSpellData(featData.m_Spell);
					if (spellData != null)
					{
						return spellData;
					}
				}
			}
		}
		
		return null;
	}
	
	public function AddSkill(skillFeatId:Number, augmentFeatId:Number, passiveFeatId:Number, gear:GearItem):Void
	{
		if (m_main != null)
		{
			var activeData:SpellData = GetSkillData(skillFeatId);
			var passiveData:SpellData = GetPassiveData(passiveFeatId);
			var augmentData:SpellData = GetAugmentData(augmentFeatId);
			if (activeData != null || passiveData != null)
			{
				var activeId:Number = null;
				var activeName:String = null;
				if (activeData != null)
				{
					activeId = activeData.m_Id;
					activeName = activeData.m_Name;
				}
				
				var passiveId:Number = null;
				var passiveName:String = null;
				if (passiveData != null)
				{
					passiveId = passiveData.m_Id;
					passiveName = passiveData.m_Name;
				}
				
				var augId:Number = null;
				var augmentName:String = null;
				if (augmentData != null)
				{
					augId = augmentData.m_Id;
					augmentName = augmentData.m_Name;
				}
				
				var spellData:SpellData = activeData;
				if (spellData == null)
				{
					spellData = passiveData;
				}

				var iconColor:Object = Colors.GetColorlineColors(spellData.m_ColorLine);						
				m_buttons.push(CreateIconFrame("button_" + m_skillCount, m_main, iconColor.highlight, iconColor.background, Utils.CreateResourceString(spellData.m_Icon), spellData.m_SpellType, activeName, activeId, augmentName, augId, passiveName, passiveId, gear));
				m_skillCount += 1;
				var newHeight:Number = (m_buttonHeight * m_skillCount) + (m_skillCount * m_margin);
				m_mainY = m_button._y - newHeight;
				m_main._y = m_mainY;
			}
		}
	}
	
	public function Close():Void
	{
		ButtonPressed(true);
	}
	
	public function Unload():Void
	{
		Shortcut.SignalShortcutAdded.Disconnect(OnSignalShortcutAdded, this);
		m_main._visible = false;
		m_main.removeMovieClip();
		m_main = null;
	}
	
	private function SetButtonCoords(x:Number, y:Number):Void
	{
		m_button._x = x;
		m_button._y = y;
		m_button.hitArea._x = x - 2;
		m_button.hitArea._y = y - 2;
	}
	
	private function CreateButton(name:String, parent:MovieClip):MovieClip
	{
		var buttonBkg:MovieClip = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		buttonBkg._visible = true;
		var backColour:Number = 0xFFFFFF;
		var backAlpha:Number = 80;
		buttonBkg.lineStyle(0, backColour, backAlpha, true, "none", "square", "round");
		buttonBkg.beginFill(backColour, backAlpha);
		buttonBkg.moveTo(0, 8);
		buttonBkg.lineTo(16, 8);
		buttonBkg.lineTo(8, 0);
		buttonBkg.lineTo(0, 8);
		buttonBkg.endFill();
		
		var hitBox:MovieClip = parent.createEmptyMovieClip(name+"_Hit", parent.getNextHighestDepth());
		hitBox.lineStyle(1, 0xa09e98, 0);
		hitBox.beginFill(0xa09e98, 0);
		hitBox.moveTo(0, 0);
		hitBox.lineTo(20, 0);
		hitBox.lineTo(20, 10);
		hitBox.lineTo(0, 10);		
		hitBox.lineTo(0, 0);		
		hitBox.endFill();
		buttonBkg.hitArea = hitBox;
		buttonBkg.onPress = Delegate.create(this, ButtonPressed);

		return buttonBkg;
	}
	
	private function CreateIconFrame(name:String, parent:MovieClip, iconColor1:Number, iconColor2:Number, iconPath:String, spellType:Number, skillName:String, spellId:Number, augmentName:String, augmentId:Number, passiveName:String, passiveId:Number, gear:GearItem):MovieClip
	{
		var radius:Number = 4;
		var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
		var web20Filters:Array = [web20Glow];
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var colors:Array = [iconColor1, iconColor2]
		var frameColors:Array = [0xFFFFFF, 0xFFFFFF];

		if (spellType == _global.Enums.SpellItemType.eEliteActiveAbility || spellType == _global.Enums.SpellItemType.eElitePassiveAbility)
		{
			frameColors = [0xf2d055, 0xe2a926];
		}
		else if (m_slot == 7)
		{
			frameColors = [0xFFFFFF, 0xFFFFFF];
		}
		else
		{
			frameColors = [0x000000, 0x000000];
		}
		
		matrix.createGradientBox(m_buttonWidth, m_buttonHeight, 90 / 180 * Math.PI, 0, 0);
		var buttonSlider:MovieClip = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		buttonSlider._x = 0;
		buttonSlider._y = 0;
		buttonSlider.lineStyle(m_frameWidth, 0x000000, 100, true, "none", "square", "round");
		buttonSlider.lineGradientStyle("linear", frameColors, alphas, ratios, matrix);
		buttonSlider.beginGradientFill("linear", colors, alphas, ratios, matrix);
		buttonSlider.moveTo(radius, 0);
		buttonSlider.lineTo((m_buttonWidth-radius), 0);
		buttonSlider.curveTo(m_buttonWidth, 0, m_buttonWidth, radius);
		buttonSlider.lineTo(m_buttonWidth, (m_buttonHeight-radius));
		buttonSlider.curveTo(m_buttonWidth, m_buttonHeight, (m_buttonWidth-radius), m_buttonHeight);
		buttonSlider.lineTo(radius, m_buttonHeight);
		buttonSlider.curveTo(0, m_buttonHeight, 0, (m_buttonHeight-radius));
		buttonSlider.lineTo(0, radius);
		buttonSlider.curveTo(0, 0, radius, 0);
		buttonSlider.endFill();
		buttonSlider.skillName = skillName;
		buttonSlider.spellId = spellId;
		buttonSlider.augmentName = augmentName;
		buttonSlider.augmentId = augmentId;
		buttonSlider.passiveName = passiveName;
		buttonSlider.passiveId = passiveId;		
		buttonSlider.gear = gear;
		buttonSlider.onPress = Proxy.create(this, TryButtonPress, buttonSlider);
		
		loadIcon(name, iconPath, buttonSlider);
		return buttonSlider;
	}
	
	private function loadIcon(name:String, iconPath:String, parent:MovieClip):Void
	{
		if (iconPath != null)
		{
			var icon:MovieClip = parent.createEmptyMovieClip(name + "_icon", parent.getNextHighestDepth());
			icon._x = m_frameWidth / 2;
			icon._y = m_frameWidth / 2;
			m_loader.loadClip(iconPath, icon);
		}
	}
	
	private function onLoadInit(icon:MovieClip):Void
	{
		icon._xscale = m_buttonWidth-(icon._x*2);
		icon._yscale = m_buttonHeight-(icon._y*2);
	}
	
	private function SetSkill(mc:Object):Boolean
	{
		var spellId:Number = mc.spellId;
		var skillName:String = mc.skillName;
		
		if (spellId != null)
		{
			if (Shortcut.IsSpellEquipped(spellId))
			{
				DebugWindow.Log(DebugWindow.Error, "Spell already equipped " + skillName);
				return false;
			}
			else
			{
				m_skillToAdd = mc;
				Shortcut.AddSpell(_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + m_slot, spellId);
				return true;
			}
		}
		
		return false;
	}
	
	private function SetAugment(mc:Object):Boolean
	{
		var spellId:Number = mc.augmentId;
		var skillName:String = mc.augmentName;
		
		if (skillName == null)
		{
			return false;
		}
		else
		{
			if	(Shortcut.IsSpellEquipped(spellId))
			{
				DebugWindow.Log(DebugWindow.Error, "Augment already equipped " + skillName);
				return false;
			}
			else
			{
				Shortcut.AddAugment(_global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + m_slot, spellId);
				return true;
			}
		}
	}
	
	private function SetPassive(mc:Object):Boolean
	{
		var spellId:Number = mc.passiveId;
		var skillName:String = mc.passiveName;
		
		if (skillName == null)
		{
			return false;
		}
		else if	(Spell.IsPassiveEquipped(spellId))
		{
			DebugWindow.Log(DebugWindow.Error, "Passive already equipped " + skillName);
			return false;
		}
		else
		{
			Spell.EquipPassiveAbility(m_slot, spellId);
			return true;
		}
	}
	
	private function SetGearItem(gear:GearItem):Boolean
	{
		if (gear != null)
		{
			var charInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance());
			var charInv:Inventory = new Inventory(charInvId);
			var charItemIndex:Number = GearItem.FindGearItem(charInv, gear);
			if (charItemIndex == -1)
			{
				var bagInvId:ID32 = new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharacter().GetID().GetInstance());
				var bagInv:Inventory = new Inventory(bagInvId);
				var itemIndex:Number = GearItem.FindGearItem(bagInv, gear);
				if (itemIndex != -1)
				{
					var bagItem:InventoryItem = bagInv.GetItemAt(itemIndex);
					var destPos:Number = _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot;
					if (bagItem.m_DefaultPosition == _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot)
					{
						destPos = _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot;
					}
					
					var addItemResult:Number = charInv.AddItem(bagInvId, itemIndex, destPos);
					if (addItemResult == _global.Enums.InventoryAddItemResponse.e_AddItem_Success)
					{
						return true;
					}
				}
				else
				{
					DebugWindow.Log(DebugWindow.Error, "Couldn't find item " + gear.toString());
				}
			}
			else
			{
				return true;
			}
			
			return false;
		}
		
		return true;
	}
	
	private function TryButtonPress(mc:Object):Void
	{
		if (SetSkill(mc) == true)
		{
			ButtonPressed(true);
		}
		else
		{
			m_skillToAdd = mc;
			if (CompleteSkillAdd() == true)
			{
				ButtonPressed(true);
			}
		}
	}
	
	private function OnSignalShortcutAdded(itemPos:Number):Void
	{
		var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
		if (m_skillToAdd != null && shortcutData != null && shortcutData.m_Name == m_skillToAdd.skillName)
		{
			setTimeout(Delegate.create(this, CompleteSkillAdd), 10);
		}
	}
	
	private function CompleteSkillAdd():Boolean
	{
		var ret:Boolean = false;
		
		if (SetGearItem(m_skillToAdd.gear) == true)
		{
			ret = SetPassive(m_skillToAdd);
			SetAugment(m_skillToAdd);
		}
		
		m_skillToAdd = null;
		return ret;
	}
	
	private function IsButtonEquipped(indx:Number):Boolean
	{
		var ret:Boolean = false;
		if (m_buttons[indx].spellId != null)
		{
			ret = Shortcut.IsSpellEquipped(m_buttons[indx].spellId);
			if (ret == true && m_buttons[indx].passiveId != null)
			{
				ret = Spell.IsPassiveEquipped(m_buttons[indx].passiveId);
			}
		}
		else if (m_buttons[indx].passiveId != null)
		{
			ret = Spell.IsPassiveEquipped(m_buttons[indx].passiveId);
		}

		return ret;
	}
	
	private function ShowButtons():Void
	{
		var skillNumber:Number = 0;
		for (var i:Number = 0; i < m_buttons.length; ++i)
		{
			if (IsButtonEquipped(i) == true)
			{
				m_buttons[i]._visible = false;
			}
			else
			{
				m_buttons[i]._y = (m_buttonHeight * skillNumber) + (m_margin * skillNumber);
				++skillNumber;
				m_buttons[i]._visible = true;
			}
		}
		
		if (skillNumber > 0)
		{
			m_main._y = m_buttonY;
			m_main._alpha = 0;
			var riseHeight:Number = m_mainY + (m_buttonHeight + m_margin) * (m_buttons.length - skillNumber);
			Tweener.addTween(m_main, { _y:riseHeight, _alpha:100, time:0.3, transition:"easeOutQuad"} );
			m_main._visible = true;
		}
		else
		{
			m_main._visible = false;
		}
	}
	
	private function onMouseDown():Void
	{
		if (!m_main.hitTest(_root._xmouse, _root._ymouse, false) && !m_button.hitArea.hitTest(_root._xmouse, _root._ymouse, false))
		{
			ButtonPressed(true);
		}		
	}
	
	private function ButtonPressed(forceClose:Boolean):Void
	{
		if (m_button._yscale > 0 && forceClose != true)
		{
			SignalOpening.Emit();
			SetButtonCoords(m_button._x, m_buttonY + m_button._height);
			ShowButtons();
			m_button._yscale = -100;
			m_button.hitArea._yscale = -100;
			if (m_main._visible == true)
			{
				Mouse.addListener(this);
			}
		}
		else
		{
			Mouse.removeListener(this);
			SetButtonCoords(m_button._x, m_buttonY);
			Tweener.addTween(m_main, { _y:m_buttonY, _alpha:0, time:0.3, transition:"easeOutQuad", onComplete:function() { this._visible = false; }} );
			m_button._yscale = 100;
			m_button.hitArea._yscale = 100;
		}
	}
}