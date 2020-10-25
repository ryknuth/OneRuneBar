if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------

OneRuneBar = CreateFrame("frame", nil, UIParent);
OneRuneBar:RegisterEvent("ADDON_LOADED"); -- Wait for variables to load before initializing
OneRuneBar:RegisterEvent("PLAYER_LOGIN"); -- Wait for variables to load before enabling
OneRuneBar:SetScript("OnEvent", function(frame, event, ...) frame[event](frame, ...); end ); -- Event handling

-- For bar textures
SM = nil;
if( LibStub and LibStub.GetLibrary ) then
	SM = LibStub:GetLibrary("LibSharedMedia-3.0", true);
end

function OneRuneBar:UpdateCombatFading()
	local value = self:Config_GetOOCAlpha();

	-- In combat it should be fully visible
	if( self.inCombat ) then value = 1.0;
	-- OOC, but not all runes ready
	elseif ( not ORB_Runes:AreAllReady() ) then value = self:Config_GetOOCNotAllReadyAlpha(); end

	-- Update alpha value for modules
	for name, m in pairs(self.modules) do
		if( m.frame ) then
			m.frame:SetAlpha( value );
		end
	end
end

function OneRuneBar:PLAYER_REGEN_ENABLED()
	-- out of combat
	self.inCombat = nil;

	self:UpdateCombatFading();
	
	-- Reduce frame strata no need to be above blizzards 'Power Aura' when we are out of combat
	-- Prevent our runebars to get above bags or other frames.
	for _, m in pairs(self.modules) do
		m:ChangeStrata("LOW");
	end
end

function OneRuneBar:PLAYER_REGEN_DISABLED()
	-- in combat
	self.inCombat = true;
	
	self:UpdateCombatFading();
	
	-- Increase frame strata so it will get above blizzards 'Power Aura'
	for _, m in pairs(self.modules) do
		m:ChangeStrata("HIGH");
	end
end

function OneRuneBar:PET_BATTLE_OPENING_START()
	for name, m in pairs(self.modules) do
		m:ChangeVisibility( false );
	end
end

function OneRuneBar:PET_BATTLE_OVER()
	for name, m in pairs(self.modules) do
		m:ChangeVisibility( true );
	end
end

function OneRuneBar:Unlock()
	DEFAULT_CHAT_FRAME:AddMessage("OneRuneBar Unlocked");
	self.isLocked = false;
	
	for name, m in pairs(self.modules) do
		if( m.moveFrame ) then
			m.moveFrame:Show();
		end
	end
end

function OneRuneBar:Lock()
	DEFAULT_CHAT_FRAME:AddMessage("OneRuneBar Locked");
	self.isLocked = true;
	for name, m in pairs(self.modules) do
		if( m.moveFrame ) then
			m.moveFrame:Hide();
		end
	end
end

function OneRuneBar:RegisterModule(m)

	local name = m.name;

	if( not self.modules ) then self.modules = {}; end
	
	if( not self.modules[name]) then 
		self.modules[name] = m;
	else
		DEFAULT_CHAT_FRAME:AddMessage("ORB: Module "..name.." already registered");
	end
end

function OneRuneBar:StartModules()
	for name, m in pairs(self.modules) do
		m:setConfig();
		if( not (ORB_Config.disabled_modules and ORB_Config.disabled_modules[name] and ORB_Config.disabled_modules[name] == true) ) then
			m:init();
			m:LoadPosition();
		else
			m:Disable(); -- Disable module if it's running.
		end
	end
end

function OneRuneBar:ADDON_LOADED(addon)
	if( string.lower(addon) == string.lower("OneRuneBar") and (select(2, UnitClass("player")) == "DEATHKNIGHT")) then
		--
		--	And finally the addon and it's variables has been loaded and we can start doing stuff
		--	
		DEFAULT_CHAT_FRAME:AddMessage("OneRuneBar loaded");
		
		--	Start locked, otherwise we are in an unknown state where the first /ORB will
		--	lock the bars, even though they were already locked.
		self:Lock();
		
		if( self.Options ) then
			self.Options:init();	-- Initialize ORB's Option frame and LoadConfig
		end

		if( not ORB_Config.SeenTRBTransition ) then
			StaticPopupDialogs["TRB_TRANSITION_POPUP"] = {
				text = "Thank you for using One Rune Bar! If you previously used ThreeRuneBars, please take a moment to copy over your saved variables. First, copy these instructions and logout. Second, Navigate to your World of Warcraft installation folder, then navigate to WTF/Account/<your account name>/SavedVariables. Third, delete any existing OneRuneBar.lua file and rename ThreeRuneBars.lua to OneRuneBar.lua. Everything should be as it was!",
				button1 = "OK",
				button2 = "Show Again",
				OnAccept = function()
					ORB_Config.SeenTRBTransition = true;
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			};

			StaticPopup_Show("TRB_TRANSITION_POPUP");
		end;

		-- Start sub modules like Runes, RunicPower and Diseases
		self:StartModules();
		
		-- Register OOC Fader events
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:RegisterEvent("PET_BATTLE_OPENING_START");
		self:RegisterEvent("PET_BATTLE_OVER");
		self:UnregisterEvent("ADDON_LOADED");

		-- Update OOC and FrameStrata state
		self:PLAYER_REGEN_ENABLED();
	end
end

function OneRuneBar:PLAYER_LOGIN()
	for name, m in pairs(self.modules) do
		if( not (ORB_Config.disabled_modules and ORB_Config.disabled_modules[name] and ORB_Config.disabled_modules[name] == true) ) then
			if(m.cfg.Texture) then
				m:SetBarTexture(m.cfg.Texture);
			end
		end
	end
end

function OneRuneBar:Config_GetOOCAlpha()
	return ORB_Config.OOC_Alpha or ORB_Config_Defaults.OOC_Alpha;
end

function OneRuneBar:Config_GetOOCNotAllReadyAlpha()
	return ORB_Config.OOC_NotAllReadyAlpha or ORB_Config_Defaults.OOC_NotAllReadyAlpha;
end

function OneRuneBar:Config_SetOOCAlpha(val)
	ORB_Config.OOC_Alpha = val;

	self:UpdateCombatFading();
end

function OneRuneBar:Config_SetOOCNotAllReadyAlpha(val)
	ORB_Config.OOC_NotAllReadyAlpha = val;

	self:UpdateCombatFading();
end
