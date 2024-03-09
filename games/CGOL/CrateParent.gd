extends Node2D

onready var crate_prefab = load("res://games/CGOL/Crate.tscn")
onready var fill_prefab = load("res://games/CGOL/Fill.tscn")
onready var constants = load("res://games/CGOL/Constants.gd")
onready var audio_player = get_parent().get_node("AudioStreamPlayer")
onready var player = get_parent().get_node("Player")
var tweens_completed = true
var filled = {}

func _ready():
	create_crate(2, 2)
	create_crate(1, 3)
	create_crate(1, 4)
	create_crate(3, 3)
	create_crate(4, 4)
	create_crate(2, 4)

func position_key(x, y):
	return str(x) + "," + str(y)

func crate_key(crate):
	return position_key(crate.x, crate.y)
	
func build_grid():
	var grid = {}
	for childCrate in get_children():
		if childCrate is KinematicBody2D:
			grid[crate_key(childCrate)] = childCrate
	return grid
	
func create_crate(x, y):
	var crate = crate_prefab.instance()
	add_child(crate)
	crate.position = Vector2(x * constants.grid_cell_size, y * constants.grid_cell_size)
	crate.x = x
	crate.y = y
	create_fill(x, y)
		
func create_fill(x, y):
	if filled.has(position_key(x, y)):
		return
	filled[position_key(x, y)] = true
	var fill = fill_prefab.instance()
	fill.z_index = 1
	add_child(fill)
	fill.position = Vector2(x * constants.grid_cell_size, y * constants.grid_cell_size)
	
func _process(_delta):
	if Input.is_action_just_pressed("action1"):
		run_next_step()
	elif Input.is_action_just_pressed("action2"):
		reset_grid()

func reset_grid():
	print("resetting grid")
	filled = {}
	for childCrate in get_children():
		childCrate.queue_free()
	_ready()

func get_neighbors(grid, x, y):
	var neighbors = []
	for i in range(-1, 2):
		for j in range(-1, 2):

			if i == 0 and j == 0:
				continue

			var key = position_key(x + i, y + j)
			if (grid.has(key)):
				neighbors.append(grid[key])
				
	return neighbors
				
func run_next_step():
	print("Running next step")
	audio_player.play()
	var grid = build_grid()
	
	# TODO: Need to check empty grid squares
	for x in range(0, constants.grid_width+1):
		for y in range(0, constants.grid_height+1):
			var neighbors = get_neighbors(grid, x, y)
			var live_neighbors = 0
			for neighbor in neighbors:
				live_neighbors += 1
			if live_neighbors < 2 or live_neighbors > 3:
				var key = position_key(x, y)
				if (	grid.has(key)):
					grid[key].queue_free()
			else:
				if live_neighbors == 3:
					# Don't create crate if player is in this space!
					var player_pos = player.get_position()
					if player_pos[0] == x and player_pos[1] == y:
						print("Player is in this space")
						continue

					var key = position_key(x, y)
					if (!grid.has(key)):
						create_crate(x, y)

func tweenCompleted(_crate, tween):
	print("all completed")
	tweens_completed = true
	for childCrate in get_children():
		if childCrate is KinematicBody2D:
			if (childCrate.is_pushing):
				childCrate.reset_pushing()
				create_fill(childCrate.x, childCrate.y)

	tween.queue_free()

	run_next_step()

