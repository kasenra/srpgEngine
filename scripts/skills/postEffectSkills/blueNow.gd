class_name SkillPostEffect_BlueNow
extends SkillPostEffect

func imbue(_b : Battle, _bp: BattleParticipant) -> void: ## You're blue now. That's my attack.
	if not _bp.target.u.stat.dead:
		print("You're blue now.")
		print("That's my attack.")
		_bp.target.u.modulate = Color(0.271, 0.475, 0.753)
