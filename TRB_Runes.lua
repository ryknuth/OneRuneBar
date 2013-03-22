if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";

local BarSize = {
	["Width"] = 96,
	["Height"] = 8,
};

------------------------------------------------------------------------

TRB_Runes = TRB_Module:create("Runes");
-- Register Rune module
ThreeRuneBars:RegisterModule(TRB_Runes);
------------------------------------------------------------------------

function TRB_Runes:OnDisable()
	self.frame:SetScript("OnUpdate", nil);
	self.frame:SetScript("OnEvent", nil);
end

function TRB_Runes:OnLoadPosition()
	TRB_Runes:UpdateBarPositions();
end

function TRB_Runes:UpdateBarPositions()

	if( not self.cfg.Order ) then
		-- Notify user that we have no rune order in config.
		self:Error("[TRB_Runes:UpdateBarPositions()] Failed to update bar position. Rune order not set, using default rune order.");
		
		-- Set default rune order
		self.cfg.Blood	= TRB_Config_Defaults.Runes.Order.Blood;
		self.cfg.Unholy	= TRB_Config_Defaults.Runes.Order.Unholy;
		self.cfg.Frost	= TRB_Config_Defaults.Runes.Order.Frost;
	end
	
	-- Only need to change first rune in each group because the other will follow.
	self.Runes[1]:SetPoint("TOPLEFT", self[self.cfg.Order.Blood], "TOPLEFT", 2, -2);	-- Blood
	self.Runes[3]:SetPoint("TOPLEFT", self[self.cfg.Order.Unholy], "TOPLEFT", 2, -2);	-- Unholy
	self.Runes[5]:SetPoint("TOPLEFT", self[self.cfg.Order.Frost], "TOPLEFT", 2, -2);	-- Frost

	-- Now is a good time to update sizes
	self:UpdateSizes();
end

function TRB_Runes:UpdateSizes()
	for i=1, 6 do
		local b = self.Runes[i];
		b:SetWidth( BarSize.Width/2 );
		b:SetHeight( BarSize.Height );
	end
end

