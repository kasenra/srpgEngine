extends Node

# Sorting utility for sorting inventories
#var SORT_PROXY : Dictionary[Item, int] = {
	#Weapon : 0,
	#Staff : 1,
	#Consumable : 2,
	#Item : 999
	#}
func ITEM_SORT_PROXY(i : Item) -> int:
	if i is Weapon:
		return 0
	elif i is Staff:
		return 1
	elif i is Consumable:
		return 2
	return 999
