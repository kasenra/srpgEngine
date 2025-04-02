class_name MoveOverlay
extends TileMapLayer

enum TILE {PLAYERMOVE, PLAYERATTACK, HOSTILEMOVE, HOSTILEATTACK}

func draw(cells: Array, t : TILE, clearing : bool = true) -> void:
	#will need to add another parameter here to 
	#	allow drawing attacks and threats
	if clearing:
		clear()
	var tile : Vector2
	match t:
		TILE.PLAYERMOVE:
			tile = Vector2(0,0)
		TILE.PLAYERATTACK:
			tile = Vector2(1,0)
		TILE.HOSTILEMOVE:
			tile = Vector2(0,1)
		TILE.HOSTILEATTACK:
			tile = Vector2(1,1)
	for cell in cells:
		set_cell(cell, 0, tile)
