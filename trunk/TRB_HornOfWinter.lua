if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";
local HoW_Icon = "Interface\\Icons\\INV_Misc_Horn_02";

local BarSize = {
	["Width"] = 170,
	["Height"] = 8,
};

------------------------------------------------------------------------

TRB_HornOfWinter = TRB_Module:create("Horn of Winter");
-- Register module
ThreeRuneBars:RegisterModule(TRB_HornOfWinter);
------------------------------------------------------------------------

function TRB_HornOfWinter:OnDisable()
	self.frame:SetScript("OnEvent", nil);
	self.frame:SetScript("OnUpdate", nil);
end

function TRB_HornOfWinter:getDefault(val)
	if( val == "Position" ) then
		return { "CENTER", nil, "CENTER", 160, -25 };
	end
	return nil;
end

function TRB_HornOfWinter:OnEnable()
	if( not self.frame ) then
		local f = CreateFrame("frame", nil, UIParent);
	
		-- Set Position and size
		f:ClearAllPoints();
		f:SetWidth(128);
		f:SetHeight(12);
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		f:SetFrameStrata("HIGH"); -- Set to HIGH framestrata to be visible ontop of Blizzards "Power Aura" thing
		f.owner = self;
		self.frame = f;
		
		self.HoW = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.HoW:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -4);
		
		-- Create Icon
		local icon;
		icon = self.HoW:CreateTexture(nil, "OVERLAY"); icon:ClearAllPoints(); icon:SetTexture(HoW_Icon);
		icon:SetPoint("RIGHT", self.HoW, "LEFT", -2, 0);
		icon:SetWidth(18); icon:SetHeight(18);
		self.HoW.icon = icon;
		
		self:CreateMoveFrame();
	end

	if( not self.Bars ) then

		local how = self:CreateBar("Horn_of_Winter", self.frame);
		
		how:SetValue(50);
		
		if( not self.cfg.Colors) then self.cfg.Colors = { 0, 0, 1, 1 }; end
		
		how:SetWidth(BarSize.Width);
		how:SetHeight(BarSize.Height);
		how:SetStatusBarColor( unpack(self.cfg.Colors) );
		how:Show();
		
		how.id = "Horn of Winter";
		
		how:SetPoint("TOPLEFT", self.HoW, "TOPLEFT", 2, -2);
		
		-- Bars
		self.Bars = {};
		self.Bars["how"] = how;
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	self.frame:RegisterEvent("UNIT_AURA");

	self.last = 0;
	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );
	
	self.frame:Show();
	self:UpdateBar("how");
end

function TRB_HornOfWinter:UpdateBar(barName)
		local bar = self.Bars[barName];

		local name, _, icon, _,_,  duration, expirationTime, _ = UnitAura("player", bar.id, nil, "PLAYER|HELPFUL");
		
		if name then
			self.needUpdate = true;
			local val = expirationTime - GetTime();
			local valT = format("%.0f", val);
			if( val > 60 ) then valT = format("%.0f:%02d", floor(val/60), floor(mod(val,60))); end
			if( val < 5 ) then valT = format("%.1f", val); end
			if( val < 0 ) then valT = ""; end;
			local val = (val / duration) * 100;
			bar:SetValue(val);
			
			bar.text:SetText( valT );
--			bar:Show();
		else
--			bar:Hide();
			bar:SetValue(0);
			bar.text:SetText();
			self.needUpdate = nil;
		end
end

function TRB_HornOfWinter:UNIT_AURA(unit)
	if( unit == "player" ) then
		self:UpdateBar("how");
	end
end

function TRB_HornOfWinter:OnUpdate(elapsed)
	self.last = self.last + elapsed;
	
	if( self.last > 0.1 ) then
		if( self.needUpdate) then
			self:UpdateBar("how");
		end
		
		self.last = 0;
	end
end

-- Create a border for each bar (this is not the statusbars, just the background)
function TRB_HornOfWinter:CreateBarContainer(w, h)
	local f = CreateFrame("frame", nil, self.frame)
	-- Set position
	f:SetWidth(w+2+2);
	f:SetHeight(h+2+2);
--	f:SetFrameStrata("HIGH");
	f:Show();
	
	-- Corners
	
	-- TL
	local t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "TOPLEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 0, 6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.tl = t;
	
	-- BL
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "BOTTOMLEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 14/32, 14/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.bl = t;
	
	-- TR
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "TOPRIGHT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 0, 6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.tr = t;
	
	-- BR
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("CENTER", f, "BOTTOMRIGHT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 14/32, 14/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.br = t;
	
	
	-- Sizeable parts
	
	-- L
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tl, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.bl, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(0, 6/32, 8/32, 6/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.l = t;
	
	-- R
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("TOP", f.tr, "BOTTOM", 0, 0);
	t:SetPoint("BOTTOM", f.br, "TOP", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(21/32, 21/32+6/32, 8/32, 6/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.r = t;
	
	-- Top
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.tl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.tr, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 0, 6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.t = t;
	
	-- Bottom
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.bl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.br, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 14/32, 14/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.b = t;
	
	return f;
end

function TRB_HornOfWinter:SetBarTexture(texture)
	self.cfg.Texture = texture;

	if( not SM ) then
		return;
	end

	for k,v in pairs(self.Bars) do
		v:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR,texture));
		v:GetStatusBarTexture():SetHorizTile(false);
		v:GetStatusBarTexture():SetVertTile(false);
	end
end

function TRB_HornOfWinter:OnInitOptions(panel)
	self:CreateColorButtonOption(panel, "Horn", 420, -110);
end

function TRB_HornOfWinter:GetConfigColor(module, name)
	return unpack(TRB_Config[module.name].Colors);
end

function TRB_HornOfWinter:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetTexture(r, g, b);

	TRB_Config[module.name].Colors = { r, g, b, 1 };
end