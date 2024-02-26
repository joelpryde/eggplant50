extends KinematicBody2D

var pushing = false
onready var tween = get_parent().get_parent().get_node("Tween")
onready var world = get_node("/root/CGLO_World")
onready var crateParent = get_node("/root/CGLO_World/CrateParent")

func reset_pushing():
	pushing = false

func push(direction):
	if pushing:
		return
	if test_move(transform, direction * 32):
		return
	
	pushing = true
	var newTween = Tween.new()
	world.add_child(newTween)
	newTween.connect("tween_all_completed", crateParent, 
		"tweenCompleted", [self, newTween])
	newTween.interpolate_property(
		self, "position",
		position, position + direction * 32,
		0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	newTween.start()
