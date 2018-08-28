if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------
local FF_Icon = "Interface\\Icons\\Spell_DeathKnight_FrostFever";
local BP_Icon = "Interface\\Icons\\Spell_DeathKnight_BloodPlague";
local VP_Icon = "Interface\\Icons\\ability_creature_disease_02";

local IconGap = 2;

------------------------------------------------------------------------

ORB_Diseases = ORB_Module:create("Diseases");
-- Register Disease module
OneRuneBar:RegisterModule(ORB_Diseases);
------------------------------------------------------------------------

function ORB_Diseases:OnDisable()
	self.frame:SetScript("OnEvent", nil);
	self.frame:SetScript("OnUpdate", nil);
end

function ORB_Diseases:getDefault(val)
	if( val == "Position" ) then
		return { "CENTER", nil, "CENTER", 160, -25 };
	end
	return nil;
end

function ORB_Diseases:CreateFrame()
	local f = CreateFrame("frame", nil, UIParent);

	-- Set Position and size
	f:ClearAllPoints();
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	f.owner = self;
	self.frame = f;

	self.DiseaseBarContainer = CreateFrame("frame", nil, self.frame)
	self.DiseaseBarContainer:Show();

	self:CreateBorder(self.DiseaseBarContainer);

	-- Create Icons
	local icon = self.frame:CreateTexture(nil, "OVERLAY");
	icon:ClearAllPoints();
	self.icon = icon;

	self:CreateMoveFrame();

	local bar = self:CreateBar("Disease_Bar", self.frame);
	bar:SetValue(0);
	bar:Show();
	self.DiseaseBar = bar;
end

function ORB_Diseases:PositionFrame()
	local borderSize = self:Config_GetBorderSize();
	local barSize = self:Config_GetBarSize();
	local iconSize = self:Config_GetIconSize();

	self.frame:SetWidth(barSize[1] + 2 * borderSize + IconGap + iconSize );
	self.frame:SetHeight(iconSize);

	self.DiseaseBarContainer:SetHeight(barSize[2] + 2 * borderSize );
	self.DiseaseBarContainer:SetPoint("CENTER", self.frame, "CENTER", 0, 0);
	self.DiseaseBarContainer:SetPoint("LEFT", self.frame, "LEFT", IconGap + iconSize, 0 );
	self.DiseaseBarContainer:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0);

	self.icon:SetPoint("TOP", self.frame, "TOP", 0, 0);
	self.icon:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0);
	self.icon:SetPoint("LEFT", self.frame, "LEFT", 0, 0);
	self.icon:SetPoint("RIGHT", self.frame, "LEFT", iconSize, 0);

	self.DiseaseBar:SetPoint("TOPLEFT", self.DiseaseBarContainer, "TOPLEFT", borderSize, -(borderSize));
	self.DiseaseBar:SetPoint("BOTTOMRIGHT", self.DiseaseBarContainer, "BOTTOMRIGHT", -(borderSize), borderSize);

	self:UpdateBorderSizes( self.DiseaseBarContainer );
end

function ORB_Diseases:OnEnable()
	if( not self.frame ) then
		self:CreateFrame();
	end

	self:PositionFrame();

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

function ORB_Diseases:PLAYER_SPECIALIZATION_CHANGED()
	self:UpdateDiseaseNameAndIcon();
end

function ORB_Diseases:UpdateDiseaseNameAndIcon()
	local specId = GetSpecialization();
	if( not specId ) then return; end
	if ( specId == 1 ) then
		self.icon:SetTexture(BP_Icon);
		self.DiseaseBar.id = "Blood Plague";
		self.DiseaseBar:SetStatusBarColor( ORB_Config[self.name].Colors["bp"][1], ORB_Config[self.name].Colors["bp"][2], ORB_Config[self.name].Colors["bp"][3] );
	elseif( specId == 2 ) then
		self.icon:SetTexture(FF_Icon);
		self.DiseaseBar.id = "Frost Fever";
		self.DiseaseBar:SetStatusBarColor( ORB_Config[self.name].Colors["ff"][1], ORB_Config[self.name].Colors["ff"][2], ORB_Config[self.name].Colors["ff"][3] );
	else
		self.icon:SetTexture(VP_Icon);
		self.DiseaseBar.id = "Virulent Plague";
		self.DiseaseBar:SetStatusBarColor( ORB_Config[self.name].Colors["vp"][1], ORB_Config[self.name].Colors["vp"][2], ORB_Config[self.name].Colors["vp"][3] );
	end
end

