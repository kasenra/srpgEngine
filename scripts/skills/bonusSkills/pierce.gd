class_name SkillActionBonus_Attack_Pierce
extends SkillAttackBonus

@export var scalar : float = 0.5

func affect(_b : Battle, _bp : BattleParticipant) -> void: ## Add Half the Relevant Defense to damage.
	print("Activating Piercing")
	_bp.u._animator.play("skill_activation")
	if _bp.w.damageType == Codex.DAMAGE_TYPE.PHYSICAL:
		_bp.target.queueDamage(floori(scalar * _bp.target.u.getStat(Codex.STAT.DEF)))
	else:
		_bp.target.queueDamage(floori(scalar * _bp.target.u.getStat(Codex.STAT.RES)))
