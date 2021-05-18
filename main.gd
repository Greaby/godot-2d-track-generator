extends Node2D

signal generation_completed

enum CELLS {
	EMPTY = -1, 
	LOCK = -2, 
}

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

export (Rect2) var track_rect := Rect2(Vector2(0,0), Vector2(16, 9))
export (bool) var generation_debug := false
export (float, 0.0, 1.0) var generation_delay := 0.1

export (int, 1, 10) var last_direction_priority := 0

export (int, 4, 100) var min_length := 15
export (int) var max_length := 80

export (int, 0, 10) var margin := 0

var track := []

var in_progress := false
var stop_generation := false

var last_direction : Vector2

var end_position : Vector2

onready var track_map := $TrackMap

func _ready() -> void:
	assert(min_length < max_length)
	
	randomize()
	generate()
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		
		if in_progress:
			stop_generation = true
			yield(self, "generation_completed")

		generate()


func generate() -> void:
	# init variable
	in_progress = true
	track_map.clear()
	track = []
	
	
	# start position
	var start_position = Vector2(randi() % int(track_rect.size.x - 2) + 1, randi() % int(track_rect.size.y - 2) + 1)
	track.push_back(start_position)
	
	var position = next_position()
	track.push_back(position)
	
	end_position = start_position - last_direction

	if last_direction == Vector2.UP or last_direction == Vector2.DOWN:
		track_map.set_cellv(start_position, track_map.tile_set.find_tile_by_name("start_vertical"))
	
	if last_direction == Vector2.LEFT or last_direction == Vector2.RIGHT:
		track_map.set_cellv(start_position, track_map.tile_set.find_tile_by_name("start_horizontal"))
	
	
	# generate track
	while !stop_generation and position != end_position:
		position = next_position()
		track.push_back(position)
		if track.size() > 2:
			draw_cell(track[-2], track[-3], track[-1])
		
		if generation_debug:
			yield(get_tree().create_timer(generation_delay), "timeout")
	
	# draw last cell with start_position
	draw_cell(track[-1], track[-2], track[0])


	if !stop_generation and (track.size() < min_length or track.size() > max_length):
		return generate()
	
	stop_generation = false
	in_progress = false
	emit_signal("generation_completed")


func next_position() -> Vector2:
	var position = track[-1]
	var directions := get_available_directions(position)
	
	if directions.size() == 0:
		rollback()
		return next_position()
	
	last_direction = directions[randi() % directions.size()]
	var next_position = position + last_direction
		
	return next_position
	
	
func draw_cell(cell: Vector2, prev_cell: Vector2, next_cell: Vector2) -> void:
	var next_direction = cell.direction_to(next_cell)
	var prev_direction = cell.direction_to(prev_cell)

	match [prev_direction, next_direction]:
		[Vector2.UP, Vector2.RIGHT], [Vector2.RIGHT, Vector2.UP]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("up_right"))
		[Vector2.UP, Vector2.DOWN], [Vector2.DOWN, Vector2.UP]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("vertical"))
		[Vector2.UP, Vector2.LEFT], [Vector2.LEFT, Vector2.UP]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("up_left"))
		[Vector2.RIGHT, Vector2.DOWN], [Vector2.DOWN, Vector2.RIGHT]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("down_right"))
		[Vector2.RIGHT, Vector2.LEFT], [Vector2.LEFT, Vector2.RIGHT]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("horizontal"))
		[Vector2.DOWN, Vector2.LEFT], [Vector2.LEFT, Vector2.DOWN]:
			track_map.set_cellv(cell, track_map.tile_set.find_tile_by_name("down_left"))

func rollback() -> void:
	var position = track.pop_back()
	track_map.set_cellv(position, CELLS.LOCK)
	
	
func get_available_directions(position: Vector2) -> Array:
	var available_directions := []
	
	var directions = DIRECTIONS.duplicate()
	
	if last_direction_priority != 0:
		for i in last_direction_priority:
			directions.push_back(last_direction)
	
	for direction in directions:
		var test_position = position + direction
		if track_map.get_cellv(test_position) == CELLS.EMPTY and track_rect.has_point(test_position):
			available_directions.push_back(direction)
	
	return available_directions
	
