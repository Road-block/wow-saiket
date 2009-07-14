--[[****************************************************************************
  * _Clean by Saiket                                                           *
  * _Clean.BigWigs.lua - Modifies the BigWigs addon.                           *
  ****************************************************************************]]


--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

if ( select( 6, GetAddOnInfo( "BigWigs_Plugins" ) ) ~= "MISSING" ) then
	_Clean.RegisterAddOnInitializer( "BigWigs_Plugins", function ()
		-- Reposition bar anchors to the middle of the screen
		hooksecurefunc( BigWigs:GetModule( "Bars" ), "SetupFrames", function ( self, Emphasize )
			local Anchor = Emphasize and BigWigsEmphasizedBarAnchor or BigWigsBarAnchor;
			Anchor:RegisterForDrag();
			Anchor:SetUserPlaced( false );
			Anchor:ClearAllPoints();
			if ( Emphasize ) then
				Anchor:SetPoint( "TOP", _Clean.BottomPane );
			else
				Anchor:SetPoint( "BOTTOM", _Clean.BottomPane, "TOP" );
			end

			local NilFunction = _Clean.NilFunction;
			Anchor.ClearAllPoints = NilFunction;
			Anchor.SetPoint = NilFunction;
			Anchor.StartMoving = NilFunction;
		end );
	end );
end
if ( select( 6, GetAddOnInfo( "BigWigs_Extras" ) ) ~= "MISSING" ) then
	_Clean.RegisterAddOnInitializer( "BigWigs_Extras", function ()
		-- Recolor flash frame red
		local Flash = BigWigs:GetModule( "Flash" );
		local BigWigsMessageBackup = Flash.BigWigs_Message;
		local function VarArg ( ... )
			if ( BWFlash ) then
				local Color = RED_FONT_COLOR;
				BWFlash:SetBackdropColor( Color.r, Color.g, Color.b, select( 4, BWFlash:GetBackdropColor() ) );
				BWFlash:GetRegions():SetBlendMode( "ADD" );
				Flash.BigWigs_Message = BigWigsMessageBackup;
			end
			return ...;
		end
		function Flash:BigWigs_Message ( ... )
			return VarArg( BigWigsMessageBackup( self, ... ) );
		end
	end );
end