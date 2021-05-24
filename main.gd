extends Node2D

onready var checkpoint_container := $Checkpoints
onready var track_generator := $TrackGenerator
onready var track_map := $TrackMap


func _ready() -> void:
	randomize()
	
	track_generator.connect("generation_finished", self, "_on_track_generated")
	track_generator.generate()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		
		# Makes sure to stop the generation of the track
		var stop = track_generator.stop()
		if stop is GDScriptFunctionState:
			yield(stop, "completed")
		
		reset_track()
		track_generator.generate()


func _on_track_generated(track: Array) -> void:
	reset_track()
	create_road(track)
	create_checkpoints(track)


func create_road(track: Array) -> void:
	for index in track.size():
		var position = track[index]
		
		var next_direction = position.direction_to(track[(index + 1) % track.size()])
		var prev_direction = position.direction_to(track[index - 1])

		match [index, prev_direction, next_direction]:
			[0, Vector2.UP, _], [0, Vector2.DOWN, _]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("start_vertical"))
			[0, Vector2.RIGHT, _], [0, Vector2.LEFT, _]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("start_horizontal"))
			[_, Vector2.UP, Vector2.RIGHT], [_, Vector2.RIGHT, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("up_right"))
			[_, Vector2.UP, Vector2.DOWN], [_, Vector2.DOWN, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("vertical"))
			[_, Vector2.UP, Vector2.LEFT], [_, Vector2.LEFT, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("up_left"))
			[_, Vector2.RIGHT, Vector2.DOWN], [_, Vector2.DOWN, Vector2.RIGHT]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("down_right"))
			[_, Vector2.RIGHT, Vector2.LEFT], [_, Vector2.LEFT, Vector2.RIGHT]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("horizontal"))
			[_, Vector2.DOWN, Vector2.LEFT], [_, Vector2.LEFT, Vector2.DOWN]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("down_left"))


func create_checkpoints(track: Array) -> void:
	for position in track:
		var checkpoint_scene = load("res://road/checkpoint.tscn").instance()
		checkpoint_scene.position = position * track_map.cell_size
		checkpoint_container.add_child(checkpoint_scene)


func reset_track() -> void:
	track_map.clear()
	for checkpoint in checkpoint_container.get_children():
		checkpoint.queue_free()
