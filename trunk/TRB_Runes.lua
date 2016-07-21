if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";

local RuneWidth = 46
local RuneHeight = 6
local BorderSize = 2
local FullBarWidth = 48 * 6
local FullBarHeight = 6
local FrameWidth = FullBarWidth + BorderSize
local FrameHeight = FullBarHeight + BorderSize * 2

------------------------------------------------------------------------

TRB_Runes = TRB_Module:create("Runes");
-- Register Rune module
ThreeRuneBars:RegisterModule(TRB_Runes);
------------------------------------------------------------------------

function TRB_Runes:OnDisable()
	self.frame:SetScript("OnUpdate", nil);
	self.frame:SetScript("OnEvent", nil);
end

function TRB_Runes:UpdateBarPositions()
	-- Now is a good time to update sizes
	for i=1, 6 do
		local b = self.Runes[i];
		b:SetWidth( RuneWidth );
		b:SetHeight( RuneHeight );
	end
end

function TRB_Runes:OnEnable()
	--DEFAULT_CHAT_FRAME:AddMessage("UT: module Runes Loaded");

	if( not self.frame ) then
		local frame = CreateFrame("frame", nil, UIParent);

		-- Set position
		frame:SetWidth(FrameWidth);
		frame:SetHeight(FrameHeight);
		frame:SetFrameStrata("HIGH");
		frame.owner = self;
		self.frame = frame;
		frame:Show();

		-- Create Border around our runebar
		self.Bar = self:CreateBarContainer(FullBarWidth, FullBarHeight);
		self.Bar:SetPoint("LEFT", self.frame, "LEFT", 0, 0 );

		-- Set border colors black
		self:SetBorderColor(0, 0, 0, 1);

		-- Create a moveframe so user can unlock and move the rune bars
		self:CreateMoveFrame();
	end
	
	if( not self.Runes ) then
		-- Create the runebars
		self.Runes = {};

		-- Blood
		self.Runes[1] = self:CreateBar("TRB_Rune1", self.frame);
		self.Runes[1]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", BorderSize, -(BorderSize));	-- Place first bar in the bar frame

		self.Runes[2] = self:CreateBar("TRB_RuneBorderSize", self.frame);
		self.Runes[2]:SetPoint("TOPLEFT", self.Runes[1], "TOPRIGHT", BorderSize, 0);		-- Link second rune to first so it will follow when bar order is changed.
		
		-- Unholy
		self.Runes[3] = self:CreateBar("TRB_Rune3", self.frame);
		self.Runes[3]:SetPoint("TOPLEFT", self.Runes[BorderSize], "TOPRIGHT", BorderSize, 0);	-- Place first bar in the bar frame
		self.Runes[4] = self:CreateBar("TRB_Rune4", self.frame);
		self.Runes[4]:SetPoint("TOPLEFT", self.Runes[3], "TOPRIGHT", BorderSize, 0);		-- Link second rune to first so it will follow when bar order is changed.

		-- Frost
		self.Runes[5] = self:CreateBar("TRB_Rune5", self.frame);
		self.Runes[5]:SetPoint("TOPLEFT", self.Runes[4], "TOPRIGHT", BorderSize, 0);	-- Place first bar in the bar frame
		self.Runes[6] = self:CreateBar("TRB_Rune6", self.frame);
		self.Runes[6]:SetPoint("TOPLEFT", self.Runes[5], "TOPRIGHT", BorderSize, 0);		-- Link second rune to first so it will follow when bar order is changed.

		self:UpdateBarPositions()
		self:UpdateColor()
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	if(not self.RuneInfoTable) then
		self.RuneInfoTable = {}
		self.SortedRuneInfos = {}
	end

	for runeIndex=1, 6 do
		if( not self.RuneInfoTable[runeIndex] ) then
			self.RuneInfoTable[runeIndex] = { runeIndex, 0, 0, false };
			self.SortedRuneInfos[runeIndex] = self.RuneInfoTable[runeIndex];
		end;
	end

	--
	--  EVENTS
	--
	-- Runes
	self.frame:RegisterEvent("RUNE_POWER_UPDATE");

	self.last = 0;
	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );

	-- New first login OnUpdate timer, to set rune colors.
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );
end

--
-- UpdateColor(rune, currentValue, duration)
-- Update the runebar color
--
function TRB_Runes:UpdateColor(currentValue, duration)
	local a = 1;
	if( (currentValue or 1) < (duration or 0) ) then
		a = 0.8;
	end

	if( not self.cfg.Color ) then
		self.cfg.Color = {}
		self.cfg.Color[1] = TRB_Config_Defaults.Runes.Color[1];
		self.cfg.Color[2] = TRB_Config_Defaults.Runes.Color[2];
		self.cfg.Color[3] = TRB_Config_Defaults.Runes.Color[3];
	end;

	-- Update Runebar color
	for runeIndex=1, 6 do
		self.Runes[runeIndex]:SetStatusBarColor(self.cfg.Color[1], self.cfg.Color[2], self.cfg.Color[3], a);
		--self:SetWaitingRuneColor(runeIndex, 0, 0, 0);
	end
end

