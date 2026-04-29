class_name Holder 
extends Node2D
@export_file("*.tscn") var tile_path

var childs: Array = []

#Muss aus obv gründen gleich lang sein
@export var MISSION_ONE:Array = []
@export var MISSION_ONE_TIMES:Array = []

func _ready() -> void:
	activate_certain_tiles(MISSION_ONE)
	#TODO set here the different tile types
	pass


func activate_certain_tiles(tiles:Array) -> void:
	var tile_scene = load("res://TileHolder/SelectTile/Tile.tscn")
	var grid = $ColorRect/GridContainer
	for i in range(tiles.size()):
		var tile_to_activate:int = tiles.pop_front()
		
		var map:Dictionary
		
		var tile_instance = tile_scene.instantiate() as SelectTile
		tile_instance.set_tile(tile_to_activate)
		tile_instance.set_times(MISSION_ONE_TIMES.pop_front())
		
		map = {
		"key": tile_to_activate,
		"value": tile_instance
		}
		
		var target = grid.get_child(tile_to_activate)
		target.add_child(tile_instance)
		childs.append(map)
