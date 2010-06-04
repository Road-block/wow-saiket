--[[ _NPCScan.Tools by Saiket
Tools/UpdateTamableIDs.lua - Pulls tamable NPC IDs and locations from WowHead and WoWDB.

1. Prepare database files from the WoW client: (Only needs to be done once per WoW patch)
   a. Find the latest versions of these DBC files in WoW's MPQ archives using a
      tool such as WinMPQ:
      * <DBFilesClient/CreatureFamily.dbc>
      * <DBFilesClient/WorldMapArea.dbc>
      * <DBFilesClient/AreaTable.dbc>
   b. Extract them to the <DBFilesClient> folder.
   c. Run <DBCUtil.bat> to convert all found *.DBC files into *.CSV files using
      nneonneo's <DBCUtil.exe> program.

This script must be run with a standalone Lua 5.1 interpreter, and it
overwrites <../../_NPCScan/_NPCScan.TamableIDs.lua>.
]]




local RareMapOverrides = { -- [ NpcID ] = ForcedMapID;
	[ 11497 ] = 13; -- "The Razza" spawns in the Dire Maul courtyard, which doesn't properly appear in Feralas. Use Kalimdor map instead.
};
local OutputFilename = [[../../_NPCScan/_NPCScan.TamableIDs.lua]];


-- Create a list of all tamable creature types for the WowHead query
require( "DbcCSV" );
local CreatureFamilies = DbcCSV.Parse( [[DBFilesClient/CreatureFamily.dbc.csv]], 1,
	"ID", nil, nil, nil, nil, nil, nil, nil, "PetTalentType" );

