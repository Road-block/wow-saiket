--[[****************************************************************************
  * _NPCScan by Saiket                                                         *
  * Localization.lua - Localized string constants (en-US).                     *
  ****************************************************************************]]


do
	local Title = "_|cffCCCC88NPCScan|r";
	local LDQuo, RDQuo = "\226\128\156", "\226\128\157";
	_NPCScanLocalization = setmetatable(
		{
			MESSAGE_FORMAT = Title..": %s";

			FOUND_FORMAT = "Found "..GREEN_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE.."!";
			BUTTON_FOUND = "NPC found!";

			NPC_ADD_FORMAT = "Added NPC "..GRAY_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE.." (ID %d).";
			NPC_REMOVE_FORMAT = "Removed NPC "..GRAY_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE.." (ID %d).";

			ALREADY_CACHED_FORMAT = "Consider clearing your cache to reset the following units: %s.";
			NAME_FORMAT = GRAY_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE;
			NAME_SEPARATOR = ", ";

			CMD_ADD = "ADD";
			CMD_ADDDUPLICATE_FORMAT = "NPC "..GRAY_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE.." (ID %d) already being searched for.";
			CMD_REMOVE = "REMOVE";
			CMD_REMOVENOTFOUND_FORMAT = "NPC "..GRAY_FONT_COLOR_CODE..LDQuo.."%s"..RDQuo..FONT_COLOR_CODE_CLOSE.." not found. (Case sensitive!)";
			CMD_HELP = "Commands are "..GRAY_FONT_COLOR_CODE..LDQuo.."/npcscan add "..GREEN_FONT_COLOR_CODE.."<NpcID> <Name>"..GRAY_FONT_COLOR_CODE..RDQuo..FONT_COLOR_CODE_CLOSE.." and "..GRAY_FONT_COLOR_CODE..LDQuo.."/npcscan remove "..GREEN_FONT_COLOR_CODE.."<Name>"..GRAY_FONT_COLOR_CODE..RDQuo..FONT_COLOR_CODE_CLOSE..".";
		}, {
			__index = function ( self, Key )
				rawset( self, Key, Key );
				return Key;
			end;
		} );




--------------------------------------------------------------------------------
-- Globals
----------

	SLASH__NPCSCAN1 = "/npcscan";
	SLASH__NPCSCAN2 = "/scan";

	BINDING_HEADER__NPCSCAN = Title;
	_G[ "BINDING_NAME_CLICK _NPCScanButton:LeftButton" ] = "Target found unit";
end
