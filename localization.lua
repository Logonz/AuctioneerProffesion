-- default strings
BTM_BUTTON_TEXT_START = "5 Scan";
BTM_BUTTON_TEXT_TOGGLE = "Toggle";
BTM_BUTTON_TEXT_FULLSCAN = "Full Scan";	
BTM_FONTSTRING_TEXT_BROADCAST = "Broadcast:";

if ( GetLocale() == "deDE" ) then
	-- need localization
	BTM_BUTTON_TEXT_START = "GE Scan!";
	BTM_BUTTON_TEXT_TOGGLE = "Toggle";
	BTM_BUTTON_TEXT_FULLSCAN = "FULLSKANNEN";
	BTM_FONTSTRING_TEXT_BROADCAST = "BROADCASTEN:";		
end

-- French by Feu
if ( GetLocale() == "frFR" ) then
	BTM_BUTTON_TEXT_START = "Le Scan";	
	BTM_BUTTON_TEXT_TOGGLE = "Toggle";			 
	BTM_BUTTON_TEXT_FULLSCAN = "LE FullScan";	
	BTM_FONTSTRING_TEXT_BROADCAST = "Le Broadcast:";				
end