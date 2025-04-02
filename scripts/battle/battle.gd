class_name Battle ## Battle logic is stored here. UI Collects Units, their Terrains, and their Supporters 
extends RefCounted

enum STANCE {NONE, OFF, DEF}
enum POSITION {NONE, ATTACKER, DEFENDER, ATTACKERTAG, DEFENDERTAG}
const DOUBLE_THRESHOLD = 5

var reach : int
var initiative : Array[BattleParticipant]
var doubler : BattleParticipant

var attacker: Unit
var att_terrain: Codex.TERRAIN
var att_supporter: Unit
var att_stance : STANCE

var defender: Unit
var def_terrain: Codex.TERRAIN
var def_supporter: Unit
var def_stance : STANCE

# Prediction Stats

var att_dmg := Vector2() ## (Attacker Damage, Attacker Support Damage)
var att_hit := Vector2() ## (Attacker Hit, Attacker Support Hit)
var att_crit := Vector2() ## (Attacker Crit, Attacker Support Crit)
var att_multi := Vector2() ## (Attacker Mulitplicity, Attacker Support Multiplicity)

var def_dmg := Vector2() ## (Defender Damage, Defender Support Damage)
var def_hit := Vector2() ## (Defender Hit, Defender Support Hit)
var def_crit := Vector2() ## (Defender Crit, Defender Support Crit)
var def_multi := Vector2() ## (Defender Mulitplicity, Defender Support Multiplicity)

## Caching some repeated concatenates
var att_skillList : Array[Skill]
var def_skillList : Array[Skill]

## We also need to move our participants to statics.
## WOW, this is getting messy.
var atkPart : BattleParticipant
var defPart : BattleParticipant
var atkSPart : BattleParticipant
var defSPart : BattleParticipant

func _init(att: Unit, def: Unit, distance:int, atS : Unit = null, deS : Unit = null, at_ter : Codex.TERRAIN = Codex.TERRAIN.NONE, de_ter : Codex.TERRAIN = Codex.TERRAIN.NONE, at_stance : STANCE = STANCE.NONE, de_stance : STANCE = STANCE.NONE) -> void:
	reach = distance
	
	attacker = att
	att_supporter = atS
	att_stance = at_stance
	att_terrain = at_ter
	
	defender = def
	def_supporter = deS
	def_stance = de_stance
	def_terrain = de_ter
	
	reset()
func reset() -> void: ## Resets key battle setup variables
	att_dmg = Vector2(0,0)
	att_hit = Vector2(0,0)
	att_crit = Vector2(0,0)
	att_multi = Vector2(0,0)
	
	def_dmg = Vector2(0,0)
	def_hit = Vector2(0,0)
	def_crit = Vector2(0,0)
	def_multi = Vector2(0,0)
	
	doubler = null
	