--
-- UpdateText
-- Update cooldown text on runebars
--
function TRB_Runes:UpdateText( runeIndex, value, duration )

	if( self.cfg.noText ) then
		self.Runes[runeIndex].text:SetText("");
		return;
	end

--	self:Print("Rune "..rune.." value "..value.." duration "..duration);

	if( value > 0 and value < duration) then
		if( value < 2 ) then
			self.Runes[runeIndex].text:SetText( format("%.1f", value) );
		else
			self.Runes[runeIndex].text:SetText( format("%.0f", value) );
		end
	else
		self.Runes[runeIndex].text:SetText("");
	end
end

function TRB_Runes:UpdateRuneInfoTable()
	for runeIndex=1, 6 do
		if( not self.RuneInfoTable[runeIndex][4] ) then
			local start, duration, ready = GetRuneCooldown( runeIndex );
			local value = GetTime() - start;

			if( value < 0 ) then value = 0 end;

			self.RuneInfoTable[runeIndex][2] = value;
			self.RuneInfoTable[runeIndex][3] = duration;
			self.RuneInfoTable[runeIndex][4] = ready;
		end
	end
end

function sort(t)
	local itemCount = #t;

	local hasChanged = true;

	while( hasChanged ) do
		hasChanged = false;

		itemCount = itemCount - 1;

		for index=1,itemCount do
			if( t[index][2] < t[index + 1][2] ) then
				local temp = t[index];
				t[index] = t[index + 1];
				t[index + 1] = temp;
				hasChanged = true;
			end
		end
	end
end

function TRB_Runes:SortRuneInfos()
	for runeIndex=1, 6 do
		self.SortedRuneInfos[runeIndex] = self.RuneInfoTable[runeIndex];
	end

	sort(self.SortedRuneInfos);
end

function TRB_Runes:UpdateFullBar()
	self:UpdateRuneInfoTable();
	self:SortRuneInfos();

	for runeIndex=1, 6 do
		local oldValue = self.Runes[runeIndex]:GetValue();

		local value = self.SortedRuneInfos[runeIndex][2];
		local duration = self.SortedRuneInfos[runeIndex][3];
		self.Runes[runeIndex]:SetValue( value / duration * 100 );
		self:UpdateText(runeIndex, duration - value, duration);

		--if( oldValue and value and value > oldValue and value >= 100 ) then self:Flash_Start(runeIndex); end
	end
end

-- Runes EVENTS
function TRB_Runes:RUNE_POWER_UPDATE(runeIndex, useable)
	if( not useable ) then
		self.RuneInfoTable[runeIndex][4] = false;
	end
end

-- OnUpdate
function TRB_Runes:OnUpdate(elapsed)
	self.last = self.last + elapsed;

	if( self.last > 0.01 ) then
		self:UpdateFullBar();

		--self:Flash_Update(self.last);
		self.last = 0;
	end
end

function TRB_Runes:Flash_SetColor(runeIndex, v1, v2)
	local bar = self.Bar;

	if( not bar ) then return; end
	
--	if( runeIndex == 1 or runeIndex == 3 or runeIndex == 5 ) then
--		-- Flash left side
--		bar.tl:SetVertexColor(v1, v1, v1);
--		bar.l:SetVertexColor(v1, v1, v1);
--		bar.bl:SetVertexColor(v1, v1, v1);
--
--		bar.t:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
--		bar.b:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
--
--		bar.m1:SetGradient("HORIZONTAL", v2, v2, v2, 0, 0, 0);
--	else
--		-- Flash right side
--	
--		bar.tr:SetVertexColor(v2, v2, v2);
--		bar.r:SetVertexColor(v2, v2, v2);
--		bar.br:SetVertexColor(v2, v2, v2);
--		
--		bar.t2:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
--		bar.b2:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
--		
--		bar.tm:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
--		bar.m:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
--		bar.bm:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
--	end
end

function TRB_Runes:Flash_Update(elapsed)

	if( not self.flashtime ) then return; end

	for i=1,6 do
		if( self.flashtime[i] ) then
			local x = (self.flashtime[i] or 0) + elapsed;
			self.flashtime[i] = x;
			if( x > 0.5) then self.flashtime[i] = nil; end
			
			x = 6.28 * x;
			local v1 = cos(deg(x));		-- Change to lookup table to save CPU power?
			local v2 = sin(deg(x));
		
			self:Flash_SetColor(i, v1, v2);
		end
	end
end

function TRB_Runes:Flash_Start(rune)

	if not self.flashtime then self.flashtime = {}; end
	self.flashtime[rune] = 0;
end

--
-- SetWaitingRuneColor
-- This will set the color of the border to the waiting rune color type
--
function TRB_Runes:SetWaitingRuneColor(runeIndex, r, g, b)
	local bar = self.Bar;

	-- This function is only intended to use on Rune 2,4,6 if called with other rune number bar is nil, then we end this.
	if( not bar ) then return; end

	local v=0.3;

	--bar.m1:SetGradient("HORIZONTAL", 0, 0, 0, r*v, g*v, b*v);

	bar.t:SetGradient("HORIZONTAL", r*v, g*v, b*v, r, g, b);
	bar.b:SetGradient("HORIZONTAL", r*v, g*v, b*v, r, g, b);

	bar.tr:SetVertexColor(r,g,b);
	bar.r:SetVertexColor(r,g,b);
	bar.br:SetVertexColor(r,g,b);
