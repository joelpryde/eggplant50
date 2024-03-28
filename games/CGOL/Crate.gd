class_name Crate
extends KinematicBody2D

var is_pushing = false

onready var tween = get_parent().get_parent().get_node("Tween")
onready var world = get_node("/root/CGLO_World")
onready var crateParent = get_node("/root/CGLO_World/CrateParent")
var x = 0
var y = 0

func reset_pushing():
	is_pushing = false

func push(direction):
	if is_pushing:
		print("already pushing")
		return

	if test_move(transform, direction * 32):
		print("can't move from " + str(position) + " to " + str(position + direction * 32))
		return
	
	is_pushing = true

	var newTween = Tween.new()
	world.add_child(newTween)

	newTween.connect("tween_all_completed", crateParent, 
		"tweenCompleted", [self, newTween])

	newTween.interpolate_property(
		self, "position",
		position, position + direction * 32,
		0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	x += direction.x
	y += direction.y

	newTween.start()
