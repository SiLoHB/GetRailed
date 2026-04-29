extends Node

@onready var sound0 = $sound0
@onready var sound1 = $sound1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound_melody()

func sound_main():
	sound0.play(sound1.get_playback_position())
	sound1.stop()

func sound_melody():
	sound1.play(sound0.get_playback_position())
	sound0.stop()
