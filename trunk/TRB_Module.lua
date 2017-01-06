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

	if( not self.cfg ) then
		self.cfg = TRB_Config[self.name];
	end

	-- Now we are ready to enable this module
	if( self.OnEnable ) then self:OnEnable(); end
	
	self.isRunning = true;
	self:Print((self.name or "Unknown").." module enabled.");
end

function TRB_Module:CreateTexture(f, w, h)
	local tex = self.frame:CreateTexture(nil, "BACKGROUND");
	--tex:SetWidth(w);
	--tex:SetHeight(h);
	tex:SetPoint("CENTER", f, "CENTER", 0, 0);
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
	Bar.bg:SetColorTexture(0.25, 0.25, 0.25, 0.5);
	
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
	f.bg:SetColorTexture(0.8,0.8,0.8, 0.4);
	f:SetFrameStrata("HIGH");
	f:Hide();
	
	self.moveFrame = f;
end

function TRB_Module:CreateBorderTexture(f, from, to, borderSize)
	local t = self:CreateTexture(f, borderSize, borderSize);
	t:SetPoint(from, f, to, 0, 0);
	t:SetPoint(to, f, from, 0, 0);
	t:SetColorTexture( 0.0, 0.0, 0.0 );
	return t;
end

function TRB_Module:CreateBorder(f, borderSize)
	f.t = self:CreateBorderTexture( f, "TOPLEFT", "TOPRIGHT", borderSize );
	f.b = self:CreateBorderTexture( f, "BOTTOMLEFT", "BOTTOMRIGHT", borderSize );
	f.l = self:CreateBorderTexture( f, "TOPLEFT", "BOTTOMLEFT", borderSize );
	f.r = self:CreateBorderTexture( f, "TOPRIGHT", "BOTTOMRIGHT", borderSize );
end

function TRB_Module:UpdateBorderSizes( f )
	local borderSize = self:Config_GetBorderSize();

	f.t:SetHeight( borderSize );
	f.b:SetHeight( borderSize );
	f.l:SetWidth( borderSize );
	f.r:SetWidth( borderSize );
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
	cb:SetPoint("TOPLEFT", header, "TOPLEFT", 0, yoff);
	cb.text = _G[cb:GetName().."Text"];
	cb.text:SetText("Enable "..self.name.." module");
	local v = true;
	if( TRB_Config.disabled_modules and TRB_Config.disabled_modules[self.name] and TRB_Config.disabled_modules[self.name] == true ) then
		v = false;
	end
	cb:SetChecked( v );
	self.CB_Disabled = cb;

	-- Texture options
	local textureText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	textureText:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 0, yoff);
	textureText:SetText("Texture");

	local textureDD = CreateFrame("frame", "TRB_ModuleTextureDD_"..self.name, panel, "UIDropDownMenuTemplate");
	textureDD:ClearAllPoints();
	textureDD:SetPoint("TOPLEFT", textureText, "BOTTOMLEFT", -20, 0);
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

	local borderSizeLabel = self:CreateLabel( panel, "Border Size:");
	borderSizeLabel:SetPoint("TOPLEFT", textureDD, "BOTTOMLEFT", 20, yoff);
	
	local borderSizeBox = self:CreateEditBox( panel, "TRB_ModuleBorderSizeEditBox_"..self.name,
		function(self) return self:Config_GetBorderSize(); end,
		function(self, value) self:Config_SetBorderSize(value); end );
	borderSizeBox:SetPoint("TOPLEFT", borderSizeLabel, "TOPRIGHT", 4, 0);
	borderSizeBox:SetPoint("BOTTOMLEFT", borderSizeLabel, "BOTTOMRIGHT", 0, 0);

	local barWidthLabel = self:CreateLabel( panel, "Bar Width:");
	barWidthLabel:SetPoint("TOPLEFT", borderSizeLabel, "BOTTOMLEFT", 0, yoff);
	
	local barWidthBox = self:CreateEditBox( panel, "TRB_ModuleBarWidthEditBox_"..self.name,
		function(self) return self:Config_GetBarSize()[1]; end,
		function(self, value) self:Config_SetBarSize(value, self:Config_GetBarSize()[2]); end );
	barWidthBox:SetPoint("TOPLEFT", barWidthLabel, "TOPRIGHT", 4, 0);
	barWidthBox:SetPoint("BOTTOMLEFT", barWidthLabel, "BOTTOMRIGHT", 0, 0);

	local barHeightLabel = self:CreateLabel( panel, "Height:");
	barHeightLabel:SetPoint("TOPLEFT", barWidthBox, "TOPRIGHT", 4, 0);
	
	local barHeightBox = self:CreateEditBox( panel, "TRB_ModuleBarHeightEditBox_"..self.name,
		function(self) return self:Config_GetBarSize()[2]; end,
		function(self, value) self:Config_SetBarSize(self:Config_GetBarSize()[1], value); end );
	barHeightBox:SetPoint("TOPLEFT", barHeightLabel, "TOPRIGHT", 4, 0);
	barHeightBox:SetPoint("BOTTOMLEFT", barHeightLabel, "BOTTOMRIGHT", 0, 0);

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
	tex:SetColorTexture( self:GetConfigColor(self, name) );

	if( not panel.barcolor ) then
		panel.barcolor = {};
	end

	panel.barcolor[name] = tex;
end

function TRB_Module:CreateLabel( panel, labelText )
	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetText(labelText);
	return label
end

function TRB_Module:CreateEditBox( panel, name, getConfigFunc, setConfigFunc )
	local box = CreateFrame( "editbox", name, panel, "InputBoxTemplate");
	box.owner = self;
	box:SetHeight(30);
	box:SetWidth(30);
	box:SetAutoFocus(false);
	box:SetMaxLetters(3);
	box:SetNumeric(true);

	box:SetScript("OnShow", function(self) self:SetText(getConfigFunc(self.owner)); self:SetCursorPosition(0); end);
	box:SetScript("OnEscapePressed", function(self) self:SetText(getConfigFunc(self.owner)); self:ClearFocus(); end);
	box:SetScript("OnEnterPressed", function(self) local val = self:GetNumber(); setConfigFunc(self.owner, val); self:ClearFocus(); end);

	return box;
end

function TRB_Module:_OnOkay()
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
	if( self.OnCancel ) then
		self:OnCancel();
	end
end

function TRB_Module:_OnDefault()
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

function TRB_Module:Config_GetBorderSize()
	return TRB_Config[self.name].BorderSize or TRB_Config_Defaults[self.name].BorderSize;
end

function TRB_Module:Config_SetBorderSize(val)
	TRB_Config[self.name].BorderSize = val;

	if( self.PositionFrame ) then
		self:PositionFrame();
	end
end

function TRB_Module:Config_GetBarSize()
	return TRB_Config[self.name].BarSize or TRB_Config_Defaults[self.name].BarSize;
end

function TRB_Module:Config_SetBarSize(width, height)
	TRB_Config[self.name].BarSize = { width, height };

	if( self.PositionFrame ) then
		self:PositionFrame();
	end
end
