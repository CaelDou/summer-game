extends Marker2D

@onready var animation_player = $AnimationPlayer

@export var damage: int = 2
@export var stagger: int = 2
@export var cooldown: float = 0.5
var time_passed: float = 0
var can_attack: bool = true

@export var weapon_scale: float

func _process(_delta):
	if Input.is_action_just_pressed("m1"):
		if can_attack:
			can_attack = false
			$Timer.start(cooldown)
			animation_player.play("slash")

func _physics_process(_delta):
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	
	if mouse_position.x - global_position.x < 0.0:
		scale.y = -weapon_scale
	else:
		scale.y = weapon_scale

#func _on_area_2d_body_entered(body):
	#if body is NigredoEnemy:
		#body.take_damage(GameManager.current_damage, GameManager.current_stagger)

func _on_timer_timeout():
	can_attack = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slash":
		animation_player.play("RESET")

func _on_area_2d_area_entered(area):
	if area.owner is NigredoEnemy and area.name == "HitArea":
		area.owner.take_damage(GameManager.current_damage, GameManager.current_stagger)
