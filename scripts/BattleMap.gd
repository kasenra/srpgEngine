class_name BattleMap
extends TileMapLayer
@onready var _wallMap = $WallMap
const NEIGHBORS: Array[Vector2] = [
	Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1),
	Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)
]

#This overwrites grid.size bc this is the least coupled way
#		I can think to make it work. Fuck my chungus life.
@export var size: Vector2 = Vector2(20,20)

#	Terrain Types are:
#		0	-	Flat		1	-	LightCover
#		2	-	Flying		3	-	Impassable
@export var idToTerrain : Dictionary[int, Codex.TERRAIN] = {
	0 : Codex.TERRAIN.NONE,
	1 : Codex.TERRAIN.LIGHTCOVER,
	2 : Codex.TERRAIN.FLYING,
	3 : Codex.TERRAIN.IMPASSABLE
}
# Change to Items
@export var chests: Dictionary[Vector2, Item] = {}

## Traversal Revision Record: Increments every time a traversal-facing map change happens
##	This allows AI Pathfinder Pools to update their grids only when out of date.
var traversalRevision : int = 0
func trigger_retraverse() -> void: ## Updates traversal revision record, causing AI Pools to recalculate traversal costs. Must be triggered on any instance of traversal-facing map changes.
	traversalRevision += 1

func getDoor(cell: Vector2) -> Vector2:
	for d in NEIGHBORS:
		if _wallMap.get_cell_source_id(cell + d) == 1:
			return cell + d
	return Vector2(0,0)
func openDoor(cell: Vector2) -> void:
	var d = getDoor(cell)
	if d:
		_wallMap.set_cell(d, -1)
		trigger_retraverse()

func getChest(cell: Vector2) -> Vector2:
	for d in NEIGHBORS:
		if _wallMap.get_cell_source_id(cell + d) == 3 && _wallMap.get_cell_atlas_coords(cell+d) == Vector2i(0,0):
			return cell + d
	return Vector2(0,0)
func openChest(cell: Vector2) -> Item:
	var c = getChest(cell)
	if c and chests.has(c):
		_wallMap.set_cell(c, 3, Vector2i(1,0))
		## No retraverse bc opened chests are still solid.
		return chests[c]
	return null

func getMoveCost(cell: Vector2, mt: Codex.MOVETYPE) -> float: ## Provided a cell and a unit on this map, determine that unit's movecost for that cell
	# Doors and Walls are unwalkable
	if _wallMap.get_cell_source_id(cell) in [1,2,3]:
		return 999
	return Codex.TERRAIN_MOVE[Vector2i(idToTerrain[get_cell_source_id(cell)], mt)]
func getAttackable(cell: Vector2) -> bool:
	if _wallMap.get_cell_source_id(cell) in [1,2,3]:
		return false
	return (Codex.TERRAIN_MOVE[Vector2i(idToTerrain[get_cell_source_id(cell)], Codex.MOVETYPE.ATTACK)]) == 1
	
