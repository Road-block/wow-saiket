--[[****************************************************************************
  * _Clean by Saiket                                                           *
  * _Clean.ActionBar.lua - Slide the action bars along the corners of the      *
  *   screen so that they still align when the scaling changes. Also, the      *
  *   backgrounds are removed to free more screen real-estate.                 *
  *                                                                            *
  * + Removes spacing between the action button grids.                         *
  * + Shrinks all action bars and makes them slightly transparent.             *
  * + Gets rid of backgrounds on action bars.                                  *
  * + Moves the aura bar to where the cluster of UI panel buttons was, and     *
  *   removes those panel buttons from view.                                   *
  * + Repositions the pet action bar to just below the center of the screen.   *
  * + Only shows the backgrounds of buttons when actions are being dragged.    *
  * + Colors action buttons red when out of range.                             *
  ****************************************************************************]]
-- NOTE(Slightly desaturate action buttons, possibly with gradient.)


local _Clean = _Clean;
local me = {
	Bars = {
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MultiBarLeft,
		MultiBarRight
	};
};
_Clean.ActionBar = me;
local Bars = me.Bars;

local Icons = {};




--[[****************************************************************************
  * Function: _Clean.ActionBar.ActionButtonModify                              *
  * Description: Modifies textures on an action button.                        *
  ****************************************************************************]]
function me.ActionButtonModify ( Prefix, Index )
	_G[ Prefix..Index ]:GetNormalTexture():SetAlpha( 1.0 );
	_Clean.RemoveButtonIconBorder( _G[ Prefix..Index.."Icon" ] );
	_G[ Prefix..Index.."Border" ]:SetAlpha( 0.8 );
end


--[[****************************************************************************
  * Function: _Clean.ActionBar.ActionButtonOnUpdate                            *
  * Description: Tints action buttons red when out of range.                   *
  ****************************************************************************]]
function me.ActionButtonOnUpdate ()
	if ( this.rangeTimer == TOOLTIP_UPDATE_TIME ) then -- Just updated
		me.ActionButtonUpdateUsable();
	end
end
--[[****************************************************************************
  * Function: _Clean.ActionBar.ActionButtonUpdateUsable                        *
  * Description: Tints action buttons red when out of range.                   *
  ****************************************************************************]]
