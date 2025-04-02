extends Node
## Contains global UI signal handling, interfacing between state and UI
signal display_prediction(b : Battle)
signal hide_prediction()

func emit_display_prediction(b: Battle): ## Called by Attack action to display the battle prediction UI
	display_prediction.emit(b)
func emit_hide_prediction(): ## Called to hide the battle prediction after a moment.
	hide_prediction.emit()
