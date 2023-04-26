extends Node2D


#onready var Monster = preload("res://Assets/Monster/Monster.tscn")
#onready var Monster2 = preload("res://Assets/Monster/Monster2.tscn")

const N = 0x1
const E = 0x2
const S = 0x4
const W = 0x8


var direction = {E: Vector2(1, 0), W: Vector2(-1, 0), S: Vector2(0, 1), N: Vector2(0, -1)}
var cell_walls = {Vector2(1, 0): E, Vector2(-1, 0): W,  Vector2(0, 1): S, Vector2(0, -1): N}
var direction_vertical = {direction[E]:direction[N], direction[W]:direction[N],
						  direction[N]:direction[E], direction[S]:direction[E]}

# maps the cell_index to the walls representation
var cell_walls_map = {
7: 2+8, 8:0, 9: 1+4, 11: 4+8, 12: 1+8, 13:1+2, 14:0, 15:2+4, 16:2+4, 17:4+8, 
18:1+8, 19:1+2, 20:0, 21: 2+8, 22: 1+4,
23: 1+2+8
#0: 0, 1: 2+8, 2: 1+4, 3: 2+4, 4: 4+8, 5: 1+8, 6: 1+2, 24: 1+2+8, 25: 2+4+8
}
# starts: 23: 1+2+8, 27: 1+4+8
# ends:   25: 1+2+8, 28: 1+4+8

var width = 4  # width of map (in tiles)
var height = 5  # height of map (in tiles)
var MAP_LENGTH = 10

var CORIDOR_WIDTH = 3 # 3x2 + 1
var SEED = 11


func _ready():
	seed(SEED)
	var visited = []
	var level_tiles = []
	var level_edge_tiles = []
	var level_edge_positions = []
	
	
	# add starting block and position player next to it
	var current = Vector2(0,0)
	$Start.position = Vector2(256, 256)
	$TileMap.set_cellv(current + direction[E], 23)
	visited.append(current + direction[E])
	current += 2*direction[E] + direction[S]
	
	# hardcoded starting direction
	var random_direction = direction[W]
	
	# create initial path
	for i in range(MAP_LENGTH):
		# 20% chance to switch direction
		if randi() % 100 < 10:
			var valid_directions = find_unvisited_directions(current, visited)
			if valid_directions.size() == 0:
				random_direction = direction.values()[randi() % 4]
			else:
				random_direction = valid_directions[randi() % valid_directions.size()]

		# add positions to generate tiles on
		var vertical_direction = direction_vertical[random_direction]
		# one direction
		for j in range(CORIDOR_WIDTH):
			level_tiles.append(vertical_direction*(j+1) + current)
			level_tiles.append(-vertical_direction*(j+1) + current)

		# edge positions
		level_edge_positions.append(vertical_direction*(CORIDOR_WIDTH+1) + current)
		level_edge_positions.append(-vertical_direction*(CORIDOR_WIDTH+1) + current)

		# edge tiles
		if random_direction == direction[N] or random_direction == direction[S]:
			level_edge_tiles.append(9)
			level_edge_tiles.append(9)
		else:
			level_edge_tiles.append(7)
			level_edge_tiles.append(7)

		current += random_direction
		$TileMap.set_cellv(current, 8)
		visited.append(current)

	
	# vertical direction to finish direction
	var vertical_direction = direction_vertical[random_direction]

	# add edge walls for last position
	for j in range(CORIDOR_WIDTH+1):
		level_edge_positions.append(vertical_direction*(j+1) + current)
		level_edge_positions.append(-vertical_direction*(j+1) + current)

		if random_direction == direction[N] or random_direction == direction[S]:
			level_edge_tiles.append(7)
			level_edge_tiles.append(7)
		else:
			level_edge_tiles.append(9)
			level_edge_tiles.append(9)

	
	# fill the map with random tiles
	for level_tile in level_tiles:
		if visited.has(level_tile):
			continue

		var valid_tiles = find_valid_tiles(level_tile, 23)
		var num_valid = valid_tiles.size()
		if num_valid > 0:
			var random_number = randi() % num_valid
			var random_valid_tile = valid_tiles[random_number]
			$TileMap.set_cellv(level_tile, cell_walls_map.keys()[random_valid_tile])
			visited.append(level_tile)
