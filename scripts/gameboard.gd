class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
@export var grid: Grid
@export var map: BattleMap

var units : Dictionary[Vector2, Unit] = {}
var activeOld : Vector2
var activeUnit: Unit
var walkable : Array[Vector2] = []
var attackable : Array[Vector2] = []

@onready var _path := $UnitPath
@onready var _overlay := $MoveOverlay
@onready var _cursor := $Cursor ## Debug Handle
@onready var _gbbus := $GameboardAudioBus

var cState : GameState.CURSOR_STATE = GameState.CURSOR_STATE.NEUTRAL

func _ready() -> void:
	# This Grid resource setup has me fucked up
	#	But it works.
	assert(map, "Attempted to load misconfigured GameBoard object: No Map.")
	assert(grid, "Attempted to load misconfigured GameBoard object: No Grid.")
	grid.map_size = map.size
	_path.createPather()
	reinitialize()
func _unhandled_input(event: InputEvent) -> void:
	if activeUnit and event.is_action_pressed("ui_cancel"):
		if cState == GameState.CURSOR_STATE.MOVE:
			hideNav()
			clearActive()
			print("Cancelling Move")
			cState = GameState.CURSOR_STATE.NEUTRAL
			_gbbus.playSound(GBAudioBus.SOUNDS.DESELECT)
		elif cState == GameState.CURSOR_STATE.TARGET:
			units.erase(activeUnit.cell)
			activeUnit.cell = activeOld
			activeUnit.position = grid.mapPosition(activeOld)
			units[activeOld] = activeUnit
			hideNav()
			clearActive()
			print("Cancelling Attack")
			cState = GameState.CURSOR_STATE.NEUTRAL
			_gbbus.playSound(GBAudioBus.SOUNDS.DESELECT)

func reinitialize() -> void:
	units.clear()
	for child in get_children():
		var u := child as Unit
		if u:
			units[u.cell] = u
func isOccupied(cell: Vector2) -> bool:
	return units.has(cell)
func getWalkable(unit: Unit) -> Array[Vector2]: ## Finds the walkable area for unit
	return costedFloodFill(unit)
func getAttackable(unit: Unit) -> Array[Vector2]: ## Finds the reach of unit's weapon from their square
	if unit.getEquipped():
		return weaponFill(unit.cell, unit.getEquipped())
	return []
func getAttackAround(unit: Unit) -> Array[Vector2]:
	if unit.getEquipped():
		return weaponAround(getWalkable(unit), unit.getEquipped())
	return []
func costedFloodFill(unit : Unit, weapon : bool = false) -> Array[Vector2]:
	# Movecost Ideas:
	#	Add costs DURING EXPLORATION
	var explored : Array[Vector2] = []
	var stack := [unit.cell]
	var costs : Dictionary[Vector2, float]
	costs = {unit.cell : unit.getStat(Codex.STAT.MOV)}
	while not stack.size() == 0:
		# Allies can be passed, enemies can only be passed with a skill
		#	To make this work, we cost tiles with nonhostile units, but we don't explore them.
		#	This SHOULD literally just work.
		var current = stack.pop_back()
		explored.append(current)	
		var remain: float = costs[current]
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			var reach
			reach = remain - map.getMoveCost(coordinates, unit.stat.moveType)
			# This logic is getting so heavy that we have to multiline it for sanity lol
			if (isOccupied(coordinates) and units[coordinates].stat.allegiance != unit.stat.allegiance):
				continue
			if !grid.withinBounds(coordinates) or reach < 0 or (costs.has(coordinates) and costs[coordinates] >= reach):
				continue
			stack.append(coordinates)
			costs[coordinates] = reach
	if weapon: # Erase cells with a manhattan distance beneath min range
		var culled : Array[Vector2] = []
		for point in explored:
			if manhattan(unit.cell, point) >= unit.getEquipped().reachMin:
				#explored.erase(point)
				culled.append(point)
		explored = culled
	return explored
func manhattan(start : Vector2, end : Vector2) -> int:
	return abs(start.x-end.x) + abs(start.y - end.y)
func weaponFill(cell : Vector2, weap: Weapon, mask : Array[Vector2] = []) -> Array[Vector2]: ## Calculates Targets for a weapon around a cell.
	var explored : Array[Vector2] = []
	var stack : Array [Vector2] = [cell]
	
	while not stack.size() == 0:
		var current : Vector2 = stack.pop_back()
		if current in explored or !grid.withinBounds(current):
			continue
		if manhattan(current, cell) > weap.reachMax:
			continue
		
		explored.append(current)
		
		for dir in DIRECTIONS:
			var coord : Vector2 = current + dir
			if coord in explored:
				continue
			if coord in stack:
				continue
			# If we move this down to the culling step, we 
			#	get an attack logic that allows ranged users 
			#	to shoot over walls and impassables.
			if !map.getAttackable(coord):
				continue
			stack.append(coord)
	
	var culled : Array[Vector2] = []
	for node in explored:
		if manhattan(node, cell) >= weap.reachMin and node not in mask:
			culled.append(node)
	return culled
