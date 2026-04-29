class_name Train
extends CharacterBody2D

var running := true

@export var rails: TileMapLayer
@export_range(50, 200) var speed: int = 50
@export var snap_distance: float = 2.0
@export var origin_station_label: String = ""
@export var target: Station

var current_dir: Vector2 = Vector2.ZERO
var current_cell: Vector2i

func _enter_tree() -> void:
	print("Train ENTER TREE: ", name)

func _ready() -> void:
	print("Train READY, rails export=", rails)
	print("Train READY: ", name)
	Event.start_trains.connect(_on_start_trains)
	Event.stop_trains.connect(_on_stop_trains)

	if rails == null:
		var rails_node := get_tree().get_root().find_child("Rails", true, false)
		if rails_node is TileMapLayer:
			rails = rails_node

	print("Rails after lookup =", rails)
	if rails == null:
		push_error("Train: rails is NULL (can't move)")
		return

	# WICHTIG: Startzelle korrekt bestimmen
	current_cell = rails.local_to_map(rails.to_local(global_position))
	print("Spawn global=", global_position, " cell=", current_cell)
	print("Tile type at cell=", _get_tile_type(current_cell))
	print("Neighbor types: R=", _get_tile_type(current_cell + Vector2i(1,0)),
		" D=", _get_tile_type(current_cell + Vector2i(0,1)),
		" L=", _get_tile_type(current_cell + Vector2i(-1,0)),
		" U=", _get_tile_type(current_cell + Vector2i(0,-1)))
	global_position = _get_cell_center_global(current_cell)

	# Versuch 1: vom aktuellen Tile aus (falls da Rail liegt)
	var tile_type := _get_tile_type(current_cell)
	var options := RailSystem.get_connections(tile_type)
	current_dir = _choose_next_direction(tile_type, options, Vector2.ZERO)

	# Versuch 2: wenn Bahnhof/Spawn-Tile kein Rail ist -> Nachbarn prüfen
	if current_dir == Vector2.ZERO:
		current_dir = _choose_start_direction_from_neighbors(current_cell)

func _choose_start_direction_from_neighbors(cell: Vector2i) -> Vector2:
	# Prüfe Nachbarn in stabiler Reihenfolge (deterministisch)
	var dirs := [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

	for dir: Vector2 in dirs:
		var neighbor := cell + Vector2i(int(dir.x), int(dir.y))
		var neighbor_type := _get_tile_type(neighbor)
		if neighbor_type == -1:
			continue

		# Kann der Nachbar zurück in unsere Zelle?
		var neighbor_conns := RailSystem.get_connections(neighbor_type)
		if neighbor_conns.has(-dir):
			return dir

	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not running or rails == null:
		return

	if current_dir == Vector2.ZERO:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = current_dir * float(speed)
	move_and_slide()

	var cell := rails.local_to_map(rails.to_local(global_position))
	var center := _get_cell_center_global(cell)
	if global_position.distance_to(center) <= snap_distance:
		current_cell = cell
		global_position = center
		_on_reached_tile_center()

func _on_reached_tile_center() -> void:
	var tile_type := _get_tile_type(current_cell)
	var connections := RailSystem.get_connections(tile_type)

	if connections.is_empty():
		current_dir = Vector2.ZERO
		velocity = Vector2.ZERO
		return

	current_dir = _choose_next_direction(tile_type, connections, current_dir)

func _choose_next_direction(tile_type: int, options: Array[Vector2], previous_dir: Vector2) -> Vector2:
	if options.is_empty():
		return Vector2.ZERO

	# Kreuzung: NUR geradeaus (gegenüberliegende Seite)
	if RailSystem.is_cross(tile_type) and previous_dir != Vector2.ZERO:
		if options.has(previous_dir):
			return previous_dir
		# fallback wenn geradeaus aus irgendeinem Grund nicht möglich ist

	# Normalregel: nicht rückwärts, außer es gibt keine Alternative
	var reverse := -previous_dir
	var filtered: Array[Vector2] = []
	for d in options:
		if previous_dir != Vector2.ZERO and d == reverse:
			continue
		filtered.append(d)

	var candidates: Array[Vector2]
	if not filtered.is_empty():
		candidates = filtered
	else:
		candidates = options

	# Deterministisch: geradeaus bevorzugen
	if previous_dir != Vector2.ZERO and candidates.has(previous_dir):
		return previous_dir

	# Deterministische Priorität
	var priority := [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	for p in priority:
		if candidates.has(p):
			return p

	return candidates[0]

func _get_tile_type(cell: Vector2i) -> int:
	var td: TileData = rails.get_cell_tile_data(cell)
	if td == null:
		return -1

	var v = td.get_custom_data("tile_type")
	if typeof(v) == TYPE_INT:
		return int(v)
	return -1

func _get_cell_center_global(cell: Vector2i) -> Vector2:
	var tile_size: Vector2 = Vector2(rails.tile_set.tile_size) # Vector2i -> Vector2
	var local_center: Vector2 = rails.map_to_local(cell) + (tile_size * 0.5)
	return rails.to_global(local_center)

func _on_start_trains() -> void:
	running = true

func _on_stop_trains() -> void:
	queue_free() # oder running = false, je nachdem was du willst