function TRB_Runes:OnEnable()

	--DEFAULT_CHAT_FRAME:AddMessage("UT: module Runes Loaded");
	
	if( not self.frame ) then
		local f = CreateFrame("frame", nil, UIParent);
		
		-- Set position
		f:SetWidth(48*6+22);
		f:SetHeight(8+4);
		--f:SetPoint("CENTER", UIParent, "CENTER", 0, 0 );
		f:SetFrameStrata("HIGH");
		f.owner = self;
		self.frame = f;
		f:Show();
		
		-- Create Border around our runebars 
		self.Bar1 = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.Bar1:SetPoint("LEFT", self.frame, "LEFT", 0, 0 );
		self.Bar2 = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.Bar2:SetPoint("LEFT", self.Bar1, "RIGHT", 2, 0 );
		self.Bar3 = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.Bar3:SetPoint("LEFT", self.Bar2, "RIGHT", 2, 0 );
		
		-- Set border colors black
		self:SetBorderColor(1, 0, 0, 0, 1);
		self:SetBorderColor(2, 0, 0, 0, 1);
		self:SetBorderColor(3, 0, 0, 0, 1);
		self:SetBorderColor(4, 0, 0, 0, 1);
		self:SetBorderColor(5, 0, 0, 0, 1);
		self:SetBorderColor(6, 0, 0, 0, 1);
		
		-- Create a moveframe so user can unlock and move the rune bars
		self:CreateMoveFrame();
	end
	
	if( not self.Runes ) then
	
		-- Create the runebars
		
		self.Runes = {};
		self.needUpdate = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false };
		
		if( not self.cfg.Order ) then
			-- Notify user that we have no rune order in config.
			self:Error("[TRB_Runes:OnEnable()] Failed to update bar position. Rune order not set, using default rune order.");
			
			-- Set default rune order
			self.cfg.Blood	= TRB_Config_Defaults.Runes.Order.Blood;
			self.cfg.Unholy	= TRB_Config_Defaults.Runes.Order.Unholy;
			self.cfg.Frost	= TRB_Config_Defaults.Runes.Order.Frost;
		end

		-- Blood
		self.Runes[1] = self:CreateBar("TRB_Rune1", self.frame);
		self.Runes[1]:SetPoint("TOPLEFT", self[self.cfg.Order.Blood], "TOPLEFT", 2, -2);	-- Place first bar in the bar frame
		self.Runes[2] = self:CreateBar("TRB_Rune2", self.frame);
		self.Runes[2]:SetPoint("TOPLEFT", self.Runes[1], "TOPRIGHT", 2, 0);		-- Link second rune to first so it will follow when bar order is changed.
		self:UpdateColor(1, 1);
		self:UpdateColor(2, 1);
		
		-- Unholy
		self.Runes[3] = self:CreateBar("TRB_Rune3", self.frame);
		self.Runes[3]:SetPoint("TOPLEFT", self[self.cfg.Order.Unholy], "TOPLEFT", 2, -2);	-- Place first bar in the bar frame
		self.Runes[4] = self:CreateBar("TRB_Rune4", self.frame);
		self.Runes[4]:SetPoint("TOPLEFT", self.Runes[3], "TOPRIGHT", 2, 0);		-- Link second rune to first so it will follow when bar order is changed.
		self:UpdateColor(3, 2);
		self:UpdateColor(4, 2);

		-- Frost
		self.Runes[5] = self:CreateBar("TRB_Rune5", self.frame);
		self.Runes[5]:SetPoint("TOPLEFT", self[self.cfg.Order.Frost], "TOPLEFT", 2, -2);	-- Place first bar in the bar frame
		self.Runes[6] = self:CreateBar("TRB_Rune6", self.frame);
		self.Runes[6]:SetPoint("TOPLEFT", self.Runes[5], "TOPRIGHT", 2, 0);		-- Link second rune to first so it will follow when bar order is changed.
		self:UpdateColor(5, 3);
		self:UpdateColor(6, 3);
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	--
	--  EVENTS
	--	
	-- Runes
	self.frame:RegisterEvent("RUNE_POWER_UPDATE");
	self.frame:RegisterEvent("RUNE_TYPE_UPDATE");

	self.last = 0;
	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );
end

--
-- UpdateColor(rune, type, cur_value, duration)
-- Update the runebar color
--
function TRB_Runes:UpdateColor(r, t, v, d)
	if( t == nil) then t=GetRuneType(r); end

	local a = 1;
	if( (v or 1) < (d or 0) ) then
		a = 0.8;
	end
	-- Update Runebar color
	self.Runes[r]:SetStatusBarColor(self.cfg["Colors"][t][1], self.cfg["Colors"][t][2], self.cfg["Colors"][t][3], a);

	-- Change border color for the runebar to match the runetype of the waiting rune.
	local bg = self.Runes[r].bg;
	if( ((v or 1) <= 0) and ((r==2) or (r==4) or (r==6)) ) then
		self:SetWaitingRuneColor(r, self.cfg.Colors[t][1], self.cfg.Colors[t][2], self.cfg.Colors[t][3]);
	else
		self:SetWaitingRuneColor(r, 0, 0, 0);
	end
end

--
-- UpdateText (Called from Updatebar)
-- Update cooldown text on runebars
--
function TRB_Runes:UpdateText( rune, value, duration )

	if( self.cfg.noText ) then
		self.Runes[rune].text:SetText("");
		return;
	end

--	self:Print("Rune "..rune.." value "..value.." duration "..duration);

	if( value > 0 and value < duration) then
		if( value < 2 ) then
			self.Runes[rune].text:SetText( format("%.1f", value) );
		else
			self.Runes[rune].text:SetText( format("%.0f", value) );
		end
	else
		self.Runes[rune].text:SetText("");
	end
end

