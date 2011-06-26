--[[****************************************************************************
  * GuildBankSearch by Saiket, originally by Harros                            *
  * Locales/Locale-frFR.lua - Localized string constants (fr-FR).              *
  ****************************************************************************]]


if ( GetLocale() ~= "frFR" ) then
	return;
end


-- See http://wow.curseforge.com/addons/guild-bank-search/localization/frFR/
local GuildBankSearch = select( 2, ... );
GuildBankSearch.L = setmetatable( {
	ALL = "|cffcccccc(Tout)|r",
	CLEAR = "RàZ",
	FILTER = "Filtrer",
	ITEM_CATEGORY = "Categorie d'objet",
	ITEM_LEVEL = "iLevel:",
	NAME = "Nom:",
	QUALITY = "Qualité:",
	REQUIRED_LEVEL = "Level requis:",
	SLOT = "Emplacement:",
	SUB_TYPE = "Sous-type:",
	TYPE = "Type:",
}, { __index = GuildBankSearch.L; } );