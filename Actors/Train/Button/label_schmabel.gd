extends Node

@onready var label = $Label

var toggle = false

# Niklas sagt der Code seie perfekt und er liebe ihn <3
func _pressed() -> void:
	toggle = !toggle
	if toggle:
		Event.start_trains.emit()
		label.text = str("Stop Train")
	else:
		Event.stop_trains.emit()
		label.text = str("Start Train")