end

--
-- SetBorderColor
-- This will set the color of the border for a specefic rune. (At the moment only used for setting the border black on init)
--
function TRB_Runes:SetBorderColor(r, g, b, a)
	local bar = self.Bar;
	bar.tl:SetVertexColor(r,g,b,a);
	bar.tr:SetVertexColor(r,g,b,a);
	bar.bl:SetVertexColor(r,g,b,a);
	bar.br:SetVertexColor(r,g,b,a);
	bar.l:SetVertexColor(r,g,b,a);
	bar.r:SetVertexColor(r,g,b,a);
	bar.t:SetVertexColor(r,g,b,a);
	bar.b:SetVertexColor(r,g,b,a);

	--bar.m1:SetVertexColor(r,g,b,a);
end

--
-- CreateBarContainer
-- Create a holder frame for each bar. This is not the statusbars, just the border around them to make the six runebars look like 3 bars with 2 runes in each.
--
-- TL T1 TM T2 TR
-- L      M     R
-- BL B1 BM B2 BR
--
function TRB_Runes:CreateBarContainer(w, h)
	local f = CreateFrame("frame", nil, self.frame)
	-- Set position
	f:SetWidth(FrameWidth);
	f:SetHeight(FrameHeight);
	f:Show();

	-- Corners

	-- TL
	local t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "TOPLEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 0, 6/32);
	f.tl = t;
	
	-- BL
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "BOTTOMLEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 14/32, 14/32+6/32);
	f.bl = t;
	
	-- TR
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "TOPRIGHT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 0, 6/32);
	f.tr = t;
	
	-- BR
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "BOTTOMRIGHT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 14/32, 14/32+6/32);
	f.br = t;

	-- Top
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.tl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.tr, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 0, 6/32);
	f.t = t;

	-- Bottom
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.bl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.br, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 14/32, 14/32+6/32);
	f.b = t;

	-- L
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tl, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.bl, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 8/32, 6/32+6/32);
	f.l = t;

	-- R
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tr, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.br, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 8/32, 6/32+6/32);
	f.r = t;

	--local width = f.tr:GetLeft() - f.tl:GetRight();
	local runeWidth = ( FrameWidth ) / 6;

	-- Create the splitters
	--for i=1,5 do
	--	t = self:CreateTexture(f, 6, 6);
	--	t:SetPoint("LEFT", f.t, "LEFT", runeWidth * i - 6, 0);
	--	t:SetPoint("TOP", f.t, "BOTTOM", 0, 0);
	--	t:SetPoint("BOTTOM", f.b, "TOP", 0, 0);
	--	t:SetTexture(BG_Tex);
	--	t:SetTexCoord(14/32, 14/32+6/32, 8/32, 6/32+6/32);
	--	t:SetVertexColor(0, 0, 0);
	--	f["m"..i] = t;
	--end

	return f;
end


---------------- Config ------------------------------------------------------------------------------------------
--
-- OnDefault
-- Update the settings UI elements.
--
function TRB_Runes:OnDefault()
	-- Update the Color of the runebars
	self:UpdateColor(1, 0); -- Rune 1 Bar 1
end

function TRB_Runes:OnCancel()
	-- Reset bar position
	self:UpdateBarPositions();
end

function TRB_Runes:OnOkay()
	-- Disable/Enable cooldown countdown text
	local status = self.CB_DisableText:GetChecked();
	if( status ) then
		TRB_Config.Runes.noText = nil;
	else
		TRB_Config.Runes.noText = true;
	end
	
	self:UpdateBarPositions();
end

function TRB_Runes:OnInitOptions(panel)
	--
	-- Disable Rune cooldown counter text
	--
	local cb = CreateFrame("CheckButton", "TRB_Runes_DisableText", panel, "InterfaceOptionsCheckButtonTemplate");
	cb:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -150);
	cb.text = _G[cb:GetName().."Text"];
	cb.text:SetText("Enable "..self.name.." cooldown counter text");
	local v = true;
	if( TRB_Config.Runes.noText and TRB_Config.Runes.noText == true ) then
		v = false;
	end
	cb:SetChecked( v );
	self.CB_DisableText = cb;

	---
	--- Color buttons
	---

	self:CreateColorButtonOption(panel, "Rune Color", 20, -180);
end

function TRB_Runes:SetBarTexture(texture)
	self.cfg.Texture = texture;

	if( not SM ) then
		return;
	end

	for k,v in pairs(self.Runes) do
		v:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR,texture));
		v:GetStatusBarTexture():SetHorizTile(false);
		v:GetStatusBarTexture():SetVertTile(false);
	end
end

function TRB_Runes:GetConfigColor(module)
	return unpack(TRB_Config[module.name].Colors);
end

function TRB_Runes:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetTexture(r, g, b);

	local newColor = {r, g, b, 1};

	TRB_Config[module.name].Color = newColor;

	self:UpdateColor();
end