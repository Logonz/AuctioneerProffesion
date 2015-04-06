DEBUG = false;

function EnchantrixValues(totals)
	local hps = Enchantrix.Util.Round(totals.hspValue * totals.conf, 3);
	local median = Enchantrix.Util.Round(totals.medValue * totals.conf, 3);
	local baseLine = Enchantrix.Util.Round(totals.mktValue * totals.conf, 3);
	local Average =  (hps + median + baseLine) / 3;
	return hps,median ,baseLine, Average;
end

function AucProf_MoneyString(amount, color)
	local color = false or color;
	local BOg,BOs,BOc = EnhTooltip.GetGSC(amount);
	if(color == true) then
		if(amount < 0) then
			return "|cFFFF0000"..BOg.."|rg|cFFFF0000"..BOs.."|rs|cFFFF0000"..BOc.."|rc";
		else
			return "|cFF00FF00"..BOg.."|rg|cFF00FF00"..BOs.."|rs|cFF00FF00"..BOc.."|rc";
		end
	else
		return BOg.."g"..BOs.."s"..BOc.."c";
	end
end

lastStep = 0;
lastRefresh = GetTime();
function AucProf_OnUpdate()
	if(getglobal("TradeSkillListScrollFrameScrollBar"):GetValue() ~= lastStep or GetTime() - lastRefresh > 0.1) then
		UpdatePrice();
		lastStep = getglobal("TradeSkillListScrollFrameScrollBar"):GetValue();
		lastRefresh = GetTime();
	end
end


function AucProf_OnLoad()


	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("TRADE_SKILL_UPDATE");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("UPDATE_TRADESKILL_RECAST");
	this:RegisterEvent("TRADE_SKILL_FILTER_UPDATE");
	this:RegisterEvent("MERCHANT_SHOW");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("AuctioneerProffesion v".."0.01".." loaded");
	end
	SlashCmdList["AUCTIONEERPROFFESION"] = AucProf_SlashHandler;
	SLASH_AUCTIONEERPROFFESION1 = "/AuctioneerProffesion"; -- Fixed by Aingnale@WorldOfWar
	SLASH_AUCTIONEERPROFFESION2 = "/aucp";
end


FirstRun = true;
function AucProf_OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)

	if (event == "PLAYER_ENTERING_WORLD" or event == "ADDON_LOADED") then
		--aucprof_PrintError("Test");
	elseif(event == "TRADE_SKILL_UPDATE" or event == "UPDATE_TRADESKILL_RECAST" or event == "TRADE_SKILL_FILTER_UPDATE") then
		if(FirstRun ~= true) then
			aucprof_PrintDebug("Update "..tostring(event));
			UpdatePrice();
		end
	elseif(event == "TRADE_SKILL_SHOW") then
		if(FirstRun == true) then
			aucprof_PrintDebug("Creating the FontStrings and Frame");
			newFrame = CreateFrame("Frame","AuctioneerTradeSkillFrame",getglobal("TradeSkillFrame"));
			point, relativeTo, relativePoint, xOfs, yOfs = getglobal("TradeSkillFrame"):GetPoint(n);
			newFrame:SetPoint(point,relativeTo,relativePoint, xOfs, yOfs);
			for index=0, 7 do
				local frameName = "TradeSkillSkill"..index+1;
				local name = "";
				if(index == 0) then
					name = "TradeSkillSkillJUNKAuctioneer"
				else
					name = "TradeSkillSkill"..index.."Auctioneer";
				end
				fontstring = newFrame:CreateFontString(name, "OVERLAY", "GameFontWhite");
				point, relativeTo, relativePoint, xOfs, yOfs = getglobal("TradeSkillSkill"..index+1):GetPoint(n);
				--aucprof_Print(index.."-"..xOfs.."-"..yOfs);
				fontstring:SetPoint("TOPRIGHT",getglobal("TradeSkillSkill"..index),"TOPRIGHT", 0, 0);
				fontstring:SetJustifyH("LEFT");
				fontstring:SetText("ASDAS|cFFFF0000DASA|r");
				fontstring:SetText("");
				fontstring:SetTextHeight(12);
				fontstring:Show();
			end
				local frameName = "TradeSkillSkill".."8";
				fontstring = newFrame:CreateFontString("TradeSkillSkill".."8".."Auctioneer", "OVERLAY", "GameFontWhite");
				point, relativeTo, relativePoint, xOfs, yOfs = getglobal("TradeSkillSkill".."8"):GetPoint(n);
				--aucprof_Print("8".."-"..xOfs.."-"..yOfs);
				fontstring:SetPoint("TOPRIGHT",getglobal("TradeSkillSkill".."8"),"TOPRIGHT", 0, 0);
				fontstring:SetJustifyH("LEFT");
				fontstring:SetText("ASDAS|cFFFF0000DASA|r");
				fontstring:SetText("");
				fontstring:SetTextHeight(12);
				fontstring:Show();
			FirstRun = false;
			UpdatePrice();
		end
		AuctioneerProffesion_InfoFrame:ClearAllPoints();
		AuctioneerProffesion_InfoFrame:SetParent(TradeSkillFrame);
		AuctioneerProffesion_InfoFrame:SetPoint("TOPRIGHT","TradeSkillFrame","TOPRIGHT",200,-15);
		AuctioneerProffesion_InfoFrame:Show();
		aucprof_PrintDebug("Shown");
	elseif event == "VARIABLES_LOADED" then
		aucprof_Print("Vars Loaded");
		if(aucprof_merchantitems == nil) then
			aucprof_merchantitems={};
		end
	elseif(event == "MERCHANT_SHOW") then
		AucProf_Merchant_UpdateMerchantList();
	end
	
