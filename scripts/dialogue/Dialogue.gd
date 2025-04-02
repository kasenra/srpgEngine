class_name Dialogue ## Static class managing the transfer of variables and signals to and from Dialogic. This one's gonna be ugly.
extends Node

func supportTimeline(c1 : Character, c2 : Character) -> String: ## Returns the timeline for supports between two Characters. The internals here are nasty but you don't need to think about them, kitten.
	if c1.name > c2.name:
		return supportTable["%s+%s" % [c2.name, c1.name]]	
	return supportTable["%s+%s" % [c1.name, c2.name]]
var supportTable : Dictionary[String, String] = { ## To get past hashing issues, supports are accessed using a string identifier of uke_seme (actually unicode sorted, but that's basically the same). There should be no collision issues unless we have units who share a name, which is obviously a problem. This is a bit of a nightmare, but I think it works with the localization strings.
	"NAME_ARTEMIS+NAME_SERAPHINA" : "ART_PHINA_SUPPORT"
	
}

func refreshStatics() -> void: ## TODO: Refreshes any static variables that are needed in Dialogic
	pass

func play() -> void: ## TODO: Formats and plays a timeline
	pass
