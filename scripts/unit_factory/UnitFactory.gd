class_name UnitFactory ## The UnitFactory is instantiated to print units out of UnitStat resources. This allows the creation of random enemies AND the loading of allied units from resources.
extends Node

func stripStats(u: Unit) -> UnitStats:
	return u.stat
func newUnit(us: UnitStats) -> Unit:
	var u : Unit = Unit.new()
	u.stat = us
	return u
func newFromTemplate(t : UnitStats, level : int, faction : String) -> Unit: ## Takes a level 1* unit template and prepares a unit at a certain level. (WILL NOT PROMOTE)
	var u = Unit.new()
	u.stat = t
	while u.stat.level != level:
		u.stat.levelUp()
	u.name = faction
	return u
func strip(u : Unit) -> UnitStats:
	return u.stat
func build(us: UnitStats) -> Unit:
	var u := Unit.new()
	u.stat = us
	u.initialize()
	return u
