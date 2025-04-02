class_name SkillAdjustor_BloodyCrit
extends SkillAdjustor
## If this skill's wearer is bloodied (Y% HP), they gain +X Crit

@export var critBonus: int = 20
@export var recipBloody : int = 2


func modify(_bp :BattleParticipant) -> void:
	if _bp.u.getBloodied(recipBloody): ## 50% or lower
		_bp.adj_crit += critBonus
