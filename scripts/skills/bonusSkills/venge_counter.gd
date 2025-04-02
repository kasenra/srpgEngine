class_name SkillAttackBonus_Venge_Counter
extends SkillAttackBonus

@export var counter_ratio: float = 0.5

func affect(_b : Battle, _bp : BattleParticipant) -> void: ## Abstract function for Attack Bonus skills. Called on a hit and successful roll.
	print("Activating Counter")
	_bp.u._animator.play("skill_activation")
	_bp.target.queueDamage(floori(counter_ratio * _bp.queued_damage))
	_bp.target.realizeDamage()
