extends Sprite2D

@onready var animation_player = $AnimationPlayer

@export var damage: int = 2
@export var stagger: int = 2
@export var cooldown: float = 0.5
var time_passed: float = 0
var can_attack: bool = true

func _process(delta):
	if Input.is_action_just_pressed("m1"):
		if can_attack:
			can_attack = false
			$Timer.start(cooldown)
			animation_player.play("slash")

func _on_area_2d_body_entered(body):
	if body is NigredoEnemy:
		body.take_damage(GameManager.current_damage, GameManager.current_stagger)

func _on_timer_timeout():
	can_attack = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slash":
		animation_player.play("RESET")