end



function AucProf_Merchant_UpdateMerchantList()
	if(MerchantFrame:IsVisible()) then
		local numitems=GetMerchantNumItems();
		if(numitems==148) then numitems=0; end
		for i=1,numitems,1 do
			--local itemId, suffixId, enchantId, uniqueId = EnhTooltip.BreakLink(itemLink);
			local itemId, suffixId, enchantId, uniqueId = EnhTooltip.BreakLink(GetMerchantItemLink(i));
			if(itemId) then
				local name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(i);
				if(numAvailable==-1 and aucprof_merchantitems[itemId] == nil) then
					aucprof_merchantitems[itemId] = {};
					aucprof_merchantitems[itemId].buyable = true;
					aucprof_merchantitems[itemId].itemName = name;
					aucprof_PrintDebug("Added item "..GetMerchantItemLink(i));
				end
			end
		end
	end
end

function AucProf_Merchant_CheckIfAvailable(itemid)
	if(aucprof_merchantitems[itemid] ~= nil and aucprof_merchantitems[itemid].buyable == true) then
		return true;
	else
		return false;
	end
end

function GetSkillInfo(itemName, frameName)
	local cost = -1;
	local profit = -1;
	for i=1, GetNumTradeSkills() do

		skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(i)
		link = GetTradeSkillItemLink(i);
		if(link ~= nil) then
			local itemKey = Auctioneer.ItemDB.CreateItemKeyFromLink(link);
			local bidPrice, buyPrice, marketPrice, warn = Auctioneer.Statistic.GetSuggestedResale(itemKey, ahKey, 1);
			if(skillName == itemName) then
				--aucprof_Print(link);
				local ahKey = Auctioneer.Util.GetAuctionKey();
				numReagents = GetTradeSkillNumReagents(i);
				local TotalPrice = 0;
				for r=1, numReagents do
					link = GetTradeSkillReagentItemLink(i, r);
					local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, r);
					local itemKey = Auctioneer.ItemDB.CreateItemKeyFromLink(link);
					local itemTotals = Auctioneer.HistoryDB.GetItemTotals(itemKey, ahKey);
					local commonPrice = Auctioneer.Statistic.GetMarketPrice(itemKey, ahKey);
					local itemId, suffixId, enchantId, uniqueId = EnhTooltip.BreakLink(link);
					if(AucProf_Merchant_CheckIfAvailable(itemId) == false) then
						--aucprof_Print(link);
						TotalPrice = TotalPrice + (reagentCount*commonPrice);
					else
						TotalPrice = TotalPrice + (reagentCount*Auctioneer.API.GetVendorSellPrice(itemId));
					end
				end
				minMade, maxMade = GetTradeSkillNumMade(i);
				--""..AucProf_MoneyString(round(TotalPrice))..
				cost = round(TotalPrice);
				profit = round(buyPrice - TotalPrice)*minMade;
				return cost, profit;
			end
		end
	end
	
	return cost, profit;
end

function UpdatePrice()
	for index=1, 8 do
		local aucText = "TradeSkillSkill"..index.."Auctioneer";
		getglobal(aucText):SetText("");
		local frameName = "TradeSkillSkill"..index;
		local fixedString = string.sub(getglobal(frameName):GetText(),2);
		local cost, profit = GetSkillInfo(fixedString, frameName);
		getglobal(aucText):SetText("("..AucProf_MoneyString(profit,true)..")");
		getglobal(aucText):Show();
	end
end

function AucProf_SlashHandler(msg)
	if (msg=="show" or msg=="hide") then msg = ""; end
	if (not msg or msg=="") then
		--Base command
		aucprof_Print("SlashCommand Used");
	end
	if(msg == "t") then
		for k, v in pairs(aucprof_merchantitems) do
			aucprof_Print(k.." "..v.itemName);
		end
	end
	if(msg =="price") then
		UpdatePrice();
	end
	
end

function aucprof_Print(message) -- Send Message to Chat Frame
	local msg = "[AP] "..message;
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 1.0, 0.5);
end

function aucprof_PrintError(message) -- Send Error to Chat Frame
	local msg = "[AP] ERROR: "..message;
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0, 0);
end

function aucprof_PrintDebug(message) -- Send Error to Chat Frame
	if(DEBUG == true) then
		local msg = "[AP] Debug: "..message;
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 1.0);
	end
	
end

-- Round m to n digits in given base
function round(m, n, base, offset)
	base = base or 10 -- Default to base 10
	offset = offset or 0.5

	if (n or 0) == 0 then
		return math.floor(m + offset)
	end

	if m == 0 then
		return 0
	elseif m < 0 then
		return -round(-m, n, base, offset)
	end

	-- Get integer and fractional part of n
	local f = math.floor(n)
	n, f = f, n - f

	-- Pre-rounding multiplier is 1 / f
	local mul = 1
	if f > 0.1 then
		mul = math.floor(1 / f + 0.5)
	end

	local d
	if n > 0 then
		d = base^(n - math.floor(math.log(m) / math.log(base)) - 1)
	else
		d = 1
	end
	if offset >= 1 then
		return math.ceil(m * d * mul) / (d * mul)
	else
		return math.floor(m * d * mul + offset) / (d * mul)
	end
end