--
-- Updatebar
-- Update the bar for runes rune1 and rune2.
--
function TRB_Runes:Updatebar( rune1, rune2 )
	local s1, d1, r1 = GetRuneCooldown(rune1);
	local s2, d2, r2 = GetRuneCooldown(rune2);
	local rt1 = GetRuneType(rune1);
	local rt2 = GetRuneType(rune2);
	
--	local val1 = ((r1 and d1) or (GetTime() - s1)); -- <- Working?
	
	local val1 = GetTime() - s1;	-- Calculate cooldown
	local val2 = GetTime() - s2;
	if( r1 or val1 > d1) then
		val1 = d1;	-- rune1 is ready
	end
	if( r2 or val2 > d2) then
		val2 = d2;	-- rune2 is ready
	end
	if( val1 < 0 ) then val1 = 0; end
	if( val2 < 0 ) then val2 = 0; end
	
	-- Save the bar values so we can check if any of the runes has finished the cooldown.
	local o1, o2 = self.Runes[rune1]:GetValue(), self.Runes[rune2]:GetValue();
	
	-- Update bar values for the runes of this bar. Swap place if needed to get the Energy like behaviour.
	if( val1 < val2 ) then
		self.Runes[rune1]:SetValue((val2 / d2) * 100);
		self.Runes[rune2]:SetValue((val1 / d1) * 100);
		
		-- Update Cooldown text
		self:UpdateText(rune1, d2-val2, d2);
		self:UpdateText(rune2, d1-val1, d1);
		
		-- Update Color
		self:UpdateColor(rune1, rt2, val2, d2);
		self:UpdateColor(rune2, rt1, val1, d1);
	else
		self.Runes[rune1]:SetValue((val1 / d1) * 100);
		self.Runes[rune2]:SetValue((val2 / d2) * 100);
		
		-- Update Cooldown text
		self:UpdateText(rune1, d1-val1, d1);
		self:UpdateText(rune2, d2-val2, d2);
		
		-- Update Color
		self:UpdateColor(rune1, rt1, val1, d1);
		self:UpdateColor(rune2, rt2, val2, d2);
	end
	
	-- Get the new bar values
	local n1, n2 = self.Runes[rune1]:GetValue(), self.Runes[rune2]:GetValue();
	
	-- Determin if we need to flash a ready rune.
	if( n1 > o1 and n1 >= 100 ) then self:Flash_Start(rune1); end
	if( n2 > o2 and n2 >= 100 ) then self:Flash_Start(rune2); end
	
end

-- Runes EVENTS
function TRB_Runes:RUNE_POWER_UPDATE(rune, useable)
	if( not useable ) then
		self.needUpdate[rune] = true;
	end
end

function TRB_Runes:RUNE_TYPE_UPDATE(rune)
	self:UpdateColor(rune);
end

-- OnUpdate
function TRB_Runes:OnUpdate(elapsed)
	self.last = self.last + elapsed;

	if( self.last > 0.01 ) then
		if( self.needUpdate[1] or self.needUpdate[2] ) then
			self:Updatebar( 1, 2); -- Blood
		end
		
		if( self.needUpdate[3] or self.needUpdate[4] ) then
			self:Updatebar( 3, 4); -- Unholy
		end
		
		if( self.needUpdate[5] or self.needUpdate[6] ) then
			self:Updatebar( 5, 6); -- Frost
		end
		
		self:Flash_Update(self.last);
		self.last = 0;
	end
	
end

