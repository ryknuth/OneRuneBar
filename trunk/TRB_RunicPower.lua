if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

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

function TRB_RunicPower:CreateFrame()
	local f = CreateFrame("frame", nil, UIParent);

	-- Set Position and size
	f:ClearAllPoints();
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	f:Show();
	f.owner = self;
	self.frame = f;

	self:CreateBorder(self.frame);
	
	self:CreateMoveFrame();

	-- Runic Power
	local rp = self:CreateBar("TRB_RunicPower", self.frame);
	rp:SetValue( UnitPower("player") );
	rp:SetMinMaxValues( 0, UnitPowerMax("player", 6) );
	rp:SetStatusBarColor( unpack(TRB_Config[self.name].Colors) );
	
	-- Text for Runic Power
	rp.text:SetText(UnitPower("player") or 0);
	self.Bar = rp;
end

function TRB_RunicPower:PositionFrame()
	local borderSize = self:Config_GetBorderSize();
	local barSize = self:Config_GetBarSize();

	self.frame:SetWidth(barSize[1] + 2 * borderSize);
	self.frame:SetHeight(barSize[2] + 2 * borderSize);

	self.Bar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", borderSize, -(borderSize));
	self.Bar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -(borderSize), borderSize);

	self:UpdateBorderSizes( self.frame );
end

function TRB_RunicPower:OnEnable()
	if( not self.frame ) then
		self:CreateFrame();
	end

	self:PositionFrame();

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
		self.Bar:SetMinMaxValues( 0, UnitPowerMax("player", 6) );
		self.Bar:SetValue(rp);
		self.Bar.text:SetText(rp);
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