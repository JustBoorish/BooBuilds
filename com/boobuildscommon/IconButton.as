import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.boobuildscommon.DebugWindow;
import com.boobuildscommon.Graphics;
import flash.geom.Matrix;
import caurina.transitions.Tweener;
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
class com.boobuildscommon.IconButton
{
	public static var PLUS:Number = 1;
	public static var MINUS:Number = 2;
	public static var NONE:Number = 0;
	public static var TOPLEFT_CORNER:Number = 1;
	public static var TOPRIGHT_CORNER:Number = 2;
	public static var BOTTOMLEFT_CORNER:Number = 4;
	public static var BOTTOMRIGHT_CORNER:Number = 8;
	public static var BUTTON_WIDTH:Number = 47;
	public static var BUTTON_HEIGHT:Number = 47;
	private var m_name:String;
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_icon:MovieClip;
	private var m_pips:MovieClip;
	private var m_buttonWidth:Number;
	private var m_buttonHeight:Number;
	private var m_loader:MovieClipLoader;
	private var m_frameWidth:Number;
	private var m_data:Object;
	private var m_callback:Function;
	private var m_tooltipData:TooltipData
	private var m_tooltip:TooltipInterface;
	private var m_buttonStyle:Number;
	private var m_frameStyle:Number;
	private var m_backgroundColors:Array;
	private var m_frameColors:Array;
	private var m_enabled:Boolean;
	private var m_numPips:Number;
	private var m_iconPath:String;
	private var m_iconHover:MovieClip;

	public function IconButton(name:String, parent:MovieClip, x:Number, y:Number, buttonWidth:Number, buttonHeight:Number, inBackgroundColors:Array, inFrameColors:Array, callback:Function, buttonStyle:Number, frameStyle:Number, tooltipData:TooltipData)
	{
		m_name = name;
		m_buttonHeight = buttonHeight;
		m_buttonWidth = buttonWidth;
		m_parent = parent;
		m_buttonStyle = buttonStyle;
		m_frameStyle = frameStyle;
		m_data = null;
		m_callback = callback;
		m_tooltip = null;
		m_enabled = true;
		m_numPips = 0;
		
		m_loader = new MovieClipLoader();
		m_loader.addListener(this);
		m_frameWidth = (m_buttonHeight + m_buttonWidth) / 48;
		
		if (inBackgroundColors == null)
		{
			m_backgroundColors = [0x2E2E2E, 0x1C1C1C];
		}
		else
		{
			m_backgroundColors = inBackgroundColors;
		}
		
		if (inFrameColors == null)
		{
			m_frameColors = [0x000000, 0x000000];
		}
		else
		{
			m_frameColors = inFrameColors;
		}
		
		CreateEmptyFrame(m_name, m_parent, x, y, m_backgroundColors, m_frameColors);
		DeleteIcon();
		m_tooltipData = tooltipData;
	}
	
	public function Unload():Void
	{
		m_pips.removeMovieClip();
		m_icon.removeMovieClip();
		m_frame.removeMovieClip();
	}
	
	public function GetData():Object
	{
		return m_data;
	}
	
	public function SetEnabled(enabled:Boolean):Void
	{
		m_enabled = enabled;
		if (m_enabled == true)
		{
			m_frame._alpha = 100;
		}
		else
		{
			m_frame._alpha = 50;
		}
	}
	
	public function DeleteIcon():Void
	{
		ClearIcon();
		/*if (m_tooltipData == null)
		{
			if (m_buttonStyle == MINUS)
			{
				m_tooltipData = new TooltipData();
				m_tooltipData.AddDescription(Localisation.DeleteIconTooltipDesc);
				if (Localisation.DeleteIconTooltipMisc.length > 0)
				{
					m_tooltipData.m_MiscItemInfo = Localisation.DeleteIconTooltipMisc;			
				}
			}
			else if (m_buttonStyle == PLUS)
			{
				m_tooltipData = new TooltipData();
				m_tooltipData.AddDescription(Localisation.IconTooltipDesc);
				m_tooltipData.m_MiscItemInfo = Localisation.IconTooltipMisc;
			}
		}*/
		
		CreateIconFrame(m_name, m_frame, m_backgroundColors, false, m_frameColors);
	}
	