function TRB_Runes:Flash_SetColor(rune, v1, v2)
	local bar = nil;
	
	if( rune == 1 or rune == 2) then
		bar = self[self.cfg.Order["Blood"]];
	elseif( rune == 3 or rune == 4) then
		bar = self[self.cfg.Order["Unholy"]];
	elseif( rune == 5 or rune == 6) then
		bar = self[self.cfg.Order["Frost"]];
	end
	
	if( not bar ) then return; end
	
	if( rune == 1 or rune == 3 or rune == 5 ) then
		-- Flash left side
		bar.tl:SetVertexColor(v1, v1, v1);
		bar.l:SetVertexColor(v1, v1, v1);
		bar.bl:SetVertexColor(v1, v1, v1);
		
		bar.t1:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
		bar.b1:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
		
		bar.tm:SetGradient("HORIZONTAL", v2, v2, v2, 0, 0, 0);
		bar.m:SetGradient("HORIZONTAL", v2, v2, v2, 0, 0, 0);
		bar.bm:SetGradient("HORIZONTAL", v2, v2, v2, 0, 0, 0);
	else
		-- Flash right side
	
		bar.tr:SetVertexColor(v2, v2, v2);
		bar.r:SetVertexColor(v2, v2, v2);
		bar.br:SetVertexColor(v2, v2, v2);
		
		bar.t2:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
		bar.b2:SetGradient("HORIZONTAL", v1, v1, v1, v2, v2, v2);
		
		bar.tm:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
		bar.m:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
		bar.bm:SetGradient("HORIZONTAL", 0, 0, 0, v1, v1, v1);
	end
	
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
function TRB_Runes:SetWaitingRuneColor(rune, r, g, b)
	local bar = nil;
	
	if( rune == 2) then
		bar = self[self.cfg.Order["Blood"]]; -- Get the bar for Blood runes
	elseif( rune == 4) then
		bar = self[self.cfg.Order["Unholy"]]; -- Get the bar for Unholy runes
	elseif( rune == 6) then
		bar = self[self.cfg.Order["Frost"]]; -- Get the bar for Frost runes
	end
	
	-- This function is only intended to use on Rune 2,4,6 if called with other rune number bar is nil, then we end this.
	if( not bar ) then return; end
	
	local v=0.3;
	
	bar.tm:SetGradient("HORIZONTAL", 0, 0, 0, r*v, g*v, b*v);
	bar.m:SetGradient("HORIZONTAL", 0, 0, 0, r*v, g*v, b*v);
	bar.bm:SetGradient("HORIZONTAL", 0, 0, 0, r*v, g*v, b*v);
	
	bar.t2:SetGradient("HORIZONTAL", r*v, g*v, b*v, r, g, b);
	bar.b2:SetGradient("HORIZONTAL", r*v, g*v, b*v, r, g, b);
	
	bar.tr:SetVertexColor(r,g,b);
	bar.r:SetVertexColor(r,g,b);
	bar.br:SetVertexColor(r,g,b);
end

--
-- SetBorderColor
-- This will set the color of the border for a specefic rune. (At the moment only used for setting the border black on init)
--
function TRB_Runes:SetBorderColor(rune, r, g, b, a)

	if( rune == 1 ) then
		local bar = self.Bar1;
		bar.tl:SetVertexColor(r,g,b,a);
		bar.bl:SetVertexColor(r,g,b,a);
		bar.l:SetVertexColor(r,g,b,a);
		bar.t1:SetVertexColor(r,g,b,a);
		bar.b1:SetVertexColor(r,g,b,a);
		
		bar.tm:SetVertexColor(r,g,b,a);
		bar.m:SetVertexColor(r,g,b,a);
		bar.bm:SetVertexColor(r,g,b,a);
	elseif( rune == 2 ) then
		local bar = self.Bar1;
		bar.tr:SetVertexColor(r,g,b,a);
		bar.r:SetVertexColor(r,g,b,a);
		bar.br:SetVertexColor(r,g,b,a);
		bar.t2:SetVertexColor(r,g,b,a);
		bar.b2:SetVertexColor(r,g,b,a);
		
	elseif( rune == 3 ) then
		local bar = self.Bar2;
		bar.tl:SetVertexColor(r,g,b,a);
		bar.bl:SetVertexColor(r,g,b,a);
		bar.l:SetVertexColor(r,g,b,a);
		bar.t1:SetVertexColor(r,g,b,a);
		bar.b1:SetVertexColor(r,g,b,a);
		
		bar.tm:SetVertexColor(r,g,b,a);
		bar.m:SetVertexColor(r,g,b,a);
		bar.bm:SetVertexColor(r,g,b,a);
	elseif( rune == 4 ) then
		local bar = self.Bar2;
		bar.tr:SetVertexColor(r,g,b,a);
		bar.r:SetVertexColor(r,g,b,a);
		bar.br:SetVertexColor(r,g,b,a);
		bar.t2:SetVertexColor(r,g,b,a);
		bar.b2:SetVertexColor(r,g,b,a);
	elseif( rune == 5 ) then
		local bar = self.Bar3;
		bar.tl:SetVertexColor(r,g,b,a);
		bar.bl:SetVertexColor(r,g,b,a);
		bar.l:SetVertexColor(r,g,b,a);
		bar.t1:SetVertexColor(r,g,b,a);
		bar.b1:SetVertexColor(r,g,b,a);
		
		bar.tm:SetVertexColor(r,g,b,a);
		bar.m:SetVertexColor(r,g,b,a);
		bar.bm:SetVertexColor(r,g,b,a);
	elseif( rune == 6 ) then
		local bar = self.Bar3;
		bar.tr:SetVertexColor(r,g,b,a);
		bar.r:SetVertexColor(r,g,b,a);
		bar.br:SetVertexColor(r,g,b,a);
		bar.t2:SetVertexColor(r,g,b,a);
		bar.b2:SetVertexColor(r,g,b,a);
	end

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
	f:SetWidth(w+2+2+2);
	f:SetHeight(h+2+2);