func predict(atkW : Weapon) -> void: ## Predicts a battle with Attacker initiating against Defender with weapon atkW. Sets the prediction state.
	
	## Set Up Participants
	atkPart = BattleParticipant.new(attacker, atkW)
	atkPart.combat_position = POSITION.ATTACKER ## Pass Aggression into the BP for skill purposes.
	defPart = BattleParticipant.new(defender, defender.getEquipped())
	defPart.combat_position = POSITION.DEFENDER
	
	atkPart.target = defPart
	defPart.target = atkPart
	
	## Sort Participant Skills into:
	##	Flag	Buff	Attack Replacement	After Effect
	##	BonusAttack		Bonus Defend		Bonus Venge
	atkPart.aggregateSkills()
	defPart.aggregateSkills()
	
	## And Supporters if needed
	if att_supporter and att_stance == STANCE.OFF:
		atkSPart = BattleParticipant.new(att_supporter, att_supporter.getEquipped())
		atkSPart.combat_position = POSITION.ATTACKERTAG
		atkSPart.target = defPart
	if def_supporter and def_stance == STANCE.OFF and defPart.canAttack(reach):
		defSPart = BattleParticipant.new(def_supporter, def_supporter.getEquipped())
		defSPart.combat_position = POSITION.DEFENDERTAG
		defSPart.target = atkPart
	
	## Adjust for Terrain and Support
	atkPart.adjust(Codex.TERRAIN_COMBAT[att_terrain], attacker.getSupportBonuses(att_supporter))
	defPart.adjust(Codex.TERRAIN_COMBAT[def_terrain], defender.getSupportBonuses(def_supporter))
	
	
	## With this new refactor, checking flag skills is piss easy and has almost no cost.
	var wary : bool = "FLAG_NOFOLLOWUP" in atkPart.flagSkills or "FLAG_NOFOLLOWUP" in defPart.flagSkills
	
	## Modifiers go here, to allow for defensive pseudostat adjustment.
	for skill in atkPart.buffSkills:
		if skill.enemy_side:
			skill.modify(defPart)
		else:
			skill.modify(atkPart)
	for skill in defPart.buffSkills:
		if skill.enemy_side:
			skill.modify(atkPart)
		else:
			skill.modify(defPart)
	
	## Oppose Defenses into Offenses and add triangle to get base predicted combat
	atkPart.oppose(defPart)
	defPart.oppose(atkPart)
	
	# And again to add avo into supported attacks
	if atkSPart:
		atkSPart.adjust(Codex.TERRAIN_COMBAT[att_terrain], att_supporter.getSupportBonuses(attacker))
		atkSPart.oppose(defPart)
		atkSPart.adj_dmg = int(0.5 * atkSPart.adj_dmg)
		att_multi.y = 1
	if defSPart:
		defSPart.adjust(Codex.TERRAIN_COMBAT[def_terrain], def_supporter.getSupportBonuses(defender))
		defSPart.oppose(atkPart)
		defSPart.adj_dmg = int(0.5 * defSPart.adj_dmg)
		def_multi.y = 1
	
	## Determine Attack Multiplicity
	if atkPart.w:
		att_multi.x = 1
		if atkPart.adj_asd >= defPart.adj_asd + DOUBLE_THRESHOLD and atkPart.w.canDouble and !wary:
			att_multi.x = 2
			doubler = atkPart
	if defPart.w and defPart.canAttack(reach):
		def_multi.x = 1
		if defPart.adj_asd >= atkPart.adj_asd + DOUBLE_THRESHOLD and defPart.w.canDouble and !wary:
			def_multi.x = 2	
			doubler = defPart
	
	## Including doublers from Braves
	if atkPart.w and atkPart.w.trait_aggressiveDouble:
		att_multi.x *= 2
	if atkSPart and atkSPart.w and atkSPart.w.trait_aggressiveDouble:
		att_multi.y *= 2
	## Set Prediction State
	att_dmg.x = atkPart.adj_dmg
	att_hit.x = atkPart.adj_hit
	att_crit.x= atkPart.adj_crit
	
	def_dmg.x = defPart.adj_dmg
	def_hit.x = defPart.adj_hit
	def_crit.x= defPart.adj_crit
	
	if atkSPart and not def_stance == STANCE.DEF:
		att_dmg.y = atkSPart.adj_dmg
		att_hit.y = atkSPart.adj_hit
		att_crit.y= atkSPart.adj_crit
	if defSPart and not att_stance == STANCE.DEF:
		def_dmg.y = defSPart.adj_dmg
		def_hit.y = defSPart.adj_hit
		def_crit.y= defSPart.adj_crit