	public function SetIcon(inIconColors:Array, iconPath:String, numPips:Number, isElite:Boolean, inFrameColors:Array, tooltipData:TooltipData, data:Object):Void
	{
		ClearIcon();
		m_tooltipData = tooltipData;
		m_data = data;
		m_numPips = numPips;
		m_iconPath = iconPath;
		
		var iconColors:Array = inIconColors;
		if (iconColors == null)
		{
			iconColors = m_backgroundColors;
		}
		
		var frameColors:Array = inFrameColors;
		if (frameColors == null)
		{
			frameColors = m_frameColors;
		}
		
		CreateIconFrame(m_name, m_frame, iconColors, isElite, frameColors);
	}
	
	public function ClearIcon():Void
	{
		CloseTooltip();
		m_tooltipData = null;
		m_data = null;
		m_numPips = 0;
		m_iconPath = null;
		
		if (m_icon != null)
		{
			m_icon._visible = false;
			m_icon.removeMovieClip();
			m_icon = null;
		}
		
		if (m_pips != null)
		{
			m_pips._visible = false;
			m_pips.removeMovieClip();
			m_pips = null;
		}
	}
	
	private function CloseTooltip():Void
	{
		if (m_tooltip != null)
		{
			m_tooltip.Close();
			m_tooltip = null;
		}
	}
	
	private function ShowTooltip():Void
	{
        CloseTooltip();
		if (m_tooltipData != null)
		{
			m_tooltip = TooltipManager.GetInstance().ShowTooltip( m_frame, TooltipInterface.e_OrientationVertical, 0.2, m_tooltipData );
		}
	}
	
	private function CreateBackgroundFrame(name:String, parent:MovieClip, x:Number, y:Number, inBackgroundColors:Array, isElite:Boolean, inFrameColors:Array):MovieClip
	{
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
		var matrix:Matrix = new Matrix();
		var colors:Array = [0x0, 0x0];
		var frameColors:Array = [0x000000, 0x000000];

		if (Graphics.ColourArrayValid(inFrameColors) == true)
		{
			frameColors = [inFrameColors[0], inFrameColors[1]];
		}
		else if (isElite == true)
		{
			frameColors = [0xf2d055, 0xe2a926];
		}
		else
		{
			frameColors = [0x000000, 0x000000];
		}
		
		if (Graphics.ColourArrayValid(inBackgroundColors) == true)
		{
			colors = [inBackgroundColors[0], inBackgroundColors[1]];
		}
		
		matrix.createGradientBox(m_buttonWidth, m_buttonHeight, 90 / 180 * Math.PI, 0, 0);
		var frame:MovieClip = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		frame._x = x;
		frame._y = y;
		frame.lineStyle(m_frameWidth, 0x000000, 100, true, "none", "square", "round");
		frame.lineGradientStyle("linear", frameColors, alphas, ratios, matrix);
		frame.beginGradientFill("linear", colors, alphas, ratios, matrix);

		var radius:Number = (m_buttonHeight + m_buttonWidth) / 16;
		
		if (m_frameStyle == NONE)
		{
			frame.moveTo(radius, 0);
			frame.lineTo((m_buttonWidth - radius), 0);
			frame.curveTo(m_buttonWidth, 0, m_buttonWidth, radius);
			frame.lineTo(m_buttonWidth, (m_buttonHeight-radius));
			frame.curveTo(m_buttonWidth, m_buttonHeight, (m_buttonWidth-radius), m_buttonHeight);
			frame.lineTo(radius, m_buttonHeight);
			frame.curveTo(0, m_buttonHeight, 0, (m_buttonHeight-radius));
			frame.lineTo(0, radius);
			frame.curveTo(0, 0, radius, 0);
			frame.endFill();
		}
		else
		{
			var slope:Number = (m_buttonHeight + m_buttonWidth) / 7;
			if (m_frameStyle & TOPLEFT_CORNER)
			{
				frame.moveTo(slope, 0);				
			}
			else
			{
				frame.moveTo(radius, 0);
			}
			
			if (m_frameStyle & TOPRIGHT_CORNER)
			{
				frame.lineTo(m_buttonWidth - slope, 0);
				frame.lineTo(m_buttonWidth, slope);
			}
			else
			{
				frame.lineTo((m_buttonWidth - radius), 0);
				frame.curveTo(m_buttonWidth, 0, m_buttonWidth, radius);
			}
			
			if (m_frameStyle & BOTTOMRIGHT_CORNER)
			{
				frame.lineTo(m_buttonWidth, m_buttonHeight - slope);
				frame.lineTo(m_buttonWidth - slope, m_buttonHeight);
			}
			else
			{
				frame.lineTo(m_buttonWidth, (m_buttonHeight-radius));
				frame.curveTo(m_buttonWidth, m_buttonHeight, (m_buttonWidth-radius), m_buttonHeight);
			}
			
			if (m_frameStyle & BOTTOMLEFT_CORNER)
			{
				frame.lineTo(slope, m_buttonHeight);
				frame.lineTo(0, m_buttonHeight - slope);
			}
			else
			{
				frame.lineTo(radius, m_buttonHeight);
				frame.curveTo(0, m_buttonHeight, 0, (m_buttonHeight-radius));
			}
			
			if (m_frameStyle & TOPLEFT_CORNER)
			{
				frame.lineTo(0, slope);
				frame.lineTo(slope, 0);
			}
			else
			{
				frame.lineTo(0, radius);
				frame.curveTo(0, 0, radius, 0);
			}
			frame.endFill();
		}
		
		return frame;
	}
	
