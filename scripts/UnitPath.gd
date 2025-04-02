class_name UnitPath
extends TileMapLayer
@export var grid: Grid

var pathfinder : Pathfinder
var currentPath := PackedVector2Array()
@onready var _nub := $Nub

func createPather() -> void: ## Creates a pathfinding object for the UnitPath
	pathfinder = Pathfinder.new(grid)

func initialize(walkable: Array, map:BattleMap, mt: Codex.MOVETYPE) -> void: ## Prepares the pathfinding grid for a unit's walkable and moveType
	pathfinder.prepare(walkable, map, mt)

func draw(start: Vector2, end: Vector2): ## Draws the unit UnitPath
	clear()
	_nub.position = grid.mapPosition(start) - Vector2(32,32)
	currentPath = pathfinder.calculatePath(start, end)
	set_cells_terrain_connect(currentPath, 0, 0, true)
	_nub.show()

func stop() -> void:
	clear()
	_nub.hide()
