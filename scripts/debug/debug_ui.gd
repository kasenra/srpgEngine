extends Control
@export var gb : GameBoard
@export var u:Unit
@export var uList: Array[Unit]
@export var ghost: Unit
@export var uCursor: int = 0
@export var hd: Weapon

func time(f: Callable, a : Variant = null) -> void:
	var s : int = Time.get_ticks_msec()
	if a:
		for i in range(100):
			f.callv(a)
	else:
		for i in range(100):
			f.call()
	print("Took %d ms" % (Time.get_ticks_msec() - s))
func _physics_process(_delta: float) -> void:
	var p = gb.grid.gridPosition(gb._cursor.position)
	$CursorPosition.text = "(%d, %d)" % [p.x, p.y]
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
	for un in uList:
		un.initialize()
		$Initialize.hide()
func _on_fix_r_ns_pressed() -> void:
	print(u.stat.growthRns)
	u.stat.fixGrowths()
	print(u.stat.growthRns)
func _on_draw_reach_pressed() -> void:
	gb._overlay.draw(gb.getAttackable(u), MoveOverlay.TILE.PLAYERATTACK, false)
func _on_refresh_stock_pressed() -> void:
	$OptionButton.refreshStock(u)
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
func _on_self_battle_pressed() -> void:
	time(Callable(self, "testBattle1"))
func testBattle1() -> void:
	var b = Battle.new(uList[0], uList[1], 1)
	b.predict(u.getEquipped())
	print(b)
func _on_change_unit_pressed() -> void:
	uCursor = (uCursor+1) % 3
	u = uList[uCursor]
func _on_damage_pressed() -> void:
	u.damage(1)
func _on_print_pseudos_pressed() -> void:
	print("D: %d, H: %d, C: %d, P: %d, A: %d, Dd: %d" % [
		u.dmg, u.hit, u.crit,
		u.prot, u.avo, u.ddg
	])
func _on_ghost_pressed() -> void:
	gb.debugGhostAssist(ghost, u)
var mhp = 20
var hp = 6
func bloodTestQuotient(r : float) -> bool:
	return (float(hp) / mhp) <= r
func bloodTestProduct(p: int) -> bool:
	return hp * p <= mhp
func _on_blood_test_pressed() -> void:
	time(Callable(self, "bloodTestQuotient"), 0.5)
	time(Callable(self, "bloodTestProduct"), 2)
func _on_fill_test_pressed() -> void:
	time(Callable(gb, "getAttackAround"), [u])


func _on_advance_rn_pressed() -> void:
	RNG.coreRNG.randf()
