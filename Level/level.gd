extends Node2D

@export var grid: GridContainer
@export var disabled_grid_indices: Array[int] = []
## Rail tiles are put here
@export var rails_node: Node2D

@export_file(".tscn") var scene_after_win: String


var object: TrackTile = null
var targetCell: GridCell = null
var objectCells: Array[GridCell] = []
var isValid := false

var placement_disabled:bool = false

var slow_trains: int
var normal_trains: int
var fast_trains: int


func _ready() -> void:
	Event.create_new_tile.connect(create_new)
	Event.move_tile.connect(create_new)
	Event.remove_tile.connect(remove)
	Pause.enabled = true
	Event.start_trains.connect(_allow_to_place)
	Event.stop_trains.connect(_stop_place)
	Event.train_reached_station.connect(on_train_reached_station)
	
	await get_tree().process_frame
	fill_start_cells()
	
	count_trains()
	
	_reset_highlight()
	
	Bgm.sound_main()

func _cancel_selected_tile():
	if object:
		object.global_position = object.original_position
		object.modulate.a = 1.0
		object.queue_free()
	
	object = null
	targetCell = null
	objectCells.clear()
	isValid = false
	_reset_highlight()
	

func on_train_reached_station(train_type: Enum.TrainType) -> void:
	print(train_type, " reached station")
	match train_type:
		Enum.TrainType.SLOW:
			slow_trains -= 1
		Enum.TrainType.NORMAL:
			normal_trains -= 1
		Enum.TrainType.FAST:
			fast_trains -= 1
	
	if slow_trains <= 0 and normal_trains <= 0 and fast_trains <= 0:
		print_debug("Level won")
		if not scene_after_win:
			push_error("No level after win set")
			return
		
		get_tree().change_scene_to_file(scene_after_win)


func count_trains() -> void:
	slow_trains = 0
	normal_trains = 0
	fast_trains = 0
	
	## count trains currently set in the level as a target
	var stations = get_tree().get_nodes_in_group("Station")
	for station: Station in stations:
		for schedule: TrainSchedule in station.trains:
			match schedule.train_type:
				Enum.TrainType.SLOW:
					slow_trains += 1
				Enum.TrainType.NORMAL:
					normal_trains += 1
				Enum.TrainType.FAST:
					fast_trains += 1
	printt("trains counted", slow_trains, normal_trains, fast_trains)
	

func fill_start_cells():
	var cells = grid.get_children()
	for idx in disabled_grid_indices:
		if idx >= 0 and idx < cells.size():
			var cell := cells[idx] as GridCell
			if cell:
				cell.full = true
				cell.disabled = true
				cell.change_color(Color(0.5, 0.5, 0.5, 0.0))

func _input(event):
	if placement_disabled:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and isValid:
			_place_placement()


func create_new(object1):
	if placement_disabled:
		return
	if object:
		return
	
	object1.original_position = object1.global_position
	
	object1.modulate.a = 1.0
	var cell:GridCell = _get_target_cell(get_global_mouse_position())
	if  cell != null:
		cell.full = false
	
	if object1.get_parent():
		object1.get_parent().remove_child(object1)
	rails_node.add_child(object1)
	object1.global_position = get_global_mouse_position()
	object = object1


func _on_grid_gui_input(event):
	if event is InputEventMouseMotion:
		if not object:
			return
		var mouse_pos = get_global_mouse_position()
		var new_cell = _get_target_cell(mouse_pos)
		if new_cell:
			targetCell = new_cell
			object.global_position = targetCell.global_position
			_reset_highlight()
			objectCells = _get_object_cells()
			_check_and_highlight_cells()



func _get_target_cell(pos) -> GridCell:
	for child: GridCell in grid.get_children():
		if child.get_global_rect().has_point(pos):
			return child
	return null



func _get_object_cells() -> Array[GridCell]:
	var cells: Array[GridCell] = []
	if targetCell:
		cells.append(targetCell)
	return cells

func _check_and_highlight_cells():
	if not targetCell:
		isValid = false
		return false
	isValid = not targetCell.full
	if targetCell.full:
		targetCell.change_color(Color.RED)
	else:
		targetCell.change_color(Color.GREEN)
	return isValid



func _reset_highlight():
	for child: GridCell in grid.get_children():
		if child.disabled:
			child.change_color(Color(0.5, 0.5, 0.5, 0.0))
		else:
			child.change_color(Color(0.502, 0.502, 0.502, 0.251))

func _place_placement():
	if placement_disabled:
		return
	if not object or not targetCell:
		return
	object.set_on_place()
	targetCell.full = true
	object = null
	targetCell = null
	objectCells.clear()
	isValid = false
	_reset_highlight()

func _allow_to_place():
	placement_disabled = true
	_cancel_selected_tile()

func _stop_place():
	placement_disabled = false
	count_trains()

func remove(tile:TrackTile) -> void:
	if not targetCell:
		return
	
	object = tile
	object.modulate.a = 0
	targetCell.full = false
	targetCell = null
	object.queue_free()
	isValid = true
	objectCells.clear()
	_reset_highlight()
