class_name Pathfinder
extends Object

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var grid: Resource
var astar := AStarGrid2D.new()

func _init(nGrid: Grid) -> void:
	grid = nGrid
	astar.size = grid.cell_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()
	
	#for y in grid.map_size.y:
		#for x in grid.map_size.x:
			#astar.set_point_weight_scale(Vector2(x,y), map.getMoveCost())

func prepare(walkable: Array, map:BattleMap, mt: Codex.MOVETYPE) -> void: ## Sets the pathfinder state so it can quickly find routes within a certain walkable area.
	var c: Vector2
	for y in grid.map_size.y:
		for x in grid.map_size.x:
			c = Vector2(x,y)
			if not walkable.has(c):
				astar.set_point_solid(c, true)
			else:
				astar.set_point_solid(c, false)
				astar.set_point_weight_scale(c, map.getMoveCost(c, mt))

## AI Pool Object
##		Contains a Pathfinder and a set of units w the same movement costs
##		Checks a timestamp on map to determine if it's been changed and needs to recalculate each turn


func prepareLong(map: BattleMap, mt: Codex.MOVETYPE) -> void: ## Sets the pathfinder state to find the optimal route for an AI to approach a location. These can be pooled among AIs with the same MoveCosts to reduce performance overhead.
	var c: Vector2
	var c_cost: int
	for y in grid.map_size.y:
		for x in grid.map_size.x:
			c = Vector2(x,y)
			c_cost = map.getMoveCost(c, mt)
			if c_cost == 999:
				astar.set_point_solid(c, true)
			else:
				astar.set_point_solid(c, false)
				astar.set_point_weight_scale(c, c_cost)


func calculatePath(start: Vector2, end: Vector2) -> PackedVector2Array:
	return astar.get_id_path(start, end)
