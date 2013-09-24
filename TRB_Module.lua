if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end
------------------------------------------------------------------
-- Local config

local BarSize = {
	["height"] = 8,
	["width"] = 48,
};

local NoTextureText = "(none)";

------------------------------------------------------------------

TRB_Module		= {};

--
-- Change strata level for this module. Used when entering/leaving combat
--
function TRB_Module:ChangeStrata(strata)
	if( self.frame) then
		self.frame:SetFrameStrata(strata);
	end
end

--
-- Change Alpha level for in/out of combat
--
function TRB_Module:OnOutOfCombatFade(alpha)
	if not alpha then return; end
	if( self.frame ) then
		self.frame:SetAlpha(alpha);
	end
end

--
-- Create a module.
-- Use:
-- local myModule = TRB_Module:create("SomeName");
-- function myModule:OnEnable() (do stuff) end
-- ThreeRuneBars:RegisterModule(myModule);
--
function TRB_Module:create(name)
	local n = {};
	setmetatable(n, { __index = TRB_Module } );
	n.name = name;
	return n;
end

--
-- Init the module, Modules should use Enable
--
function TRB_Module:init()
	if( self.isRunning ) then return; end
	
-- This should alreay have been checked in InitOptions()
	-- Get this module settings
--	if( not TRB_Config[self.name] ) then
--		self:ResetConfig(); -- No config exists for this module. Reset to default values needed for this module.
--	end

	if( not self.cfg ) then
		self.cfg = TRB_Config[self.name];
	end

	-- Now we are ready to enable this module
	if( self.OnEnable ) then self:OnEnable(); end
	
	-- Update scale ( this is also done in ThreeRuneBars:ADDON_LOADED, Need only one?)
	if( self.frame and self.cfg.Scale ) then
		self.frame:SetScale( self.cfg.Scale );
	end
	
	self.isRunning = true;
	self:Print((self.name or "Unknown").." module enabled.");
end

function TRB_Module:CreateTexture(f, w, h)
		local tex = f:CreateTexture(nil, "BACKGROUND");
		tex:SetWidth(w);
		tex:SetHeight(h);
		tex:SetPoint("CENTER", f, "CENTER", 0, 0);
--		tex:SetTexture(BG_Tex);
		
	return tex;
end

function TRB_Module:CreateBar(name, parent)
	local Bar = CreateFrame("StatusBar", name, parent);
	Bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	Bar:GetStatusBarTexture():SetHorizTile(true);
	Bar:SetMinMaxValues(0, 100);
	Bar:SetValue(100);
	Bar:SetWidth(BarSize["width"]);
	Bar:SetHeight(BarSize["height"]);
	
	Bar.bg = Bar:CreateTexture(nil, "BACKGROUND");
	Bar.bg:SetAllPoints(Bar);
	Bar.bg:SetTexture(0.25, 0.25, 0.25, 0.5);
	
	-- Create text on bar
	local text = Bar:CreateFontString(nil, "ARTWORK", "GameFontHighlightExtraSmall");
	text:SetPoint("CENTER", Bar, "CENTER", 0, 0);
	Bar.text = text;

	return Bar;
end

function TRB_Module:CreateMoveFrame()
	local f = CreateFrame("frame", nil, self.frame);
	f.parent = self.frame;
	f:SetAllPoints(f.parent);
	f.parent:SetMovable(true);
	f:EnableMouse(true);
	f:RegisterForDrag("LeftButton");
	f:SetScript("OnDragStart", function(frame) frame.parent:StartMoving() end );
	f:SetScript("OnDragStop", function(frame) frame.parent:StopMovingOrSizing(); frame.parent.owner:SavePosition() end );
	
	f.bg = f:CreateTexture(nil, "ARTWORK");
	f.bg:SetAllPoints(f);
	f.bg:SetTexture(0.8,0.8,0.8, 0.4);
	f:SetFrameStrata("HIGH");
	f:Hide();
	
	self.moveFrame = f;
end

function TRB_Module:Disable()
	if( not self.isRunning ) then return; end -- Not running
	
	-- Hide frame and unregister all events
	if( self.frame ) then
		self.frame:Hide();
		self.frame:UnregisterAllEvents();
	end

	if( self.OnDisable ) then self:OnDisable(); end

	self.isRunning = nil;
	self:Print(self.name.." module disabled.");
end

function TRB_Module:ChangeVisibility(show)
	if( not self.isRunning ) then return; end

	if( self.frame ) then
		if( show ) then
			self.frame:Show();
		else
			self.frame:Hide();
		end
	end
end

function TRB_Module:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("TRB: "..msg);
end

function TRB_Module:SavePosition()
	if( not self.frame ) then return; end
	
