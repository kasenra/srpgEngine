@tool
extends Node2D
signal accept_pressed(cell:Vector2)
signal moved(newCell:Vector2)

@export var grid: Grid
@export var uiCooldown: float = 0.1

@export var cell : Vector2 = Vector2.ZERO:
	set(c):
		var nc: Vector2 = grid.gridClamp(c)
		if nc.is_equal_approx(cell):
			return cell
		cell = nc
		position = grid.mapPosition(cell)
		moved.emit(cell)
		$Timer.start()

func _ready() -> void:
	$Timer.wait_time = uiCooldown
	position = grid.mapPosition(cell)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		self.cell = grid.gridPosition(event.position)
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("click"):
		accept_pressed.emit(cell)
		get_viewport().set_input_as_handled()
		
	var should_move = event.is_pressed()
	if event.is_echo():
		should_move = should_move and $Timer.is_stopped()
	if !should_move:
		return
	
	if event.is_action("ui_right"):
		cell += Vector2.RIGHT
	elif event.is_action("ui_left"):
		cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		cell += Vector2.DOWN
	elif event.is_action("ui_up"):
		cell += Vector2.UP

func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.CORNFLOWER_BLUE , false, 2.0)
