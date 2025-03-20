extends Control
@export var gb : GameBoard
@export var u:Unit
@export var hd: Weapon

func _on_check_doors_pressed() -> void:
	print(gb.map.getDoor(u.cell))

func _on_open_doors_pressed() -> void:
	gb.map.openDoor(u.cell)


func _on_check_chests_pressed() -> void:
	print(gb.map.getChest(u.cell))

func _on_open_chests_pressed() -> void:
	var cc: String = gb.map.openChest(u.cell)
	print("Got a %s!!" % cc)


func _on_check_inventory_pressed() -> void:
	print("Unit: %s of Team %d" % [u.stat.uName, u.stat.allegiance])
	print(u.stat.inv)


func _on_sort_inventory_pressed() -> void:
	u.stat.inv.inventorySort()


func _on_add_dogs_to_inv_pressed() -> void:
	print(u.stat.inv.add(hd.duplicate()))


func _on_equip_item_0_pressed() -> void:
	print(u.stat.inv.equipW(u.stat.inv.index(0)))


func _on_print_stats_pressed() -> void:
	print(u)
	
func _on_level_up_pressed() -> void:
	SaveState.growth = SaveState.GROWTH.RANDOM
	print(u.stat.levelUp())

func _on_initialize_pressed() -> void:
	u.stat.initStats()

func _on_fix_r_ns_pressed() -> void:
	print(u.stat.growthRns)
	u.stat.fixGrowths()
	print(u.stat.growthRns)

func _on_draw_reach_pressed() -> void:
	gb._overlay.draw(gb.getAttackable(u), MoveOverlay.TILE.PLAYERATTACK, false)

func _on_refresh_stock_pressed() -> void:
	$OptionButton.refreshStock()


func _on_option_button_item_selected(index: int) -> void:
	u.equip(u.getInv().index(index))


func _on_draw_walk_reach_pressed() -> void:
	gb._overlay.draw(gb.getAttackAround(u), MoveOverlay.TILE.PLAYERATTACK, false)

func _on_draw_outline_pressed() -> void:
	gb._overlay.draw(gb.getWalkable(u), MoveOverlay.TILE.PLAYERMOVE, false)
	gb._overlay.draw(gb.outline(gb.getWalkable(u)), MoveOverlay.TILE.HOSTILEMOVE, false)


func _on_test_local_pressed() -> void:
	print("NAME_ARTEMIS")
	print("NAME_SERAPHINA")
	for letter in "NAME_ARTEMIS":
		print(letter)
	var c = Character.new()
	c.name = "NAME_ARTEMIS"
	print(c.name)
	for l in c.name:
		print(l)
	var d := {"NAME_ARTEMIS" : "It works", "Avitia" : "It doesn't work."}
	
	
	pass # Replace with function body.
