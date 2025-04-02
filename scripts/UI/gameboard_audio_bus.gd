class_name GBAudioBus
extends AudioStreamPlayer2D

enum SOUNDS {SELECT, DESELECT}

@export var soundfiles : Dictionary[SOUNDS, AudioStream] 

func playSound(source : SOUNDS) -> void:
	(get_stream_playback() as AudioStreamPlaybackPolyphonic).play_stream(soundfiles[source])
