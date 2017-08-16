import com.boocommon.IconButton;
import com.boocommon.ITabPane;
import com.boocommon.TabStrip;
import com.Utils.Text;
import com.GameInterface.DistributedValue;
import caurina.transitions.Tweener;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import org.sitedaniel.utils.Proxy;
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
class com.boocommon.TabWindow
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_closedCallback:Function;
	private var m_textFormat:TextFormat;
	private var m_maxWidth:Number;
	private var m_titleHeight:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_tabStrip:TabStrip;
	private var m_tabs:Array;
	private var m_firstTime:Boolean;
	private var m_helpIcon:MovieClip;
	
	public function TabWindow(parent:MovieClip, title:String, x:Number, y:Number, width:Number, height:Number, closedCallback:Function, helpIcon:String) 
	{
		m_name = title;
		m_parent = parent;
		m_closedCallback = closedCallback;
		m_frame = m_parent.createEmptyMovieClip(title + "TabWindow", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_margin = 6;
		m_titleHeight = 60;
		m_maxHeight = height + (210 - m_titleHeight);
		m_tabs = new Array();
		m_firstTime = true;
		
		m_textFormat = new TextFormat();
		m_textFormat.align = "left";
		m_textFormat.font = "tahoma";
		m_textFormat.size = 14;
		m_textFormat.color = 0xFFFFFF;
		m_textFormat.bold = false;
		
		DrawFrame(helpIcon);
	}
	
	public function AddTab(name:String, tab:ITabPane):Void
	{
		tab.CreatePane(m_parent, m_frame, name, 14, m_titleHeight + 10, m_maxWidth - 42, m_maxHeight - m_titleHeight - 27);
		m_tabStrip.AddTab(name);
		m_tabs.push(tab);
	}
	
	public function Unload():Void
	{
		m_frame._visible = false;
		m_frame.removeMovieClip();
	}
	
	public function ToggleVisible():Void
	{
		SetVisible(!GetVisible());
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true && m_firstTime == true)
		{
			m_tabStrip.Rebuild();
			m_firstTime = false;
			m_tabs[0].SetVisible(true);
			for (var indx:Number = 1; indx < m_tabs.length; ++indx)
			{
				m_tabs[indx].SetVisible(false);
			}
		}
		
		m_frame._visible = visible;
		
		if (visible != true && m_closedCallback != null)
		{
			Save();
			m_closedCallback();
		}
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	private function Save():Void
	{
		for (var i:Number = 0; i < m_tabs.length; ++i)
		{
			m_tabs[i].Save();
		}
	}

	private function StartDrag():Void
	{
		for (var i:Number = 0; i < m_tabs.length; ++i)
		{
			m_tabs[i].StartDrag();
		}
	}
	
	private function StopDrag():Void
	{
		for (var i:Number = 0; i < m_tabs.length; ++i)
		{
			m_tabs[i].StopDrag();
		}
	}
	
	private function TabPressed(newTab:Number, oldTab:Number):Void
	{
		if (oldTab >= 0 && oldTab < m_tabs.length)
		{
			m_tabs[oldTab].Save();
			m_tabs[oldTab].SetVisible(false);
		}
		
		m_tabs[newTab].SetVisible(true);
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
	
	private function DrawFrame(helpIcon:String):Void
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
		dragWindow.onPress = Proxy.create(this, function() { this.StartDrag(); configWindow.startDrag(); } );
		dragWindow.onRelease = Proxy.create(this, function() { this.StopDrag(); configWindow.stopDrag(); } );
		
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
		
		if (helpIcon != null)
		{
			m_helpIcon = configWindow.attachMovie(helpIcon, "HelpIcon", configWindow.getNextHighestDepth());
			m_helpIcon._width = 14;
			m_helpIcon._height = 14;
			m_helpIcon._y = titleHeight / 2 - m_helpIcon._height / 2;
			m_helpIcon._x = buttonBack._x - m_helpIcon._width - 10;

			var helpHover:MovieClip = m_helpIcon.createEmptyMovieClip(m_name + "HelpHover", m_helpIcon.getNextHighestDepth());
			DrawCircle(helpHover, 6 / m_helpIcon._xscale * 100, 0x6bcdf0, 80);
			helpHover._alpha = 0;
		
			m_helpIcon.onRollOver = Proxy.create(this, function() { helpHover._alpha = 0; Tweener.addTween(helpHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
			m_helpIcon.onRollOut = Proxy.create(this, function() { Tweener.removeTweens(helpHover); helpHover._alpha = 0; } );
			m_helpIcon.onPress = Proxy.create(this, function() { Tweener.removeTweens(helpHover); helpHover._alpha = 0; this.onHelpPress(); } );
		}
		
		m_tabStrip = new TabStrip(configWindow, m_name + "TabStrip", 10, titleHeight + 10, m_maxWidth - 20, m_maxHeight - titleHeight - 20, Delegate.create(this, TabPressed), 0);
	}
	
	private function onHelpPress():Void
	{
		var newURL:String = "https://tswact.wordpress.com/boocommon/";
		DistributedValue.SetDValue("WebBrowserStartURL", newURL);
		DistributedValue.SetDValue("web_browser", true);
	}
}