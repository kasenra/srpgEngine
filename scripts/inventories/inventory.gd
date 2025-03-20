class_name Inventory
extends Resource

# Inventory Size from 5-6 are generally acceptable.
#	The important thing is that this max is representable in the UI
const MAX_ITEMS : int = 6
@export var inv : Array[Item] ## Raw Item List in a Unit's Inventory
var equip : Weapon

# Custom sort function for sorting items in inventories
#	Priority is Type > Name
#	return true if a comes before b, false if b comes before a
func invSort(a : Item, b : Item) -> bool:
	var ap : int = Util.ITEM_SORT_PROXY(a)
	var bp : int = Util.ITEM_SORT_PROXY(b)
	if ap < bp:
		return true
	elif bp < ap:
		return false
	if a.name < b.name:
		return true
	# b.name first or names equal both mean false
	return false

func inventorySort():
	inv.sort_custom(invSort)

func add(i : Item) -> bool: ## Add to an inventory. Returns true if there is an error.
	if inv.size() == MAX_ITEMS:
		return true # Handling overflow is the job of the controller
	inv.push_back(i)
	inventorySort()
	return false

#func equipS(i : int) -> bool: ## Equip the weapon in slot i. Returns true (or assert crashes) if something goes wrong.
	## Just to make equipping easier to debug later:
	#assert(i < MAX_ITEMS, "Overflowed Inventory Slots in EquipI.")
	#assert(inv[i] is Weapon, "Equipping non-weapon.")
	#if inv[i] is Weapon:
		#for item in inv:
			#if item is Weapon:
				#item.equipped = false
		#inv[i].equipped = true
		#return false
	#else:
		#return true

func equipW(w : Weapon) -> bool: ## Equip from a weapon item. Returns true (or assert crashes) if this fails. Handling Proficiency is delegated to the helper function in the Unit class.
	assert(w in inv, "Illegally equipped a weapon")
	clearEquip()
	w.equipped = true
	equip = w
	return false

func clearEquip() -> void:
	for item in inv:
			if item is Weapon:
				item.equipped = false

func index(i:int) -> Item: # Gets the item at a position in inv. Useful for UI stuff.
	assert(abs(i) < MAX_ITEMS, "Overflowed Inventory Indexing.")
	if i >= inv.size():
		return null
	return inv[i]

func _to_string() -> String:
	var ro = "---\n"
	for item in inv:
		ro = ro + "%s\n" % item
	return ro + "---"