--	f:SetFrameStrata("HIGH");
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
	
	
	-- TM
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(14/32, 14/32+6/32, 0, 6/32);
	f.tm = t;
	
	-- BM
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "BOTTOM", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(14/32, 14/32+6/32, 14/32, 14/32+6/32);
	f.bm = t;
	
	-- Sizeable parts
	
	-- L
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tl, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.bl, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 8/32, 6/32+6/32);
	f.l = t;
	
	-- M	
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tm, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.bm, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(14/32, 14/32+6/32, 8/32, 6/32+6/32);
	f.m = t;
	
	-- R
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tr, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.br, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 8/32, 6/32+6/32);
	f.r = t;
	
	-- Top 1
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.tl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.tm, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 0, 6/32);
	f.t1 = t;
	
	-- Top 2
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.tm, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.tr, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 0, 6/32);
	f.t2 = t;
	
	-- Bottom 1
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.bl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.bm, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 14/32, 14/32+6/32);
	f.b1 = t;
	
	-- Bottom 2
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.bm, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.br, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 14/32, 14/32+6/32);
	f.b2 = t;
	
	return f;
end














---------------- Config ------------------------------------------------------------------------------------------
local DD_items = { "Blood", "Unholy", "Frost" }; -- Dropdown box items

--
-- OnDefault
-- Update the settings UI elements.
--
function TRB_Runes:OnDefault()
	self.Order = nil;

	-- Hide/Show DropDown boxes to update values
	self.DD_Bar1:Hide();
	self.DD_Bar1:Show();
	self.DD_Bar2:Hide();
	self.DD_Bar2:Show();
	self.DD_Bar3:Hide();
	self.DD_Bar3:Show();
	
	-- Update the Color of the runebars
	self:UpdateColor(1, 1, 1, 0); -- Rune 1 Bar 1
	self:UpdateColor(2, 1, 1, 0); -- Rune 2 Bar 1
	self:UpdateColor(3, 2, 1, 0); -- Rune 3 Bar 2
	self:UpdateColor(4, 2, 1, 0); -- Rune 4 Bar 2
	self:UpdateColor(5, 3, 1, 0); -- Rune 5 Bar 3
	self:UpdateColor(6, 3, 1, 0); -- Rune 6 Bar 3

end

function TRB_Runes:OnCancel()
	self.Order = nil;
	-- Reset bar position
	self:UpdateBarPositions();
end

