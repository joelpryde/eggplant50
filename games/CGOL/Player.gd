extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 150

func _process(delta):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2.RIGHT
		$AnimatedSprite.play("right")
		
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT
		$AnimatedSprite.play("left")
		
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP
		$AnimatedSprite.play("up")
		
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN
		$AnimatedSprite.play("down")
		
	if Input.is_action_just_released("ui_left") or \
		Input.is_action_just_released("ui_right") or \
		Input.is_action_just_released("ui_up") or \
		Input.is_action_just_released("ui_down"):
		$AnimatedSprite.stop()
			 
	var collision = move_and_collide(velocity * speed * delta)
	if collision:
		var node = collision.collider
		if (node is KinematicBody2D):
			node.push(velocity)
