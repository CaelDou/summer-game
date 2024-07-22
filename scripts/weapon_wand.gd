extends Sprite2D

@onready var game = get_tree().get_root().get_node("Game")
@onready var projectile = load("res://scenes/projectiles/test.tscn")

@export var damage: int = 1
@export var stagger: int = 1
@export var cooldown: float = 0.5
var time_passed: float = 0.0

func _process(delta):
	time_passed += delta
	
	if Input.is_action_just_pressed("m1"):
		if time_passed >= cooldown:
			shoot()

func shoot():
	time_passed = 0
	var instance = projectile.instantiate()
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - global_position).normalized()
	
	instance.global_position = global_position + direction_to_mouse * 30
	instance.direction = direction_to_mouse
	instance.rotation = direction_to_mouse.angle()
	
	game.add_child.call_deferred(instance)