#
#	# fill not visited with floor
#	for level_tile in level_tiles:
#		if not visited.has(level_tile):
#			$TileMap.set_cellv(level_tile, 8)
#
#	# add map edges
#	for i in range(level_edge_positions.size()):
#		var level_edge_position = level_edge_positions[i]
#		var level_edge_tile = level_edge_tiles[i]
#
#		if level_edge_position in visited:
#			continue
#
#		$TileMap.set_cellv(level_edge_position, level_edge_tile)
#		visited.append(level_edge_position)
	
	# set Start and Finish
	var finish_position = $TileMap.map_to_world(current)
	$Finish.position = finish_position + Vector2(180/2,256/2)
	
	



func find_unvisited_directions(current, visited):
	var valid_directions = []
	for dir in direction.values():
		if not visited.has(dir+current):
			valid_directions.append(dir)
	return valid_directions


func select_by_weighted_probability(list, ratios):
	# len(list) == len(ratios) - 1
	var random_float = randf()

	if random_float < 0.8:
		# 80% chance of being returned.
		return "Common"
	elif random_float < 0.95:
		# 15% chance of being returned.
		return "Uncommon"
	else:
		# 5% chance of being returned.
		return "Rare"
	
#	# make starting square
#	for x in range(width):
#		if not visited.has(Vector2(x,0)):
#			$TileMap.set_cellv(Vector2(x,0), 7)
#			visited.append(Vector2(x,0))
#
#		if not visited.has(visited.has(Vector2(x,height-1))):
#			$TileMap.set_cellv(Vector2(x,height-1), 7)
#			visited.append(Vector2(x,height-1))
#
#	for y in range(height):
#		if not visited.has(Vector2(0,y)):
#			$TileMap.set_cellv(Vector2(0,y), 9)
#			visited.append(Vector2(0,y))
#
#		if not visited.has(Vector2(width-1,y)):
#			$TileMap.set_cellv(Vector2(width-1,y), 9)
#			visited.append(Vector2(width-1,y))
#
#	# make starting edges
#	$TileMap.set_cellv(Vector2(0,0), 16)
#	$TileMap.set_cellv(Vector2(0,height-1), 13)
#	$TileMap.set_cellv(Vector2(width-1,0), 17)
#	$TileMap.set_cellv(Vector2(width-1,height-1), 12)
#
#	visited.append(Vector2(0,0))
#	visited.append(Vector2(0,height-1))
#	visited.append(Vector2(width-1,0))
#	visited.append(Vector2(width-1,height-1))
#	visited.append(Vector2(current + direction[E]))
##
##
#
#	for x in get_random_numbers(0, width):
#		for y in get_random_numbers(0, height):
#			current = Vector2(x,y)
#			if visited.has(current):
#				continue
#			var valid_tiles = find_valid_tiles(current, 23)
#
#			var num_valid = valid_tiles.size()
#			if num_valid > 0:
#				var random_number = randi() % num_valid
#				var random_valid_tile = valid_tiles[random_number]
#				$TileMap.set_cellv(current, cell_walls_map.keys()[random_valid_tile])
#				visited.append(current)
##
#
#
#	# fill not visited with floor
#	for x in range(width):
#		for y in range(height):
#			current = Vector2(x,y)
#			if not visited.has(current):
#				$TileMap.set_cellv(Vector2(x,y), 0)
#
#
#
#
func find_valid_tiles(cell, start_value=23):
	var valid_tiles = []
	# check all possible tiles, 0 - N
	for i in range(cell_walls_map.keys().size()):
		# check the target space's neighbors (if they exist)
		var is_match = false
		for n in cell_walls.keys():
			var neighbor_id = $TileMap.get_cellv(cell + n)
			# skip blank -1 tile
			if neighbor_id >= 0:
				# convert ID to wall value 4bit representation
				neighbor_id = cell_walls_map[neighbor_id]

				if (neighbor_id & cell_walls[-n])/cell_walls[-n] == (cell_walls_map[cell_walls_map.keys()[i]] & cell_walls[n])/cell_walls[n]:
					is_match = true
				else:
					is_match = false
					# if we found a mismatch, we don't need to check the remaining sides
					break
		if is_match and not i in valid_tiles:
			if cell_walls_map.keys()[i] != start_value:
				valid_tiles.append(i)
	return valid_tiles
#
#
func get_random_numbers(from, to):
	var arr = []
	for i in range(from,to):
		arr.append(i)
	arr.shuffle()
	return arr