--	TRB_Config[self.name].Position = { self.frame:GetPoint() };
	
	-- Save position
	self.cfg.Position = { self.frame:GetPoint() };
end

function TRB_Module:LoadPosition()
	if( not self.frame ) then return; end -- if no frame exists no position exists.
--[[	
-- This should never happen. TRB_Config should exist here.
	if( not TRB_Config[self.name] ) then TRB_Config[self.name] = TRB_Config_Defaults[self.name]; end
	
-- Module should always have a position	
	if( not TRB_Config[self.name].Position ) then
		local pos = TRB_Config_Defaults[self.name].Position;
		TRB_Config[self.name].Position = pos;
	end
--]]	
--	self.frame:SetPoint( unpack(TRB_Config[self.name].Position) );

	if( self.cfg and self.cfg.Position ) then
		self.frame:SetPoint( unpack(self.cfg.Position) );
	else
		self:Error("Failed to load position for module "..self.name);
	end
	
	if( self.OnLoadPosition ) then
		self:OnLoadPosition();
	end
end

function TRB_Module:Error(msg)
	DEFAULT_CHAT_FRAME:AddMessage("TRB Error: "..msg);
end

function TRB_Module:ResetConfig()
	
	-- Create new empty table
	TRB_Config[self.name] = nil; self.cfg = nil;
	TRB_Config[self.name] = {};
	
	-- Copy default values needed for this module
	for k,v in pairs(TRB_Config_Defaults[self.name]) do
		TRB_Config[self.name][k] = v;
	end
	
	-- Set it as our config
	self.cfg = TRB_Config[self.name];	
end

function TRB_Module:InitOptions(parent)

	-- Make sure we have our configuration settings available
	if( not TRB_Config[self.name] ) then
		self:ResetConfig();
	end

	local panel = CreateFrame("frame", self.name.."_OptionsPanel", parent);
	panel.name = self.name;
	panel.parent = parent.name;
	panel.owner = self;
	panel.okay = function(self) self.owner._OnOkay(self.owner); end
	panel.cancel = function(self) self.owner._OnCancel(self.owner); end
	panel.default = function(self) self.owner._OnDefault(self.owner); end
	--
	-- Module panel
	--
	local xoff, yoff = 20, -20;
	
	local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	header:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff);
	header:SetText(parent.name.." - "..panel.name );
	panel.header = header;
	
	-- Module disable checkbox
	local cb = CreateFrame("CheckButton", "TRB_DisableModule_"..self.name, panel, "InterfaceOptionsCheckButtonTemplate");
	cb:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff-40);
	cb.text = _G[cb:GetName().."Text"];
	cb.text:SetText("Enable "..self.name.." module");
	local v = true;
	if( TRB_Config.disabled_modules and TRB_Config.disabled_modules[self.name] and TRB_Config.disabled_modules[self.name] == true ) then
		v = false;
	end
	cb:SetChecked( v );
	self.CB_Disabled = cb;
	
	-- Scale
	local slider = CreateFrame("slider", "TRB_ModuleScaleSlider_"..self.name, panel, "OptionsSliderTemplate");
	slider:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff-90);
	slider:SetWidth(200);
	slider:SetHeight(20);
	slider:SetOrientation("HORIZONTAL");
	slider:SetMinMaxValues(0.1, 2.0);
	slider:SetValue(1);
	slider:SetValueStep(0.1);
	_G[slider:GetName().."Low"]:SetText("0.1");
	_G[slider:GetName().."High"]:SetText("2.0");
	slider.Text = _G[slider:GetName().."Text"];
	slider.owner = self;
	slider:SetScript("OnValueChanged", function(self, value) self.Text:SetText(format("Set Scale: %.1f", value) ); self.owner.frame:SetScale(value); end);
	slider:SetScript("OnShow", function(self) self:SetValue(TRB_Config[self.owner.name].Scale or TRB_Config_Defaults[self.owner.name].Scale or 1.0); end);
	slider.Text:SetText( format("Set Scale: %.1f", slider:GetValue()) );
	slider:Show();
	self.ScaleSlider = slider;

	-- Texture options
	local textureText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	textureText:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff+260, yoff-77);
	textureText:SetText("Texture");

	local textureDD = CreateFrame("frame", "TRB_ModuleTextureDD_"..self.name, panel, "UIDropDownMenuTemplate");
	textureDD:ClearAllPoints();
	textureDD:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff+240, yoff-90);
	textureDD:SetScript("OnShow", function(self)
									UIDropDownMenu_SetSelectedValue(self, TRB_Config[self.owner.name].Texture or NoTextureText);
									UIDropDownMenu_SetText(self, TRB_Config[self.owner.name].Texture or NoTextureText);
								end
						);
	textureDD:Show();
	textureDD.owner = self;
	self.TextureDD = textureDD;

	UIDropDownMenu_Initialize(
		textureDD,
		function(self, level)
			local OnClick = 
				function(self)
					UIDropDownMenu_SetSelectedID(self.owner, self:GetID());
					if( self.owner.owner.SetBarTexture ) then self.owner.owner:SetBarTexture(self.value); end
				end;

			local info = UIDropDownMenu_CreateInfo();
			info.text = NoTextureText;
			info.value = nil;
			info.owner = self;
			info.func = OnClick;
			UIDropDownMenu_AddButton(info, level);

			local BarTextures = {};
			if( SM ) then
				BarTextures = SM:List("statusbar");
			end

			for k,v in pairs(BarTextures) do
				info = UIDropDownMenu_CreateInfo();
				info.text = v;
				info.value = v;
				info.owner = self;
				info.func = OnClick;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	);
	UIDropDownMenu_SetWidth(textureDD, 100);
	UIDropDownMenu_SetButtonWidth(textureDD, 124);
	UIDropDownMenu_JustifyText(textureDD, "LEFT");

	if( self.OnInitOptions ) then self:OnInitOptions(panel); end
	
	--
	-- Add panel to blizzards addon config
	--
	self.panel = panel;
	InterfaceOptions_AddCategory(self.panel);
