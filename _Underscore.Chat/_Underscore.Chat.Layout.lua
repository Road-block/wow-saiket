--[[****************************************************************************
  * _Underscore.Chat by Saiket                                                 *
  * _Underscore.Chat.Layout.lua - Modifies the chat frames.                    *
  ****************************************************************************]]


-- NOTE(Abandon hope, all ye who enter here.)
local _Underscore = _Underscore;
local me = CreateFrame( "Frame", nil, UIParent );
_Underscore.Chat.Layout = me;

me.ButtonAlpha = DEFAULT_CHATFRAME_ALPHA + 0.25;
me.ExpandedAlpha = min( DEFAULT_CHATFRAME_ALPHA + 0.25, 1 );

local ChatFrames = {}; -- Ordered list of chat frames
me.ChatFrames = ChatFrames;
local ExpandedFrames = {}; -- Chat frames hashed to boolean values
me.ExpandedFrames = ExpandedFrames;

local Borders = {}; -- Chat frames hashed to arrays of borders
me.Borders = Borders;
local Buttons = {}; -- Chat frames hashed to tables of buttons
me.Buttons = Buttons;

local Tab = {};
me.Tab = Tab;
local TabFrames = {};
Tab.TabFrames = TabFrames;
local DisabledMenuButtons = {};
Tab.DisabledMenuButtons = DisabledMenuButtons;




--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.Expand                                   *
  * Description: Expand the chat frame to fit the height of the screen and     *
  *   darken its backdrop for readability, or undo this effect.                *
  ****************************************************************************]]
function me:Expand ( Expand )
	local ID = self:GetID();
	local TabFrame = TabFrames[ ID ];
	local OriginalAlpha = select( 6, GetChatWindowInfo( ID ) );

	ExpandedFrames[ self ] = Expand;

	if ( Expand ) then -- Darken the window to make it easier to read
		self:SetFrameStrata( "TOOLTIP" );
		TabFrame:SetFrameStrata( "TOOLTIP" );
		FCF_SetWindowAlpha( self, max( me.ExpandedAlpha, OriginalAlpha ), 1 );
		TabFrame:SetAlpha( 1.0 );

		if ( ID == 1 or ID == 2 ) then
			self:SetPoint( "TOP", MinimapCluster, "BOTTOM" );
		end
	else -- Contract and restore old alpha
		self:SetFrameStrata( "BACKGROUND" );
		TabFrame:SetFrameStrata( "BACKGROUND" );
		FCF_SetWindowAlpha( self, OriginalAlpha, 1 );
		TabFrame:SetAlpha( me.ButtonAlpha );

		if ( ID == 1 or ID == 2 ) then
			self:SetPoint( "TOP", _Underscore.BottomPane, 0, -3 );
		end
	end
end


--[[****************************************************************************
  * Function: _Underscore.Chat.Layout:SetTabPosition                           *
  * Description: Undoes the changes made by FCF_SetTabPosition.                *
  ****************************************************************************]]
function me:SetTabPosition ( Offset )
	local ID = self:GetID();
	local TabFrame = TabFrames[ ID ];
	local Background = _G[ self:GetName().."Background" ];

	TabFrame:ClearAllPoints();
	if ( ID == 2 ) then
		TabFrame:SetPoint( "BOTTOMRIGHT", Background, "TOPRIGHT" );
	else
		TabFrame:SetPoint( "BOTTOMLEFT", Background, "TOPLEFT",
			ID == 1 and 0 or ( Offset - 3 ), 0 );
	end
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.UpdateCombatLogPosition                  *
  * Description: Undoes the changes made by FCF_UpdateCombatLogPosition.       *
  ****************************************************************************]]
function me.UpdateCombatLogPosition ()
	ChatFrame2:ClearAllPoints();
	ChatFrame2:SetPoint( "BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 4, 0 );
	ChatFrame2:SetPoint( "RIGHT", _Underscore.ActionBars.BackdropRight, "LEFT", -2, 0 );
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.UpdateDockPosition                       *
  * Description: Undoes the changes made by FCF_UpdateDockPosition.            *
  ****************************************************************************]]
