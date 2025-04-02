class_name UnitClass ## Contains information about a class a unit can take. Damn you, overlap between OOP and RPG terminology.
extends Resource

# Class Name
@export_group("Identity")
@export var name : String ## Translation String for class name.

# Base Stat Boosts
@export_group("Bases")
@export var base_mhp : int ## Boost to base MHP. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_str : int ## Boost to base STR. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_mag : int ## Boost to base MAG. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_skl : int ## Boost to base SKL. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_spd : int ## Boost to base SPD. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_lck : int ## Boost to base LCK. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_def : int ## Boost to base DEF. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_res : int ## Boost to base RES. Supplements character bases and provides promotion bonuses. (So promoted should always include their pre-class's bases)
@export var base_mov : int ## Sole source of MOV. Defines a class's movement.

# Stat Growth Boosts
@export_group("Boosts")
@export_range(0,40) var growth_mhp : int ## Boost to MHP growth. Supplements character growths.
@export_range(0,40) var growth_str : int ## Boost to STR growth. Supplements character growths.
@export_range(0,40) var growth_mag : int ## Boost to MAG growth. Supplements character growths.
@export_range(0,40) var growth_skl : int ## Boost to SKL growth. Supplements character growths.
@export_range(0,40) var growth_spd : int ## Boost to SPD growth. Supplements character growths.
@export_range(0,40) var growth_lck : int ## Boost to LCK growth. Supplements character growths.
@export_range(0,40) var growth_def : int ## Boost to DEF growth. Supplements character growths.
@export_range(0,40) var growth_res : int ## Boost to RES growth. Supplements character growths.

# Stat Caps
@export_group("Caps")
@export var max_mhp : int ## Max MHP. Primary source of stat caps.
@export var max_str : int ## Max STR. Primary source of stat caps.
@export var max_mag : int ## Max MAG. Primary source of stat caps.
@export var max_skl : int ## Max SKL. Primary source of stat caps.
@export var max_spd : int ## Max SPD. Primary source of stat caps.
@export var max_lck : int ## Max LCK. Primary source of stat caps.
@export var max_def : int ## Max DEF. Primary source of stat caps.
@export var max_res : int ## Max RES. Primary source of stat caps.

@export_group("Pseudo Bonuses")
@export var bonus_dmg : int
@export var bonus_hit : int
@export var bonus_avo : int
@export var bonus_crit: int
@export var bonus_ddg : int

@export_group("Other")
@export var mType : Codex.MOVETYPE
@export var proficiencies : Dictionary [Codex.WEAPON_TYPE, Codex.PROFICIENCY] ## Static per class weapon proficiencies. Higher classes have higher profs, more core profs are higher.
@export var tier : Codex.CLASS_TIER ## Used for promotion seal logic.
@export var previous : UnitClass ## Stores the previous class in line. Convergent classes need two versions of their resource to resolve this.
@export var promotes : Array[UnitClass]
@export var skills : Dictionary[int, Skill] ## Class skills at level boundaries. Any more than 2 ignored.
@export var innateSkills : Array[Skill] ## Always active class innates. Hidden skills.

func _to_string() -> String:
	return name

func classSkills(us : UnitStats) -> void: ## Modifies a UnitStats to have the relevant skills for its class.
	var s : Skill
	if previous and previous.previous: ## Reclassing at tier 3 is kinda crazy actually. 
		for l in previous.previous.skills.keys():
			s = previous.previous.skills[l]
			if s not in us.skills: 
				us.addSkill(s)
				return
	if previous:
		for l in previous.skills.keys():
			s = previous.skills[l]
			if s not in us.skills: 
				us.addSkill(s)
				return
	for l in skills.keys():
		if l > us.level:
			return
		s = skills[l]
		if s not in us.skills:
			us.addSkill(s)
			return
		
