import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.SkillWheel.Cell;
import com.GameInterface.SkillWheel.Cluster;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.Colors;
import com.boobuilds.Localisation;
import com.boobuildscommon.MenuPanel;
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
class com.boobuilds.SkillMenu
{
	private var m_parent:MovieClip;
	private var m_menu:MovieClip;
	private var m_name:String;
	private var m_includeActive:Boolean;
	private var m_includeAuxActive:Boolean;
	private var m_includePassive:Boolean;
	private var m_includeAuxPassive:Boolean;
	private var m_includeAugments:Boolean;
	private var m_callback:Function;
	private var m_deleteCallback:Function;
	private var m_inheritCallback:Function;
	private var m_panels:Array;
	private var m_clusters:Object;
	private var m_inheritIndx:Number;
	
	public function SkillMenu(parent:MovieClip, name:String, includeActive:Boolean, includePassive:Boolean, includeAugments:Boolean, includeAuxActive:Boolean, includeAuxPassive:Boolean)
	{
		m_clusters = new Object();
		m_name = name;
		m_parent = parent;
		m_callback = null;
		m_deleteCallback = null;
		m_inheritCallback = null;
		m_includeActive = includeActive;
		m_includeAuxActive = includeAuxActive;
		m_includePassive = includePassive;
		m_includeAuxPassive = includeAuxPassive;
		m_includeAugments = includeAugments;
		m_menu = m_parent.createEmptyMovieClip(m_name, m_parent.getNextHighestDepth());
		m_menu._visible = false;
		m_panels = new Array();
		var panel:MenuPanel = new MenuPanel(m_menu, m_name + "1", 4);
		m_panels.push(panel);
		
		InitializeClusters();
		if (m_includeActive == true || m_includePassive == true)
		{
			CreateMainSkillClusters(panel);
		}
		
		if (m_includeAuxActive == true || m_includeAuxPassive == true)
		{
			CreateAuxClusters(panel);
		}
		
		if (m_includeAugments == true)
		{
			CreateAugClusters(panel);
		}
		
		panel.AddItem(Localisation.Delete, Proxy.create(this, DeletePressed), 0x2E2E2E, 0x1C1C1C, null);
		m_inheritIndx = panel.AddItem(Localisation.Inherit, Proxy.create(this, InheritPressed), 0x2E2E2E, 0x1C1C1C, null);
		
		var pt:Object = panel.GetDimensions(0, 100, true, 0, 0, 2560, 1600);
		panel.Rebuild();
		panel.SetVisible(true);
	}
	
	public function SetCoords(x:Number, y:Number):Void
	{
		var pt:Object = m_panels[0].GetCoords();
		m_menu._x = x;
		m_menu._y = y - pt.y;
	}

	private function SetVisible(visible:Boolean):Void
	{
		m_menu._visible = visible;
		m_panels[0].SetVisible(visible);
	}
	
	public function Show(callback:Function, deleteCallback:Function, inheritCallback:Function):Void
	{
		m_callback = callback;
		m_deleteCallback = deleteCallback;
		m_inheritCallback = inheritCallback;
		m_panels[0].SetCellHidden(m_inheritIndx, m_inheritCallback == null);
		SetVisible(true);
	}
	
	public function Hide():Void
	{
		SetVisible(false);
		m_callback = null;
		m_deleteCallback = null;
		m_inheritCallback = null;
	}
	
	private function SkillPressed(feat:FeatData):Void
	{
		if (m_callback != null)
		{
			m_callback(feat);
		}
	}
	
	private function DeletePressed(feat:FeatData):Void
	{
		if (m_deleteCallback != null)
		{
			m_deleteCallback(feat);
		}
	}
	
	private function InheritPressed(feat:FeatData):Void
	{
		if (m_inheritCallback != null)
		{
			m_inheritCallback(feat);
		}
	}
	
	private function IsFeatIncluded(featData:FeatData):Boolean
	{
		var ret:Boolean = false;
		if (Spell.IsActiveSpell(featData.m_Spell))
		{
			if (m_includeActive == true || m_includeAuxActive == true)
			{
				ret = true;
			}
		}
		else if (Spell.IsPassiveSpell(featData.m_Spell))
		{
			if (m_includePassive == true || m_includeAuxPassive == true)
			{
				ret = true;
			}
		}
		else
		{
			if (m_includeAugments == true)
			{
				ret = true;
			}
		}
		
		return ret;
	}
	
	private function SetBestColor(colorCounts:Object):Number
	{
		var bestColor:Number = 0;
		var bestCount:Number = 0;
		for (var color in colorCounts)
		{
			if ((m_includeActive == true && m_includePassive == true) ||
			    (m_includeAuxActive == true && m_includeAuxPassive == true))
			{
				if (color != "6" && color != "0" && colorCounts[color] > bestCount)
				{
					bestCount = colorCounts[color];
					bestColor = Number(color);
				}
			}
			else if (color != "0" && colorCounts[color] > bestCount)
			{
				bestCount = colorCounts[color];
				bestColor = Number(color);
			}
		}
		
		return bestColor;
	}
	
