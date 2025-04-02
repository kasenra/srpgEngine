class_name StatAdjustment
extends Resource
## Dummy class for packaging a modification to stats.
## Used by pair up, conditions, etc.

var str : int = 0
var mag : int = 0
var spd : int = 0
var skl : int = 0
var lck : int = 0
var def : int = 0
var res : int = 0
var mov : int = 0

func _init(strength : int = 0, magic : int = 0, speed : int = 0, skill : int = 0, luck : int = 0, defense : int = 0, resistance : int = 0, movement : int = 0) -> void:
	str = strength
	mag = magic
	spd = speed
	skl = skill
	lck = luck
	def = defense
	res = resistance
	mov = movement
