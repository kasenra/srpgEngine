class_name SavedGame ## Stores a copy of save-specific flags to be stored as a save file
extends Resource

@export var difficulty: SaveState.DIFFICULTY
@export var death: SaveState.DEATH
@export var growth : SaveState.GROWTH
@export var ironman: bool
@export var coreRNGState : int
@export var levelRNGState : int

@export var chapter: int

# Army State
@export var armyStats: Array[UnitStats] ## Save Data Store for stats of all army units. Need to instantiate into units on load.
# Convoy State

# Story Flags Go Here
 