function me.UpdateDockPosition ()
	ChatFrame1:ClearAllPoints();
	ChatFrame1:SetPoint( "BOTTOMLEFT", _Underscore.ActionBars.BackdropBottomLeft, "TOPLEFT", _Underscore.Backdrop.Padding, 6 );
	ChatFrame1:SetPoint( "RIGHT", _Underscore.ActionBars.BackdropBottomRight, "LEFT" );
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.ToggleLock                               *
  * Description: Replaces FCF_ToggleLock.                                      *
  ****************************************************************************]]
function me.ToggleLock ()
	local ChatFrame = FCF_GetCurrentChatFrame();
	FCF_SetLocked( ChatFrame, not ChatFrame.isLocked and 1 or nil );
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout:SetLocked                                *
  * Description: Undoes the changes made by FCF_SetLocked.                     *
  ****************************************************************************]]
function me:SetLocked ( IsLocked )
	local ID = self:GetID();

	if ( ID == 1 or ID == 2 ) then
		SetChatWindowLocked( ID, 1 );
	else
		local Method = IsLocked and "Hide" or "Show";
		for _, Region in ipairs( Borders[ self ] ) do
			Region[ Method ]( Region );
		end
	end
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout:SetButtonSide                            *
  * Description: Undoes the changes made by FCF_SetButtonSide.                 *
  ****************************************************************************]]
function me:SetButtonSide ()
	local BottomButton = Buttons[ self ].Bottom
	BottomButton:ClearAllPoints();
	BottomButton:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
	BottomButton:SetPoint( "BOTTOMRIGHT", self, 0, -6 );
end


--[[****************************************************************************
  * Function: _Underscore.Chat.Layout:ChatFrameOnShow                          *
  * Description: Keep the up and down buttons hidden.                          *
  ****************************************************************************]]
function me:ChatFrameOnShow ()
	local ButtonList = Buttons[ self or this ]; -- Workaround for bug in Blizzard_CombatLog
	ButtonList.Up:Hide();
	ButtonList.Down:Hide();
end


--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.OnUpdate                                 *
  * Description: Keeps visible chat frames' tabs visible as well.              *
  ****************************************************************************]]
do
	local GetChatWindowInfo = GetChatWindowInfo;
	local select = select;
	local ipairs = ipairs;
	local BottomButton, Shown, Docked, TabFrame, _;
	function me.OnUpdate ()
		for Index, ChatFrame in ipairs( ChatFrames ) do
			if ( ChatFrame:IsVisible() ) then
				-- Show bottom button when necessary
				BottomButton = Buttons[ ChatFrame ].Bottom;
				if ( ChatFrame:AtBottom() ) then
					BottomButton:Hide();
				else
					BottomButton:Show();
				end
			end

			-- Keep tab visible
			Shown, _, Docked = select( 7, GetChatWindowInfo( Index ) );
			if ( Shown or ( Docked and Docked > 0 ) ) then -- In use
				TabFrame = TabFrames[ Index ];
				TabFrame:SetAlpha( Shown
					and ( ExpandedFrames[ ChatFrame ] and 1.0 or me.ButtonAlpha )
					or me.ButtonAlpha / 2 );
				TabFrame:Show();
			end
		end
	end
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.OnEvent                                  *
  * Description: Repositions the two main chat windows after they're updated.  *
  ****************************************************************************]]
