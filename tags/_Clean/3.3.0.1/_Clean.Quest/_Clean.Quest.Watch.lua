--[[****************************************************************************
  * _Clean.Quest by Saiket                                                     *
  * _Clean.Quest.Watch.lua - Modifies the quest/achievement watch frame.       *
  ****************************************************************************]]


if ( IsAddOnLoaded( "Carbonite" ) ) then
	return;
end
local _Clean = _Clean;
local me = {};
_Clean.Quest.Watch = me;




--[[****************************************************************************
  * Function: _Clean.Quest.Watch:OnLeftClick                                   *
  * Description: Stops tracking if shift is held.                              *
  ****************************************************************************]]
do
	local Backup = WatchFrameLinkButtonTemplate_OnLeftClick;
	function me:OnLeftClick ( ... )
		if ( IsShiftKeyDown() ) then -- Stop tracking
			CloseDropDownMenus();
			if ( self.type == "QUEST" ) then
				RemoveQuestWatch( GetQuestIndexForWatch( self.index ) );
				WatchFrame_Update();
				if ( QuestLogFrame:IsVisible() ) then
					QuestLog_Update();
				end
			elseif ( self.type == "ACHIEVEMENT" ) then
				( AchievementButton_ToggleTracking or RemoveTrackedAchievement )( self.index );
			end

		else
			return Backup( self, ... );
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.Quest.Watch:GetFrame                                      *
  * Description: Hooks newly made buttons.                                     *
  ****************************************************************************]]
do
	local Backup = WatchFrame.buttonCache.GetFrame;
	function me:GetFrame ( ... )
		local NumFrames = self.numFrames;
		local Frame = Backup( self, ... );

		if ( NumFrames ~= self.numFrames ) then -- Created new frame
			_Clean.AddLockedButton( Frame );
		end

		return Frame;
	end
end


--[[****************************************************************************
  * Function: _Clean.Quest.Watch.UpdateQuests                                  *
  * Description: Repositions quest item buttons.                               *
  ****************************************************************************]]
function me.UpdateQuests ()
	for Index = 1, WATCHFRAME_NUM_ITEMS do
		local Button = _G[ "WatchFrameItem"..Index ];
		if ( Button:IsShown() ) then
			Button:SetPoint( "TOPRIGHT", ( select( 2, Button:GetPoint( 1 ) ) ) );
		else
			break;
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.Quest.Watch.Manage                                        *
  ****************************************************************************]]
function me.Manage ()
	WatchFrame:ClearAllPoints();
	WatchFrame:SetPoint( "TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, -8 );
	WatchFrame:SetPoint( "BOTTOM", Dominos.Frame:Get( 3 ), "TOP" );
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	-- Right-align the header text
	WatchFrameTitle:SetPoint( "RIGHT", WatchFrameCollapseExpandButton, "LEFT", -8, 0 );
	WatchFrameTitle:SetJustifyH( "RIGHT" );
	
	-- Reposition list
	WatchFrameLines:SetPoint( "BOTTOMRIGHT" );
	_Clean.RegisterPositionManager( me.Manage );
	local Backup = WatchFrame_DisplayTrackedQuests;
	hooksecurefunc( "WatchFrame_DisplayTrackedQuests", me.UpdateQuests );
	if ( WatchFrame_RemoveObjectiveHandler( Backup ) ) then
		WatchFrame_AddObjectiveHandler( WatchFrame_DisplayTrackedQuests );
	end


	WatchFrameLinkButtonTemplate_OnLeftClick = me.OnLeftClick;

	WatchFrame.buttonCache.GetFrame = me.GetFrame;
	for _, Frame in ipairs( WatchFrame.buttonCache.frames ) do
		_Clean.AddLockedButton( Frame );
	end
	for _, Frame in ipairs( WatchFrame.buttonCache.usedFrames ) do
		_Clean.AddLockedButton( Frame );
	end
end