	private function FindCellColor(cell:Cell):Number
	{
		var colorCounts:Object = new Object();
		for (var indx:Number = 0; indx < cell.m_Abilities.length; ++indx)
		{
			var feat:FeatData = FeatInterface.m_FeatList[cell.m_Abilities[indx]];
			if (IsFeatIncluded(feat))
			{
				if (colorCounts[feat.m_ColorLine] == null)
				{
					colorCounts[feat.m_ColorLine] = 1;
				}
				else
				{
					colorCounts[feat.m_ColorLine] = colorCounts[feat.m_ColorLine] + 1;
				}
			}
		}
		
		return SetBestColor(colorCounts);
	}
	
	private function FindClusterColor(cluster:Cluster, inCounts:Object):Number
	{
		if (cluster == null || cluster.m_Name == null || cluster.m_Name.length < 1)
		{
			return 0;
		}
		
		var colorCounts:Object;
		if (inCounts != null)
		{
			colorCounts = inCounts;
		}
		else
		{
			colorCounts = new Object();
		}
		
		if (cluster.m_Clusters != null && cluster.m_Clusters.length > 0)
		{
			for (var i:Number = 0; i < cluster.m_Clusters.length; ++i)
			{
				var tempColor:Number = FindClusterColor(FindCluster(cluster.m_Clusters[i]), colorCounts);
				if (colorCounts[tempColor] == null)
				{
					colorCounts[tempColor] = 1;
				}
				else
				{
					colorCounts[tempColor] = colorCounts[tempColor] + 1;
				}
			}
		}
		
		for (var i:Number = 0; i < cluster.m_Cells.length; ++i)
		{
			var tempColor:Number = FindCellColor(cluster.m_Cells[i]);
			if (colorCounts[tempColor] == null)
			{
				colorCounts[tempColor] = 1;
			}
			else
			{
				colorCounts[tempColor] = colorCounts[tempColor] + 1;
			}
		}
		
		var bestColor:Number = SetBestColor(colorCounts);
		return SetBestColor(colorCounts);
	}
	
	private function CellMapper(cell:Cell):Number
	{
		var ret:Number = cell.m_ClusterId;
		var mappedCellId:Number = Math.floor((cell.m_Id / 2) + 0.5);
		if (cell.m_ClusterId == 1)
		{
			ret = 10 + mappedCellId;
		}
		else if (cell.m_ClusterId == 101)
		{
			ret = 110 + mappedCellId;
		}
		else if (cell.m_ClusterId == 201)
		{
			ret = 210 + mappedCellId;
		}
		
		return ret;
	}
	
	private function CreateClusterPanels(cluster:Cluster, parentPanel:MenuPanel, panelMap:Object)
	{
		if (cluster == null || cluster.m_Name == null || cluster.m_Name.length < 1)
		{
			return;
		}
		
		var colors:Object = null;
		var panel:MenuPanel = panelMap[cluster.m_Name];
		if (panel == null)
		{
			colors = Colors.GetColorlineColors(FindClusterColor(cluster));
			panel = new MenuPanel(m_menu, cluster.m_Name, 4, colors.highlight, colors.background);
			parentPanel.AddSubMenu(cluster.m_Name, panel, colors.highlight, colors.background);
			m_panels.push(panel);
			panelMap[cluster.m_Name] = panel;
		}
		
		if (cluster.m_Clusters != null && cluster.m_Clusters.length > 0)
		{
			for (var i:Number = 0; i < cluster.m_Clusters.length; ++i)
			{
				CreateClusterPanels(FindCluster(cluster.m_Clusters[i]), panel, panelMap);
			}
		}

		for (var i:Number = 0; i < cluster.m_Cells.length; ++i)
		{
			var subPanel:MenuPanel = panelMap[cluster.m_Cells[i].m_Name];
			var clusterPanel:MenuPanel;
			var cellColors:Object;
			if (subPanel == null)
			{
				var newClusterId:Number = CellMapper(cluster.m_Cells[i]);
				if (newClusterId == cluster.m_Cells[i].m_ClusterId)
				{
					clusterPanel = panel;
				}
				else
				{
					var tempCluster:Cluster = FindCluster(newClusterId);
					clusterPanel = panelMap[tempCluster.m_Name];
				}
				
				cellColors = Colors.GetColorlineColors(FindCellColor(cluster.m_Cells[i]));
				subPanel = new MenuPanel(m_menu, cluster.m_Cells[i].m_Name, 4, cellColors.highlight, cellColors.background);
			}
			
			var empty:Boolean = true;
			for (var indx:Number = 0; indx < cluster.m_Cells[i].m_Abilities.length; ++indx)
			{
				var feat:FeatData = FeatInterface.m_FeatList[cluster.m_Cells[i].m_Abilities[indx]];
				if (IsFeatIncluded(feat))
				{
					empty = false;
					colors = Colors.GetColorlineColors(feat.m_ColorLine);
					var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( feat.m_Spell );
					subPanel.AddItem(feat.m_Name, Proxy.create(this, SkillPressed, feat), colors.highlight, colors.background, tooltipData, !feat.m_Trained);
				}
			}
			
			if (empty == false)
			{
				clusterPanel.AddSubMenu(cluster.m_Cells[i].m_Name, subPanel, cellColors.highlight, cellColors.background);
				m_panels.push(subPanel);
				panelMap[cluster.m_Cells[i].m_Name] = subPanel;
			}
		}
	}
	