function TRB_Runes:OnOkay()
--	if( not TRB_Config.Runes ) then self:LoadConfig(true); end
	if( not self.cfg.Order ) then 
		self:Error("[TRB_Runes:OnOkay()] Runes Order not available");
		self.cfg.Order = {}; 
	end

	-- Now save the new rune order.
	if( self.Order ) then
		TRB_Config.Runes.Order.Blood = self.Order.Blood;
		TRB_Config.Runes.Order.Unholy = self.Order.Unholy;
		TRB_Config.Runes.Order.Frost = self.Order.Frost;
		self.Order = nil;
		
		--self:Print("Blood => "..(TRB_Config.Runes.Order.Blood or "nil"));
		--self:Print("Unholy => "..(TRB_Config.Runes.Order.Unholy or "nil"));
		--self:Print("Frost => "..(TRB_Config.Runes.Order.Frost or "nil"));
	end
	
	-- Disable/Enable cooldown countdown text
	local status = self.CB_DisableText:GetChecked();
	if( status ) then
		TRB_Config.Runes.noText = nil;
	else
		TRB_Config.Runes.noText = true;
	end
	
	self:UpdateBarPositions();
end

function TRB_Runes:DD_Update(bar1, value1)
	value1 = DD_items[value1];	-- Get value as text
	
	if( not self.Order ) then
		self.Order = {};
		-- make it so we can lookup what rune a bar have
		for k,v in pairs(self.cfg.Order) do
			self.Order[v] = k;
			self.Order[k] = v;
		end
	end


--	self:Print(bar1.." set to "..value1);
	

	-- 1) Find bar2 that value1 has
	local bar2 = self.Order[value1]; -- Get bar2;
	-- 2) Find value2 that bar1 has
	local value2 = self.Order[bar1]; -- Get value2
	
--	self:Print(bar2.." currently set to "..value1.." changed to "..value2);
	
	-- 3) Give bar2 value2
	UIDropDownMenu_SetSelectedValue(_G["TRB_Runes_"..bar2], value2);
	
	-- 4) Save changes
	self.Order[bar1] = value1;
	self.Order[bar2] = value2;
	self.Order[value1] = bar1;
	self.Order[value2] = bar2;
	
	self:UpdateBarPositions();	
end

function DD_Bar1OnClick(self)
	UIDropDownMenu_SetSelectedID(TRB_Runes.DD_Bar1, self:GetID())
	
	TRB_Runes:DD_Update("Bar1", self:GetID() );
end

function DD_Bar2OnClick(self)
	UIDropDownMenu_SetSelectedID(TRB_Runes.DD_Bar2, self:GetID())
	TRB_Runes:DD_Update("Bar2", self:GetID() );
end

function DD_Bar3OnClick(self)
	UIDropDownMenu_SetSelectedID(TRB_Runes.DD_Bar3, self:GetID())
	TRB_Runes:DD_Update("Bar3", self:GetID() );
end

function DropDownInit(self, level)
--	DEFAULT_CHAT_FRAME:AddMessage("INIT DD: "..self:GetName() );
	
	local info = UIDropDownMenu_CreateInfo()
	for k,v in pairs(DD_items) do
		info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.value = v
		if( self:GetName() == "TRB_Runes_Bar1" ) then
			info.func = DD_Bar1OnClick
		elseif( self:GetName() == "TRB_Runes_Bar2" ) then
			info.func = DD_Bar2OnClick
		else
			info.func = DD_Bar3OnClick
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