	private function CreateEmptyFrame(name:String, parent:MovieClip, x:Number, y:Number, backgroundColors:Array, frameColors:Array):Void
	{
		m_frame = CreateBackgroundFrame(name, parent, x, y, backgroundColors, false, frameColors);
		
		if (m_buttonStyle != NONE)
		{
			var crossRadius:Number = 6;
			m_frame.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
			m_frame.beginFill(0x000000, 60);
			m_frame.moveTo(m_buttonWidth / 2 - crossRadius - m_frameWidth, m_buttonHeight / 2 - crossRadius - m_frameWidth);
			m_frame.lineTo(m_buttonWidth / 2 + crossRadius + m_frameWidth, m_buttonHeight / 2 - crossRadius - m_frameWidth);
			m_frame.lineTo(m_buttonWidth / 2 + crossRadius + m_frameWidth, m_buttonHeight / 2 + crossRadius + m_frameWidth);
			m_frame.lineTo(m_buttonWidth / 2 - crossRadius - m_frameWidth, m_buttonHeight / 2 + crossRadius + m_frameWidth);
			m_frame.lineTo(m_buttonWidth / 2 - crossRadius - m_frameWidth, m_buttonHeight / 2 - crossRadius - m_frameWidth);
			m_frame.endFill();
			
			m_frame.lineStyle(2, 0xFFFFFF, 100, true, "none", "square", "round");
			m_frame.moveTo(m_buttonWidth / 2 - crossRadius, m_buttonHeight / 2);
			m_frame.lineTo(m_buttonWidth / 2 + crossRadius, m_buttonHeight / 2);
			if (m_buttonStyle == PLUS)
			{
				m_frame.moveTo(m_buttonWidth / 2, m_buttonHeight / 2 - crossRadius);
				m_frame.lineTo(m_buttonWidth / 2, m_buttonHeight / 2 + crossRadius);
			}
		}
	}
	
