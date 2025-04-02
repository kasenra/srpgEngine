class_name UnitStats ## This Resource contains a stat block for a unit. When combined with a Character, it forms a Player Unit, but it can also hold a template for generics.
extends Resource

@export_group("Identifiers")
@export var uName: String = ""
@export var identity: Character

@export_group("Class")
@export_range(1,60) var level : int
@export var charClass : UnitClass
@export_group("Current Stats")
@export var hp: int
@export var mhp: int
@export var strength: int
@export var magic: int
@export var speed: int
@export var skill: int
@export var luck: int
@export var defense: int
@export var resistance: int
@export var move: int
@export var moveType: Codex.MOVETYPE

@export_group("Skills")
const MAX_SKILLS : int = 7 ## Maximum number of skills a unit can equip. Does not count Locked Skills.
@export var skills : Array[Skill] = [] ## Holds all skills which can be equipped or unequipped
@export var equippedSkills : Array[Skill] = [] ## Holds all equippable skills which are currently equipped
@export var lockedSkills : Array[Skill] = [] ## Holds special skills which can't be equipped or unequipped.
@export var innateProficiencies : Dictionary[Codex.WEAPON_TYPE, Codex.PROFICIENCY] ## Holds innate proficiencies granted by supports, events, intrinsics, etc.

@export_group("Gear")
@export var inv: Inventory ## Inventory Object for a Unit
@export var equipped: Weapon

@export_group("Team")
#expand this to teams n stuff later
@export var allegiance: Codex.TEAM
@export var dead: bool = false

@export_group("Support")
## No real reason to pass full characters to this when not needed when name strings do the trick. Display name can change, but internal name cannot
@export var supportPoints : Dictionary[String, int] ## Support points between this character and others. Don't increment if at max (Including S)
@export var clearedRanks : Dictionary[String, Codex.SUPPORT] ## Max Viewed Support Conversation, Used to cut off Growth before viewing conversations.
@export var lover : Character


@export_group("Fixed Growths")
@export var growthRns : Dictionary[int, Array] = {} ## maps int: level to Array[float] for rns for [mhp, str, mag ...]

func initStats() -> void: ## Used by the factory to set base stats off Template and Class. Sets level to 1 because we always build from level 1 (just sometimes in a promoted class)
	assert(move == 0, "Initialized an already initialized unit.")
	level = 1
	modStats(
		identity.base_mhp + charClass.base_mhp,
		identity.base_str + charClass.base_str,
		identity.base_mag + charClass.base_mag,
		identity.base_spd + charClass.base_spd,
				
		identity.base_skl + charClass.base_skl,
		identity.base_lck + charClass.base_lck,
		identity.base_def + charClass.base_def,
		identity.base_res + charClass.base_res,

		charClass.base_mov
	)
	moveType = charClass.mType
	hp = mhp
	var prf : Skill = identity.personal
	if prf:
		lockedSkills.append(prf)

func fixGrowths() -> void: ## Rolled on join when Fixed Growths are enabled. Sets fixed growths for this unit.
	var i : int = 1
	var rn := RNG.levelRNG
	while growthRns.keys().size() < 59:
		#hit the gacha 8 times B)
		growthRns[i] = [
			100 * rn.randf(),
			100 * rn.randf(),
			
			100 * rn.randf(),
			100 * rn.randf(),
			
			100 * rn.randf(),
			100 * rn.randf(),
			
			100 * rn.randf(),
			100 * rn.randf()
		]
		i += 1

