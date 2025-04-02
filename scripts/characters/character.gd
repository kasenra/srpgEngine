class_name Character ## This resource stores static information about a character to cut savefile sizes.
extends Resource

# Name
@export_category("Name")
@export var name: String ## Internal Character Name. Template Name is Overriden by Faction.
@export var displayName : String ## Name as displayed. Usually identical, but any unit changing names should change this one.
# Base Stats
@export_category("Personal Bases")
@export var base_mhp : int ## Personal Base Max Hit Points. Main Source of base MHP.
@export var base_str : int ## Personal Base Strength. Main Source of base STR.
@export var base_mag : int ## Personal Base Magic. Main Source of base MAG.
@export var base_spd : int ## Personal Base Speed. Main Source of base SPD.
@export var base_skl : int ## Personal Base Skill. Main Source of base SKL.
@export var base_lck : int ## Personal Base Skill. Main Source of base LCK.
@export var base_def : int ## Personal Base Defense. Main Source of base DEF.
@export var base_res : int ## Personal Base Resistance. Main Source of base RES.
# Base Move is strictly determined by class

# Innate Growths
@export_category("Personal Growths")
@export_range(0,100) var growth_mhp : int ## Personal Growth Modifier for Max Hit Points. Main source of growth.
@export_range(0,100) var growth_str : int ## Personal Growth Modifier for Strength. Main source of growth.
@export_range(0,100) var growth_mag : int ## Personal Growth Modifier for Magic. Main source of growth.
@export_range(0,100) var growth_skl : int ## Personal Growth Modifier for Speed. Main source of growth.
@export_range(0,100) var growth_spd : int ## Personal Growth Modifier for Skill. Main source of growth.
@export_range(0,100) var growth_lck : int ## Personal Growth Modifier for Luck. Main source of growth.
@export_range(0,100) var growth_def : int ## Personal Growth Modifier for Defense. Main source of growth.
@export_range(0,100) var growth_res : int ## Personal Growth Modifier for Resistance. Main source of growth.

# Innate Caps
@export_category("Personal Cap Modifiers")
@export var max_mhp : int ## Personal Limit Modifier for Max Hit Points. Modifies Class-Limit.
@export var max_str : int ## Personal Limit Modifier for Strength. Modifies Class-Limit.
@export var max_mag : int ## Personal Limit Modifier for Magic. Modifies Class-Limit.
@export var max_skl : int ## Personal Limit Modifier for Speed. Modifies Class-Limit.
@export var max_spd : int ## Personal Limit Modifier for Skill. Modifies Class-Limit.
@export var max_lck : int ## Personal Limit Modifier for Skill. Modifies Class-Limit.
@export var max_def : int ## Personal Limit Modifier for Defense. Modifies Class-Limit.
@export var max_res : int ## Personal Limit Modifier for Resistance. Modifies Class-Limit.

# Joining Class
@export_category("Joining Class")
@export var joinClass : UnitClass ## Initial class before any class changes.

@export_category("Supports")
# Support stats should always be recursive. Scientists have yet to find an alternative.
# 	Each pairing only needs one timeline, and we can gate it using Dialogic Variables
#		After each conversation, we can just run a helper to check Dialogic Support Vars
#		for the entire army.

# Available Supports
@export var availableSupports : Dictionary[Character, Codex.SUPPORT] ## Lists all support partners
# Support Growth Rates
@export var supportRates : Dictionary[Character, float] ## Support Growth is Multiplied by the corresponding value. 
# Support Bonuses [DMG, PROT, HIT, AVO, CRIT, DDG]
@export var supportBonuses : Dictionary[Codex.SUPPORT, Array] ## Stat bonuses per support rank with this character.


# Personal Skill, Added upon Instantiation
@export_category("Personal Bonuses")
@export var personal : Skill ## Automatically obtained upon joining.
