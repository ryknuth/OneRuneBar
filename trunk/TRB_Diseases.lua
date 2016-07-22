if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local BG_Tex = "Interface\\AddOns\\ThreeRuneBars\\borders.tga";
local FF_Icon = "Interface\\Icons\\Spell_DeathKnight_FrostFever";
local BP_Icon = "Interface\\Icons\\Spell_DeathKnight_BloodPlague";
local VP_Icon = "Interface\\Icons\\ability_creature_disease_02";

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

		self.DiseaseBarContainer = self:CreateBarContainer(BarSize.Width, BarSize.Height);
		self.DiseaseBarContainer:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -4);

		-- Create Icons
		local icon;
		icon = self.DiseaseBarContainer:CreateTexture(nil, "OVERLAY");
		icon:ClearAllPoints();
		icon:SetPoint("RIGHT", self.DiseaseBarContainer, "LEFT", -2, 0);
		icon:SetWidth(18);
		icon:SetHeight(18);
		self.DiseaseBarContainer.icon = icon;

		self:CreateMoveFrame();
	end

	if( not self.DiseaseBar ) then

		local bar = self:CreateBar("Disease_Bar", self.frame);
		bar:SetValue(0);
		bar:SetWidth(BarSize.Width);
		bar:SetHeight(BarSize.Height);
		bar:Show();
		bar:SetPoint("TOPLEFT", self.DiseaseBarContainer, "TOPLEFT", 2, -2);
		self.DiseaseBar = bar;
	end

	if(self.cfg.Texture) then
		self:SetBarTexture(self.cfg.Texture);
	end

	self:UpdateDiseaseNameAndIcon();

	self.frame:RegisterEvent("UNIT_AURA");
	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");

	self.last = 0;
	self.frame:SetScript("OnEvent", function(frame, event, ...) frame.owner[event](frame.owner, ...); end );
	self.frame:SetScript("OnUpdate", function(frame, elapsed) frame.owner:OnUpdate(elapsed); end );

	self.frame:Hide();
end

function TRB_Diseases:PLAYER_SPECIALIZATION_CHANGED()
	self:UpdateDiseaseNameAndIcon();
end

function TRB_Diseases:UpdateDiseaseNameAndIcon()
	local specId = GetSpecialization();
	if( not specId ) then return; end
	if ( specId == 1 ) then
		self.DiseaseBarContainer.icon:SetTexture(BP_Icon);
		self.DiseaseBar.id = "Blood Plague";
		self.DiseaseBar:SetStatusBarColor( TRB_Config[self.name].Colors["bp"][1], TRB_Config[self.name].Colors["bp"][2], TRB_Config[self.name].Colors["bp"][3] );
	elseif( specId == 2 ) then
		self.DiseaseBarContainer.icon:SetTexture(FF_Icon);
		self.DiseaseBar.id = "Frost Fever";
		self.DiseaseBar:SetStatusBarColor( TRB_Config[self.name].Colors["ff"][1], TRB_Config[self.name].Colors["ff"][2], TRB_Config[self.name].Colors["ff"][3] );
	else
		self.DiseaseBarContainer.icon:SetTexture(VP_Icon);
		self.DiseaseBar.id = "Virulent Plague";
		self.DiseaseBar:SetStatusBarColor( TRB_Config[self.name].Colors["vp"][1], TRB_Config[self.name].Colors["vp"][2], TRB_Config[self.name].Colors["vp"][3] );
	end
end

function TRB_Diseases:UpdateDiseaseBar()
		local bar = self.DiseaseBar;

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
		--self:SetFrameStrata("MEDIUM");
		self.needUpdate = false;
		self.DiseaseBar:SetValue(0);
	end
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
			self:UpdateDiseaseBar();
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

function TRB_Diseases:SetBarTexture(texture)
	self.cfg.Texture = texture;

	if( not SM ) then
		return;
	end

	self.DiseaseBar:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR,texture));
	self.DiseaseBar:GetStatusBarTexture():SetHorizTile(false);
	self.DiseaseBar:GetStatusBarTexture():SetVertTile(false);
end

function TRB_Diseases:OnInitOptions(panel)
	self:CreateColorButtonOption(panel, "FFever", 420, -80);
	self:CreateColorButtonOption(panel, "BPlague", 420, -110);
	self:CreateColorButtonOption(panel, "VPlague", 420, -140);
end

function TRB_Diseases:GetConfigColor(module, name)
	if( name == "FFever" ) then
		if( not TRB_Config[module.name].Colors["ff"] ) then
			TRB_Config[module.name].Colors["ff"] = TRB_Config_Defaults[module.name].Colors["ff"];
		end
		return unpack(TRB_Config[module.name].Colors["ff"]);
	elseif( name == "BPlague" ) then
		if( not TRB_Config[module.name].Colors["bp"] ) then
			TRB_Config[module.name].Colors["bp"] = TRB_Config_Defaults[module.name].Colors["bp"];
		end
		return unpack(TRB_Config[module.name].Colors["bp"]);
	elseif( name == "VPlague" ) then
		if( not TRB_Config[module.name].Colors["vp"] ) then
			TRB_Config[module.name].Colors["vp"] = TRB_Config_Defaults[module.name].Colors["vp"];
		end
		return unpack(TRB_Config[module.name].Colors["vp"]);
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
	elseif( name == "VPlague" ) then
		TRB_Config[module.name].Colors["np"] = newColor;
	end
end