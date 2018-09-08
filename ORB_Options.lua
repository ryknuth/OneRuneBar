if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end
-----------------------------------------------------------------------------------
-- Info on panels: http://www.wowwiki.com/Using_the_Interface_Options_Addons_panel
-----------------------------------------------------------------------------------
ORB_Options = {};

function ORB_Options:init()
	--
	-- Make sure we have our configuration available
	--
	if ( not ORB_Config ) then
		if( TRB_Config ) then
			ORB_Config = TRB_Config;
			TRB_Config = nil;
		else
			self:ResetConfig();
		end
	end

	--
	-- Create settings panel for OneRuneBar under the addon settings in the Blizzard UI
	--
	local panel = CreateFrame("frame", "OneRuneBar_Options", UIParent);
	panel.name = "One Rune Bar";
	panel.okay = function() ORB_Options:Okay(ORB_Options); end
	panel.default = function() ORB_Options:Default(ORB_Options); end

	--
	-- Main panel
	--
	local xoff, yoff = 20, -20;

	local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	header:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff);
	header:SetText(panel.name.." v"..GetAddOnMetadata("Onerunebar", "Version") );
	panel.header = header;

	local function createSlider(name, textFormat, yoffset, getter, setter)
		local slider = CreateFrame("slider", name, panel, "OptionsSliderTemplate");
		slider:SetPoint("TOPLEFT", panel, "TOPLEFT", xoff, yoff+yoffset);
		slider:SetWidth(200);
		slider:SetHeight(20);
		slider:SetOrientation("HORIZONTAL");
		slider:SetMinMaxValues(0, 1.0);
		slider:SetValue(1);
		slider:SetValueStep(0.05);
		_G[slider:GetName().."Low"]:SetText("0.0");
		_G[slider:GetName().."High"]:SetText("1.0");
		slider.Text = _G[slider:GetName().."Text"];

		slider:SetScript("OnValueChanged", function(self, value)
			self.Text:SetText(format(textFormat, value))
			setter(OneRuneBar, value);
		end);

		slider:SetValue(getter(OneRuneBar));
		return slider;
	end

	-- OOC Alpha
	self.OOCSlider = createSlider("ORB_OOCSlider", "Out of Combat (OOC) alpha: %.2f",
		-50, OneRuneBar.Config_GetOOCAlpha, OneRuneBar.Config_SetOOCAlpha);
	self.OOCNotAllReadySlider = createSlider("ORB_OOCNotAllReadySlider", "OOC alpha while still recharging %.2f",
		-100, OneRuneBar.Config_GetOOCNotAllReadyAlpha, OneRuneBar.Config_SetOOCNotAllReadyAlpha);

	--
	-- Add panel to blizzards addon config
	--
	self.panel = panel;
	InterfaceOptions_AddCategory(self.panel);

	--
	-- Add module panels to blizzards addon config
	--
	for name, m in pairs(OneRuneBar.modules) do
		if( m.InitOptions ) then
			m:InitOptions(self.panel);
		end
	end

end

function ORB_Options:ResetConfig()
	DEFAULT_CHAT_FRAME:AddMessage("ORB: Default config loaded.");
	
	ORB_Config = nil;
	ORB_Config = {};
	
	-- Copy default settings
	ORB_Config.OOC_Alpha = ORB_Config_Defaults.OOC_Alpha;
end

function ORB_Options:Okay()
	--
	-- Call module panels 
	--
	for name, m in pairs(OneRuneBar.modules) do
		if( m._OnOkay ) then
			m:_OnOkay();
		end
	end
	
	-- Restart modules
	OneRuneBar:StartModules();
end

function ORB_Options:Default()
	self:ResetConfig();
	
	self.OOCSlider:SetValue(ORB_Config_Defaults.OOC_Alpha);
	--
	-- Call module panels 
	--
	for name, m in pairs(OneRuneBar.modules) do
		if( m._OnDefault ) then
			m:_OnDefault();
		end
	end
end

-- add Options to ORB
OneRuneBar.Options = ORB_Options;

---
--- Slash handling
---
SLASH_ORB1, SLASH_ORB2 = "/orb", "/onerunebar";

local function ORB_SlashHandler(msg, editbox)

--	InterfaceOptionsFrame_OpenToCategory(ORB_Options.panel);
--	return;

	if(msg == "config") then
		InterfaceOptionsFrame_OpenToCategory(ORB_Options.panel.name);
		InterfaceOptionsFrame_OpenToCategory(ORB_Options.panel.name);
	elseif( not msg or msg=="" or msg=="lock" or msg=="unlock" ) then
		if( OneRuneBar.isLocked ) then
			OneRuneBar:Unlock();
		else
			OneRuneBar:Lock();
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Usage:");
		DEFAULT_CHAT_FRAME:AddMessage(" /orb - Lock/Unlock");
		DEFAULT_CHAT_FRAME:AddMessage(" /orb config - Open configuration.");
	end

end
SlashCmdList["ORB"] = ORB_SlashHandler;
