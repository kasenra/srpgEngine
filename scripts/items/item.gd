class_name Item
extends Resource

@export var name: String
@export var thumbPath: String
@export var discardable: bool
@export var tradeable: bool
@export var droppable : bool

func exhaust() -> void: ## Used by all items which break, destroys the item.
	pass

func _to_string() -> String:
	return "<| %s |>" % name
