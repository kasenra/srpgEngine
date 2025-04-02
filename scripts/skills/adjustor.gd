class_name SkillAdjustor 
extends Skill
## Abstract class extended by skills which modify unit combat stats
## The activator's BattleParticipant() is passed to the modify(bp) function at the start of each combat.
## This also applies to enemy-side adjustors, which run on the enemy.

@export var enemy_side : bool = false

func modify(_bp : BattleParticipant) -> void: ## Abstract modifier method.
	pass
