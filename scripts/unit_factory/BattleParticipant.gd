class_name BattleParticipant ## Stores information about a unit in the context of a battle.
extends RefCounted


var u : Unit 
var w : Weapon

## Core Flags
var combat_position : Battle.POSITION = Battle.POSITION.NONE
var target : BattleParticipant ## Fuck it, just drop a pointer to the target. Kill, hound.
var queued_damage : int ## Adding to this value will queue damage on a target, and after defend bonuses have a chance to trigger it will be inflicted.

## We'll calculate pseudostats from weapon and stats in the Unit
##	and adjusting based on the enemy will be handled here.
var adj_dmg : int ## DMG - Enemy Prot + Support Bonuses x Effectiveness
var adj_hit : int ### HIT - Enemy Avo + Support Bonuses + Weapon Triangle
var adj_crit : int ## CRIT - Enemy Ddg + Support Bonuses

var adj_prot: int ## PROT+ Terrain Prot+ Support Bonuses
var adj_avo : int ## AVO + Terrain Avo + Support Bonuses
var adj_ddg : int ## DDG + Support Bonuses

var adj_asd : int ## SPD + Attack Speed Modifiers

var flagSkills : Array[String]
var buffSkills : Array[SkillAdjustor]
var bonusAttackSkills : Array[SkillAttackBonus]
var bonusDefenseSkills : Array[SkillAttackBonus]
var bonusVengeSkills : Array[SkillAttackBonus]
var replaceSkills : Array[SkillAttackReplacement]
var afterSkills : Array[SkillPostEffect]

## Lockouts, useful in the interplay of skills.
var lockout_attack : bool = false
var lockout_heal : bool = false


func _init(un : Unit, we : Weapon) -> void:
	u = un
	w = we

func canAttack(reach : int) -> bool: ## Checks if a participant is able to counterattack. Should only need to be checked on the defender end. Should expand to account for any condition that makes a unit unable to attack.
	if w and reach >= w.reachMin and reach <= w.reachMax:
		return true
	# Other checks will need to go here.
	return false

# Terrain Bonus is (DMG, PROT, HEALING (Ignored))
# Support Bonus is [dmg, prot, hit, avo, crit, ddg]
func adjust(terrainBonus : Vector3i, supportBonus : PseudoAdjustment) -> void: ## Adds support and terrain bonuses
	adj_dmg = u.dmg + supportBonus.dmg
	adj_hit = u.hit + supportBonus.hit
	adj_crit= u.crit + supportBonus.crit
	
	adj_prot= u.prot + terrainBonus.y + supportBonus.prot
	adj_avo = u.avo + terrainBonus.x + supportBonus.avo
	adj_ddg = u.ddg + supportBonus.ddg
	
	adj_asd = u.getStat(Codex.STAT.SPD)
	if w:
		adj_asd -= w.asdPenalty

func oppose(e: BattleParticipant) -> void: ## Modifies state with opponent's pseudostats and weapon triangle
	if !w:
		return Vector3(0, 0, 0)
	var tri : int = 0
	if e.w:
		if e.w.weaponType in Codex.WEAPON_TRIANGLE[w.weaponType]:
			tri = 20
			if e.w.trait_duelist:
				tri -= 40
		elif w.weaponType in Codex.WEAPON_TRIANGLE[e.w.weaponType]:
			tri = -20
	
	adj_dmg -= e.adj_prot
	adj_hit += tri - e.adj_avo
	adj_crit -= e.adj_ddg

func aggregateSkills() -> void: ## Readies this participant's battle skills
	var aggregate : Array[Skill] = u.stat.equippedSkills + u.stat.lockedSkills + u.stat.charClass.innateSkills
	if w:
		aggregate += w.trait_skills
	for s in aggregate:
		if s is SkillAdjustor:
			buffSkills.append(s)
		elif s is SkillAttackReplacement:
			replaceSkills.append(s)
		elif s is SkillAttackBonus:
			if s.facing == SkillAttackBonus.FACE.ATTACK:
				bonusAttackSkills.append(s)
			elif s.facing == SkillAttackBonus.FACE.VENGE:
				bonusVengeSkills.append(s)
			else:
				bonusDefenseSkills.append(s)
		elif s is SkillPostEffect:
			afterSkills.append(s)
		else:
			flagSkills.append(s.name)

func queueDamage(d : int) -> void: ## Queues damage before calculating defensive skills.
	queued_damage += d
func realizeDamage() -> bool: ## Inflicts queued damage and returns true if damage is lethal.
	print("Debug: Chunking for %d damage!!" % queued_damage)
	var r : int = u.damage(queued_damage)
	queued_damage = 0
	return r


func _to_string() -> String:
	return "%s wielding %s: dmg: %d, hit: %d, crit: %d ; prot: %d, avo: %d, ddg: %d" % [u.stat.uName, w.name, adj_dmg, adj_hit, adj_crit, adj_prot, adj_avo, adj_ddg]
