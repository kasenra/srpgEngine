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
	coreRNG.seed = hash("Sarasiel")
	levelRNG.seed = hash("Forgive Me")

func loadRNG(sCore : int, sLevel : int) -> void:
	coreRNG.state = sCore
	levelRNG.state = sLevel
	
