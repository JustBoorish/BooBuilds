import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.ID32;
import com.boobuilds.GearItem;
import com.boocommon.Graphics;
import com.boocommon.IconButton;
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
class com.boobuilds.GearSelector
{
	private var m_parent:MovieClip;
	private var m_name:String;
	private var m_frame:MovieClip;
	private var m_inventories:Array;
	private var m_selectCallback:Function;
	private var m_deleteCallback:Function;
	private var m_emptyCallback:Function;
	private var m_frameStyle:Number;
	private var m_margin:Number;
	private var m_items:Array;
	private var m_cells:Array;
	private var m_side:Number;
	private var m_buttonHeight:Number;
	private var m_buttonWidth:Number;
	
	public function GearSelector(name:String, parent:MovieClip, frameStyle:Number, inventories:Array, selectCallback:Function, deleteCallback:Function, emptyCallback:Function) 
	{
		m_name = name;
		m_parent = parent;
		m_frameStyle = frameStyle;
		m_inventories = inventories;
		m_deleteCallback = deleteCallback;
		m_selectCallback = selectCallback;
		m_emptyCallback = emptyCallback;
		m_frame = null;
		m_items = new Array();
		m_cells = new Array();
		m_side = 0;
		m_margin = 10;
		m_buttonHeight = IconButton.BUTTON_HEIGHT;
		m_buttonWidth = IconButton.BUTTON_WIDTH;
	}
	
	public function SetCoords(x:Number, y:Number):Void
	{
		var pt:Object = new Object();
		pt.x = x + m_frame._width;
		pt.y = y + m_frame._height;
		m_parent.localToGlobal(pt);
		if (pt.x > Stage.width)
		{
			x -= pt.x - Stage.width
		}
		
		if (pt.y > Stage.height)
		{
			y -= pt.y - Stage.height
		}
		
		m_frame._x = x;
		m_frame._y = y;
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			Mouse.addListener(this);
		}
		else
		{
			Mouse.removeListener(this);
		}
		