function ORB_Diseases:UpdateDiseaseBar()
	local bar = self.DiseaseBar;

	local found = false;
	local i = 1;
	for i = 1, 40 do
		local name, _, _, _, duration, expirationTime = UnitAura("target", i, "PLAYER|HARMFUL");
		if name == bar.id then
			found = true;
			break;
		end
	end

	if not found then return; end

	local name, _, _, _, duration, expirationTime = UnitAura("target", i, "PLAYER|HARMFUL");

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

function ORB_Diseases:showBars(v)
	if(v) then
		self.frame:Show();
		self.needUpdate = true;
	else
		self.frame:Hide();
		self.needUpdate = false;
		self.DiseaseBar:SetValue(0);
	end
end

function ORB_Diseases:UNIT_AURA(unit)
end

function ORB_Diseases:PLAYER_TARGET_CHANGED()
	if( UnitExists("target")) then
		self:showBars(true);
	else
		self:showBars(false);
	end
end

function ORB_Diseases:OnUpdate(elapsed)
	self.last = self.last + elapsed;

	if( self.last > 0.01 ) then
		if( self.needUpdate) then
			self:UpdateDiseaseBar();
		end

		self.last = 0;
	end
end

function ORB_Diseases:SetBarTexture(texture)
	self.cfg.Texture = texture;

	if( not SM ) then
		return;
	end

	self.DiseaseBar:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR,texture));
	self.DiseaseBar:GetStatusBarTexture():SetHorizTile(false);
	self.DiseaseBar:GetStatusBarTexture():SetVertTile(false);
end

function ORB_Diseases:OnInitOptions(panel, bottomObject)
	local btn, tex = self:CreateColorButtonOption(panel, "FFever");
	btn:SetPoint( "LEFT", self.TextureDD, "RIGHT", 20, 0 );
	local btn2, tex2 = self:CreateColorButtonOption(panel, "BPlague");
	btn2:SetPoint( "LEFT", tex, "RIGHT", 20, 0 );
	local btn3, tex3 = self:CreateColorButtonOption(panel, "VPlague");
	btn3:SetPoint( "LEFT", tex2, "RIGHT", 20, 0 );

	local iconSizeLabel = self:CreateLabel( panel, "Icon Size:");
	iconSizeLabel:SetPoint("TOPLEFT", bottomObject, "BOTTOMLEFT", 0, -20);
	
	local barHeightBox = self:CreateEditBox( panel, "ORB_IconSizeEditBox"..self.name,
		function(self) return self:Config_GetIconSize(); end,
		function(self, value) self:Config_SetIconSize(value); end );
	barHeightBox:SetPoint("TOPLEFT", iconSizeLabel, "TOPRIGHT", 4, 0);
	barHeightBox:SetPoint("BOTTOMLEFT", iconSizeLabel, "BOTTOMRIGHT", 0, 0);
end

function ORB_Diseases:GetConfigColor(module, name)
	if( name == "FFever" ) then
		if( not ORB_Config[module.name].Colors["ff"] ) then
			ORB_Config[module.name].Colors["ff"] = ORB_Config_Defaults[module.name].Colors["ff"];
		end
		return unpack(ORB_Config[module.name].Colors["ff"]);
	elseif( name == "BPlague" ) then
		if( not ORB_Config[module.name].Colors["bp"] ) then
			ORB_Config[module.name].Colors["bp"] = ORB_Config_Defaults[module.name].Colors["bp"];
		end
		return unpack(ORB_Config[module.name].Colors["bp"]);
	elseif( name == "VPlague" ) then
		if( not ORB_Config[module.name].Colors["vp"] ) then
			ORB_Config[module.name].Colors["vp"] = ORB_Config_Defaults[module.name].Colors["vp"];
		end
		return unpack(ORB_Config[module.name].Colors["vp"]);
	end
	module:Print("ORB BUG: Didn't find color config name: "..name);
end

function ORB_Diseases:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetColorTexture(r, g, b);

	local newColor = {r, g, b, 1};
	if( name == "FFever" ) then
		ORB_Config[module.name].Colors["ff"] = newColor;
	elseif( name == "BPlague" ) then
		ORB_Config[module.name].Colors["bp"] = newColor;
	elseif( name == "VPlague" ) then
		ORB_Config[module.name].Colors["np"] = newColor;
	end
end

function ORB_Module:Config_GetIconSize()
	return ORB_Config[self.name].IconSize or ORB_Config_Defaults[self.name].IconSize;
end

function ORB_Module:Config_SetIconSize(val)
	ORB_Config[self.name].IconSize = val;

	self:PositionFrame();
end