extends Node2D

var running_game = false
var tweens_completed = true

func _process(delta):
	if Input.is_action_just_pressed("action1"):
		running_game = true
		
	if running_game == true and tweens_completed:
		print("run next step")
		var childCrates = get_children()
		for childCrate in childCrates:
			if childCrate is KinematicBody2D:
				childCrate.reset_pushing()

func tweenCompleted(crate, tween):
	print("all completed")
	tweens_completed = true
	var childCrates = get_children()
	for childCrate in childCrates:
		if childCrate is KinematicBody2D:
			childCrate.reset_pushing()
	
	tween.queue_free()

