@tool
class_name Unit
extends Path2D
signal walkFinished

@onready var gb : GameBoard = get_parent()
@export var stat : UnitStats

@export_group("Pseudostats") ## Determined entirely by stats and weapons. Displayed in UI.
var dmg : int
var prot: int
var hit : int
var avo : int
var crit: int
var ddg: int

@export_group("Temporary Stats") ## For Tonics and the like
var mhp_temp: int = 0
var strength_temp: int = 0
var magic_temp: int = 0
var speed_temp: int = 0
var skill_temp: int = 0
var defense_temp: int = 0
var resistance_temp: int = 0
var luck_temp: int = 0
var move_temp: int = 0

@export_group("Graphics")
@export var tex: Texture:
	set(value):
		tex = value
		if not _sprite:
			await self.ready
		_sprite.texture = value
@export var skinOffset: Vector2 = Vector2.ZERO:
	set(offset):
		skinOffset = offset
		if not _sprite:
			await self.ready
		_sprite.position = offset

@export_group("Grid Movement")
@export var grid: Grid
@export var movespeed : float = 600 ## Speed of the walking movement.
@export var cell: Vector2 = Vector2.ZERO: ## Unit's current position in the grid.
	set(gridPos):
		cell = grid.gridClamp(gridPos)
@export var isSelected : bool = false:
	set(val):
		isSelected = val
		if isSelected:
			_animator.play("selected")
		else:
			_animator.play("RESET")
@export var isWalking: bool = false:
	set(val):
		isWalking = val
		set_process(isWalking)
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite2D
@onready var _healthbar : ProgressBar = $PathFollow2D/Sprite2D/HPBar
@onready var _animator : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_process(false)
	cell = grid.gridPosition(position)
	position = grid.mapPosition(cell)
	#print("Cell: %s; Pos: %s" % [cell, position])
	if not Engine.is_editor_hint():
		curve = Curve2D.new()
	#var debugPoints = PackedVector2Array([Vector2(2,2), Vector2(2,3), Vector2(4,1), Vector2(2,1)])
	#walkAlong(debugPoints)
func _process(delta: float) -> void:
	$PathFollow2D.progress += movespeed * delta
	if $PathFollow2D.progress_ratio >= 1.0:
		isWalking = false
		$PathFollow2D.progress = 0.00001
		position = grid.mapPosition(cell)
		curve.clear_points()
		walkFinished.emit()


## Unit Preparation Methods
func initialize() -> void: ## Initializes stats and other Unit-level variables
	stat.initStats()
	updateHealthDisplay()
	updatePseudos()
func levelUp(bonuses : Array[int] = [0,0,0,0,0,0,0,0]) -> void: ## Wraps UnitStats.LevelUp() to allow unit-level variables to be updated on midmap levelups. Will probably also interact with the global interface.
	stat.levelUp(bonuses)
	## Character Levelup Screen Signalling can go here. Should send unit and the output of levelup
	updatePseudos()
	updateHealthDisplay()

func preBattleCleanup() -> void: ## Called on all units enteriong map directly before deployment.
	updateHealthDisplay()
func postBattleCleanup() -> void: ## Called on all units leaving map directly at the end of chapter.
	# Full Heal (Yknow it would be kinda funny to not do this, but nah)
	stat.hp = stat.mhp
	
	# Remove all temp stats
	mhp_temp = 0
	strength_temp = 0
	magic_temp = 0
	speed_temp = 0
	skill_temp = 0
	luck_temp = 0
	defense_temp = 0
	resistance_temp = 0
	move_temp = 0
	
	# Turn map support points into character support points, clamped to the max values for their rank.
	# Don't do it for casual units who died tho
	
	# If units are DEAD dead, remove them from the army for good.

func onTurnStart() -> void: ## Called at the start of each player phase
	pass
func onTurnEnd() -> void: ## Called every time this unit is exhausted
	pass


## Map-Specific Stat Adjustments
func die() -> void: ## Kills the unit. If on casual, dead units come right back, but on classic they're culled. 
	# Logic for death / knockout timelines goes here.
	
	# Logic for removing from gameboard counts
	stat.dead = true
	gb.killUnit(self)
func damage(d : int) -> bool: ## Deal final damage to unit. Damage reduction is calculated in battle logic. Returns true if unit died.
	stat.hp -= d
	updateHealthDisplay()
	if stat.hp <= 0:
		die()
		return true
	return false
func heal(h : int) -> int: ## Heals a unit and returns the true amount healed (for EXP purposes)
	var damage = getStat(Codex.STAT.MHP) - getStat(Codex.STAT.HP)
	var trueHeal = min(damage, h) ## Actual healing needed
	self.stat.hp += trueHeal
	return trueHeal
func updatePseudos() -> void: ## Updates DMG, PROT, HIT, AVO, CRIT, and DDG. Retriggered at start of map and on equipping any weapon.
	dmg = 0
	prot = 0 # Prot is modified by support and weapons only
	hit = int(getStat(Codex.STAT.SKL) * 1.5 + getStat(Codex.STAT.LCK) * 0.5 + stat.charClass.bonus_hit)
	avo = int(getStat(Codex.STAT.SPD) * 1.5 + getStat(Codex.STAT.LCK) * 0.5 + stat.charClass.bonus_avo)
	crit= int((getStat(Codex.STAT.SKL) - 4) * 0.5 + stat.charClass.bonus_crit)
	ddg = int(getStat(Codex.STAT.LCK) + stat.charClass.bonus_ddg)
	if getEquipped():
		var w : Weapon = getEquipped()
		if w.damageType == Codex.DAMAGE_TYPE.PHYSICAL:
			dmg += getStat(Codex.STAT.STR) + w.might + stat.charClass.bonus_dmg
		else:
			dmg += getStat(Codex.STAT.MAG) + w.might + stat.charClass.bonus_dmg
		prot += w.prot
		hit += w.hit
		avo += w.avoid
		crit += w.crit
		ddg += w.dodge
	updateHealthDisplay()
