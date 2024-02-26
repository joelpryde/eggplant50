extends Node2D

onready var crate_prefab = load("res://games/CGOL/Crate.tscn")
const grid_cell_size = 32
const grid_width = 10
const grid_height = 10
var grid = []
var tweens_completed = true

func _ready():
	initialize_grid()
	create_crate(3, 5)
	create_crate(5, 8)
	
func initialize_grid():
	grid = []
	for x in range(grid_width):
		var column = []
		for y in range(grid_height):
			column.append(null)
		grid.append(column)
	
func create_crate(x, y):
	var crate = crate_prefab.instance()
	add_child(crate)
	crate.position = Vector2(x * grid_cell_size, y * grid_cell_size)
	crate.x = x
	crate.y = y
	grid[x][y] = crate

func _process(delta):
	if Input.is_action_just_pressed("action1"):
		run_next_step()
				
func run_next_step():
	print("Running next step")

func tweenCompleted(crate, tween):
	print("all completed")
	tweens_completed = true
	var childCrates = get_children()
	for childCrate in childCrates:
		if childCrate is KinematicBody2D:
			childCrate.reset_pushing()
	
	tween.queue_free()

