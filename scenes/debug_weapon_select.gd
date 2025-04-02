extends OptionButton
@export var hd: Weapon

func refreshStock(u : Unit) -> void:
	var item : Item
	clear()
	for i in range(u.getInv().MAX_ITEMS):
		item = u.getInv().index(i)
		if item:
			add_item(item.name, i)
		else:
			break
