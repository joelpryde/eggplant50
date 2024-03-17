extends Node2D

onready var crate_prefab = load("res://games/CGOL/Crate.tscn")
onready var fill_prefab = load("res://games/CGOL/Fill.tscn")
onready var constants = load("res://games/CGOL/Constants.gd")
onready var audio_player = get_parent().get_node("AudioStreamPlayer")
onready var player = get_parent().get_node("Player")
onready var fill_parent = get_parent().get_node("FillParent")
var tweens_completed = true
var filled = {}

func create_box_level():
	var create_crate_start = 2
	var create_crate_end = 5
	for i in range(create_crate_start, create_crate_end+1):
		create_crate(create_crate_start, i)
		create_crate(create_crate_end, i)
		create_crate(i, create_crate_start)
		create_crate(i, create_crate_end)

    # left top
	create_fill(2,1)
	create_fill(2,2)
	create_fill(1,2)

	# right top
	create_fill(5,1)
	create_fill(5,2)
	create_fill(6,2)

	# bottom left
	create_fill(2,6)
	create_fill(2,5)
	create_fill(1,5)

	# bottom right
	create_fill(5,6)
	create_fill(5,5)
	create_fill(6,5)

func create_cross_level():
	create_crate(3, 4)
	create_crate(4, 4)
	create_crate(5, 3)
	create_fill(4, 3)
	create_fill(4, 4)
	create_fill(4, 5)

func _ready():
	create_box_level()

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
	print("Creating crate at " + str(x) + ", " + str(y))
	var crate = crate_prefab.instance()
	add_child(crate)
	crate.position = Vector2(x * constants.grid_cell_size, y * constants.grid_cell_size)
	crate.x = x
	crate.y = y
		
func create_fill(x, y):
	print("Creating fill at " + str(x) + ", " + str(y))
	if filled.has(position_key(x, y)):
		return
	filled[position_key(x, y)] = true
	var fill = fill_prefab.instance()
	fill.z_index = 1
	fill_parent.add_child(fill)
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
	
	for x in range(0, constants.grid_size+1):
		for y in range(0, constants.grid_size+1):

			if (x < 1 or x >= constants.grid_size or y < 1 or y > constants.grid_size):
				continue

			var neighbors = get_neighbors(grid, x, y)
			
			if neighbors.size() < 2 or neighbors.size() > 3:	# Death case
				var key = position_key(x, y)
				if (grid.has(key)):
					print("Killing crate at " + str(x) + ", " + str(y))
					grid[key].queue_free()
			else:
				if neighbors.size() == 3: # Birth case
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
		if childCrate is Crate:
			if (childCrate.is_pushing):
				childCrate.reset_pushing()

	tween.queue_free()

	run_next_step()

