class_name Chest
extends Node2D
# Change to be an item
@export var contents : String
@export var location : Vector2
var opened = false

func _ready() -> void:
	get_parent().get_parent().chests[location] = self

func isOpen() -> bool:
	return opened

# Change to return an item
func open() -> String:
	if opened:
		return ""
	opened = true
	$OpenSprite.show()
	$ClosedSprite.hide()
	return contents
	