		m_frame._visible = visible;
	}
	
	public function Unload():Void
	{
		if (m_frame != null)
		{
			m_frame._visible = false;
			for (var i:Number = 0; i < m_cells.length; ++i)
			{
				m_cells[i].ClearIcon();
			}
			
			m_frame.removeMovieClip();
			m_frame = null;
		}
	}
	
	public function AddItem(gear:GearItem):Void
	{
		m_items.push(gear);
	}
	
	public function Rebuild():Void
	{
		Unload();
		
		var len:Number = m_items.length + 1;
		m_side = Math.floor(Math.sqrt(len));
		if (m_side * m_side != len)
		{
			m_side += 1;
		}
		
		if (m_side < 2)
		{
			m_side = 2;
		}
		
		var maxHeight:Number = m_side * (m_buttonHeight + m_margin) + m_margin;
		if (maxHeight > Stage.height)
		{
			var ratio:Number = Stage.height / maxHeight;
			m_buttonHeight *= ratio;
			m_buttonWidth *= ratio;
			m_margin *= ratio;
		}
		
		var maxWidth:Number = m_side * (m_buttonWidth + m_margin) + m_margin;
		if (maxWidth > Stage.width)
		{
			var ratio:Number = Stage.width / maxWidth;
			m_buttonHeight *= ratio;
			m_buttonWidth *= ratio;
			m_margin *= ratio;
		}
		
		CreateFrame();
		CreateCells();
	}
	
	private function onMouseDown():Void
	{
		if (!m_frame.hitTest(_root._xmouse, _root._ymouse, false))
		{
			SetVisible(false);
		}		
	}
	
	private function DeletePressed():Void
	{
		SetVisible(false);
		if (m_deleteCallback != null)
		{
			m_deleteCallback();
		}
	}
	
	private function EmptyPressed():Void
	{
		SetVisible(false);
		if (m_emptyCallback != null)
		{
			m_emptyCallback();
		}
	}
	
	private function ItemPressed(indx:Number):Void
	{
		SetVisible(false);
		if (m_selectCallback != null)
		{
			m_selectCallback(m_items[indx]);
		}
	}
	
	private function CreateIcon(indx:Number, callback:Function, buttonStyle:Number):IconButton
	{
		var col:Number = indx % m_side;
		var row:Number = Math.floor(indx / m_side);
		var x:Number = (col + 1) * m_margin + col * m_buttonWidth;
		var y:Number = (row + 1) * m_margin + row * m_buttonHeight;
		return new IconButton(m_name + "_" + indx, m_frame, x, y, m_buttonWidth, m_buttonHeight, null, null, callback, buttonStyle, m_frameStyle);
	}
	
	private function CreateFrame():Void
	{
		m_frame = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		var width:Number = m_side * m_buttonWidth + (m_margin  * (m_side + 1));
		var height:Number = m_side * m_buttonHeight + (m_margin * (m_side + 1));
		var colors:Array = [0x2E2E2E, 0x1C1C1C];
		var matrix:Matrix = new Matrix();
		
		matrix.createGradientBox(width, height, 90 / 180 * Math.PI, 0, 0);
		Graphics.DrawGradientFilledRoundedRectangle(m_frame, 0xD8D8D8, 4, colors, 0, 0, width, height);
		m_frame._visible = false;
		
		var deleteIcon:IconButton = CreateIcon(0, Delegate.create(this, DeletePressed), IconButton.MINUS);
		m_cells = new Array();
		m_cells.push(deleteIcon);
	}
	
	private function CreateCells():Void
	{
		var dontCheckBound:Boolean = m_inventories[0] == _global.Enums.InvType.e_Type_GC_WearInventory;
		var charInvId:ID32 = new ID32(m_inventories[0], Character.GetClientCharacter().GetID().GetInstance());
		var charInv:Inventory = new Inventory(charInvId);
		var bagInvId:ID32 = new ID32(m_inventories[1], Character.GetClientCharacter().GetID().GetInstance());
		var bagInv:Inventory = new Inventory(bagInvId);
	
		for (var i:Number = 0; i < m_items.length; ++i)
		{
			var gear:GearItem = m_items[i];
			var invItem:InventoryItem = null;
			var invId:ID32 = null;
			var charItemIndex:Number = GearItem.FindGearItem(charInv, gear, dontCheckBound);
			if (charItemIndex == -1)
			{
				charItemIndex = GearItem.FindGearItem(bagInv, gear, dontCheckBound);
				if (charItemIndex != -1)
				{
					invItem = bagInv.GetItemAt(charItemIndex);
					invId = bagInvId;
				}
			}
			else
			{
				invItem = charInv.GetItemAt(charItemIndex);
				invId = charInvId;
			}
			
			if (invItem != null)
			{
				var gearIcon:IconButton = CreateIcon(i + 1, Proxy.create(this, ItemPressed, i), IconButton.NONE);
				var colors:Object = Colors.GetColorlineColors(invItem.m_ColorLine);
				var frameColor:Number = Colors.GetItemRarityColor(invItem.m_Rarity);
				var frameColors:Array = [frameColor, frameColor];
				
				var tooltipData:TooltipData;
				if (invItem.m_ACGItem != undefined)
				{
					tooltipData = TooltipDataProvider.GetACGItemTooltip(invItem.m_ACGItem);
				}
				else
				{
					tooltipData = TooltipDataProvider.GetInventoryItemTooltip(invId, charItemIndex);
				}
				
				if (invItem.m_Icon == null || invItem.m_Icon.m_Instance == 0)
				{
					gearIcon.SetIcon([colors.highlight, colors.background], gear.GetIconPath(), invItem.m_Pips, false, frameColors, tooltipData, gear);
				}
				else
				{
					gearIcon.SetIcon([colors.highlight, colors.background], Utils.CreateResourceString(invItem.m_Icon), invItem.m_Pips, false, frameColors, tooltipData, gear);
				}
				
				m_cells.push(gearIcon);
			}
		}

		if (m_emptyCallback != null)
		{
			var emptyIcon:IconButton = CreateIcon(m_cells.length, Delegate.create(this, EmptyPressed), IconButton.NONE);
			emptyIcon.SetIcon(null, "BooDecksNoSign", 00, false, [0xFFFFFF, 0xFFFFFF], null, null, true);
			m_cells.push(emptyIcon);
		}
	}
}