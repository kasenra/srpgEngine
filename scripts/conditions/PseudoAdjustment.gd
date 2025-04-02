class_name PseudoAdjustment 
extends Resource
## Dummy class for packaging a modification to pseudostats.
var dmg : int = 0
var prot : int = 0
var hit : int = 0
var avo : int = 0
var crit : int = 0
var ddg : int = 0

func _init(d : int = 0, p : int = 0, h : int = 0, a : int = 0, c : int = 0, dd : int = 0) -> void:
	dmg = d
	prot = p
	hit = h
	avo = a
	crit = c
	ddg = dd

func score(u : Unit) -> int: ## Returns a compressed score for this pseudostat adjustment. Used to roughly compare partners for picking tag teams. Supplying a unit will add some basic logic to determine the best of a few weights.
	## This whole thing is VERY subjective, and we can try a lot of different formulas
	##  to try and tune it properly.
	##  Generally, defense should be slightly preferred, since it has a 
	##  discounting effect on your unit's future ventures.
	##	Passing a unit will give a more specific set of priorities
	if u:
		if u.getBloodied(5):
			return int( Vector2(dmg, prot).dot(Vector2(0,4)) +
				Vector2(hit, avo).dot(Vector2(0,0.8)) +
				Vector2(crit, ddg).dot(Vector2(0,0.2))
				)
		elif u.getBloodied(2):
			return int( Vector2(dmg, prot).dot(Vector2(1,4)) +
				Vector2(hit, avo).dot(Vector2(0.1,0.8)) +
				Vector2(crit, ddg).dot(Vector2(0.2,0.2))
				)
		else:
			return int( Vector2(dmg, prot).dot(Vector2(2,2)) +
				Vector2(hit, avo).dot(Vector2(0.2,0.2)) +
				Vector2(crit, ddg).dot(Vector2(0.4,0.2))
				)
	
	
	
	return int( Vector2(dmg, prot).dot(Vector2(1,2)) +
				Vector2(hit, avo).dot(Vector2(0.1,0.2)) +
				Vector2(crit, ddg).dot(Vector2(0.2,0.2))
				)