function TRB_Runes:OnInitOptions(panel)

	local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	text:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -180);
	text:SetText("Rune order");
	
	local bar1 = CreateFrame("frame", "TRB_Runes_Bar1", panel, "UIDropDownMenuTemplate");
	bar1:ClearAllPoints();
	bar1:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -200);
	bar1:SetScript("OnShow", function(self) 
									local o = {};
									for k,v in pairs(TRB_Config.Runes.Order) do
										o["TRB_Runes_"..v] = k;
									end
									UIDropDownMenu_SetSelectedValue(self, (o[self:GetName()] or "Blood"));
									UIDropDownMenu_SetText(self, (o[self:GetName()] or "Blood"));
								end );
	bar1:Show();
	self.DD_Bar1 = bar1
	
	UIDropDownMenu_Initialize(bar1, DropDownInit)
	UIDropDownMenu_SetWidth(bar1, 100);
	UIDropDownMenu_SetButtonWidth(bar1, 124)
	UIDropDownMenu_JustifyText(bar1, "LEFT")

	local bar2 = CreateFrame("frame", "TRB_Runes_Bar2", panel, "UIDropDownMenuTemplate");
	bar2:ClearAllPoints();
	bar2:SetPoint("TOPLEFT", panel, "TOPLEFT", 0+130, -200);
	bar2:SetScript("OnShow", function(self) 
									local o = {};
									for k,v in pairs(TRB_Config.Runes.Order) do
										o["TRB_Runes_"..v] = k;
									end
									--DEFAULT_CHAT_FRAME:AddMessage( self:GetName().." Default "..o[self:GetName()]);
									UIDropDownMenu_SetSelectedValue(self, (o[self:GetName()] or "Unholy"));
									UIDropDownMenu_SetText(self, (o[self:GetName()] or "Unholy"));
								end );
	bar2:Show();
	self.DD_Bar2 = bar2
	
	UIDropDownMenu_Initialize(bar2, DropDownInit)
	UIDropDownMenu_SetWidth(bar2, 100);
	UIDropDownMenu_SetButtonWidth(bar2, 124)
	UIDropDownMenu_JustifyText(bar2, "LEFT")
	
	local bar3 = CreateFrame("frame", "TRB_Runes_Bar3", panel, "UIDropDownMenuTemplate");
	bar3:ClearAllPoints();
	bar3:SetPoint("TOPLEFT", panel, "TOPLEFT", 0+260, -200);
	bar3:SetScript("OnShow", function(self) 
									local o = {};
									for k,v in pairs(TRB_Config.Runes.Order) do
										o["TRB_Runes_"..v] = k;
									end
									--DEFAULT_CHAT_FRAME:AddMessage( self:GetName().." Default "..self.o[self:GetName()]);
									UIDropDownMenu_SetSelectedValue(self, (o[self:GetName()] or "Frost"));
									UIDropDownMenu_SetText(self, (o[self:GetName()] or "Frost"));
								end );
	bar3:Show();
	self.DD_Bar3 = bar3
	
	UIDropDownMenu_Initialize(bar3, DropDownInit)
	UIDropDownMenu_SetWidth(bar3, 100);
	UIDropDownMenu_SetButtonWidth(bar3, 124)
	UIDropDownMenu_JustifyText(bar3, "LEFT")
	
	--
	-- Disable Rune cooldown counter text
	--
	local cb = CreateFrame("CheckButton", "TRB_Runes_DisableText", panel, "InterfaceOptionsCheckButtonTemplate");
	cb:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -250);
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

	self:CreateColorButtonOption(panel, "Blood", 20, -300);
	self:CreateColorButtonOption(panel, "Unholy", 140, -300);
	self:CreateColorButtonOption(panel, "Frost", 20, -325);
	self:CreateColorButtonOption(panel, "Death", 140, -325);
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

function TRB_Runes:GetConfigColor(module, name)

	local runeType = 0;
	if( name == "Blood" ) then
		runeType = 1;
	elseif( name == "Unholy" ) then
		runeType = 2;
	elseif( name == "Frost" ) then
		runeType = 3;
	elseif( name == "Death" ) then
		runeType = 4;
	end

	return unpack(TRB_Config[module.name].Colors[runeType]);
end

function TRB_Runes:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetTexture(r, g, b);

	local runeType = 0;
	local newColor = {r, g, b, 1};

	if( name == "Blood" ) then
		runeType = 1;
	elseif( name == "Unholy" ) then
		runeType = 2;
	elseif( name == "Frost" ) then
		runeType = 3;
	elseif( name == "Death" ) then
		runeType = 4;
	end

	TRB_Config[module.name].Colors[runeType] = newColor;

	if( runeType < 4 ) then	
		self:UpdateColor(runeType*2-1, runeType, 1, 0);
		self:UpdateColor(runeType*2, runeType, 1, 0);
	end
end