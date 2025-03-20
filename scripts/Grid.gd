@tool
class_name Grid
extends Resource

@export var map_size : Vector2 = Vector2(20,20)
@export var cell_size : Vector2 = Vector2(64,64)
var cell_center : Vector2 = cell_size/2

func mapPosition(gridPos : Vector2) -> Vector2: ## Convert tile to pixel position
	#print("Map Position of %s = (%s * %s) + %s = %s" % [gridPos, gridPos, cell_size, cell_center, (gridPos * cell_size) + cell_center])
	return(gridPos * cell_size + cell_center)
func gridPosition(mapPos : Vector2) -> Vector2: ## Convert pixel position to tile
	return((mapPos / cell_size).floor())

func withinBounds(gridPos : Vector2) -> bool:
	return(gridPos.x >= 0 and gridPos.x < map_size.x and gridPos.y >= 0 and gridPos.y < map_size.y)
func gridClamp(gridPos: Vector2) -> Vector2:
	return(Vector2(clamp(gridPos.x, 0.0, map_size.x-1), clamp(gridPos.y, 0.0, map_size.y-1)))

#func cellIndex(gridPos : Vector2) -> int:
	#return int(gridPos.x + map_size.x * gridPos.y)
