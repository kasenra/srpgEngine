class_name FragileWeapon
extends Weapon
## Class for weapons which have limited uses. Weapons which use 'ammo' take durability damage on a miss, but others only do so on a hit.

@export var maxDurability : int
@export var durability : int

@export var usesAmmunition : bool

func consumeUse() -> bool: ## Uses up a durability on this weapon, exhausting if needed. Returns true on break.
	durability -= 1
	if durability <= 0:
		exhaust()
		return true
	return false
