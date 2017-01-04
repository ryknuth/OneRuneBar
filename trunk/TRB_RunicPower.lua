if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";

local BarSize = {
	["Width"] = 306,
	["Height"] = 8,
};

------------------------------------------------------------------------
TRB_RunicPower = TRB_Module:create("RunicPower");
-- Register Disease module
ThreeRuneBars:RegisterModule(TRB_RunicPower);
------------------------------------------------------------------------

function TRB_RunicPower:OnDisable()
	self.frame:SetScript("OnEvent", nil);
	self.frame:SetScript("OnUpdate", nil);
end

function TRB_RunicPower:getDefault(val)
	if( val == "Position" ) then
		return { "CENTER", nil, "CENTER", 160, -25 };
	end
	return nil;
end

function TRB_RunicPower:OnEnable()
	if( not self.frame ) then
		local f = CreateFrame("frame", nil, UIParent);
	
		-- Set Position and size
		f:ClearAllPoints();
		f:SetWidth(BarSize.Width+2+2);
		f:SetHeight(BarSize.Height+2+2);
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		f:SetFrameStrata("HIGH"); -- Set to HIGH framestrata to be visible ontop of Blizzards "Power Aura" thing
		f:Show();
		f.owner = self;
		self.frame = f;
		
		-- Background
--		local bg = f:CreateTexture(nil, "BACKGROUND");
--		bg:SetWidth(512);
--		bg:SetHeight(512);
--		bg:SetPoint("CENTER", f, "CENTER", 0, 0);
--		bg:SetTexture(BG_Tex);
--		f.bg = bg;
		
		self:CreateBorder();
		
		self:CreateMoveFrame();
	end

	if( not self.Bar ) then
	
		-- Runic Power
		local rp = self:CreateBar("TRB_RunicPower", self.frame);
		rp:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 2, -2);
		rp:SetWidth(BarSize.Width);
		rp:SetHeight(BarSize.Height);
		rp:SetValue( UnitPower("player") );
		rp:SetMinMaxValues( 0, UnitPowerMax("player", 6) );
		rp:SetStatusBarColor( unpack(TRB_Config[self.name].Colors) );
		
		-- Text for Runic Power
		rp.text:SetText(UnitPower("player") or 0);
		self.Bar = rp;
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	-- Runic Power
	self.frame:RegisterEvent("UNIT_POWER");
	self.frame:RegisterEvent("UNIT_MAXPOWER");

	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );
	
end

function TRB_RunicPower:getDefault(val)
	if( val == "Position" ) then
		return TRB_Config_Defaults[self.name].Position or { "CENTER", nil, "CENTER", 0, -150 };
	elseif( val == "Color" ) then
		return TRB_Config_Defaults[self.name].Colors or { [1] = 0.2, [2] = 0.7, [3] = 1,   [4] = 1 };
	end
	return nil;
end

-- Runic Power EVENTS
function TRB_RunicPower:UNIT_POWER(unit, power)
	if( unit == "player" ) then
		local rp = UnitPower("player")
		--DEFAULT_CHAT_FRAME:AddMessage("RP: "..rp);
		self.Bar:SetMinMaxValues( 0, UnitPowerMax("player", 6) );
		self.Bar:SetValue(rp);
		self.Bar.text:SetText(rp);
		--DEFAULT_CHAT_FRAME:AddMessage("bar: "..Bars[7]:GetValue());
	end
end

function TRB_RunicPower:UNIT_MAXPOWER(unit, power)
	self.Bar:SetMinMaxValues( 0, UnitPowerMax("player", 6) );
end

-- OnUpdate
function TRB_RunicPower:OnUpdate(elapsed)
	self.last = (self.last or 0) + elapsed;
	
	if( self.last > 2.0 ) then
	
		self:UNIT_POWER("player", "RUNIC_POWER");
		
		self.last = 0;
	end
end

-- Create Border
function TRB_RunicPower:CreateBorder()
	local f = self.frame;
	
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
	f.t1 = t;
	
	-- Bottom
	t = self:CreateTexture(f, 6, 6);
	t:SetPoint("LEFT", f.bl, "RIGHT", 0, 0);
	t:SetPoint("RIGHT", f.br, "LEFT", 0, 0);
	t:SetTexture(BG_Tex);
	t:SetTexCoord(8/32, 6/32+6/32, 14/32, 14/32+6/32);
	t:SetVertexColor(0, 0, 0, 1);
	f.b1 = t;
	
	return f;
end

function TRB_RunicPower:SetBarTexture(texture)
	self.cfg.Texture = texture;

	if( not SM ) then
		return;
	end

	self.Bar:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR,texture));
	self.Bar:GetStatusBarTexture():SetHorizTile(false);
	self.Bar:GetStatusBarTexture():SetVertTile(false);
end

function TRB_RunicPower:OnInitOptions(panel)
	self:CreateColorButtonOption(panel, "RPower", 420, -110);
end

function TRB_RunicPower:GetConfigColor(module, name)
	return unpack(TRB_Config[module.name].Colors);
end

function TRB_RunicPower:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetColorTexture(r, g, b);

	TRB_Config[module.name].Colors = { r, g, b, 1 };
end