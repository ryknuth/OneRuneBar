if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";
local FF_Icon = "Interface\\Icons\\Spell_DeathKnight_FrostFever";
local BP_Icon = "Interface\\Icons\\Spell_DeathKnight_BloodPlague";
local NP_Icon = "Interface\\Icons\\Spell_DeathKnight_NecroticPlague";

local BarSize = {
	["Width"] = 98,
	["Height"] = 8,
};

------------------------------------------------------------------------

TRB_Diseases = TRB_Module:create("Diseases");
-- Register Disease module
ThreeRuneBars:RegisterModule(TRB_Diseases);
------------------------------------------------------------------------

function TRB_Diseases:OnDisable()
	self.frame:SetScript("OnEvent", nil);
	self.frame:SetScript("OnUpdate", nil);
end

function TRB_Diseases:getDefault(val)
	if( val == "Position" ) then
		return { "CENTER", nil, "CENTER", 160, -25 };
	end
	return nil;
end

function CreateDiseaseIcon( barContainer, texture )
	local icon;
	icon = barContainer:CreateTexture( nil, "OVERLAY" );
	icon:ClearAllPoints();
	icon:SetTexture( texture );
	icon:SetPoint( "RIGHT", barContainer, "LEFT", -2, 0 );
	icon:SetWidth( 18 );
	icon:SetHeight( 18 );
	barContainer.icon = icon;
end

function TRB_Diseases:CreateDiseaseBar( strDiseaseLong, strDiseaseShort, strDiseaseName, barContainer )
	local bar = self:CreateBar( strDiseaseLong , self.frame );
	barContainer.bar = bar;

	bar:SetValue( 0 );

	bar:SetWidth( BarSize.Width );
	bar:SetHeight( BarSize.Height );
	local colors = TRB_Config[self.name].Colors[strDiseaseShort];
	bar:SetStatusBarColor( colors[1], colors[2], colors[3] );

	bar.id = strDiseaseName;

	bar:SetPoint( "TOPLEFT", barContainer, "TOPLEFT", 2, -2 );

	self.Bars[ strDiseaseShort ] = bar;
end

function TRB_Diseases:OnEnable()
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
		
		self.FrostFever = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.FrostFever:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -4);
		self.BloodPlague = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.BloodPlague:SetPoint("TOP", self.FrostFever, "BOTTOM", 0, -8);
		self.NecroticPlague = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.NecroticPlague:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -4);
		
		-- Create Icons
		CreateDiseaseIcon( self.FrostFever, FF_Icon );
		CreateDiseaseIcon( self.BloodPlague, BP_Icon );
		CreateDiseaseIcon( self.NecroticPlague, NP_Icon );
		
		self:CreateMoveFrame();
	end

	if( not self.Bars ) then
		self.Bars = {};

		self:CreateDiseaseBar( "Frost_Fever", "ff", "Frost Fever", self.FrostFever );
		self:CreateDiseaseBar( "Blood_Plague", "bp", "Blood Plague", self.BloodPlague );
		self:CreateDiseaseBar( "Necrotic_Plague", "np", "Necrotic Plague", self.NecroticPlague );
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	self.frame:RegisterEvent("UNIT_AURA");
	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self.frame:RegisterEvent("PLAYER_TALENT_UPDATE");

	self.last = 0;
	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );
	
	self.frame:Hide();
end

function UpdateBarVisibility( bar, value )

	if value then
		bar:Show();
		bar.bar:Show();
	else
		bar:Hide();
		bar.bar:Hide();
	end
end

function TRB_Diseases:UpdateVisibilities()
	-- Default visibility is necrotic plague is off
	local showNecroticPlague = false;

	local selected = false;
	for tier=1, MAX_TALENT_TIERS do
		for column=1, NUM_TALENT_COLUMNS do
			local id, name, iconPath, selected, available = GetTalentInfo( tier, column, GetActiveSpecGroup() );
			if id == 21207 and selected then
				showNecroticPlague = true;
				break;
			end
		end
	end

	UpdateBarVisibility( self.FrostFever, not showNecroticPlague );
	UpdateBarVisibility( self.BloodPlague, not showNecroticPlague );
	UpdateBarVisibility( self.NecroticPlague, showNecroticPlague );
end

function TRB_Diseases:UpdateDiseaseBar(disease)
		local bar = self.Bars[disease];

		local name, _, icon, _,_,  duration, expirationTime, _ = UnitAura("target", bar.id, nil, "PLAYER|HARMFUL");
		
		if name then
			local val = expirationTime - GetTime();
			local valT = format("%.0f", val);
			if( val < 5 ) then valT = format("%.1f", val); end
			if( val < 0 ) then valT = ""; end;
			local val = (val / duration) * 100;
			bar:SetValue(val);
			
			bar.text:SetText( valT );
		else
			bar:SetValue(0);
			bar.text:SetText();
		end
end

function TRB_Diseases:showBars(v)
	if(v) then
		self.frame:Show();
		self.needUpdate = true;
	else
		self.frame:Hide();
		self.needUpdate = false;
		self.Bars["ff"]:SetValue(0);
		self.Bars["bp"]:SetValue(0);
		self.Bars["np"]:SetValue(0);
	end
end

function TRB_Diseases:PLAYER_TALENT_UPDATE()
	self:UpdateVisibilities();
end

function TRB_Diseases:ACTIVE_TALENT_GROUP_CHANGED()
	self:UpdateVisibilities();
end

function TRB_Diseases:UNIT_AURA(unit)
end

function TRB_Diseases:PLAYER_TARGET_CHANGED()
	if( UnitExists("target")) then
		self:showBars(true);
	else
		self:showBars(false);
	end
end

function TRB_Diseases:OnUpdate(elapsed)
	self.last = self.last + elapsed;
	
	if( self.last > 0.01 ) then
		if( self.needUpdate) then
			self:UpdateDiseaseBar("ff");
			self:UpdateDiseaseBar("bp");
			self:UpdateDiseaseBar("np");
		end
		self.last = 0;
	end
end

-- Create a holder frame for each bar (this is not the statusbars, just the background)
function TRB_Diseases:CreateBarContainer(w, h)
	local f = CreateFrame("frame", nil, self.frame)

	-- Set position
	f:SetWidth(w+2+2);
	f:SetHeight(h+2+2);
	
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

function TRB_Diseases:SetBarTexture(texture)
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

function TRB_Diseases:OnInitOptions(panel)
	self:CreateColorButtonOption(panel, "FFever", 420, -80);
	self:CreateColorButtonOption(panel, "BPlague", 420, -110);
	self:CreateColorButtonOption(panel, "NPlague", 420, -140);
end

function TRB_Diseases:GetConfigColor(module, name)
	if( name == "FFever" ) then
		return unpack(TRB_Config[module.name].Colors["ff"]);
	elseif( name == "BPlague" ) then
		return unpack(TRB_Config[module.name].Colors["bp"]);
	elseif( name == "NPlague" ) then
		return unpack(TRB_Config[module.name].Colors["np"]);
	end
	module:Print("TRB BUG: Didn't find color config name: "..name);
end

function TRB_Diseases:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetTexture(r, g, b);

	local newColor = {r, g, b, 1};
	if( name == "FFever" ) then
		TRB_Config[module.name].Colors["ff"] = newColor;
	elseif( name == "BPlague" ) then
		TRB_Config[module.name].Colors["bp"] = newColor;
	elseif( name == "NPlague" ) then
		TRB_Config[module.name].Colors["np"] = newColor;
	end
end