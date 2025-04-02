class_name Weapon
extends Item
@export_group("In Use")
@export var equipped: bool

@export_group("Stats")

@export var might: int
@export var prot: int
@export var avoid: int
@export var hit: int
@export var crit: int
@export var dodge: int

@export var damageType : Codex.DAMAGE_TYPE

@export_group("Limits")
@export var reachMin : int
@export var reachMax : int

@export var asdPenalty: int ## Penalty to Speed for determining attack speed.
## When Effects become a thing, a weapon should have an Effect slot for it's post combat debuff.
@export var canDouble : bool = true

@export_group("Proficiency")
@export var profReq: Codex.PROFICIENCY
@export var weaponType: Codex.WEAPON_TYPE

@export_group("Damage Modifiers")
@export var critMult : float = 3
@export var effectiveMult : Dictionary[Codex.UNITTYPE, float] = {}

@export_group("Traits")
@export var trait_skills : Array[Skill]
@export var trait_aggressiveDouble : bool = false ## Adds a bonus attack which doesn't trigger
@export var trait_duelist : bool = false ## Reverses and Improves Weapon Triangle

func _to_string() -> String:
	if equipped:
		return "<|[%s: MT=%d, AVO=%d, CRIT=%d: Requires %s Rank]|>" % [name, might, avoid, crit, profReq]
	else:
		return "<| %s: MT=%d, AVO=%d, CRIT=%d: Requires %s Rank |>" % [name, might, avoid, crit, profReq]