func weaponAround(walk: Array[Vector2], weap : Weapon) -> Array[Vector2]: ## Calculates weapon range around the walkable area using successive shells.
	if not weap:
		return []
	#var out : Array[Vector2]
	var overlap : Array[Vector2] = []
	for cell in walk:
		overlap += weaponFill(cell, weap, overlap)
	return overlap
	# Heartbreaking: The clever shelling function is only marginally faster than the
	#	absurdly stupid brute force method
	#for shell in range(0, weap.reachMin):
		#out = outline(walk)
		#for cell in out:
			#overlap += weaponFill(cell, weap)
			#walk.erase(cell)
	#return overlap
func outline(area : Array[Vector2]) -> Array[Vector2]:
	var out : Array[Vector2] = []
	for cell in area:
		if cell + DIRECTIONS[0] not in area:
			out.append(cell)
			continue
		if cell + DIRECTIONS[1] not in area:
			out.append(cell)
			continue
		if cell + DIRECTIONS[2] not in area:
			out.append(cell)
			continue
		if cell + DIRECTIONS[3] not in area:
			out.append(cell)
			continue
	return out
func attackActive(dest : Vector2) -> void:	
	if not isOccupied(dest) or (not dest in attackable) or (isOccupied(dest) and units[dest].stat.allegiance == activeUnit.stat.allegiance):
		return
	_gbbus.playSound(GBAudioBus.SOUNDS.DESELECT)
	var b = Battle.new(activeUnit, units[dest], manhattan(activeUnit.cell, dest))
	b.predict(activeUnit.getEquipped())
	#print(b)
	UISignal.emit_display_prediction(b)
	b.strife()
	hideNav()
	clearActive()
	cState = GameState.CURSOR_STATE.NEUTRAL	
func moveActive(dest: Vector2) -> void:
	if (isOccupied(dest) and activeUnit.cell != dest) or not dest in walkable:
		return
	activeOld = activeUnit.cell
	cState = GameState.CURSOR_STATE.FROZEN
	if dest != activeUnit.cell:
		units.erase(activeUnit.cell)
		units[dest] = activeUnit
		activeUnit.walkAlong(_path.currentPath)
		await activeUnit.walkFinished
	hideNav()
	_gbbus.playSound(GBAudioBus.SOUNDS.SELECT)
	# Context Menu goes here.
	if activeUnit.getEquipped():
		cState = GameState.CURSOR_STATE.TARGET
		attackable = getAttackable(activeUnit)
		_overlay.draw(attackable, MoveOverlay.TILE.PLAYERATTACK)
	else:
		hideNav()
		clearActive()
		cState = GameState.CURSOR_STATE.NEUTRAL
func selectUnit(cell: Vector2) -> void:
	if not units.has(cell):
		return
	if cState == GameState.CURSOR_STATE.NEUTRAL and units[cell].stat.allegiance == Codex.TEAM.PLAYER:
		_gbbus.playSound(GBAudioBus.SOUNDS.SELECT)
		UISignal.emit_hide_prediction()
		cState = GameState.CURSOR_STATE.MOVE
		activeUnit = units[cell]
		activeUnit.isSelected = true
		walkable = getWalkable(activeUnit)
		_overlay.draw(walkable, MoveOverlay.TILE.PLAYERMOVE)
		_path.initialize(walkable, map, activeUnit.stat.moveType)
		# If we want to render the overlay for attack range AROUND movement range, we need a helper
		#	to check for cells with empty borders. That's gonna be a nightmare.
func hideNav() -> void:
	#activeUnit.isSelected = false
	_overlay.clear()
	_path.stop()
func clearActive() -> void:
	activeUnit.isSelected = false
	activeUnit = null
	walkable.clear()
func killUnit(u : Unit) -> void:
	units.erase(u.cell)
	print("%s Died!" % u.stat.uName)
	u._animator.play("die")
	await u._animator.animation_finished
	u.hide()


func _get_configuration_warnings() -> PackedStringArray:
	if not grid:
		return PackedStringArray(["You need a grid resource for this node to work."])
	return PackedStringArray()
func cursorActivate(cell: Vector2) -> void:
	#print("Ping")
	if not activeUnit and cState == GameState.CURSOR_STATE.NEUTRAL:
		selectUnit(cell)
	elif activeUnit.isSelected and cState == GameState.CURSOR_STATE.MOVE:
		moveActive(cell)
	elif cState == GameState.CURSOR_STATE.TARGET:
		attackActive(cell)	
func cursorMove(newCell: Vector2) -> void:
	if activeUnit and activeUnit.isSelected and cState == GameState.CURSOR_STATE.MOVE:
		_path.draw(activeUnit.cell, newCell)

func debugGhostAssist(old : Unit, new : Unit) -> void:
	var oldPos = old.cell
	old.queue_free()
	new.reparent(self)
	#add_child(new)
	if new.cell:
		units.erase(new.cell)
	new.cell = oldPos
	units[oldPos] = new
	new.position = grid.mapPosition(oldPos)
