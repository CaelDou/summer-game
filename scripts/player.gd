extends CharacterBody2D
class_name Player

#const Player = preload("res://scripts/player.gd")

# =====< references >=====
@onready var game = get_tree().get_root().get_node("Game")
@onready var damage_label = load("res://scenes/interface/damage_label.tscn")
@onready var anim = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var item_holder = $ItemHolder
var held_item = null
#@onready var inventory: Control = $Inventory_UI

# to test if get and update held_weapon work
@onready var weapon_wand = load("res://scenes/weapons/weapon_wand.tscn")
@onready var weapon_sword = load("res://scenes/weapons/weapon_sword.tscn")

# =====< stats >=====
@export var health: int = 20
@export var base_damage: int = 0
@export var base_stagger: int = 0
@export var speed: float = 300 # max speed
var was_hit = false

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

func _ready():
	GameManager.update_health(health)

func _process(_delta):
	#handle_inventory()
	
	# update last_direction until the player stops
	if direction != Vector2.ZERO:
		last_direction = direction
	
	# check the direction to handle animations
	if direction == Vector2.ZERO:
		anim.play("idle_" + direction_anim[last_direction])
	else:
		anim.play("walk_" + direction_anim[direction])
	
	if held_item != null and held_item.name.begins_with("Weapon"):
		GameManager.current_damage = base_damage + held_item.damage
		GameManager.current_stagger = base_stagger + held_item.stagger
	else:
		GameManager.current_damage = base_damage
		GameManager.current_stagger = base_stagger
	
	# everywhere you call update_held_weapon, you have to instantiate
	# the new_weapon as in update_held_weapon(new_weapon.instantiate())
	if Input.is_action_just_pressed("ctrl"):
		update_held_item(weapon_wand.instantiate())
	if Input.is_action_just_pressed("shift"):
		update_held_item(weapon_sword.instantiate())

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

func take_damage(dmg_amount: int):
	if !was_hit:
		was_hit = true
		
		health -= dmg_amount
		
		var label = damage_label.instantiate()
		game.add_child(label)
		label.pos = global_position + Vector2(0, -50)
		label.set_info(global_position + Vector2(0, -50), dmg_amount)
		
		if health <= 0:
			animation_player.play("death")
		else:
			animation_player.play("hit")
			GameManager.update_health(health)
		$Timer.start(2) # if expires, stagger is reset

func get_held_item():
	if item_holder.get_child_count() > 0:
		held_item = item_holder.get_child(0)
	else:
		held_item = null

# this could be connected to a signal 
# removes held_weapon from weapon_holder and adds parameter to it
# HAVE TO INSTANTIATE new_weapon
func update_held_item(new_item: Node):
	if held_item != null:
		item_holder.remove_child(held_item)
	
	held_item = new_item
	item_holder.add_child(held_item)
	item_holder.get_item_sprite()

#func handle_inventory():
	#if Input.is_action_just_pressed("tab"):
		#if !inventory.is_open:
			#inventory.open_inventory()
		#else:
			#inventory.close_inventory()

func _on_timer_timeout():
	was_hit = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		get_tree().reload_current_scene()