	private function CreateIconFrame(name:String, parent:MovieClip, backgroundColors:Array, isElite:Boolean, frameColors:Array):Void
	{
		m_icon = CreateBackgroundFrame(name + "IconBack", parent, 0, 0, backgroundColors, isElite, frameColors);

		if (m_iconPath != null)
		{
			loadIcon(name + "Icon", m_icon);
		}
		else
		{
			m_icon._alpha = 0;
		}
		
		m_icon.onPress = Delegate.create(this, function() { this.HideHover(); this.CloseTooltip(); this.TryButtonPress(); } );
		m_icon.onRollOver = Delegate.create(this, function() { this.ShowHover(); this.ShowTooltip(); } );
		m_icon.onRollOut = Delegate.create(this, function() { this.HideHover(); this.CloseTooltip(); } );
	}
	
	private function loadIcon(name:String, parent:MovieClip):Void
	{
		if (m_iconPath != null)
		{
			if (m_iconPath.indexOf(":") < 0)
			{
				var icon:MovieClip = parent.attachMovie(m_iconPath, name + "_icon", parent.getNextHighestDepth());
				onAttachInit(icon);
			}
			else
			{
				var icon:MovieClip = parent.createEmptyMovieClip(name + "_icon", parent.getNextHighestDepth());
				m_loader.loadClip(m_iconPath, icon);
			}
		}
	}
	
	private function SetPips(name:String, icon:MovieClip)
	{
		if (m_numPips > 0)
		{
			var parent:MovieClip = icon._parent;
			m_pips = parent.createEmptyMovieClip(name + "_pips", parent.getNextHighestDepth());
			
			var xOffset:Number = 0;
			for (var i:Number = 0; i < m_numPips; ++i)
			{
				Graphics.DrawFilledCircle(m_pips, m_buttonWidth * 0.05, xOffset, 0, 0xfbe31e, 100);
				xOffset = xOffset + m_buttonWidth * 0.05 * 2 + m_frameWidth * 2;
			}
			
			m_pips._y = m_buttonHeight - m_pips._height - 2;
			m_pips._x = m_buttonWidth / 2 - m_pips._width / 2;
		}
	}
	
	private function onLoadInit(icon:MovieClip):Void
	{
		icon._x = m_frameWidth / 2;
		icon._y = m_frameWidth / 2;
		icon._xscale = m_buttonWidth-m_frameWidth;
		icon._yscale = m_buttonHeight-m_frameWidth;
		
		SetPips(icon._name, icon);		
	}
	
	private function onAttachInit(icon:MovieClip):Void
	{
		icon._x = m_frameWidth / 2;
		icon._y = m_frameWidth / 2;
		var scale:Number = (m_buttonWidth - m_frameWidth) / icon._width;
		var scaleY:Number = (m_buttonHeight - m_frameWidth) / icon._height;
		if (scaleY < scale)
		{
			scale = scaleY;
		}
		
		icon._xscale = scale * 100;
		icon._yscale = scale * 100;
		
		SetPips(icon._name, icon);		
	}
	
	private function onLoadError(target_mc:MovieClip, errorCode:String):Void
	{
		DebugWindow.Log(DebugWindow.Debug, "Failed to load icon " + errorCode);
	}
	
	private function ShowHover():Void
	{
		if (m_enabled == true)
		{
			if (m_callback != null && m_icon != null)
			{
				if (m_iconHover == null)
				{
					m_iconHover = m_icon.createEmptyMovieClip("IconHover", m_icon.getNextHighestDepth());
					Graphics.DrawFilledRoundedRectangle(m_iconHover, 0x000000, 0, 0xFFFFFF, 70, 0, 0, m_icon._width, m_icon._height);
					m_iconHover._x = 0;
					m_iconHover._y = 0;
					m_iconHover._alpha = 0;
				}
				
				m_iconHover._alpha = 0;
				Tweener.addTween(m_iconHover, { _alpha:40, time:0.5, transition:"linear" } );
			}
		}
	}
	
	private function HideHover():Void
	{
		if (m_iconHover != null)
		{
			Tweener.removeTweens(m_iconHover);
			m_iconHover._alpha = 0;
		}
	}
	
	private function TryButtonPress():Void
	{
		if (m_enabled == true)
		{
			if (m_callback != null)
			{
				m_callback.call(m_data);
			}
		}
	}
}