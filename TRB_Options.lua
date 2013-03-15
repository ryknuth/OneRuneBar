if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end
-----------------------------------------------------------------------------------
-- Info on panels: http://www.wowwiki.com/Using_the_Interface_Options_Addons_panel
-----------------------------------------------------------------------------------
TRB_Options = {};

function TRB_Options:init()

--	self:LoadConfig();

	--
	-- Make sure we have our configuration available
	--
	if ( not TRB_Config ) then 
		self:ResetConfig();
	end

	--
	-- Create settings panel for ThreeRuneBars under the addon settings in the Blizzard UI
	--
	local panel = CreateFrame("frame", "ThreeRuneBars_Options", UIParent);
	panel.name = "Three Rune Bars";
	panel.okay = function() TRB_Options:Okay(TRB_Options); end
	panel.cancel = function() TRB_Options:Cancel(TRB_Options); end
	panel.default = function() TRB_Options:Default(TRB_Options); end

	--
	-- Main panel
	--
	local xoff, yoff = 20, -20;
	
	local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	header:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff);
	header:SetText(panel.name.." v"..GetAddOnMetadata("ThreeRunebars", "Version") );
	panel.header = header;
	
	-- OOC Alpha
	local OOCSlider = CreateFrame("slider", "TRB_ScaleSlider", panel, "OptionsSliderTemplate");
	OOCSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff-50);
	OOCSlider:SetWidth(200);
	OOCSlider:SetHeight(20);
	OOCSlider:SetOrientation("HORIZONTAL");
	OOCSlider:SetMinMaxValues(0, 1.0);
	OOCSlider:SetValue(1);
	OOCSlider:SetValueStep(0.05);
	_G[OOCSlider:GetName().."Low"]:SetText("0.0");
	_G[OOCSlider:GetName().."High"]:SetText("1.0");
	OOCSlider.Text = _G[OOCSlider:GetName().."Text"];
	OOCSlider:SetScript("OnValueChanged", function(self, value) TRB_Options:SetOOCAlphaValue(self, value); end);
	OOCSlider:SetScript("OnShow", function(self) self:SetValue(TRB_Config.OOC_Alpha or TRB_Config_Defaults.OOC_Alpha); end);
	OOCSlider.Text:SetText( format("Out of Combat Alpha: %.2f", OOCSlider:GetValue()) );
	OOCSlider:Show();
	self.OOCSlider = OOCSlider;
	
	--
	-- Add panel to blizzards addon config
	--
	self.panel = panel;
	InterfaceOptions_AddCategory(self.panel);

	--
	-- Add module panels to blizzards addon config
	--
	for name, m in pairs(ThreeRuneBars.modules) do
		if( m.InitOptions ) then
			m:InitOptions(self.panel);
		end
	end

end

function TRB_Options:ResetConfig()
	DEFAULT_CHAT_FRAME:AddMessage("TRB: Default config loaded.");
	
	TRB_Config = nil;
	TRB_Config = {};
	
	-- Copy default settings
	TRB_Config.OOC_Alpha = TRB_Config_Defaults.OOC_Alpha;
end

function TRB_Options:Okay()

--	DEFAULT_CHAT_FRAME:AddMessage("TRB: Okay");
	
	-- Save new OOC Alpha
		TRB_Config.OOC_Alpha = self.OOCSlider:GetValue();
	
	--
	-- Call module panels 
	--
	for name, m in pairs(ThreeRuneBars.modules) do
		if( m._OnOkay ) then
			m:_OnOkay();
		end
	end
	
	-- Restart modules
	ThreeRuneBars:StartModules();
	
	-- Update Alpha
	ThreeRuneBars:UpdateCombatFading();
end

function TRB_Options:Cancel()
	-- Reset values to what they was before configuration started.
--	DEFAULT_CHAT_FRAME:AddMessage("TRB: Discards changes");
	
	-- Reset OOC Alpha
		ThreeRuneBars:UpdateCombatFading();
		
	--
	-- Call module panels 
	--
	for name, m in pairs(ThreeRuneBars.modules) do
		if( m._OnCancel ) then
			m:_OnCancel();
		end
	end
end

function TRB_Options:Default()
	self:ResetConfig();
	
	self.OOCSlider:SetValue(TRB_Config.OOC_Alpha);
	--
	-- Call module panels 
	--
	for name, m in pairs(ThreeRuneBars.modules) do
		if( m._OnDefault ) then
			m:_OnDefault();
		end
	end

	--ThreeRuneBars:StartModules();
end

function TRB_Options:SetScaleValue(slider, value)
	slider.Text:SetText(format("Set Scale: %.1f", value) );

	-- Update scale to get a preview of how big the frames is.
	ThreeRuneBars:ChangeScale(value);	
end

function TRB_Options:SetOOCAlphaValue(slider, value)
	slider.Text:SetText(format("Out of Combat Alpha: %.2f", value) );

	-- Preview update
	ThreeRuneBars:UpdateCombatFading(value);
end







-- add Options to TRB
ThreeRuneBars.Options = TRB_Options;

---
--- Slash handling
---
SLASH_TRB1, SLASH_TRB2 = "/trb", "/ThreeRuneBars";

local function TRB_SlashHandler(msg, editbox)

--	InterfaceOptionsFrame_OpenToCategory(TRB_Options.panel);
--	return;

	if(msg == "config") then
		InterfaceOptionsFrame_OpenToCategory(TRB_Options.panel);
	elseif( not msg or msg=="" or msg=="lock" or msg=="unlock" ) then
		if( ThreeRuneBars.isLocked ) then
			ThreeRuneBars:Unlock();
		else
			ThreeRuneBars:Lock();
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Usage:");
		DEFAULT_CHAT_FRAME:AddMessage(" /trb - Lock/Unlock");
		DEFAULT_CHAT_FRAME:AddMessage(" /trb config - Open configuration.");
	end

end
SlashCmdList["TRB"] = TRB_SlashHandler;
