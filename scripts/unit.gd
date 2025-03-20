@tool
class_name Unit
extends Path2D
signal walkFinished

var gb : GameBoard = get_parent()
@export var stat : UnitStats

@export_group("Pseudostats") ## Determined entirely by stats and weapons. Displayed in UI.
var dmg : int
var prot: int
var hit : int
var avo : int
var crit: int
var ddg: int

@export_group("Temporary Stats") ## For Tonics and the like
var hp_temp: int = 0
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
			$AnimationPlayer.play("selected")
		else:
			$AnimationPlayer.play("RESET")
@export var isWalking: bool = false:
	set(val):
		isWalking = val
		set_process(isWalking)
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite2D

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

func updatePseudos() -> void: ## Updates DMG, HIT, AVO, CRIT, and DDG. Retriggered at start of map and on equipping any weapon.
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

func postBattleCleanup() -> void:
	stat.hp = stat.mhp
	# Turn map support points into character support points, clamped to the max values for their rank.
	# Don't do it for casual units who died tho
	
	# If units are DEAD dead, remove them from the army for good.

func die() -> void: ## Kills the unit. If on casual, dead units come right back, but on classic they're culled. 
	# Logic for death / knockout timelines goes here.
	
	# Logic for removing from gameboard counts
	stat.dead = true

func damage(d : int) -> bool: ## Deal final damage to unit. Damage reduction is calculated in battle logic. Returns true if unit died.
	stat.hp -= d
	if stat.hp < 0:
		die()
		return true
	return false

func walkAlong(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	#curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.mapPosition(point)-position)
	cell = path[-1]
	self.isWalking = true

func canEquip(w : Weapon) -> bool: ## Checks if a weapon is equippable for a unit. Checks proficiency and if present in inv.
	return(w in stat.inv.inv and w.profReq <= stat.charClass.proficiencies[w.weaponType])

func equip(w: Weapon) -> void: ## Equips weapon at index i. Should only be passed valid options.
	if w:
		assert(w in getInv().inv, "Illegal weapon equip: Not in Inventory")
		assert(proficient(w), "Illegal weapon equip: Lacking proficiency")
		getInv().equipW(w)
		stat.equipped = w
	else:
		getInv().clearEquip()
		stat.equipped = null
	updatePseudos()

func getEquipped() -> Weapon: ## Used in attack range and combat calculations.
	return stat.equipped
func getInv() -> Inventory: ## Used in the chain of (Push getInv() to UI) -+- (Select a Weapon) -+- (inv.equip(wep))
	return stat.inv
func proficient(w : Weapon) -> bool:
	var plist : Dictionary[Codex.WEAPON_TYPE, Codex.PROFICIENCY] = stat.charClass.proficiencies
	if plist.keys().has(w.weaponType) and plist[w.weaponType] >= w.profReq:
		return true
	return false

func getStat(s: Codex.STAT) -> int: ## Gets this unit's stats, shadowed by their caps. This should be the ONLY way you access these stats, to avoid issues with caps.
	match s:
		Codex.STAT.HP:
			return stat.hp ## HP is the one stat we'll use normally bc it can be lastingly affected in combat. For other stats, use temp_stat though
		Codex.STAT.MHP:
			return min(stat.mhp, stat.charClass.max_mhp + stat.identity.max_mhp)
		Codex.STAT.STR:
			return min(stat.strength, stat.charClass.max_str + stat.identity.max_str)
		Codex.STAT.MAG:
			return min(stat.magic, stat.charClass.max_mag + stat.identity.max_mag)
		Codex.STAT.SPD:
			return min(stat.speed, stat.charClass.max_spd + stat.identity.max_spd)
		Codex.STAT.SKL:
			return min(stat.skill, stat.charClass.max_skl + stat.identity.max_skl)
		Codex.STAT.LCK:
			return min(stat.luck, stat.charClass.max_lck + stat.identity.max_lck)
		Codex.STAT.DEF:
			return min(stat.defense, stat.charClass.max_def + stat.identity.max_def)
		Codex.STAT.RES:
			return min(stat.resistance, stat.charClass.max_res + stat.identity.max_res)
		Codex.STAT.MOV:
			return stat.move
	@warning_ignore("assert_always_false")
	assert(1<0, "This should not be fucking possible how did you do this you imbecile. 
					You changed the fucking stat enum didn't you you fucking dumbass.")
	return 80085

func _to_string() -> String:
	return "%s : Level %d %s : (%d / %d) :\n\t\tSTR %d, MAG %d, SPD %d, SKL %d,\n\t\tLCK %d, DEF %d, RES %d, MOV %d" % [stat.uName, stat.level, stat.charClass, getStat(Codex.STAT.HP), getStat(Codex.STAT.MHP), getStat(Codex.STAT.STR), getStat(Codex.STAT.MAG), getStat(Codex.STAT.SPD), getStat(Codex.STAT.SKL), getStat(Codex.STAT.LCK), getStat(Codex.STAT.DEF), getStat(Codex.STAT.RES), getStat(Codex.STAT.MOV)]
