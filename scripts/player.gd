extends CharacterBody2D

@export var speed: float = 100 # max speed
@export var accel: float = 10  # how quickly the player get to max speed

func _physics_process(_delta):
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	velocity.x = move_toward(velocity.x, speed * direction.x, accel)
	velocity.y = move_toward(velocity.y, speed * direction.y, accel)
	
	move_and_slide()
