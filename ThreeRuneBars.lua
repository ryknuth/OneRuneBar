if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
   return
end

------------------------------------------------------------------------

ThreeRuneBars = CreateFrame("frame", nil, UIParent);
ThreeRuneBars:RegisterEvent("ADDON_LOADED"); -- Wait for variables to load before we do anything
ThreeRuneBars:SetScript("OnEvent", function(frame, event, ...) frame[event](frame, ...); end ); -- Event handling

-- For bar textures
SM = nil;
if( LibStub and LibStub.GetLibrary ) then
	SM = LibStub:GetLibrary("LibSharedMedia-3.0");
end

function ThreeRuneBars:UpdateCombatFading(value)

	-- Choose value if value exists else use OOC_Alpha from Config or OOC_Alpha from Default config.
	local v = value or (TRB_Config.OOC_Alpha or TRB_Config_Defaults.OOC_Alpha); 
	
	-- In combat it should be fully visible
	if( self.inCombat ) then v = 1.0; end
	
	-- Update alpha value for modules
	for name, m in pairs(self.modules) do
		if( m.frame ) then
			m.frame:SetAlpha( v );
		end
	end
end

function ThreeRuneBars:PLAYER_REGEN_ENABLED()
	-- out of combat
	self.inCombat = nil;

	self:UpdateCombatFading(TRB_Config.OOC_Alpha);
	
	-- Reduce frame strata no need to be above blizzards 'Power Aura' when we are out of combat
	-- Prevent our runebars to get above bags or other frames.
	for _, m in pairs(self.modules) do
		m:ChangeStrata("LOW");
	end
end

function ThreeRuneBars:PLAYER_REGEN_DISABLED()
	-- in combat
	self.inCombat = true;
	
	self:UpdateCombatFading(1.0);
	
	-- Increase frame strata so it will get above blizzards 'Power Aura'
	for _, m in pairs(self.modules) do
		m:ChangeStrata("HIGH");
	end
end

function ThreeRuneBars:PET_BATTLE_OPENING_START()
	for name, m in pairs(self.modules) do
		m:ChangeVisibility( false );
	end
end

function ThreeRuneBars:PET_BATTLE_OVER()
	for name, m in pairs(self.modules) do
		m:ChangeVisibility( true );
	end
end

function ThreeRuneBars:Unlock()
	DEFAULT_CHAT_FRAME:AddMessage("ThreeRuneBars Unlocked");
	self.isLocked = false;
	
	for name, m in pairs(self.modules) do
		if( m.moveFrame ) then
			m.moveFrame:Show();
		end
	end
end

function ThreeRuneBars:Lock()
	DEFAULT_CHAT_FRAME:AddMessage("ThreeRuneBars Locked");
	self.isLocked = true;
	for name, m in pairs(self.modules) do
		if( m.moveFrame ) then
			m.moveFrame:Hide();
		end
	end
end

function ThreeRuneBars:RegisterModule(m)

	local name = m.name;

	if( not self.modules ) then self.modules = {}; end
	
	if( not self.modules[name]) then 
		self.modules[name] = m;
	else
		DEFAULT_CHAT_FRAME:AddMessage("TRB: Module "..name.." already registered");
	end
end

function ThreeRuneBars:StartModules()
	for name, m in pairs(self.modules) do
		if( not (TRB_Config.disabled_modules and TRB_Config.disabled_modules[name] and TRB_Config.disabled_modules[name] == true) ) then
			m:init();
			m:LoadPosition();
		else
			m:Disable(); -- Disable module if it's running.
		end
	end
end

function ThreeRuneBars:ADDON_LOADED(addon)
	if( string.lower(addon) == string.lower("ThreeRuneBars") and (select(2, UnitClass("player")) == "DEATHKNIGHT")) then
		--
		--	And finally the addon and it's variables has been loaded and we can start doing stuff
		--	
		DEFAULT_CHAT_FRAME:AddMessage("ThreeRuneBars loaded");
		
		--	Start locked, otherwise we are in an unknown state where the first /trb will
		--	lock the bars, even though they were already locked.
		self:Lock();
		
		if( self.Options ) then
			self.Options:init();	-- Initialize TRB's Option frame and LoadConfig
		end
		
		-- Start sub modules like Runes, RunicPower and Diseases
		self:StartModules();
		
		-- Register OOC Fader events
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:RegisterEvent("PET_BATTLE_OPENING_START");
		self:RegisterEvent("PET_BATTLE_OVER");

		-- Update OOC and FrameStrata state
		self:PLAYER_REGEN_ENABLED();
	end
end
