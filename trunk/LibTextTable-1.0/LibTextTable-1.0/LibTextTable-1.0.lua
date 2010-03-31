--[[****************************************************************************
  * LibTextTable-1.0 by Saiket                                                 *
  * LibTextTable-1.0.lua - Creates table controls for tabular text data.       *
  ****************************************************************************]]


local MAJOR, MINOR = "LibTextTable-1.0", 4;

local lib = LibStub:NewLibrary( MAJOR, MINOR );
if ( not lib ) then
	return;
end

lib.RowMeta = { __index = {}; };
local RowMethods = lib.RowMeta.__index;
lib.TableMeta = { __index = {}; };
local TableMethods = lib.TableMeta.__index;

local RowHeight = 14;
local ColumnPadding = 6;




--[[****************************************************************************
  * Function: local RowOnClick                                                 *
  * Description: Selects a row element when the row is clicked.                *
  ****************************************************************************]]
local function RowOnClick ( Row )
	Row:GetParent().Table:SetSelection( Row );
end
--[[****************************************************************************
  * Function: local RowInsert                                                  *
  * Description: Creates a new row button for the table.                       *
  ****************************************************************************]]
local function RowInsert ( Table, Index )
	local Rows = Table.Rows;
	Index = Index or #Rows + 1;

	local Row = next( Table.UnusedRows );
	if ( Row ) then
		Table.UnusedRows[ Row ] = nil;
		Row:Show();
	else
		Row = CreateFrame( "Button", nil, Rows );
		Row:SetScript( "OnClick", RowOnClick );
		Row:RegisterForClicks( "AnyUp" );
		Row:SetHeight( RowHeight );
		Row:SetPoint( "LEFT" );
		Row:SetPoint( "RIGHT", Table.Body ); -- Expand to right side of view
		Row:SetHighlightTexture( [[Interface\FriendsFrame\UI-FriendsFrame-HighlightBar]], "ADD" );
		-- Apply row methods
		if ( not getmetatable( RowMethods ) ) then
			setmetatable( RowMethods, getmetatable( Row ) );
		end
		setmetatable( Row, lib.RowMeta );
	end

	if ( Rows[ Index ] ) then -- Move old row below new one
		Rows[ Index ]:SetPoint( "TOP", Row, "BOTTOM" );
	end
	if ( Index == 1 ) then
		Row:SetPoint( "TOP" );
	else
		Row:SetPoint( "TOP", Rows[ Index - 1 ], "BOTTOM" );
	end

	Row:SetID( Index );
	tinsert( Rows, Index, Row );
	return Row;
end
--[[****************************************************************************
  * Function: local RowRemove                                                  *
  * Description: Hides a row button and allows it to be recycled.              *
  ****************************************************************************]]
local RowRemove;
do
	local function ClearElements ( Count, ... )
		for Index = 1, Count do
			local Element = select( Index, ... );
			Element:Hide();
			Element:SetText();
		end
	end
	function RowRemove ( Table, Index )
		local Rows = Table.Rows;
		local Row = Rows[ Index ];

		tremove( Rows, Index );
		Table.UnusedRows[ Row ] = true;
		Row:Hide();
		Row.Key = nil;
		ClearElements( Table.NumColumns, Row:GetRegions() );
		for Column = 1, Table.NumColumns do -- Remove values
			Row[ Column ] = nil;
		end
		-- Reanchor next row
		local NextRow = Rows[ Index ];
		if ( NextRow ) then
			if ( Index == 1 ) then
				NextRow:SetPoint( "TOP" );
			else
				NextRow:SetPoint( "TOP", Rows[ Index - 1 ], "BOTTOM" );
			end
		end
	end
end




--[[****************************************************************************
  * Function: RowObject:GetNumRegions                                          *
  ****************************************************************************]]
do
	local RowMethodsOriginal = getmetatable( BasicScriptErrorsButton ).__index; -- Generic button metatable
	function RowMethods:GetNumRegions ()
		return RowMethodsOriginal.GetNumRegions( self ) - 1; -- Skip highlight region
	end
