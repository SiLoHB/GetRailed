class_name SelectTile
extends Node2D

var tile_type: int
@export var rect: Rect2
@export var level: Node2D
@export var times: int
@export var is_placed: bool = false
var is_train_going:bool = false

var placement_disabled:bool = false

const TILE_SCENE := preload("res://TileHolder/TrackTile/Tile.tscn")

func _ready() -> void:
	Event.start_trains.connect(_disable_placement)
	Event.stop_trains.connect(_enable_placement)

func _enable_placement():
	placement_disabled = false

func _disable_placement():
	placement_disabled = true

func set_times(time: int) -> void:
	times = time - 1

func set_tile(type: int) -> void:
	tile_type = type
	var y = type / 4
	var x = type % 4
	%TileMapLayer.set_cell(Vector2i(0, 0), 0, Vector2i(x, y), 0)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_placed:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and !placement_disabled:
		if(times <= 0):
			is_placed = true
			%TileMapLayer.erase_cell(Vector2i(0,0))
		else:
			times -= 1
		
		var tile = TILE_SCENE.instantiate()
		tile.set_tile(tile_type)
		Event.create_new_tile.emit(tile)
		if tile.has_node("Area2D"):
			tile.get_node("Area2D").input_pickable = false
			tile.get_node("Area2D").monitoring = false
			tile.get_node("Area2D").monitorable = false
