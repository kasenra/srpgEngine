class_name SkillActivator ## Extended by skills which activate based on a % Chance.
extends Skill

@export var baseChance : int
@export var chanceMult: float
@export var scalingStat: Codex.STAT
@export var maximumChance : int = 100

func roll(u : Unit) -> bool:
	if scalingStat == Codex.STAT.NONE and baseChance < 100:
		return (RNG.coreRNG.randf()*100) < (baseChance)
	if (baseChance >= 100 or baseChance + (u.getStat(scalingStat) * chanceMult) >= 100) and maximumChance >= 100:
		return true
	return (RNG.coreRNG.randf()*100) < min(baseChance + u.getStat(scalingStat)*chanceMult, maximumChance)
