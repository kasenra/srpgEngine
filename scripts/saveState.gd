extends Node
# Contains per-save globals such as story branches and difficulty

#	4 Difficulties
#	Story should simplify AIs and loosen time-based objectives. No experience needed.
#	Classic should be the baseline, someone with RPG experience should beat it
#		and someone with SRPG experience should be able to manage side objectives
#	Tactician should be somewhere between Hard1 to Hard2, SRPG experience should 
#		carry you to the end, but it should take SotS experience to get side objectives
#		-- Unlocked after clearing Tactician --
#	Relentless should be utterly impossible without deep knowledge of enemy AI
#		and the quirks of SotS. Not UNFAIR, but never forgiving.
#
#	Permanent death is simply, temporary death just takes them off the map.
#		Maybe a support points penalty? Would be funny.
#
#	Fixed Growths rolls all 59 levelup RNs when they join, making LevelScumming useless
#	Random Growths use the LevelRNG on levelup, meaning different level orders cause different growths

enum DIFFICULTY {STORY, CLASSIC, TACTICIAN, RELENTLESS}
enum DEATH {TEMPORARY, PERMANENT}
enum GROWTH {RANDOM, FIXED}

var difficulty: DIFFICULTY ## Enabled difficulty on this save
var death: DEATH ## Enabled Death Flag on this save
var growth: GROWTH ## Level RN generation method for this save. 0=False=Random, 1=True=Fixed

# Ironman saves can only be saved in the Ironman Assistance slot, which deletes itself
# 	every time you load it. Make it to the next save point, anon. You can do it.
var ironman: bool ## Ironman enabled on this save
var chapter: int ## Current chapter number. Should correspond to a Chapter lookup in the Codex.

# Army Contains Units made by the Unit Factory
var army: Array[Unit]


func loadFromStored(s : SavedGame) -> void: ## Loads a save from a SavedGame resource | Called by the SaveLoad system
	difficulty = s.difficulty
	death = s.death
	growth = s.growth
	ironman = s.ironman
	chapter = s.chapter
	
	RNG.coreRNG.state = s.coreRNGState
	RNG.levelRNG.state = s.levelRNGState
	
	army = []
	var fac := UnitFactory.new()
	for stat in s.armyStats:
		army.append(fac.build(stat))
	
func buildFile() -> SavedGame: ##Packages saved data into a SavedGame resource | Called by the SaveLoad system
	var f := SavedGame.new()
	
	f.difficulty = difficulty
	f.death = death
	f.growth = growth
	f.ironman = ironman
	f.chapter = chapter
	f.coreRNGState = RNG.coreRNG.state
	f.levelRNGState = RNG.levelRNG.state
	
	f.armyStats = []
	var fac := UnitFactory.new()
	for unit in army:
		f.armyStats.append(fac.strip(unit))
	
	return f
