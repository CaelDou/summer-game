class_name Ghost
extends CharacterBody2D

# =====< FEEL FREE TO DELETE/ADD COMMENTS >=====

# references
@onready var game = get_tree().get_root().get_node("Game")
@onready var player = get_node("/root/Game/Player")
@onready var damage_label = load("res://scenes/interface/damage_label.tscn")

# we use AnimationPlayer because it can modify node properties,
# for example we access the Sprite2D's rotation and modulate (color)
# properties to make the animation "hit"
@onready var animation_player = $AnimationPlayer
@onready var sprite2D = $Sprite2D
@onready var hit_particles = $CPUParticles2D
@onready var area2D = $Area2D 

@onready var navigation_agent = $NavigationAgent2D
var target: Node2D = null

# FLEE is flee from light sources
enum State { IDLE, ROAM, CHASE, STAGGER, FLEE, POSSESS, POSSESSING }
var current_state: State
var direction: Vector2
var can: bool = true

# stats
@export var health: int
@export var damage: int
@export var speed: float
@export var poise: int # how many stagger they need before entering STAGGER
@export var hurt_cooldown: float = 0.25
var stagger: int = 0 # track stagger received

var flee_time: float = 0
var hurt_time: float = 0
var was_hit: bool = false

var is_dead = false
var is_possessing = false

# check boundaries so the enemy can't roam around the whole map
var initial_position
@export var boundary: float

#position
func _ready():
	current_state = State.IDLE
	initial_position = global_position

func _process(delta):
	if was_hit:
		hurt_time += delta
		if hurt_time >= hurt_cooldown:
			was_hit = false
			hurt_time = 0

func _physics_process(delta):
	if !is_dead:
		check_states(delta)

func check_states(delta):
	match current_state:
		State.IDLE:
			animation_player.play("walk")
			
			# always checks true, 'can' is reset to true after $Timer expires
			# we set 'can' to false so the timer is started only once
			if can:
				can = false
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.ROAM:
			animation_player.play("walk")
			roam()
			
			# always checks true, 'can' is reset to true after $Timer expires
			# randomize direction only once after setting to WALK
			if can:
				can = false
				randomize_direction()
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.CHASE:
			animation_player.play("walk")
			chase()

		State.STAGGER:
			animation_player.play("stagger")
			check_flip()
			stagger = 0
			# returns to State.CHASE through _on_animation_player_animation_finished()

		State.FLEE:
			animation_player.play("walk")
			flee(delta)

		State.POSSESS:
			animation_player.play("possess")
			if animation_player.current_animation != "possess":
				flee_from(player)
			 #turns target's is_possessed to true when "possess" anim ends

		State.POSSESSING:
			sprite2D.visible = false
			is_possessing = true
			if target.is_dead and target.is_possessed and !target.health <= 0:
				position = target.position
			else:
				target.is_possessed = false
				target.visible = false
				die()

func check_flip():
	if direction.x < 0:
		sprite2D.flip_h = true
	elif direction.x > 0:
		sprite2D.flip_h = false

func roam():
	# check boundaries, e.g. initial_position is (0, 0) and boundary is 50:
	# if position.x is 50 or higher, it shouldn't keep going to the right
	# so we randomize the direction again
	var distance = position.distance_to(initial_position)
	if distance >= boundary:
		direction = (initial_position - position).normalized()
		check_flip()
		
	velocity = direction * speed
	move_and_slide()

func chase():
	if position.distance_to(target.position) <= 10:
		current_state = State.POSSESS
	
	navigation_agent.target_position = target.position
	
	direction = (target.position - position).normalized()
	check_flip()
	
	velocity = direction * speed
	move_and_slide()

func flee(delta):
	if target:
		direction = (position - target.position).normalized()
		check_flip()
		
		velocity = direction * speed
		move_and_slide()
		
		flee_time += delta
		if flee_time >= 8.0:
			flee_time = 0
			current_state = State.IDLE
			
			# reset area so it trigger "on_area_entered" from enemy corpses
			area2D.monitorable = false
			await get_tree().process_frame
			area2D.monitorable = true

# this is just to get the light source position, called by the light source
func flee_from(danger_node: Node2D):
	target = danger_node
	flee_time = 0
	current_state = State.FLEE

func randomize_direction():
	# reset direction so it always enters the while
	direction = Vector2.ZERO
	
	# direction (0, 0) would play the walk animation and not move
	# so we randomize direction until it's not (0, 0) anymore
	while direction == Vector2.ZERO:
		direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
		check_flip()

func take_damage(dmg_amount: int, stg_amount: int): # stagger_amount
	if !was_hit:
		was_hit = true
		
		if current_state != State.STAGGER:
			animation_player.play("hit")
		# get angle to player and invert it so particles play opposite to player
		var angle_to_player = (player.position - position).angle()
		hit_particles.rotation = angle_to_player + PI
		
		stagger += stg_amount
		health -= dmg_amount
		
		var label = damage_label.instantiate()
		game.add_child(label)
		label.pos = global_position + Vector2(0, -50)
		label.set_info(global_position + Vector2(0, -50), dmg_amount)
		
		if health <= 0:
			die()
		elif stagger >= poise:
			stagger = 0
			if current_state != State.STAGGER:
				current_state = State.STAGGER
		
		$Timer.start(2) # if expires, stagger is reset

func die():
	animation_player.play("death")
	is_dead = true
	
	var resource = randi_range(0, 3)
	var amount = randi_range(5, 8)
	GameManager.increase_ingredient(resource, amount)

# ==============< SIGNALS >===============
func _on_timer_timeout():
	# it means our current state's started $Timer expired
	# meaning we spent 1, 2 or 3 seconds on that state, so we change it
	match current_state:
		State.IDLE:
			current_state = State.ROAM
		State.ROAM:
			current_state = State.IDLE
	can = true
	stagger = 0

# ===============< COLLISIONS >===============

# =====< HitArea collisions >=====
func _on_hit_area_body_entered(body):
	if body is Player:
		body.take_damage(damage)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "possess":
		current_state = State.POSSESSING
		target.get_possessed(health, damage)
	elif anim_name == "stagger":
		flee_from(player)
	elif anim_name == "death":
		if target != player:
			target.queue_free()
		queue_free()
