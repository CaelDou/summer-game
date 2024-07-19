extends CharacterBody2D
class_name Player

# reference to the AnimatedSprite2D node
@onready var anim = $AnimatedSprite2D

# =====< movement >=====
@export var speed: float = 200 # max speed
@export var accel: float = 10  # how quickly the player get to max speed
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

# =====< animation >=====
var direction_anim = {
	Vector2(0, -1): "up",
	Vector2(0, 0): "down", # last_direction is (0, 0) on load
	Vector2(0, 1): "down",
	Vector2(1, 0): "right",
	Vector2(1, 1): "right",
	Vector2(1, -1): "right", 
	Vector2(-1, 0): "left",
	Vector2(-1, 1): "left",
	Vector2(-1, -1): "left"
}

func _process(_delta):
	# update last_direction until the player stops
	if direction != Vector2.ZERO:
		last_direction = direction
	
	# check the direction to handle animations
	if direction == Vector2.ZERO:
		anim.play("idle_" + direction_anim[last_direction])
	else:
		anim.play("walk_" + direction_anim[direction])

func _physics_process(_delta):
	# get the input direction in a Vector2, so left would be (-1, 0)
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# handle movement
	if direction != Vector2.ZERO:
		# normalize so the player doesn't go faster diagonally
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
