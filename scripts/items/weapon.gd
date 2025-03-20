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
@export var reachMin : int
@export var reachMax : int

@export_group("Class Limitations")
@export var profReq: Codex.PROFICIENCY
@export var weaponType: Codex.WEAPON_TYPE

@export_group("Damage Modifiers")
@export var critMult : float = 3
@export var effectiveMult : Dictionary[Codex.UNITTYPE, float] = {}

func _to_string() -> String:
	if equipped:
		return "<|[%s: MT=%d, AVO=%d, CRIT=%d: Requires %s Rank]|>" % [name, might, avoid, crit, profReq]
	else:
		return "<| %s: MT=%d, AVO=%d, CRIT=%d: Requires %s Rank |>" % [name, might, avoid, crit, profReq]