local PetTypes = {};
for ID, CreatureFamily in pairs( CreatureFamilies ) do
	if ( CreatureFamily.PetTalentType ~= -1 ) then -- Tamable mob type
		PetTypes[ #PetTypes + 1 ] = ID;
	end
end


-- Create a lookup for zone AreaTable IDs used by WowHead to WorldMapArea IDs
local WorldMapAreas = DbcCSV.Parse( [[DBFilesClient/WorldMapArea.dbc.csv]], 1,
	"ID", nil, "AreaTableID" );
local AreaTable = DbcCSV.Parse( [[DBFilesClient/AreaTable.dbc.csv]], 1,
	"ID", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "Localization" );

local MapIDs, MapNames = {}, {};
for ID, WorldMapArea in pairs( WorldMapAreas ) do
	if ( WorldMapArea.AreaTableID ~= 0 ) then -- Not a continent
		MapIDs[ WorldMapArea.AreaTableID ] = ID;
		MapNames[ ID ] = AreaTable[ WorldMapArea.AreaTableID ].Localization;
	end
end


local http = require( "socket.http" );
require( "Json" );
require( "bit" );




local GetNpcMap; -- Returns the mob's primary MapID
do
	local function SelectPrimaryMap ( Data ) -- Returns the map ID this mob is seen in the most
		-- Validate map data and choose the primary zone
		local PrimaryCount, PrimaryMap = 0;
		for _, MapData in ipairs( Data ) do
			assert( MapData.mapType == "npc", "Invalid mapType "..tostring( MapData.mapType ).."." );
			local AreaTableID = assert( tonumber( MapData.locationID ), "Invalid AreaTableID "..tostring( MapData.locationID ).."." );

			local CountTotal = 0;
			for _, Coord in ipairs( MapData.coords ) do
				Coord[ 3 ] = tonumber( Coord[ 3 ]:match( "<div>Spotted here (%d+) times</div>" ) );
				CountTotal = CountTotal + Coord[ 3 ];
				for Index = 4, #Coord do -- Clear unused data
					Coord[ Index ] = nil;
				end
			end

			if ( CountTotal > PrimaryCount ) then
				PrimaryCount = CountTotal;
				PrimaryMap = MapData;
			end
		end

		assert( PrimaryMap, "No points found for NPC." );
		return MapIDs[ tonumber( PrimaryMap.locationID ) ] or true;
	end
	function GetNpcMap ( NpcID )
		local Text, Status = http.request( [[http://www.wowdb.com/npc.aspx?id=]]..NpcID );
		if ( not Text ) then
			print( "    - Request failed:", Status );
		elseif ( math.floor( Status / 100 ) ~= 2 ) then
			print( "    - Invalid status code:", Status );
		else
			if ( Status ~= 200 ) then
				print( "    + Status code "..Status..":", #Text.." bytes." );
			end

			Text = Text:match( [[<script>addMapLocations%((.*)%)</script>]] );
			if ( not Text ) then
				print( "    - Could not find map location data!" );
			else
				Text = Text:gsub( ",([%]}])", "%1" ); -- Extra commas aren't allowed
				Text = Text:gsub( "([{,])%s*(%w+)%s*:%s*", [[%1"%2":]] ); -- Key identifiers must be wrapped in quotes!
				local Success, Data = pcall( Json.Decode, Text );

				if ( not Success ) then
					print( "    - Couldn't parse map data:", Data:sub( 1, 128 ) );
				else
					local Success, MapID = pcall( SelectPrimaryMap, Data );
					if ( not Success ) then
						print( "    - "..MapID );
					else
						return MapID;
					end
				end
			end
		end
	end
end


local function HandleRare ( NpcData ) -- Parses WowHead's rare data
	local ID = assert( tonumber( NpcData.id ), "Invalid Npc ID "..tostring( NpcData.id ).."." );
	local Name = assert( NpcData.name, "Missing Npc name." );
	print( ( "  + [npc:%d] %s" ):format( ID, Name ) );

	local MapID;
	if ( RareMapOverrides[ ID ] ) then
		print( "    - Map override set; Ignoring reported zone." );
		MapID = RareMapOverrides[ ID ];
	else
		local LocationTable = assert( NpcData.location, "Missing location table." );
		assert( type( LocationTable ) == "table" and #LocationTable > 0, "Invalid location table." );

		if ( #LocationTable == 1 ) then
			local AreaTableID = LocationTable[ 1 ];
			MapID = MapIDs[ AreaTableID ] or true;
		else -- Check WoWDB for the most frequent zone
			print( "    - Multiple possible zones: Checking with WoWDB..." );
			MapID = GetNpcMap( ID );
			if ( not MapID ) then -- WoWDB had no data
				print( "    - No results; Falling back on WowHead data." );
				local AreaTableID = LocationTable[ 1 ];
				MapID = MapIDs[ AreaTableID ] or true;
			end
		end
	end

	if ( MapID == true ) then
		print( "    - Mapless zone; Don't filter by location." );
	else
		print( ( "    + [map:%d] %s" ):format( MapID, MapNames[ MapID ] or "" ) );
	end
	return { ID = ID; Name = Name; MapID = MapID; };
end




print( "____" );
print( "Reading rare mob data:" );

-- Query to filter all rare/rare elite tamable mobs
local Query = ( "http://www.wowhead.com/?npcs&filter=cl=4:2;fa=%s" ):format( table.concat( PetTypes, ":" ) );
local ListViewPattern = [[<script type="text/javascript">//<!%[CDATA%[
new Listview%((%b{})%);
//%]%]></script>]]

local function ReplaceSingleQuotes ( Escapes )
	if ( #Escapes % 2 == 0 ) then -- Even number; not escaped.
		return Escapes..[["]];
	end
end

local Text, Status = http.request( Query );
if ( not Text ) then
	print( "  - Request failed:", Status );
elseif ( math.floor( Status / 100 ) ~= 2 ) then
	print( "  - Invalid status code:", Status );
else
	if ( Status ~= 200 ) then
		print( "  + Status code "..Status..":", #Text.." bytes." );
	end

	Text = Text:match( ListViewPattern );
	if ( not Text ) then
		print( "  - Could not find rare mob data!" );
	else
		Text = Text:gsub( ",+([%]}])", "%1" ); -- Extra commas aren't allowed
		Text = Text:gsub( "([%[{]),+", "%1" );
		Text = Text:gsub( "([{,])%s*(%w+)%s*:%s*", [[%1"%2":]] ); -- Key identifiers must be wrapped in quotes!
		Text = Text:gsub( "(\\*)'", ReplaceSingleQuotes );
		local Success, ListData = pcall( Json.Decode, Text );

		if ( not Success ) then
			print( "  - Couldn't parse rare mob data:", ListData:sub( 1, 128 ) );
		else
			assert( ListData.id == "npcs", "Invalid id "..tostring( ListData.id ).."." );

			local RaresList = {};
			for _, NpcData in ipairs( ListData.data ) do
				local Success, Rare = pcall( HandleRare, NpcData );
				if ( not Success ) then
					print( "    - "..Rare );
				else
					RaresList[ #RaresList + 1 ] = Rare;
				end
			end

			-- Sort by npc name
			table.sort( RaresList, function ( Rare1, Rare2 )
				return Rare1.Name < Rare2.Name;
			end );


			-- Write table
			local Outfile = assert( io.open( OutputFilename, "w+" ) );

			Outfile:write( "-- AUTOMATICALLY GENERATED BY <_NPCScan.Tools/Tools/UpdateTamableIDs.lua>!\n" );
			Outfile:write( "_NPCScan.TamableIDs = {\n" );

			for _, Rare in ipairs( RaresList ) do
				if ( Rare.MapID == true ) then
					Outfile:write( ( "\t[ %d ] = true; -- \"%s\"\n" ):format( Rare.ID, Rare.Name ) );
				else
					local MapName = MapNames[ Rare.MapID ];
					if ( not MapName ) then -- Probably overridden to a continent map
						Outfile:write( ( "\t[ %d ] = %d; -- \"%s\"\n" ):format( Rare.ID, Rare.MapID, Rare.Name ) );
					else
						Outfile:write( ( "\t[ %d ] = %d; -- \"%s\" from %s\n" ):format( Rare.ID, Rare.MapID, Rare.Name, MapName ) );
					end
				end
			end

			Outfile:write( "};\n" );

			Outfile:flush();
			Outfile:close();
		end
	end
end