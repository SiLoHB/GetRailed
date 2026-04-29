@tool
class_name Station
extends Node2D

const SLOW_TRAIN_SCENE = preload("res://Actors/Train/SlowTrain.tscn")
const NORMAL_TRAIN_SCENE = preload("res://Actors/Train/TrainYellow.tscn") # Das macht sinn
const FAST_TRAIN_SCENE = preload("res://Actors/Train/FastTrain.tscn")

var spawning_enabled := false
var spawn_token := 0

## Label is used to find this station as a target
@export var label: String = "A":
	get:
		return label
	set(value):
		label = value
		%Label.text = label

## Assign targets here, each target spawns a train
@export var trains: Array[TrainSchedule]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Event.start_trains.connect(on_start_trains)
	Event.stop_trains.connect(on_stop_trains)

func on_stop_trains() -> void:
	spawning_enabled = false
	spawn_token += 1
## main function that spawns trains
func on_start_trains() -> void:
	spawning_enabled = true
	spawn_token += 1
	var my_token := spawn_token

	for schedule: TrainSchedule in trains:
		if not spawning_enabled or my_token != spawn_token:
			return
		var target := get_target_station(schedule.target)
		if not target:
			push_error("target station not found")
			continue
		await get_tree().create_timer(schedule.start_delay).timeout
		if not spawning_enabled or my_token != spawn_token:
			return
		var train := create_train(schedule.train_type) as Train
		if train == null:
			continue
		train.target = target
		add_child(train)

func create_train(type: Enum.TrainType) -> Train:
	var train_node: Node = null

	match type:
		Enum.TrainType.SLOW:
			train_node = SLOW_TRAIN_SCENE.instantiate() as Train
		Enum.TrainType.NORMAL:
			train_node = NORMAL_TRAIN_SCENE.instantiate() as Train
		Enum.TrainType.FAST:
			train_node = FAST_TRAIN_SCENE.instantiate() as Train
		_:
			push_error("Wrong train type")
			return null

	var train := train_node as Train
	if train == null:
		push_error("Train scene root is not a Train (script/class_name Train missing on root node?)")
		return null

	train.origin_station_label = label
	return train


## finds station by looking up every station in group
func get_target_station(target_label: String) -> Station:
	var stations := get_tree().get_nodes_in_group("Station")
	for station: Station in stations:
		if station.label == target_label:
			return station
	
	return null


func _on_train_detection_area_body_entered(body: Node2D) -> void:
	if body is Train:
		var train := body as Train
		if train.origin_station_label == label:
			return
		Event.train_reached_station.emit(train.type)
		train.queue_free()