func updateHealthDisplay() -> void: ## Ensures Parity between healthbar and HP values. Called any time HP or MAX HP could be modified. (Damage, Healing, or any pseudo update)
	_healthbar.max_value = getStat(Codex.STAT.MHP)
	_healthbar.value = getStat(Codex.STAT.HP)
func equip(w: Weapon) -> void: ## Equips weapon w.
	stat.equip(w)
	updatePseudos()


## Unit Stat Check Methods
func getSupportBonuses(p : Unit) -> PseudoAdjustment: ## TODO Implement Affinity Table Calculation
	if !p:
		return PseudoAdjustment.new()
	var r : Codex.SUPPORT = stat.getSupportRank(p)
	
	return PseudoAdjustment.new()
func getSkillActive(skl : String) -> bool: ## Returns whether this unit has a certain skill equipped.
	for s in stat.equippedSkills:
		if s.name == skl:
			return true
	for s in stat.lockedSkills:
		if s.name == skl:
			return true
	return false
func getEquipped() -> Weapon: ## Used in attack range and combat calculations.
	return stat.equipped
func getInv() -> Inventory: ## Used in the chain of (Push getInv() to UI) -+- (Select a Weapon) -+- (inv.equip(wep))
	return stat.inv
func getStat(s: Codex.STAT) -> int: ## Gets this unit's stats, shadowed by their caps. This should be the ONLY way you access these stats, to avoid issues with caps.
	match s:
		Codex.STAT.HP:
			return stat.hp ## HP is the one stat we'll use normally bc it can be lastingly affected in combat. For other stats, use temp_stat though
		Codex.STAT.MHP:
			return min(stat.mhp, stat.charClass.max_mhp + stat.identity.max_mhp) + mhp_temp
		Codex.STAT.STR:
			return min(stat.strength, stat.charClass.max_str + stat.identity.max_str) + strength_temp
		Codex.STAT.MAG:
			return min(stat.magic, stat.charClass.max_mag + stat.identity.max_mag) + magic_temp
		Codex.STAT.SPD:
			return min(stat.speed, stat.charClass.max_spd + stat.identity.max_spd) + speed_temp
		Codex.STAT.SKL:
			return min(stat.skill, stat.charClass.max_skl + stat.identity.max_skl) + skill_temp
		Codex.STAT.LCK:
			return min(stat.luck, stat.charClass.max_lck + stat.identity.max_lck) + luck_temp
		Codex.STAT.DEF:
			return min(stat.defense, stat.charClass.max_def + stat.identity.max_def) + defense_temp
		Codex.STAT.RES:
			return min(stat.resistance, stat.charClass.max_res + stat.identity.max_res) + resistance_temp
		Codex.STAT.MOV:
			return stat.move
	@warning_ignore("assert_always_false")
	assert(1<0, "This should not be fucking possible how did you do this you imbecile. 
					You changed the fucking stat enum didn't you you fucking dumbass.")
	return 80085
func getStatCap(s: Codex.STAT) -> int: ## Gets this unit's stat cap for a particular stat.
	assert(s not in [Codex.STAT.MOV, Codex.STAT.HP], "Illegal Stat Cap Check: HP and MOV have no 'Cap'.")
	match s:
		Codex.STAT.MHP:
			return stat.charClass.max_mhp + stat.identity.max_mhp
		Codex.STAT.STR:
			return stat.charClass.max_str + stat.identity.max_str
		Codex.STAT.MAG:
			return stat.charClass.max_mag + stat.identity.max_mag
		Codex.STAT.SPD:
			return stat.charClass.max_spd + stat.identity.max_spd
		Codex.STAT.SKL:
			return stat.charClass.max_skl + stat.identity.max_skl
		Codex.STAT.LCK:
			return stat.charClass.max_lck + stat.identity.max_lck
		Codex.STAT.DEF:
			return stat.charClass.max_def + stat.identity.max_def
		Codex.STAT.RES:
			return stat.charClass.max_res + stat.identity.max_res
	return -1
func getBloodied(recip : int) -> bool: ## Integer-ized heal proportion checker. Returns if HP * recip >= MHP. 2 -> 50%, etc, you're a smart girl.
	return getStat(Codex.STAT.HP) * recip <= getStat(Codex.STAT.MHP)
func canEquip(w : Weapon) -> bool: ## Checks if a weapon is equippable for a unit. Checks proficiency and if present in inv.
	return(w in stat.inv.inv and w.profReq <= stat.charClass.proficiencies[w.weaponType])


func walkAlong(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	#curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.mapPosition(point)-position)
	cell = path[-1]
	self.isWalking = true



func _to_string() -> String:
	return "%s : Level %d %s : (%d / %d) :\n\t\tSTR %d, MAG %d, SPD %d, SKL %d,\n\t\tLCK %d, DEF %d, RES %d, MOV %d" % [stat.uName, stat.level, stat.charClass, getStat(Codex.STAT.HP), getStat(Codex.STAT.MHP), getStat(Codex.STAT.STR), getStat(Codex.STAT.MAG), getStat(Codex.STAT.SPD), getStat(Codex.STAT.SKL), getStat(Codex.STAT.LCK), getStat(Codex.STAT.DEF), getStat(Codex.STAT.RES), getStat(Codex.STAT.MOV)]
