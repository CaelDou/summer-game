extends CharacterBody2D
class_name NigredoEnemy

# =====< FEEL FREE TO DELETE/ADD COMMENTS >=====

# references
@onready var game = get_tree().get_root().get_node("Game")
@onready var player = get_node("/root/Game/Player")
@onready var damage_label = load("res://scenes/interface/damage_label.tscn")
@onready var animated_sprite = $AnimatedSprite2D
@onready var mark_anim = $MarkAnimatedSprite2D

# we use AnimationPlayer because it can modify node properties,
# for example we access the Sprite2D's rotation and modulate (color)
# properties to make the animation "hit"
@onready var animation_player = $AnimationPlayer
@onready var sprite2D = $Sprite2D
@onready var hit_particles = $CPUParticles2D
 
@onready var navigation_agent = $NavigationAgent2D
var target: Node2D = null

# FLEE is flee from light sources
enum State { IDLE, ROAM, ALARMED, CHASE, STAGGER, FLEE }
var current_state: State
var direction: Vector2
var can: bool = true

# stats
@export var health: int
@export var damage: int
@export var speed: float
@export var attention: float # how long enemy stays on State.ALARMED
@export var poise: int # how many stagger they need before entering STAGGER
@export var hurt_cooldown: float = 0.25
var stagger: int = 0 # track stagger received
var persistance: float = 5 # how long will continue chasing after far from player

var attention_time: float = 0 # track time that passed
var flee_time: float = 0

var hurt_time: float = 0
var was_hit: bool = false

var persist_time: float = 0
var persist: bool = false

var is_dead = false
var is_possessed = false # works as a second life if ghost possesses

# check boundaries so the chicken can't roam around the whole map
var initial_position
@export var boundary: float

func _ready():
	mark_anim.play("empty_anim")
	current_state = State.IDLE
	initial_position = position

func _process(delta):
	if was_hit:
		hurt_time += delta
		if hurt_time >= hurt_cooldown:
			was_hit = false
			hurt_time = 0

func _physics_process(delta):
	if !is_dead or is_possessed:
		check_states(delta)

func check_states(delta):
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
			mark_anim.play("empty_anim")
			attention_time = 0
			persist = false
			persist_time = 0
			
			# always checks true, 'can' is reset to true after $Timer expires
			# we set 'can' to false so the timer is started only once
			if can:
				can = false
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.ROAM:
			animated_sprite.play("walk")
			mark_anim.play("empty_anim")
			roam()
			
			# always checks true, 'can' is reset to true after $Timer expires
			# randomize direction only once after setting to WALK
			if can:
				can = false
				randomize_direction()
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.ALARMED:
			animated_sprite.play("alarmed")
			mark_anim.play("question")
			
			# add time passed to attention_time
			attention_time += delta
			if(attention_time >= attention):
				# reset for the next ALARMED state and enter CHASE
				attention_time = 0
				current_state = State.CHASE

		State.CHASE:
			animated_sprite.play("walk")
			if mark_anim.animation != "empty_anim":
				mark_anim.play("exclamation")
			
			chase()
			
			if persist:
				persist_time += delta
				if persist_time >= persistance:
					persist = false
					current_state = State.IDLE

		State.STAGGER:
			mark_anim.play("empty_anim")
			animation_player.play("stagger")
			check_flip()
			stagger = 0
			# returns to State.CHASE through _on_animation_player_animation_finished()

		State.FLEE:
			mark_anim.play("exclamation")
			persist = false
			persist_time = 0
			flee(delta)
			
			#var distance = position.distance_to(target.position)
			if position >= direction:
				current_state = State.IDLE

func check_flip():
	if direction.x < 0:
		animated_sprite.flip_h = true
		sprite2D.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false
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
	if navigation_agent.is_navigation_finished():
		pass
		# make them attack
		# problem is that they never get inside the player, so it never finishes
	
	target = player
	navigation_agent.target_position = target.position
	
	direction = (navigation_agent.get_next_path_position() - position).normalized()
	check_flip()
	
	velocity = direction * speed
	move_and_slide()

func flee(delta):
	if target:
		#navigation_agent.target_position = -target.global_position
		direction = (position - target.position).normalized()
		#direction = (navigation_agent.get_next_path_position() - position).normalized()
		check_flip()
		
		velocity = direction * speed
		move_and_slide()
		
		flee_time += delta
		if flee_time >= 2.0:
			flee_time = 0
			current_state = State.IDLE

# this is just to get the light source position, called by the light source
func flee_from(light_source_node: Node2D):
	target = light_source_node
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
	var amount = randi_range(1, 3)
	GameManager.increase_ingredient(resource, amount)
	
func get_possessed(ghost_health, ghost_damage):
	health = ghost_health
	damage = ghost_damage
	is_dead = true # just to make sure
	is_possessed = true
	current_state = State.STAGGER
	$CollisionShape2D.disabled = false
	sprite2D.scale.x = 1
	sprite2D.scale.y = 1

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

# use animation_looped signal because animation_finished wasn't firing
func _on_mark_animated_sprite_2d_animation_looped():
	if mark_anim.animation == "question" or mark_anim.animation == "exclamation":
		mark_anim.play("empty_anim")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit":
		current_state = State.CHASE
	elif anim_name == "stagger":
		current_state = State.CHASE

# ===============< COLLISIONS >===============

# =====< Area2D collisions >=====
func _on_area_2d_body_entered(body):
	if body is Player:
		if current_state != State.CHASE and current_state != State.STAGGER:
			current_state = State.ALARMED
		
		persist = false
		persist_time = 0

func _on_area_2d_body_exited(body):
	if body is Player:
		persist = true
		#current_state = State.IDLE

# =====< HitArea collisions >=====
func _on_hit_area_body_entered(body):
	if body is Player:
		body.take_damage(damage)

func _on_corpse_area_area_entered(area):
	if area.owner is Ghost:
		if !area.owner.is_possessing:
			area.owner.target = self
			area.owner.current_state = area.owner.State.CHASE
