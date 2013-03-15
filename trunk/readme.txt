
	 Three Rune Bars
	-----------------

This addon is made for tracking Death Knights Runes and Runic Power and the two primary diseases Frost Fever and Blood Plague (this submodule can be disabled if you have other disease debuff addon).

The difference between this addon and other Rune tracking addons (I have found) is that this addon treat each 2 runes of the same type as one Energy like bar that will always fill from left to right regardless of which rune is active. When it's at the middle one rune is ready (there is a mark for separating the runes in each bar)

From v1.0.2 This addon now have a verry simple configuration panel in the Blizzard's Addon Options interface. The options of disabling the Disease tracking module and changing the Scale of the frames.

v1.0.3 Added a new module base to make it easier to create configuration panels for my modules. The addon now have three modules Runes, Runic Power and Diseases and they can all be scaled and Enabled/disabled separately.

v1.0.4 Added OOC Fading and Rune order configuration.

* /trb (or /threerunebars) - This will unlock/lock the frames so you can move them and place them where you want them.
* /trb config - This will disable/enable the diseases tracing frame. //New in v1.0.2//
* /trb diseases - This will disable/enable the diseases tracing frame. //Removed in v1.0.2//

For users with some lua knowledge you can change the colors of the bars in your SaveVariables\ThreeRuneBars.lua file. Or delete that file and change the default settings in TRB_Config.lua.


McZ - mcz@linuxmail.org
