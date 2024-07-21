extends CharacterBody2D
class_name Player

const Player = preload("res://scripts/player.gd")

# =====< references >=====
@onready var game = get_tree().get_root().get_node("Game")
@onready var anim = $AnimatedSprite2D
@onready var weapon_holder = $WeaponHolder
var held_weapon = null

# to test if get and update held_weapon work
@onready var weapon_wand = load("res://scenes/weapons/weapon_wand.tscn")

# =====< stats >=====
@export var health: int = 10
@export var base_damage: int = 1 
@export var speed: float = 300 # max speed

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
	
	if held_weapon != null:
		GameManager.current_damage = base_damage + held_weapon.damage
	else:
		GameManager.current_damage = base_damage
	
	# everywhere you call update_held_weapon, you have to instantiate
	# the new_weapon as in update_held_weapon(new_weapon.instantiate())
	if Input.is_action_just_pressed("m1"):
		update_held_weapon(weapon_wand.instantiate())

func _physics_process(_delta):
	# get the input direction in a Vector2, so left would be (-1, 0)
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# handle movement
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		pass # replace with die

func get_held_weapon():
	if weapon_holder.get_child_count() > 0:
		held_weapon = weapon_holder.get_child(0)
	else:
		held_weapon = null

# this could be connected to a signal 
# removes held_weapon from weapon_holder and adds parameter to it
# HAVE TO INSTANTIATE new_weapon
func update_held_weapon(new_weapon: Node):
	if held_weapon != null:
		weapon_holder.remove_child(held_weapon)
	
	held_weapon = new_weapon
	weapon_holder.add_child(held_weapon)
	weapon_holder.get_weapon_sprite()
