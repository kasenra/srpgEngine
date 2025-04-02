class_name SkillPostEffect
extends Skill
## Skills which add out of battle effects at the end of combat extend this class.
## This is largely reliant on the StatusEffect system.

func imbue(_b : Battle, _bp: BattleParticipant) -> void: ## Abstract function for post battle effects.
	pass
