extends Node


signal create_new_tile(tile_type: Resource)
signal move_tile(tile_type: Resource)
signal remove_tile(tile_type: Resource)
signal start_trains()
signal stop_trains()
signal train_reached_station(train_type: Enum.TrainType)