func strife() -> void: ## Use prediction state to do battle.	
	var att_followup_first : bool = "FLAG_FOLLOWUP_FIRST_BLOODY" in atkPart.flagSkills and attacker.getBloodied(2)
	var def_counter_first : bool = "FLAG_COUNTER_FIRST_BLOODY" in defPart.flagSkills and defender.getBloodied(2)
	
	print("DEBUG: VANTAGE %s DESPERATION %s" % [def_counter_first, att_followup_first])
	
	## Declare initiative, accounting for Counter-First and Double-First
	
	initiative = []
	
	## We can simplify this by adding tags after initiative is calculated using find() and insert()
	## And using multiplicity in this case is just annoying, so we'll keep it for display and do our logic here.
	
	if defPart.canAttack(reach):
		if def_counter_first: ## Def Att Double
			## Skill Trigger gfx
			initiative.append(defPart)
			initiative.append(atkPart)
			if doubler:
				initiative.append(doubler)
		if att_followup_first and doubler == atkPart: ## Att Att Def
			## Skill Trigger gfx
			initiative.append(atkPart)
			initiative.append(atkPart)
			initiative.append(defPart)
		else: ## Att Def Double
			initiative.append(atkPart)
			initiative.append(defPart)
			if doubler:
				initiative.append(doubler)
	else:
		initiative.append(atkPart)
		if doubler:
			initiative.append(atkPart)
	
	## Now, we do a little searching to add our tag attacks
	if defPart.canAttack(reach) and defSPart:
		initiative.insert(initiative.find(defPart), defSPart)
	if atkSPart:
		initiative.insert(initiative.find(defPart), atkSPart)
	
	print("Debug Initiative:")
	print(initiative)
	
	## Iterate through the initiative order, launching attacks from each unit.
	var part : BattleParticipant
	var replaced : bool
	while initiative.size() > 0:
		part = initiative.pop_front() as BattleParticipant
		print("Debug: %s Attacks!" % part.u.stat.uName)
		# Roll Attack Replacers
		replaced = false
		for rep in part.replaceSkills:
			if rep.roll(part.u):
				rep.attack(self, part)
				replaced = true
				break
		# Roll Attack against BattleParticipant.target
		if not replaced:
			rollAttack(part)
		
		# Bonus Aggressive attacks can trigger onhit but not replacement
		# 	This is like 50/50 design decision vs simplifying code flow
		if part.w.trait_aggressiveDouble and part.combat_position in [POSITION.ATTACKER, POSITION.ATTACKERTAG]:
			rollAttack(part)
		
		# Roll Defense and Venge Skills
		for def in part.target.bonusDefenseSkills:
			if def.roll(part.target.u):
				def.affect(self, part.target)
		for ven in part.target.bonusVengeSkills:
			if ven.roll(part.target.u):
				ven.affect(self, part.target)
		
		# Inflict Queued Damage 
		if part.target.realizeDamage():
			## End on Unit Death Logic Here
			## Probably gonna need to pass some signals between here and the
			## Dialogue started in die() if that applies.
			break
	for poison in atkPart.afterSkills:
		poison.imbue(self, atkPart)
	for poison in defPart.afterSkills:
		poison.imbue(self, defPart)
	
func rollAttack(bp: BattleParticipant) -> int: ## Returns damage dealt by participant bp to their target.
	var d : int
	print("%d%% chance to hit..." % bp.adj_hit)
	if bp.adj_hit >= 100 or (bp.adj_hit > 0 and RNG.trueHit(bp.adj_hit)):
		d = bp.adj_dmg
		if bp.adj_crit >= 100 or (bp.adj_crit > 0 and RNG.oneRN(bp.adj_crit)):
			d = int(d * bp.w.critMult)
		bp.target.queueDamage(d)
		
		for att in bp.bonusAttackSkills:
			if att.roll(bp.u):
				att.affect(self, bp)
		print("Debug: Hit for %d damage!" % d)
		return d
	print("Debug: Miss!")
	return 0



func _to_string() -> String:
	var atkPair : String = ""
	var defPair : String = ""
	var atkSName : String = ""
	var defSName : String = ""
	
	if att_supporter and att_stance == STANCE.OFF:
		atkPair = " + {%dx%d | %d | %d}" % [att_dmg.y, att_multi.y, att_hit.y, att_crit.y]
		atkSName = " (+%s)" % att_supporter.stat.uName
	if def_supporter and def_stance == STANCE.OFF:
		defPair = " + {%dx%d | %d | %d}" % [def_dmg.y, def_multi.y, def_hit.y, def_crit.y]
		defSName = " (+%s)" % def_supporter.stat.uName
	
	return "%s%s -> %s%s: [%dx%d | %d | %d]%s -- [%dx%d | %d | %d]%s" % [
		attacker.stat.uName, atkSName, defender.stat.uName, defSName,
		att_dmg.x, att_multi.x, att_hit.x, att_crit.x,
		atkPair,
		def_dmg.x, def_multi.x, def_hit.x, def_crit.x,
		defPair
	]