do
	-- Note: This gets called a ton; optimize anything and everything.
	local IsActionInRange = IsActionInRange;
	local IsUsableAction = IsUsableAction;
	local _G = _G;
	local self, Action, Icon, Usable, NotEnoughMana;
	function me.ActionButtonUpdateUsable ()
		self = this;
		Action = self.action;
		Icon = Icons[ self ];
		if ( not Icon ) then
			Icon = _G[ self:GetName().."Icon" ];
			Icons[ self ] = Icon;
		end
		Usable, NotEnoughMana = IsUsableAction( Action );

		if ( Usable ) then -- Not out of mana or unusable
			if ( IsActionInRange( Action ) ~= 0 ) then
				Icon:SetVertexColor( 1.0, 1.0, 1.0 ); -- Usable
				self:SetAlpha( 1.0 );
			else
				Icon:SetVertexColor( 0.8, 0.1, 0.1 );
				self:SetAlpha( 0.6 );
			end
		elseif ( NotEnoughMana ) then -- Very distinct blue
			Icon:SetVertexColor( 0.1, 0.1, 1.0 );
			self:SetAlpha( 0.6 );
		end
	end
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	-- Make the bars less obtrusive
	MainMenuBarArtFrame:SetAlpha( 0.75 );
	for _, Frame in ipairs( Bars ) do
		Frame:SetAlpha( 0.75 );
	end
	MainMenuBar:SetScale( 0.75 );
	for _, Frame in ipairs( Bars ) do
		Frame:SetScale( 0.75 );
	end


	-- Remove spacing between buttons
	for Index = 2, NUM_MULTIBAR_BUTTONS do
		local Last = Index - 1;
		_G[ "ActionButton"..Index ]:SetPoint( "LEFT", "ActionButton"..Last, "RIGHT" );
		_G[ "MultiBarBottomLeftButton"..Index ]:SetPoint( "LEFT", "MultiBarBottomLeftButton"..Last, "RIGHT" );
		_G[ "MultiBarBottomRightButton"..Index ]:SetPoint( "LEFT", "MultiBarBottomRightButton"..Last, "RIGHT" );
		_G[ "MultiBarLeftButton"..Index ]:SetPoint( "TOP", "MultiBarLeftButton"..Last, "BOTTOM" );
		_G[ "MultiBarRightButton"..Index ]:SetPoint( "TOP", "MultiBarRightButton"..Last, "BOTTOM" );
	end
	-- Remove icon borders on buttons
	for Index = 1, NUM_MULTIBAR_BUTTONS do
		me.ActionButtonModify( "ActionButton", Index );
		me.ActionButtonModify( "MultiBarBottomLeftButton", Index );
		me.ActionButtonModify( "MultiBarBottomRightButton", Index );
		me.ActionButtonModify( "MultiBarLeftButton", Index );
		me.ActionButtonModify( "MultiBarRightButton", Index );
	end
	-- Resize bar frames
	local BarLength = ActionButton1:GetWidth() * NUM_MULTIBAR_BUTTONS;
	MultiBarBottomLeft:SetWidth( BarLength );
	MultiBarBottomRight:SetWidth( BarLength );
	MultiBarRight:SetHeight( BarLength );
	MultiBarLeft:SetHeight( BarLength );
	-- Shapeshift bar
	local ButtonSize = MultiBarBottomRightButton1:GetWidth() * 0.75;
	for Index = NUM_SHAPESHIFT_SLOTS, 1, -1 do
		local Button = _G[ "ShapeshiftButton"..Index ];
		Button:SetWidth( ButtonSize );
		Button:SetHeight( ButtonSize );
		_Clean.RemoveButtonIconBorder( _G[ "ShapeshiftButton"..Index.."Icon" ] );
		_G[ "ShapeshiftButton"..Index.."NormalTexture" ]:SetTexture();
		if ( Index > 1 ) then
			Button:SetPoint( "LEFT", "ShapeshiftButton"..( Index - 1 ), "RIGHT", 4, 0 );
		end
	end
	ShapeshiftButton1:SetPoint( "BOTTOMLEFT", ShapeshiftBarFrame );


	-- Remove art
	ShapeshiftBarLeft:SetTexture();
	ShapeshiftBarLeft:Hide();
	ShapeshiftBarRight:SetTexture();
	ShapeshiftBarRight:Hide();
	ShapeshiftBarMiddle:SetTexture();
	ShapeshiftBarMiddle:Hide();

	PetActionBarFrame:EnableMouse( false );
	for Index = 0, 1 do
		local Texture = _G[ "SlidingActionBarTexture"..Index ];
		Texture:SetTexture();
		Texture:Hide();
	end


	-- Anchor bars together
	MultiBarBottomLeft:ClearAllPoints();
	MultiBarBottomLeft:SetPoint( "BOTTOMLEFT", ActionButton1, "TOPLEFT" );

	MultiBarBottomRight:ClearAllPoints();
	MultiBarBottomRight:SetPoint( "BOTTOMRIGHT", MainMenuBarBackpackButton,
		"TOPRIGHT", -1, -1 );

	MultiBarRight:ClearAllPoints();
	MultiBarRight:SetPoint( "BOTTOMRIGHT", MultiBarBottomRight,
		"TOPRIGHT", 0, -2 );

	MultiBarLeft:ClearAllPoints();
	MultiBarLeft:SetPoint( "BOTTOMRIGHT", MultiBarRight, "BOTTOMLEFT", 2, 0 );

	ShapeshiftBarFrame:ClearAllPoints();
	ShapeshiftBarFrame:SetPoint( "TOPLEFT", MultiBarBottomRight,
		"BOTTOMLEFT", 2, 0 );


	-- Hooks
	UIPARENT_MANAGED_FRAME_POSITIONS[ "MultiBarBottomLeft" ] = nil;
	UIPARENT_MANAGED_FRAME_POSITIONS[ "MultiBarRight" ] = nil;
	UIPARENT_MANAGED_FRAME_POSITIONS[ "ShapeshiftBarFrame" ] = nil;
	hooksecurefunc( "ActionButton_OnUpdate", me.ActionButtonOnUpdate );
	hooksecurefunc( "ActionButton_UpdateUsable", me.ActionButtonUpdateUsable );
end
