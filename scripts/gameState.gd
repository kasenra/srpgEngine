extends Node

# Current Cursor Actions
#	Neutral selects units to move
#	Move selects tiles to move to
#	Frozen does nothing while a context menu pops up
#	Select picks a tile to attack /  staff / etc
enum CURSOR_STATE {NEUTRAL, MOVE, FROZEN, SELECT, TARGET}
