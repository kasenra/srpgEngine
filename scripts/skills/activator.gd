extends Skill

@export var chanceMult: float
@export var scalingStat: Codex.STAT

# Trigger Types:
#		0 - Attack Supplement
#			These add more damage, healing, etc to an attack. Think heal-on-hit 
#				or defense bypass (add 1/2 DEF/RES to damage).
#				These roll only after a sucessful hit.
#		1 - Attack Replacement
#			These replace an attack in some way, and should be rolled before 
#				resolving. Think 5x attack/2.	
func trigger(b: Battle, s: Battle.STANCE) -> void:
	pass

func roll(u : Unit) -> bool:
	return (RNG.coreRNG.randf()*100) < (u.getStat(scalingStat)*chanceMult)
