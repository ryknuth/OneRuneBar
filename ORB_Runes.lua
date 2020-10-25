if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------

ORB_Runes = ORB_Module:create("Runes");
-- Register Rune module
OneRuneBar:RegisterModule(ORB_Runes);
------------------------------------------------------------------------

function ORB_Runes:OnDisable()
	self.frame:SetScript("OnUpdate", nil);
	self.frame:SetScript("OnEvent", nil);
end

function ORB_Runes:CreateRunes()
	for num=1, 6 do
		local bar = self:CreateBar( "ORB_Rune"..num, self.frame);
		self.Runes[num] = bar;

		if( num ~= 1 ) then
			self:CreateMiddleLine(self.Runes[num - 1], self.Runes[num] );
		end
	end
end

function ORB_Runes:PositionRunes()
	local borderSize = self:Config_GetBorderSize();
	local barSize = self:Config_GetBarSize();

	for num=1, 6 do
		local bar = self.Runes[num];
		bar:SetWidth( barSize[1] );
		bar:SetHeight( barSize[2] );
		if( num == 1 ) then
			bar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", borderSize, -(borderSize));
		else
			bar:SetPoint("TOPLEFT", self.Runes[num - 1], "TOPRIGHT", borderSize, 0);
		end
	end
end

function ORB_Runes:CreateMiddleLine(bar1, bar2)
	local t = self:CreateTexture(self.frame);
	t:SetColorTexture( 0.0, 0.0, 0.0 );
	t:SetPoint("TOPLEFT", bar1, "TOPRIGHT", 0, 0 );
	t:SetPoint( "BOTTOMRIGHT", bar2, "BOTTOMLEFT", 0, 0 );
	return t;
end

function ORB_Runes:CreateFrame()
	local frame = CreateFrame("frame", nil, UIParent);

	frame.owner = self;
	self.frame = frame;
	frame:Show();

	self:CreateBorder( frame );

	-- Create a moveframe so user can unlock and move the rune bars
	self:CreateMoveFrame();

	-- Create the runebars
	self.Runes = {};

	self:CreateRunes();
	self:UpdateColor();
end

function ORB_Runes:PositionFrame()
	local borderSize = self:Config_GetBorderSize();
	local barSize = self:Config_GetBarSize();

	self.frame:SetWidth( 6 * barSize[1] + 7 * borderSize );
	self.frame:SetHeight( barSize[2] + 2 * borderSize );

	self:PositionRunes();
	self:UpdateBorderSizes( self.frame );
end

function ORB_Runes:OnInit()
	if( not self.frame ) then
		self:CreateFrame();
	end

	self:PositionFrame();

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
function ORB_Runes:UpdateColor(currentValue, duration)
	local a = 1;
	if( (currentValue or 1) < (duration or 0) ) then
		a = 0.8;
	end

	if( not self.cfg.Color ) then
		self.cfg.Color = {}
		self.cfg.Color[1] = ORB_Config_Defaults.Runes.Color[1];
		self.cfg.Color[2] = ORB_Config_Defaults.Runes.Color[2];
		self.cfg.Color[3] = ORB_Config_Defaults.Runes.Color[3];
	end;

	-- Update Runebar color
	for runeIndex=1, 6 do
		self.Runes[runeIndex]:SetStatusBarColor(self.cfg.Color[1], self.cfg.Color[2], self.cfg.Color[3], a);
	end
end

--
-- UpdateText
-- Update cooldown text on runebars
--
function ORB_Runes:UpdateText( runeIndex, value, duration )

	if( self:Config_GetDisableText() ) then
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

function ORB_Runes:UpdateRuneInfoTable()
	for runeIndex=1, 6 do
		local start, duration, ready = GetRuneCooldown( runeIndex );
		if (not duration) then duration = 0 end;
		if (not ready) then ready = 0 end;
		local value = 0;
		if (start) then value = GetTime() - start end;

		if( not value or value < 0 ) then value = 0 end;

		self.RuneInfoTable[runeIndex][2] = value;
		self.RuneInfoTable[runeIndex][3] = duration;
		self.RuneInfoTable[runeIndex][4] = ready;
	end