function me:OnEvent ()
	-- UPDATE_CHAT_WINDOWS
	-- General
	ChatFrame1:SetUserPlaced( false );
	FCF_SetWindowName( ChatFrame1, GENERAL );
	FCF_SetWindowColor( ChatFrame1, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b );
	FCF_SetWindowAlpha( ChatFrame1, DEFAULT_CHATFRAME_ALPHA );
	FCF_SetChatWindowFontSize( nil, ChatFrame2, 12 );
	me.UpdateDockPosition();
	me.Expand( ChatFrame1, false );
	ChatFrame1:Show();
	FCF_SetLocked( ChatFrame1, 1 );

	-- Combat Log
	ChatFrame2:SetUserPlaced( false );
	FCF_SetWindowName( ChatFrame2, COMBAT_LOG );
	FCF_SetWindowColor( ChatFrame2, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b );
	FCF_SetWindowAlpha( ChatFrame2, DEFAULT_CHATFRAME_ALPHA );
	if ( not InCombatLockdown() ) then
		FCF_UnDockFrame( ChatFrame2 );
	end
	FCF_SetChatWindowFontSize( nil, ChatFrame2, 8 );
	me.UpdateCombatLogPosition();
	me.Expand( ChatFrame2, false );
	ChatFrame2:Show();
	FCF_SetLocked( ChatFrame2, 1 );

	-- Move frames and tabs front of lowest-level frames
	for _, ChatFrame in ipairs( ChatFrames ) do
		ChatFrame:SetFrameStrata( "LOW" );
	end
	for _, TabFrame in ipairs( TabFrames ) do
		TabFrame:SetFrameStrata( "LOW" );
	end
end




--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.Tab:DropDownInitialize                   *
  * Description: Disables obsolete buttons from dropdown menus.                *
  ****************************************************************************]]
function Tab:DropDownInitialize ( Level )
	if ( Level == 1 ) then
		local Disabled = DisabledMenuButtons[ self:GetParent() ];
		for ButtonIndex = 1, DropDownList1.numButtons do
			local Button = _G[ "DropDownList1Button"..ButtonIndex ];
			if ( Disabled[ Button.value ] ) then
				Button:Disable();
			end
		end
	end
end

--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.Tab:StopMovingOrSizing                   *
  * Description: Stops the chat frame from moving when the tab stops moving.   *
  ****************************************************************************]]
function Tab:StopMovingOrSizing ()
	ChatFrames[ self:GetID() ]:StopMovingOrSizing();
end
--[[****************************************************************************
  * Function: _Underscore.Chat.Layout.Tab:OnDoubleClick                        *
  * Description: Expands or contracts the chat window.                         *
  ****************************************************************************]]
function Tab:OnDoubleClick ()
	local ChatFrame = ChatFrames[ self:GetID() ];
	me.Expand( ChatFrame, not ExpandedFrames[ ChatFrame ] and true or nil );
end




-- Modify frames
ChatFrameMenuButton:ClearAllPoints();
ChatFrameMenuButton:SetPoint( "RIGHT", ChatFrame1TabText, "LEFT", 2, 0 );
ChatFrameMenuButton:SetScale( 0.5 );
ChatFrameMenuButton:GetNormalTexture():SetAlpha( 0.5 );
ChatFrameMenuButton:SetAlpha( 0.5 );
ChatFrameMenuButton:SetParent( ChatFrame1Tab );
ChatFrameMenuButton:RegisterForClicks( "RightButtonUp" );
_Underscore.AddLockedButton( ChatFrameMenuButton );

local BottomBackdrop = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] };
local BorderSuffixes = {
	"Top", "Bottom", "Left", "Right",
	"TopLeft", "TopRight", "BottomLeft", "BottomRight"
};
local DisabledMenuButtonsNormal = {
	[ RESET_ALL_WINDOWS ] = true;
};
local DisabledMenuButtonsLocked = {
	[ RESET_ALL_WINDOWS ] = true;
	[ UNLOCK_WINDOW ] = true;
	[ LOCK_WINDOW ] = true;
	[ RENAME_CHAT_WINDOW ] = true;
	[ CLOSE_CHAT_WINDOW ] = true;
};
local function ShrinkTabBorder ( TextureName )
	local Texture = _G[ TextureName ];
	local Left, Top, _, _, Right = Texture:GetTexCoord();
	Texture:SetTexCoord( Left, Right, Top, 0.9 );
