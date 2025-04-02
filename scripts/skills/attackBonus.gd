class_name SkillAttackBonus
extends SkillActivator
## Skills which add a bonus effect on hit extend this class
## This differs from SkillAttackReplacement in that the battle logic for making an attack is not skipped.
## This includes skills which activate when the BEARER is hit, affecting either the unit (DEFEND) or the attacker (VENGE).

enum FACE {ATTACK, DEFEND, VENGE}

@export var facing : FACE

func affect(_b : Battle, _bp : BattleParticipant) -> void: ## Abstract function for Attack Bonus skills. Called on a hit and successful roll.
	pass