end

function ORB_Runes:AreAllReady()
	for runeIndex=1,6 do
		local start, duration, ready = GetRuneCooldown( runeIndex );
		if( not ready ) then return false end;
	end
	return true;
end


function ORB_sort(t)
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

function ORB_Runes:SortRuneInfos()
	for runeIndex=1, 6 do
		self.SortedRuneInfos[runeIndex] = self.RuneInfoTable[runeIndex];
	end

	ORB_sort(self.SortedRuneInfos);
end

function ORB_Runes:UpdateFullBar()
	self:UpdateRuneInfoTable();
	self:SortRuneInfos();

	local previousAllReadyState = self.allReadyState;
	self.allReadyState = self:AreAllReady();
	if (self.allReadyState ~= previousAllReadyState) then
		OneRuneBar:UpdateCombatFading();
	end

	for runeIndex=1, 6 do
		local oldValue = self.Runes[runeIndex]:GetValue();

		local value = self.SortedRuneInfos[runeIndex][2];
		local duration = self.SortedRuneInfos[runeIndex][3];
		self.Runes[runeIndex]:SetValue( value / duration * 100 );
		self:UpdateText(runeIndex, duration - value, duration);
	end
end

-- Runes EVENTS
function ORB_Runes:RUNE_POWER_UPDATE(...)
	self:UpdateFullBar();
end

-- OnUpdate
function ORB_Runes:OnUpdate(elapsed)
	self.last = self.last + elapsed;

	if( self.last > 0.01 ) then
		self:UpdateFullBar();

		self.last = 0;
	end
end


---------------- Config ------------------------------------------------------------------------------------------
--
-- OnDefault
-- Update the settings UI elements.
--
function ORB_Runes:OnDefault()
	-- Update the Color of the runebars
	self:UpdateColor(1, 0); -- Rune 1 Bar 1
end

function ORB_Runes:OnInitOptions(panel, bottomObject)
	--
	-- Disable Rune cooldown counter text
	--
	local cb = CreateFrame("CheckButton", "ORB_Runes_DisableText", panel, "InterfaceOptionsCheckButtonTemplate");
	cb:SetPoint("TOPLEFT", bottomObject, "BOTTOMLEFT", 0, -20);
	cb.text = _G[cb:GetName().."Text"];
	cb.text:SetText("Enable "..self.name.." cooldown counter text");
	cb:SetScript( "OnClick", function(self, button, down) self.owner:Config_SetDisableText( not self:GetChecked() ); end );
	cb:SetChecked( not self:Config_GetDisableText() );
	cb.owner = self;
	self.CB_DisableText = cb;

	---
	--- Color buttons
	---

	local btn, tex = self:CreateColorButtonOption(panel, "Rune Color");
	btn:SetPoint( "LEFT", self.TextureDD, "RIGHT", 20, 0 );
end

function ORB_Runes:SetBarTexture(texture)
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

function ORB_Runes:GetConfigColor(module)
	if( not ORB_Config[module.name].Color ) then
		ORB_Config[module.name].Color = ORB_Config_Defaults[module.name].Color;
	end

	return unpack(ORB_Config[module.name].Color);
end

function ORB_Runes:SetBarColor(module, name, r, g, b)
	module.panel.barcolor[name]:SetColorTexture(r, g, b);

	local newColor = {r, g, b, 1};

	ORB_Config[module.name].Color = newColor;

	self:UpdateColor();
end

function ORB_Module:Config_GetDisableText()
	if( ORB_Config[self.name].noText == nil ) then return false; end
	return ORB_Config[self.name].noText;
end

function ORB_Module:Config_SetDisableText(val)
	if( val ) then
		ORB_Config[self.name].noText = true;
	else
		ORB_Config[self.name].noText = nil;
	end
end

function ORB_Module:Config_SetFontSize(val)
	ORB_Config[self.name].FontSize = val;

	for num=1, 6 do
		self.Runes[num].text:SetFont("Fonts\\FRIZQT__.TTF", val, "");
	end
end
