class_name TrackTile
extends Node2D

var tile_type: int
@export var rect: Rect2
@export var level: Node2D
@export var is_placed2: bool = false

var original_position: Vector2

var placement_disabled = false

var holder: Node2D

const SOURCE_ID := 0
const CROSS_TILE := preload("res://TileHolder/TrackTile/CrossTile.tscn")

func _enable_placement():
	placement_disabled = false

func _disable_placement():
	placement_disabled = true

func _ready() -> void:
	holder = get_tree().get_first_node_in_group("Holder")
	Event.start_trains.connect(_disable_placement)
	Event.stop_trains.connect(_enable_placement)

func set_tile(type: int) -> void:
	tile_type = type
	var y := type / 4
	var x := type % 4
	%TileMapLayer.set_cell(Vector2i(0, 0), SOURCE_ID, Vector2i(x, y), 0)
	if tile_type == 6:
		var cross_tile = CROSS_TILE.instantiate()
		%TileMapLayer.add_child(cross_tile)

func get_global_rect() -> Rect2:
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func set_on_place():
	is_placed2 = true
	modulate.a = 1
	set_as_top_level(false)
	
	await get_tree().create_timer(0.1).timeout
	
	if has_node("Area2D"):
		var area:Area2D = get_node("Area2D")
		area.input_pickable = true
		area.monitoring = true
		area.monitorable = true

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_placed2:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() and not placement_disabled:
		is_placed2 = false
		Event.create_new_tile.emit(self)
		if has_node("Area2D"):
			var area:Area2D = get_node("Area2D")
			area.input_pickable = false
			area.monitoring = false
			area.monitorable = false


func _on_desel_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.is_pressed() and not is_placed2 \
	and not placement_disabled:
		#TODO add Tile to selectable tiles
		printt("desel")
		for tile in holder.childs:
			if tile["key"] == tile_type:
				var t: SelectTile = tile["value"]
				if t.is_placed:
					t.is_placed = false
				t.times + 1
				t.set_tile(tile_type)
		Event.remove_tile.emit(self)
		pass
