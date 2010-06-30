--[[****************************************************************************
  * oUF_SpellRange by Saiket                                                   *
  * oUF_SpellRange.lua - Improved range element for oUF.                       *
  *                                                                            *
  * Elements handled: .SpellRange                                              *
  * Settings: (Either override method or both alpha properties are required)   *
  *   - :SpellRangeOverride( InRange ) - Callback fired when a unit either     *
  *       enters or leaves range. Overrides default alpha changing.            *
  *   OR                                                                       *
  *   - .inRangeAlpha - Frame alpha value for units in range.                  *
  *   - .outsideRangeAlpha - Frame alpha for units out of range.               *
  * Note that SpellRange will automatically disable Range elements of frames.  *
  ****************************************************************************]]


local oUF = select( 2, ... ).oUF or _G[ assert( GetAddOnMetadata( ..., "X-oUF" ), "X-oUF metadata missing in parent addon." ) ];
assert( oUF, "Unable to locate oUF." );

local UpdateRate = 0.1;

local UpdateFrame;
local Objects = {};
local ObjectRanges = {};

-- Class-specific spell info
local HelpID, HelpName, CanHelp; -- ID of spell, and whether it is known by the player
local HarmID, HarmName, CanHarm;




--- Uses an appropriate range check for the given unit.
-- Actual range depends on reaction, known spells, and status of the unit.
-- @param UnitID  Unit to check range for.
-- @return True if in casting range.
local IsInRange;
do
	local UnitIsConnected = UnitIsConnected;
	local UnitCanAssist = UnitCanAssist;
	local UnitCanAttack = UnitCanAttack;
	local UnitIsUnit = UnitIsUnit;
	local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid;
	local UnitIsDead = UnitIsDead;
	local UnitOnTaxi = UnitOnTaxi;
	local UnitInRange = UnitInRange;
	local IsSpellInRange = IsSpellInRange;
	local CheckInteractDistance = CheckInteractDistance;
	function IsInRange ( UnitID )
		if ( UnitIsConnected( UnitID ) ) then
			if ( UnitCanAssist( "player", UnitID ) ) then
				if ( CanHelp and not UnitIsDead( UnitID ) ) then
					return IsSpellInRange( HelpName, UnitID ) == 1;
				elseif ( not UnitOnTaxi( "player" ) -- UnitInRange always returns nil while on flightpaths
					and ( UnitIsUnit( UnitID, "player" ) or UnitIsUnit( UnitID, "pet" )
						or UnitPlayerOrPetInParty( UnitID ) or UnitPlayerOrPetInRaid( UnitID ) )
				) then
					return UnitInRange( UnitID ); -- Fast checking for self and party members (38 yd range)
				end
			elseif ( CanHarm and not UnitIsDead( UnitID ) and UnitCanAttack( "player", UnitID ) ) then
				return IsSpellInRange( HarmName, UnitID ) == 1;
			end

			-- Fallback when spell not found or class uses none
			return CheckInteractDistance( UnitID, 4 ); -- Follow distance (28 yd range)
		end
	end
end
--- Rechecks range for a unit frame, and fires callbacks when the unit passes in or out of range.
local UpdateRange;
do
	local InRange;
	function UpdateRange ( self )
		InRange = not not IsInRange( self.unit ); -- Cast to boolean
		if ( ObjectRanges[ self ] ~= InRange ) then -- Range state changed
			ObjectRanges[ self ] = InRange;

			if ( self.SpellRangeOverride ) then
				self:SpellRangeOverride( InRange );
			else
				self:SetAlpha( self[ InRange and "inRangeAlpha" or "outsideRangeAlpha" ] );
			end
		end
	end
end
--- Checks whether the player knows his or her class-specific range checking spells.
local UpdateSpells;
do
	local IsSpellKnown = IsSpellKnown;
	function UpdateSpells ()
		-- Set to true if spell is in spellbook, and cache its name
		if ( HelpID ) then
			CanHelp = IsSpellKnown( HelpID );
			if ( CanHelp and not HelpName ) then
				HelpName = GetSpellInfo( HelpID );
			end
		end
		if ( HarmID ) then
			CanHarm = IsSpellKnown( HarmID );
			if ( CanHarm and not HarmName ) then
				HarmName = GetSpellInfo( HarmID );
			end
		end
	end
end


--- Updates the range display for all visible oUF unit frames on an interval.
local OnUpdate;
do
	local NextUpdate = 0;
	function OnUpdate ( self, Elapsed )
		NextUpdate = NextUpdate - Elapsed;
		if ( NextUpdate <= 0 ) then
			NextUpdate = UpdateRate;

			UpdateSpells();
			for Object in pairs( Objects ) do
				if ( Object:IsVisible() ) then
					UpdateRange( Object );
				end
			end
		end
	end
end


--- Called by oUF for new unit frames to setup range checking.
-- @return True if the range element was actually enabled.
local function Enable ( self, UnitID )
	if ( self.SpellRange ) then
		assert( type( self.SpellRangeOverride ) == "function"
			or ( type( self.inRangeAlpha ) == "number" and type( self.outsideRangeAlpha ) == "number" ),
			"oUF layout addon omitted required SpellRange properties." );
		if ( self.Range ) then -- Disable default range checking
			self:DisableElement( "Range" );
			self.Range = nil;
		end

		if ( not UpdateFrame ) then
			UpdateFrame = CreateFrame( "Frame" );
			UpdateFrame:SetScript( "OnUpdate", OnUpdate );
		else
			UpdateFrame:Show();
		end
		Objects[ self ] = true;
		return true;
	end
end
--- Called by oUF to disable range checking on a unit frame.
local function Disable ( self )
	Objects[ self ] = nil;
	ObjectRanges[ self ] = nil;
	if ( not next( Objects ) ) then
		UpdateFrame:Hide();
	end
end
--- Called by oUF when the unit frame's unit changes or otherwise needs a complete update.
-- @param Event  Reason for the update, defined by oUF rather than by real events.
local function Update ( self, Event, UnitID )
	if ( Event ~= "OnTargetUpdate" ) then -- Caused by a real event
		UpdateSpells();
		ObjectRanges[ self ] = nil; -- Force update to fire
		UpdateRange( self ); -- Update range immediately
	end
end




local _, Class = UnitClass( "player" );
--- Optional low level baseline skills with greater than 28 yard range
HelpID = ( {
	DRUID = 5185; -- Healing Touch
	MAGE = 1459; -- Arcane Intellect
	PALADIN = 635; -- Holy Light
	PRIEST = 2050; -- Lesser Heal
	SHAMAN = 331; -- Healing Wave
	WARLOCK = 5697; -- Unending Breath
} )[ Class ];
HarmID = ( {
	DEATHKNIGHT = 52375; -- Death Coil
	DRUID = 5176; -- Wrath
	HUNTER = 75; -- Auto Shot
	MAGE = 133; -- Fireball
	PALADIN = 62124; -- Hand of Reckoning
	PRIEST = 585; -- Smite
	SHAMAN = 403; -- Lightning Bolt
	WARLOCK = 686; -- Shadow Bolt
	WARRIOR = 355; -- Taunt
} )[ Class ];

oUF:AddElement( "SpellRange", Update, Enable, Disable );