--[[****************************************************************************
  * Function: RowObject:GetRegions                                             *
  ****************************************************************************]]
	function RowMethods:GetRegions ()
		return select( 2, RowMethodsOriginal.GetRegions( self ) ); -- Skip highlight region
	end
end
--[[****************************************************************************
  * Function: RowObject:GetData                                                *
  * Description: Returns the row's key and all original element data.          *
  ****************************************************************************]]
function RowMethods:GetData ()
	return self.Key, unpack( self, 1, self:GetParent().Table.NumColumns );
end




--[[****************************************************************************
  * Function: TableObject:Clear                                                *
  * Description: Empties the table of all rows.                                *
  ****************************************************************************]]
function TableMethods:Clear ()
	local Rows = self.Rows;
	if ( #Rows > 0 ) then
		if ( self.View.YScroll ) then -- Force correct view resize
			self.View.YScroll:SetValue( 0 );
		end
		self:SetSelection();
		wipe( self.Keys );
		for Index = #Rows, 1, -1 do -- Remove in reverse so rows don't move mid-loop
			RowRemove( self, Index );
		end
		self:Resize();
		return true;
	end
end
--[[****************************************************************************
  * Function: TableObject:SetHeader                                            *
  * Description: Sets the headers for the data table to the list of header     *
  *   labels provided.  Labels with value nil will have no label text.         *
  ****************************************************************************]]
do
	local function ColumnOnClick ( Column ) -- Sorts by this column
		Column:GetParent().Table:SetSortColumn( Column );
		PlaySound( "igMainMenuOptionCheckBoxOn" );
	end
	local function ColumnCreate ( Header ) -- Creates a new column header for the table
		local Index = #Header + 1;
		local Column = CreateFrame( "Button", nil, Header );

		Column:SetScript( "OnClick", ColumnOnClick );
		Column:SetID( Index );
		Column:SetFontString( Column:CreateFontString( nil, "ARTWORK", Header.Table.HeaderFont or "GameFontHighlightSmall" ) );
		Column:SetPoint( "TOP" );
		Column:SetPoint( "BOTTOM" );
		if ( Index == 1 ) then
			Column:SetPoint( "LEFT" );
		else
			Column:SetPoint( "LEFT", Header[ Index - 1 ], "RIGHT" );
		end

		-- Artwork
		local Left = Column:CreateTexture( nil, "BACKGROUND" );
		Left:SetPoint( "TOPLEFT" );
		Left:SetPoint( "BOTTOM" );
		Left:SetWidth( 5 );
		Left:SetTexture( [[Interface\FriendsFrame\WhoFrame-ColumnTabs]] );
		Left:SetTexCoord( 0, 0.078125, 0, 0.75 );
		local Right = Column:CreateTexture( nil, "BACKGROUND" );
		Right:SetPoint( "TOPRIGHT" );
		Right:SetPoint( "BOTTOM" );
		Right:SetWidth( 4 );
		Right:SetTexture( [[Interface\FriendsFrame\WhoFrame-ColumnTabs]] );
		Right:SetTexCoord( 0.90625, 0.96875, 0, 0.75 );
		local Middle = Column:CreateTexture( nil, "BACKGROUND" );
		Middle:SetPoint( "TOPLEFT", Left, "TOPRIGHT" );
		Middle:SetPoint( "BOTTOMRIGHT", Right, "BOTTOMLEFT" );
		Middle:SetTexture( [[Interface\FriendsFrame\WhoFrame-ColumnTabs]] );
		Middle:SetTexCoord( 0.078125, 0.90625, 0, 0.75 );
		local Highlight = Column:CreateTexture( nil, "HIGHLIGHT" );
		Highlight:SetAllPoints();
		Highlight:SetTexture( [[Interface\Buttons\UI-Panel-Button-Highlight]] );
		Highlight:SetTexCoord( 0, 0.625, 0, 0.6875 );
		Highlight:SetBlendMode( "ADD" );
		local Backdrop = Column:CreateTexture();
		Backdrop:SetPoint( "TOPLEFT", Column, "BOTTOMLEFT" );
		Backdrop:SetPoint( "RIGHT" );
		Backdrop:SetPoint( "BOTTOM", Header.Table.Body ); -- Expand to bottom of view
		Backdrop:SetTexture( 0.15, 0.15, 0.15, 0.25 );
		Column:SetHighlightTexture( Backdrop, "ADD" );

		Header[ Index ] = Column;
		return Column;
	end
	function TableMethods:SetHeader ( ... )
		local Header = self.Header;
		local NumColumns = select( "#", ... );
		if ( self.View.XScroll ) then -- Force correct view resize
			self.View.XScroll:SetValue( 0 );
		end

		-- Create necessary column buttons
		if ( #Header < NumColumns ) then
			for Index = #Header + 1, NumColumns do
				ColumnCreate( Header );
			end
		end

		-- Fill out buttons
		for Index = 1, NumColumns do
			local Column = Header[ Index ];
			local Value = select( Index, ... );
			Column:SetText( Value ~= nil and tostring( Value ) or nil );
			Column:Show();
		end
		for Index = NumColumns + 1, #Header do -- Hide unused
			local Column = Header[ Index ];
			Column:Hide();
			Column:SetText();
			Column.Sort = nil;
		end

		if ( not self:Clear() ) then
			self:Resize(); -- Fit to only headers
		end
		self.NumColumns = NumColumns;
		self:SetSortHandlers(); -- None
	end
end
--[[****************************************************************************
  * Function: TableObject:SetSortHandlers                                      *
  * Description: Allows or disallows sorting of each column with a custom sort *
  *   function.  Sort functions are passed to table.sort, and a value of true  *
  *   uses the default table.sort comparison.                                  *
  ****************************************************************************]]
function TableMethods:SetSortHandlers ( ... )
	local Header = self.Header;
	for Index = 1, self.NumColumns do
		local Column = Header[ Index ];
		local Handler = select( Index, ... );

		Column.Sort = Handler;
		if ( Handler ) then
			Column:Enable();
		else
			Column:Disable();
		end
	end
	self:SetSortColumn(); -- None
end
--[[****************************************************************************
  * Function: TableObject:SetSortColumn                                        *
  * Description: Selects or clears the column to sort by.                      *
  ****************************************************************************]]
function TableMethods:SetSortColumn ( SortColumn, Inverted )
	local Header = self.Header;

	if ( tonumber( SortColumn ) ) then
		SortColumn = Header[ tonumber( SortColumn ) ];
	end

	if ( Header.SortColumn ~= SortColumn ) then
		if ( Header.SortColumn ) then
			Header.SortColumn:UnlockHighlight();
		end
		Header.SortColumn = SortColumn;
		Header.SortInverted = Inverted or false;
		if ( SortColumn ) then
			SortColumn:LockHighlight();
			self:Sort();
		end
	elseif ( SortColumn ) then -- Selected same sort column
		if ( Inverted == nil ) then -- Unspecified; Flip inverted status
			Inverted = not Header.SortInverted;
		end
		if ( Header.SortInverted ~= Inverted ) then
			Header.SortInverted = Inverted;
			self:Sort();
		end
	end
end
--[[****************************************************************************
  * Function: TableObject:Sort                                                 *
  * Description: Schedules rows to be resorted on the next OnUpdate.           *
  ****************************************************************************]]
do
	local tostring = tostring;
	local function SortSimple ( Val1, Val2 )
		Val1, Val2 = Val1 == nil and "" or tostring( Val1 ), Val2 == nil and "" or tostring( Val2 );
		if ( Val1 ~= Val2 ) then
			return Val1 < Val2;
		end
	end
	local Handler, Column, Inverted;
	local function Compare ( Row1, Row2 )
		if ( Inverted ) then
			Row1, Row2 = Row2, Row1;
		end
		local Result = Handler( Row1[ Column ], Row2[ Column ], Row1, Row2 );
		if ( Result ~= nil ) then -- Not equal
			return Result;
		else -- Equal
			return Row1:GetID() < Row2:GetID(); -- Fall back on previous row order
		end
	end
	local function OnUpdate ( Header )
		Header:SetScript( "OnUpdate", nil );
		local Rows = Header.Table.Rows;
		if ( Header.SortColumn and #Rows > 0 ) then

			Column = Header.SortColumn:GetID();
			Handler, Inverted = Header.SortColumn.Sort, Header.SortInverted;
			if ( Handler == true ) then
				Handler = SortSimple; -- Less-than operator
			end
			sort( Rows, Compare );

			-- Clear all old anchors first
			for Index, Row in ipairs( Rows ) do
				Row:SetID( Index );
				Row:SetPoint( "TOP" );
			end
			for Index = 2, #Rows do -- First row already anchored at top
				Rows[ Index ]:SetPoint( "TOP", Rows[ Index - 1 ], "BOTTOM" );
			end
		end
	end
	function TableMethods:Sort ()
		self.Header:SetScript( "OnUpdate", OnUpdate );
	end
end
--[[****************************************************************************
  * Function: TableObject:AddRow                                               *
  * Description: Adds a row of strings to the table with the current header.   *
  ****************************************************************************]]
do
	local function RowAddElements ( Table, Row ) -- Adds and anchors missing element strings
		local Columns = Table.Header;
		for Index = Row:GetNumRegions() + 1, Table.NumColumns do
			local Element = Row:CreateFontString( nil, "ARTWORK", Table.ElementFont or "GameFontNormalSmall" );
			Element:SetPoint( "TOP" );
			Element:SetPoint( "BOTTOM" );
			Element:SetPoint( "LEFT", Columns[ Index ], ColumnPadding, 0 );
			Element:SetPoint( "RIGHT", Columns[ Index ], -ColumnPadding, 0 );
		end
	end
	local function UpdateElements ( Table, Row, ... ) -- Shows, hides, and sets the values of elements
		for Index = 1, Table.NumColumns do
			local Element = select( Index, ... );
			local Value = Row[ Index ];
			Element:SetText( Value ~= nil and tostring( Value ) or nil );
			Element:Show();
			Element:SetJustifyH( type( Value ) == "number" and "RIGHT" or "LEFT" );
		end
		for Index = Table.NumColumns + 1, select( "#", ... ) do
			select( Index, ... ):Hide();
		end
	end
	function TableMethods:AddRow ( Key, ... )
		assert( Key == nil or self.Keys[ Key ] == nil, "Index key must be unique." );
		local Row = RowInsert( self ); -- Appended
		if ( Key ~= nil ) then
			self.Keys[ Key ] = Row;
			Row.Key = Key;
		end
		for Index = 1, self.NumColumns do
			Row[ Index ] = select( Index, ... );
		end

		RowAddElements( self, Row );
		UpdateElements( self, Row, Row:GetRegions() );

		self:Resize();
		self:Sort();
		return Row;
	end
end
--[[****************************************************************************
  * Function: TableObject:Resize                                               *
  * Description: Requests that the table be resized on the next update.        *
  ****************************************************************************]]
do
	local function Resize ( Rows ) -- Resizes all table headers and elements
		local Table = Rows.Table;
		local Header = Table.Header;
		local TotalWidth = 0;
		for Index = 1, Table.NumColumns do
			local Column = Header[ Index ];
			-- Get widest column element
			local ColumnWidth = Column:GetTextWidth();
			for _, Row in ipairs( Rows ) do
				local ElementWidth = select( Index, Row:GetRegions() ):GetStringWidth();
				if ( ElementWidth > ColumnWidth ) then
					ColumnWidth = ElementWidth;
				end
			end
			ColumnWidth = ColumnWidth + ColumnPadding * 2;
			Column:SetWidth( ColumnWidth );
			TotalWidth = TotalWidth + ColumnWidth;
		end
		Rows:SetSize( TotalWidth > 1e-3 and TotalWidth or 1e-3, #Rows * RowHeight );
	end
	local function OnUpdate ( Rows ) -- Handler for tables that limits resizes to once per frame
		Rows:SetScript( "OnUpdate", nil );
		Resize( Rows );
	end
	function TableMethods:Resize ()
		self.Rows:SetScript( "OnUpdate", OnUpdate );
	end
end
--[[****************************************************************************
  * Function: TableObject:GetSelectionData                                     *
  * Description: Returns the data contained in the selected row.               *
  ****************************************************************************]]
function TableMethods:GetSelectionData ()
	if ( self.Selection ) then
		return self.Selection:GetData();
	end
end
--[[****************************************************************************
  * Function: TableObject:SetSelection                                         *
  * Description: Sets the selection to a given row.                            *
  ****************************************************************************]]
function TableMethods:SetSelection ( Row )
	assert( Row == nil or type( Row ) == "table", "Row must be an existing table row." );
	if ( Row ~= self.Selection ) then
		if ( self.Selection ) then -- Remove old selection
			self.Selection:UnlockHighlight();
		end

		self.Selection = Row;
		if ( Row ) then
			Row:LockHighlight();
		end
		if ( self.OnSelect ) then
			self:OnSelect( self:GetSelectionData() );
		end
		return true;
	end
end
--[[****************************************************************************
  * Function: TableObject:SetSelectionByKey                                    *
  * Description: Sets the selection to a row indexed by the given key.         *
  ****************************************************************************]]
function TableMethods:SetSelectionByKey ( Key )
	return self:SetSelection( self.Keys[ Key ] );
end




--[[****************************************************************************
  * Function: lib.New                                                          *
  * Description: Creates a new table.                                          *
  ****************************************************************************]]
do
	local ViewOnSizeChanged, HeaderOnSizeChanged; -- Resizes when viewing area/table data width changes
	do
		local Padding = 1 + 1e-3; -- Must be slightly larger than 1, or the Body frame will cause scrolling
		-- Adjusts row widths and table height to fill the scrollframe without changing the scrollable area
		local function Resize ( Table, RowsX, RowsY, ViewX, ViewY )
			RowsY = RowsY + RowHeight; -- Allow room for header
			local Width, Height = ( RowsX > ViewX and RowsX or ViewX ) - Padding, ( RowsY > ViewY and RowsY or ViewY ) - Padding;
			Table.Body:SetSize( Width > 1e-3 and Width or 1e-3, Height > 1e-3 and Height or 1e-3 );
		end
		function ViewOnSizeChanged ( View, ViewX, ViewY ) -- Viewing area changes
			local RowsX, RowsY = View.Table.Rows:GetSize();
			Resize( View.Table, RowsX, RowsY, ViewX, ViewY );
		end
		function RowsOnSizeChanged ( Rows, RowsX, RowsY ) -- Table data size changes
			Resize( Rows.Table, RowsX, RowsY, Rows.Table.View:GetSize() );
		end
	end

	-- Handlers for scrollwheel and scrollbar increment/decrement
	local function ScrollHorizontal ( View, Delta ) 
		local XScroll = View.XScroll;
		XScroll:SetValue( XScroll:GetValue() + Delta * XScroll:GetWidth() / 2 )
	end
	local function ScrollVertical ( View, Delta )
		local YScroll = View.YScroll;
		YScroll:SetValue( YScroll:GetValue() + Delta * YScroll:GetHeight() / 2 )
	end

	local function OnMouseWheel ( Table, Delta ) -- Scrolls with the mousewheel vertically, or horizontally if shift is held
		local View = Table.View;
		if ( View:GetHorizontalScrollRange() > 0 and ( View:GetVerticalScrollRange() == 0 or IsShiftKeyDown() ) ) then
			ScrollHorizontal( View, -Delta );
		else
			ScrollVertical( View, -Delta );
		end
	end

	local function OnValueChangedHorizontal ( ScrollBar, HorizontalScroll ) -- Horizontal scrollbar updates
		local View = ScrollBar:GetParent();
		View:SetHorizontalScroll( HorizontalScroll );

		local Min, Max = ScrollBar:GetMinMaxValues();
		View.Left[ HorizontalScroll == Min and "Disable" or "Enable" ]( View.Left );
		View.Right[ HorizontalScroll == Max and "Disable" or "Enable" ]( View.Right );
	end
	local function OnValueChangedVertical ( ScrollBar, VerticalScroll ) -- Vertical scrollbar updates
		local View = ScrollBar:GetParent();
		View:SetVerticalScroll( VerticalScroll );

		local Min, Max = ScrollBar:GetMinMaxValues();
		View.Up[ VerticalScroll == Min and "Disable" or "Enable" ]( View.Up );
		View.Down[ VerticalScroll == Max and "Disable" or "Enable" ]( View.Down );
	end

	local OnScrollRangeChanged; -- Adds and adjusts scrollbars when necessary
	do
		local function CreateScrollBar ( View, ScrollScript ) -- Creates a scrollbar, decrement button, and increment button
			local Scroll = CreateFrame( "Slider", nil, View );
			Scroll:Hide();
			Scroll:SetThumbTexture( [[Interface\Buttons\UI-ScrollBar-Knob]] );
			local Dec = CreateFrame( "Button", nil, Scroll, "UIPanelScrollUpButtonTemplate" );
			local Inc = CreateFrame( "Button", nil, Scroll, "UIPanelScrollDownButtonTemplate" );
			Dec:SetScript( "OnClick", function ()
				PlaySound( "UChatScrollButton" );
				ScrollScript( View, -1 );
			end );
			Inc:SetScript( "OnClick", function ()
				PlaySound( "UChatScrollButton" );
				ScrollScript( View, 1 );
			end );
			local Thumb = Scroll:GetThumbTexture();
			Thumb:SetSize( Dec:GetSize() );
			Thumb:SetTexCoord( 0.25, 0.75, 0.25, 0.75 ); -- Remove transparent border
			local Background = Scroll:CreateTexture( nil, "BACKGROUND" );
			Background:SetTexture( 0, 0, 0, 0.5 );
			Background:SetAllPoints();
			return Scroll, Dec, Inc;
		end
		local function RotateTextures ( ... ) -- Rotates all regions 90 degrees CCW
			for Index = 1, select( "#", ... ) do
				select( Index, ... ):SetTexCoord( 0.75, 0.25, 0.25, 0.25, 0.75, 0.75, 0.25, 0.75 );
			end
		end
		function OnScrollRangeChanged ( View, XRange, YRange )
			local XScroll, YScroll = View.XScroll, View.YScroll;
			View.Table:EnableMouseWheel( XRange > 0 or YRange > 0 ); -- Enable only if scrollable

			-- Horizontal scrolling
			if ( XRange > 0 ) then
				if ( not XScroll ) then -- Create scrollbar
					XScroll, View.Left, View.Right = CreateScrollBar( View, ScrollHorizontal );
					View.XScroll = XScroll;
					View.Left:SetPoint( "BOTTOMLEFT", View.Table );
					XScroll:SetPoint( "BOTTOMLEFT", View.Left, "BOTTOMRIGHT" );
					XScroll:SetPoint( "TOPRIGHT", View.Right, "TOPLEFT" );
					XScroll:SetOrientation( "HORIZONTAL" );
					XScroll:SetScript( "OnValueChanged", OnValueChangedHorizontal );
					RotateTextures( View.Left:GetRegions() );
					RotateTextures( View.Right:GetRegions() );
				end
				if ( not XScroll:IsShown() ) then -- Show and position scrollbar
					XScroll:Show();
					View:SetPoint( "BOTTOM", XScroll, "TOP" );
				end
				-- Setup scrollbar's range
				View.Right:SetPoint( "BOTTOMRIGHT", View.Table, YRange > 0 and -View.Right:GetWidth() or 0, 0 );
				XScroll:SetMinMaxValues( 0, XRange );
				XScroll:SetValue( min( XScroll:GetValue(), XRange ) );
			elseif ( XScroll and XScroll:IsShown() ) then -- Hide scrollbar
				XScroll:SetValue( 0 ); -- Return to origin
				XScroll:Hide();
				View:SetPoint( "BOTTOM", View.Table );
			end

			-- Vertical scrolling
			if ( YRange > 0 ) then
				if ( not YScroll ) then -- Create scrollbar
					YScroll, View.Up, View.Down = CreateScrollBar( View, ScrollVertical );
					View.YScroll = YScroll;
					View.Up:SetPoint( "TOPRIGHT", View.Table );
					YScroll:SetPoint( "TOPRIGHT", View.Up, "BOTTOMRIGHT" );
					YScroll:SetPoint( "BOTTOMLEFT", View.Down, "TOPLEFT" );
					YScroll:SetScript( "OnValueChanged", OnValueChangedVertical );
				end
				if ( not YScroll:IsShown() ) then -- Show and position scrollbar
					YScroll:Show();
					View:SetPoint( "RIGHT", YScroll, "LEFT" );
				end
				-- Setup scrollbar's range
				View.Down:SetPoint( "BOTTOMRIGHT", View.Table, 0, XRange > 0 and View.Down:GetHeight() or 0 );
				YScroll:SetMinMaxValues( 0, YRange );
				YScroll:SetValue( min( YScroll:GetValue(), YRange ) );
			elseif ( YScroll and YScroll:IsShown() ) then -- Hide scrollbar
				YScroll:SetValue( 0 ); -- Return to origin
				YScroll:Hide();
				View:SetPoint( "RIGHT", View.Table );
			end
		end
	end

	function lib.New ( Name, Parent, HeaderFont, ElementFont )
		local Table = CreateFrame( "Frame", Name, Parent );
		if ( not getmetatable( TableMethods ) ) then
			setmetatable( TableMethods, getmetatable( Table ) );
		end
		setmetatable( Table, lib.TableMeta );

		local View = CreateFrame( "ScrollFrame", nil, Table );
		Table.View = View;
		View.Table = Table;
		View:SetPoint( "TOPLEFT" );
		View:SetPoint( "BOTTOM" ); -- Bottom and right anchors moved independently by scrollbars
		View:SetPoint( "RIGHT" );
		View:SetScript( "OnScrollRangeChanged", OnScrollRangeChanged );
		View:SetScript( "OnSizeChanged", ViewOnSizeChanged );

		-- Body frame expands to fill the scrollframe
		local Body = CreateFrame( "Frame" );
		Table.Body = Body;
		View:SetScrollChild( Body );

		-- Rows frame expands to the size of table data
		local Rows = CreateFrame( "Frame", nil, Body );
		Table.Rows = Rows;
		Rows.Table = Table;
		Rows:SetPoint( "TOPLEFT", 0, -RowHeight ); -- Leave room for header
		Rows:SetScript( "OnSizeChanged", RowsOnSizeChanged );

		local Header = CreateFrame( "Frame", nil, Body );
		Table.Header = Header;
		Header.Table = Table;
		Header:SetPoint( "TOP", Table, 0, 1 ); -- Make sure rows don't show in the crack above the header
		Header:SetPoint( "LEFT", Rows );
		Header:SetPoint( "RIGHT", Rows );
		Header:SetHeight( RowHeight );
		local Background = Header:CreateTexture( nil, "OVERLAY" );
		Background:SetTexture( 0, 0, 0 );
		Background:SetPoint( "TOPLEFT" );
		Background:SetPoint( "BOTTOM" );
		Background:SetPoint( "RIGHT", Body ); -- Expand with view

		Table.Keys = {};
		Table.UnusedRows = {};
		Table.HeaderFont = HeaderFont;
		Table.ElementFont = ElementFont;

		Table:SetScript( "OnMouseWheel", OnMouseWheel );
		Table:SetHeader(); -- Clear all and resize
		return Table;
	end
end