end
local R, G, B = unpack( _Underscore.Colors.Foreground );
for Index = 1, NUM_CHAT_WINDOWS do
	local Name = "ChatFrame"..Index;
	local ChatFrame = _G[ Name ];
	local TabFrame = _G[ Name.."Tab" ];
	ChatFrames[ Index ] = ChatFrame;
	TabFrames[ Index ] = TabFrame;

	ChatFrame:HookScript( "OnShow", me.ChatFrameOnShow );

	FCF_SetChatWindowFontSize( nil, ChatFrame, 12 );


	-- Save borders
	local BorderList = {};
	for _, Suffix in ipairs( BorderSuffixes ) do
		local Border = _G[ Name.."Resize"..Suffix ];
		tinsert( BorderList, Border );
		if ( Index <= 2 ) then
			Border:Hide();
		end
	end
	Borders[ ChatFrame ] = BorderList;


	-- Hide the scroll buttons
	local DownButton = _G[ Name.."DownButton" ];
	DownButton:Hide();
	local UpButton = _G[ Name.."UpButton" ];
	UpButton:Hide();
	-- Reposition the bottom button and redo artwork
	local BottomButton = _G[ Name.."BottomButton" ];
	BottomButton:SetNormalTexture( nil );
	BottomButton:SetPushedTexture( nil );
	BottomButton:SetDisabledTexture( nil );
	BottomButton:SetBackdrop( BottomBackdrop );
	BottomButton:SetBackdropColor( R, G, B, 0.25 );
	_G[ Name.."BottomButtonFlash" ]:SetTexture( R, G, B, 0.25 );
	Buttons[ ChatFrame ] = {
		Up = UpButton;
		Down = DownButton;
		Bottom = BottomButton;
	};
	me.SetButtonSide( ChatFrame );


	-- Modify chat frame tab
	hooksecurefunc( TabFrame, "StopMovingOrSizing", Tab.StopMovingOrSizing );
	_Underscore.AddLockedButton( TabFrame );
	TabFrame:HookScript( "OnDoubleClick", Tab.OnDoubleClick );
	ShrinkTabBorder( Name.."TabLeft" );
	ShrinkTabBorder( Name.."TabMiddle" );
	ShrinkTabBorder( Name.."TabRight" );

	-- Disable some chat frame functions
	hooksecurefunc( _G[ Name.."TabDropDown" ], "initialize", Tab.DropDownInitialize );
	DisabledMenuButtons[ TabFrame ]
		= Index <= 2 and DisabledMenuButtonsLocked or DisabledMenuButtonsNormal;
end
ChatFrame1TabLeft:SetTexCoord( ChatFrame1TabMiddle:GetTexCoord() );
ChatFrame2TabRight:SetTexCoord( ChatFrame2TabMiddle:GetTexCoord() );


-- Hooks
UIPARENT_MANAGED_FRAME_POSITIONS[ "ChatFrame1" ] = nil;
UIPARENT_MANAGED_FRAME_POSITIONS[ "ChatFrame2" ] = nil;

hooksecurefunc( "FCF_SetTabPosition", me.SetTabPosition );
hooksecurefunc( "FCF_UpdateCombatLogPosition", me.UpdateCombatLogPosition );
hooksecurefunc( "FCF_UpdateDockPosition", me.UpdateDockPosition );
hooksecurefunc( "FCF_SetButtonSide", me.SetButtonSide );
hooksecurefunc( "FCF_SetLocked", me.SetLocked );

ToggleCombatLog = _Underscore.NilFunction;
FCF_Set_SimpleChat = _Underscore.NilFunction;
FCF_ToggleLock = me.ToggleLock;

me:SetScript( "OnUpdate", me.OnUpdate );
me:SetScript( "OnEvent", me.OnEvent );
me:OnEvent();
me:RegisterEvent( "UPDATE_CHAT_WINDOWS" );