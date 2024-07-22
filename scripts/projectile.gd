extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var speed: float = 500

var direction: Vector2 = Vector2.ZERO
var life_time: float = 3
var time: float

func _process(delta):
	time += delta
	if time >= life_time:
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_hit_area_area_entered(area):
	if area.owner is NigredoEnemy and area.name == "HurtArea":
		area.owner.take_damage(GameManager.current_damage, GameManager.current_stagger)
		queue_free()

func _on_hit_area_body_entered(body):
	queue_free()