func classChange(c: UnitClass) -> Array[int]: ## Handles promotion boosts and class changing. Returns net stat changes for display.
		var mod : Array[int]
		# Sometimes, the answer is the really stupid, inelegant way :\\\\\
		#if charClass:
		assert(charClass, "Tried to change class without initializing in base class. We don't do that.")
		mod = [
			c.base_mhp - charClass.base_mhp,
			c.base_str - charClass.base_str,
			c.base_mag - charClass.base_mag,
			c.base_spd - charClass.base_spd,
			c.base_skl - charClass.base_skl,
			c.base_lck - charClass.base_lck,
			c.base_def - charClass.base_def,
			c.base_res - charClass.base_res,
			c.base_mov - charClass.base_mov]
		#else: # Thanks to the need for initialization, this should never come up.
			#mod = [
					#c.base_mhp,
					#c.base_str,
					#c.base_mag,
					#c.base_spd,
					#c.base_skl,
					#c.base_lck,
					#c.base_def,
					#c.base_res,
					#c.base_mov]
		
		callv("modStats", mod)
		return mod

func modStats(maxhp: int = 0, stre: int = 0, mag: int = 0, spd:int = 0, skl:int = 0, lck:int=0, def:int = 0, res:int = 0, mov : int = 0) -> void:
	mhp += maxhp
	hp += maxhp
	strength += stre
	magic += mag
	speed += spd
	skill += skl
	luck += lck
	defense += def
	resistance += res
	move += mov

func levelUp(bonuses : Array[int] = [0,0,0,0,0,0,0,0]) -> Array: ## Levels this unit more optimally. Returns stat increases, can optionally pass an int[8] of boosts to each growth. Dialogue is handled at the caller side, and caps are handled at Unit.getStat()
	var growthRate : Array[int] = [
		identity.growth_mhp + charClass.growth_mhp + bonuses[0],
		identity.growth_str + charClass.growth_str + bonuses[1],
		identity.growth_mag + charClass.growth_mag + bonuses[2],
		identity.growth_spd + charClass.growth_spd + bonuses[3],
		identity.growth_skl + charClass.growth_skl + bonuses[4],
		identity.growth_lck + charClass.growth_lck + bonuses[5],
		identity.growth_def + charClass.growth_def + bonuses[6],
		identity.growth_res + charClass.growth_res + bonuses[7]
	]
	var outcome : Array[int] = [0,0,0,0, 0,0,0,0]
	if SaveState.growth: # Fixed = True
		var rn = growthRns[level]
		for i in range(growthRate.size()):
			while growthRate[i] > 100:
				outcome[i] += 1
				growthRate[i] -= 100
			if rn[i] < growthRate[i]:
				outcome[i] += 1
	else: # Fixed = False
		var rn = RNG.levelRNG
		for i in range(growthRate.size()):
			while growthRate[i] > 100:
				outcome[i] += 1
				growthRate[i] -= 100
			if rn.randf() * 100 < growthRate[i]:
				outcome[i] += 1
	level += 1
	callv("modStats", outcome)
	charClass.classSkills(self)
	return outcome

func getSupportRank(u : Unit) -> Codex.SUPPORT:
	var c : String = u.stat.identity.name
	if c in clearedRanks.keys():
		return clearedRanks[c]
	return Codex.SUPPORT.NONE

func setSupportRank(ally : Unit, r : Codex.SUPPORT) -> void:
	clearedRanks[ally.stat.identity.name] = r

func addSkill(s : Skill) -> void:
	skills.append(s)
	if equippedSkills.size() < MAX_SKILLS:
		equippedSkills.append(s)

func proficient(w : Weapon) -> bool:
	var clist : Dictionary[Codex.WEAPON_TYPE, Codex.PROFICIENCY] = charClass.proficiencies 
	if (clist.keys().has(w.weaponType) and clist[w.weaponType] >= w.profReq) or (innateProficiencies.keys().has(w.weaponType) and innateProficiencies[w.weaponType] >= w.profReq):
		return true
	return false

func equip(w: Weapon) -> void: ## Equips weapon at index i. Should only be passed valid options.
	if w:
		assert(w in inv.inv, "Illegal weapon equip: Not in Inventory")
		assert(proficient(w), "Illegal weapon equip: Lacking proficiency")
		inv.equipW(w)
		equipped = w
	else:
		inv.clearEquip()
		equipped = null
