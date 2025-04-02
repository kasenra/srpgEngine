extends Node ## Can you doc this?

# Any gameplay RNG should come from this to ensure set, non manipulable RNG every time.
#		It's still technically manipulable, just harder :D
var coreRNG: RandomNumberGenerator
# This one is for silly stuff that shouldn't be consistent
var fluffRNG : RandomNumberGenerator = RandomNumberGenerator.new()
# This means Level RNG is based on previous levels.
# On fixed growths, that means RNG is still based on joining order.
var levelRNG : RandomNumberGenerator

func _ready() -> void:
	coreRNG = RandomNumberGenerator.new()
	levelRNG = RandomNumberGenerator.new()
	# Do you thing gd files keep comments in decomp?
	# Do you think this file has a soul?
	# Fuck if I know
	coreRNG.seed = hash("Luna...")
	levelRNG.seed = hash("Forgive Me")

func loadRNG(sCore : int, sLevel : int) -> void:
	coreRNG.state = sCore
	levelRNG.state = sLevel

const BASEPIVOT : int = 50 ## Default value for the trueHit pivot. Raising this makes the game more 1RN, lowering it makes it more 2RN.
func trueHit(hit : int, pivot : int = BASEPIVOT) -> bool: ## Implements a version of the truehit formula inspired by FatesRNG. Hits below a given pivot use 1RN, hits above that pivot use 2RN. This punishes dodge tanking and makes reliable hits more reliable. Skills can change this pivot in battle logic.
	if hit > pivot:
		twoRN(hit)
	return oneRN(hit)
func oneRN(rate : int) -> bool:
	return (coreRNG.randf()*100) < rate
func twoRN(rate : int) -> bool:
	return (coreRNG.randf() + coreRNG.randf()) * 100 / 2 < rate