end

function TRB_Module:CreateColorButtonOption(panel, name, x, y)
	local btn = CreateFrame("button", self.name..name.."button", panel, "UIPanelButtonTemplate");
	btn.owner = self;
	btn.trbcolorname = name;
	btn:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y);
	btn:SetWidth(80);
	btn:SetHeight(22);
	btn:SetText(name);
	btn:SetScript("OnClick", function(self) 
								ColorPickerFrame.previousValues = { self.owner:GetConfigColor(self.owner, self.trbcolorname) };
								ColorPickerFrame.func = function() self.owner:SetBarColor(self.owner, self.trbcolorname, ColorPickerFrame:GetColorRGB()) end;
								ColorPickerFrame.opacityFunc = function() self.owner:SetBarColor(self.owner, self.trbcolorname, ColorPickerFrame:GetColorRGB()); end;
								ColorPickerFrame.cancelFunc = function() self.owner:SetBarColor(self.owner, self.trbcolorname, unpack(ColorPickerFrame.previousValues)); end;
								ColorPickerFrame:SetColorRGB( self.owner:GetConfigColor(self.owner, self.trbcolorname) );
								ColorPickerFrame:SetFrameStrata("DIALOG");
								ColorPickerFrame:Show();
							 end);

	local tex = panel:CreateTexture(nil, "BACKGROUND");
	tex:SetWidth(20);
	tex:SetHeight(20);
	tex:SetPoint("LEFT", btn, "RIGHT", 10, 0);
	tex:SetTexture( self:GetConfigColor(self, name) );

	if( not panel.barcolor ) then
		panel.barcolor = {};
	end

	panel.barcolor[name] = tex;
end

function TRB_Module:_OnOkay()

	-- Scale
		local scale = self.ScaleSlider:GetValue();
		if( not TRB_Config.Scale or TRB_Config.Scale ~= scale ) then
			--DEFAULT_CHAT_FRAME:AddMessage( format("TRB: New scale value saved: %.1f",scale) );
			TRB_Config[self.name].Scale = scale;
		end
	
	-- Disable/Enable
	local status = self.CB_Disabled:GetChecked();
	if( status and not self.isRunning ) then
		--self:Print(self.name.." module activated.");
		TRB_Config.disabled_modules[self.name] = nil;
		
	elseif( not status and self.isRunning ) then
		--self:Print(self.name.." module deactivated.");
		if( not TRB_Config.disabled_modules ) then TRB_Config.disabled_modules = {}; end
		TRB_Config.disabled_modules[self.name] = true;
	end
	
	if( self.OnOkay ) then
		self:OnOkay();
	end

end

function TRB_Module:_OnCancel()
	-- Reset Scale
	self:SetScale(TRB_Config[self.name].Scale or 1.0);
	
	if( self.OnCancel ) then
		self:OnCancel();
	end
end

function TRB_Module:_OnDefault()

	--TRB_Config[self.name] = {};
	--TRB_Config[self.name] = TRB_Config_Defaults[self.name];
	--self:LoadConfig(true);
	self:ResetConfig();


	-- Load default value
	local v = true;
	if( TRB_Config_Defaults.disabled_modules and TRB_Config_Defaults.disabled_modules[self.name] and TRB_Config_Defaults.disabled_modules[self.name] == true ) then
		v = false;
	end
	self.CB_Disabled:SetChecked( v );
	
	if( self.OnDefault ) then
		self:OnDefault(); 
	end
	
	if( v == true ) then
		self:init();
	else
		self:Disable();
	end
end
