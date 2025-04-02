class_name SkillAttackReplacement
extends SkillActivator
## Skills which replace a unit's attack extend this abstract class.
## This differs from SkillAttackBonus in that this skill's logic overrides the attack process.

func attack(_b : Battle, _bp : BattleParticipant) -> void: ## Abstract function for attack replacement skills. Called on a successful roll, replacing the attack.
	pass
