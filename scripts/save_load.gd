class_name SaveLoad ## ALL Saving and Loading of Savegames goes through this node.
extends Node


func saveGame(fname: String) -> Error: ##Saves static data into a SavedGame file. Nonzero return signifies failure.
	var s : SavedGame = SaveState.buildFile()
	return(ResourceSaver.save(s, "user://saves/"+fname))

func loadGame(fname: String) -> void: ##Loads static data into SaveState based off a save game. Loading chapter is reserved for the controller.
	var l : SavedGame = load("user://saves/" + fname) as SavedGame
	SaveState.loadFromStored(l)
	# Loading Control section can then use Codex.ChapterScene[SaveState.chapter] to find
	#	where to go next :).
