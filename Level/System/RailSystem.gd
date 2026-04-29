class_name RailSystem
extends RefCounted

const DIR_UP := Vector2(0, -1)
const DIR_DOWN := Vector2(0, 1)
const DIR_LEFT := Vector2(-1, 0)
const DIR_RIGHT := Vector2(1, 0)

static func is_cross(tile_type: int) -> bool:
	return tile_type == 6

static func get_connections(tile_type: int) -> Array[Vector2]:
	# IMPORTANT:
	# I don’t yet have your exact tile_type IDs → shapes mapping.
	# Replace the match cases below with your real IDs.
	#
	# Expected categories:
	# - straight horizontal: [L, R]
	# - straight vertical: [U, D]
	# - corner: 2 dirs (e.g. [U, R])
	# - T-junction: 3 dirs
	# - crossing: 4 dirs

	match tile_type:
		# Example placeholders (YOU MUST map these to your actual tile_type values)
		0: # prell up
			return [DIR_DOWN]
		1: # corner right-down
			return [DIR_RIGHT, DIR_DOWN]
		2: # T missing up (has L,R,D)
			return [DIR_LEFT, DIR_RIGHT, DIR_DOWN]
		3: # corner down-left
			return [DIR_DOWN, DIR_LEFT]
		
		4: # vertical
			return [DIR_DOWN, DIR_RIGHT]
		5: # T missing left (has U,R,D)
			return [DIR_UP, DIR_RIGHT, DIR_DOWN]
		6: # crossing (4-way)
			return [DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT]
		7: # T missing right (has U,D,L)
			return [DIR_UP, DIR_DOWN, DIR_LEFT]
		
		8: #prell down
			return [DIR_UP]
		9: # corner up-right
			return [DIR_UP, DIR_RIGHT]
		10: # T missing down (has U,L,R)
			return [DIR_UP, DIR_LEFT, DIR_RIGHT]
		11: # corner left-up
			return [DIR_LEFT, DIR_UP]
		
		12: #roundabout
			return []
		13: #prell left
			return [DIR_RIGHT]
		14: # horizontal
			return [DIR_LEFT, DIR_RIGHT]
		15: #prell right
			return [DIR_LEFT]
		
		_:
			return []