	private function CreateHive(parentPanel:MenuPanel, clusters:Array, name:String, bestColor:Number):Void
	{
		var colors:Object = Colors.GetColorlineColors(bestColor);
		var panel:MenuPanel = new MenuPanel(m_menu, name, 4, colors.highlight, colors.background);
		parentPanel.AddSubMenu(name, panel, colors.highlight, colors.background);
		m_panels.push(panel);
		
		var panelMap:Object = new Object();
		for (var indx:Number = 0; indx < clusters.length; ++indx)
		{
			CreateClusterPanels(clusters[indx], panel, panelMap);
		}
	}
	
	private function CreateMainSkillClusters(panel:MenuPanel):Void
	{
		var clusters:Array = [ FindCluster(1),
							   FindCluster(101), 
							   FindCluster(201), 
							   FindCluster(2001),
							   FindCluster(2002),
							   FindCluster(2003) ]
							   
		clusters[0].m_Clusters =  [11, 12, 13];
		clusters[1].m_Clusters =  [111, 112, 113];
		clusters[2].m_Clusters =  [211, 212, 213];
		
		CreateHive(panel, clusters, "Skills", 2);
	}
	
	private function CreateAuxClusters(panel:MenuPanel):Void
	{
		var clusters:Array = [  FindCluster(2300), 
								FindCluster(2200), 
								FindCluster(2100)]
		
		clusters[0].m_Clusters = [2311, 2301, 2303];
		clusters[1].m_Clusters = [2202, 2201, 2203];
		clusters[2].m_Clusters = [2111, 2101, 2103];
		
		CreateHive(panel, clusters, "Aux", 1);
	}
	
	private function CreateAugClusters(panel:MenuPanel):Void
	{
		var clusters:Array = [ FindCluster(3201),
							   FindCluster(3301),
							   FindCluster(3401),
							   FindCluster(3101)]
		
		CreateHive(panel, clusters, "Aug", 33);
	}
	
	private function InitializeClusters()
	{
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				//These are augments, and are special snowflakes.
				if (featData.m_ClusterIndex > 3100 && featData.m_ClusterIndex < 3500)
				{
					var cell:Cell = FindCell(featData.m_ClusterIndex, 1);
					if (cell == undefined)
					{
						cell = new Cell(1, featData.m_ClusterIndex);
						var cluster:Cluster = FindCluster(featData.m_ClusterIndex);
						if (cluster != undefined)
						{
							cluster.m_Cells[0] = cell;
						}
					}
					
					/*
					Crazy set of conditionals incoming
					We want to show an augment feat if it is:
					 1: The highest level of that augment that the player has trained
					 2: The lowest level augment if the player has trained none of them
					 
					 Augments feats are not listed in any order, so we can't assume anything.
					*/
					var currFeat:FeatData = FeatInterface.m_FeatList[cell.m_Abilities[featData.m_AbilityIndex]];
					//If there's nothing already in the slot, add it
					if (cell.m_Abilities[featData.m_AbilityIndex] == undefined)
					{
						cell.m_Abilities[featData.m_AbilityIndex] = featData.m_Id;
						currFeat = FeatInterface.m_FeatList[cell.m_Abilities[featData.m_AbilityIndex]];
					}
					//If the player knows the spell
					else if (featData.m_Trained)
					{
						//If the current spell in the slot isn't known, or is lower level, replace it
						if ((!currFeat.m_Trained) ||
							(featData.m_CellIndex > currFeat.m_CellIndex))
						{
							cell.m_Abilities[featData.m_AbilityIndex] = featData.m_Id;
						}
					}
					//If the current spell in the slot isn't known, replace it with a rank zero spell
					else if (featData.m_CellIndex == 0 && !currFeat.m_Trained)
					{
						cell.m_Abilities[featData.m_AbilityIndex] = featData.m_Id;
					}
					
				}
				//These are not augments.
				else
				{
					var cell:Cell = FindCell(featData.m_ClusterIndex, featData.m_CellIndex + 1);
					if (cell == undefined)
					{
						cell = new Cell(featData.m_CellIndex + 1, featData.m_ClusterIndex);
						var cluster:Cluster = FindCluster(featData.m_ClusterIndex);
						if (cluster != undefined)
						{
							cluster.m_Cells[featData.m_CellIndex] = cell;
						}
					}
					cell.m_Abilities[featData.m_AbilityIndex] = featData.m_Id;
				}
			}
		}
	}
	
	private function FindCluster(clusterId:Number):Cluster
	{
		var ret:Cluster = m_clusters[clusterId];
		if (ret == null)
		{
			ret = new Cluster(clusterId);
			m_clusters[clusterId] = ret;
		}
		
		return ret;
	}
	
	function FindCell(clusterID:Number, cellID:Number):Cell
	{
		return FindCluster(clusterID).m_Cells[cellID - 1];
	}
}