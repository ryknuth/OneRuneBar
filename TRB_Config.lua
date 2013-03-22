if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
	-- Don't do anything it player isn't a Death Knight
	return
end

TRB_Config_Defaults = {

	["Runes"] = {
		["Colors"] = {
			[1] = { [1] = 1,   [2] = 0,   [3] = 0,   [4] = 1 },		-- RuneType: Blood
			[2] = { [1] = 0,   [2] = 0.7, [3] = 0,   [4] = 1 },		-- RuneType: Unholy
			[3] = { [1] = 0,   [2] = 0.3, [3] = 1,   [4] = 1 },		-- RuneType: Frost
			[4] = { [1] = 0.8, [2] = 0.7,   [3] = 0.9, [4] = 1 },	-- RuneType: Death
		},
		["Position"] = { "CENTER", nil, "CENTER", 0, -135, },
		["Order"] = { ["Blood"] = "Bar1", ["Unholy"] = "Bar2", ["Frost"] = "Bar3" },
--		["WRBGA"] = 0.2; -- Waiting Rune Background Alpha (REMOVED in 1.0.10?)
	},
	
	["Diseases"] = {
		["Colors"] = { 
			["ff"] = { 0, 0.5, 1,  1, },		-- Frost Fever
			["bp"] = { 0, 0.7, 0,  1, },		-- Blood Plague
		},
		["Position"] = { "CENTER", nil, "CENTER", 160, -13, },
	},
	
	["RunicPower"] = {
		["Colors"] = { [1] = 0.2, [2] = 0.7, [3] = 1,   [4] = 1 },
		["Position"] = { "CENTER", nil, "CENTER", 0, -150, },
	},
	
	["Horn of Winter"] = {
		["Colors"] = { [1] = 0, [2] = 0, [3] = 1,   [4] = 1 },
		["Position"] = { "CENTER", nil, "CENTER", 0, 0, },
	},
	
	-- Out of Combat settings
	["OOC_Alpha"] = 0.7,
};
