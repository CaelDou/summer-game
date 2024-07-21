extends CharacterBody2D
class_name Enemy

# =====< FEEL FREE TO DELETE/ADD COMMENTS >=====

# references
@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var mark_anim = $MarkAnimatedSprite2D

# we use AnimationPlayer because it can modify node properties,
# for example we access the Sprite2D's rotation and modulate (color)
# properties to make the animation "hit"
@onready var animation_player = $AnimationPlayer
@onready var sprite2D = $Sprite2D
@onready var hit_particles = $CPUParticles2D
 
# hit turned to stagger
enum State { IDLE, ROAM, ALARMED, CHASE, STAGGER }
var current_state: State
var direction: Vector2
var can: bool = true

# stats
@export var health: int = 2
@export var damage: int = 0
@export var speed: float = 150.0

@export var attention: float = 2.0 # how long enemy stays on State.ALARMED
var attention_time: float = 0 # track time that passed

var is_dead = false
var is_possessed = false # works as a second life if ghost possesses

# check boundaries so the chicken can't roam around the whole map
var initial_position
@export var boundary: float

func _ready():
	mark_anim.play("empty_anim")
	current_state = State.IDLE
	initial_position = position

func _physics_process(delta):
	if !is_dead or is_possessed:
		check_states(delta)
	else:
		pass # replace with die

func check_states(delta):
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
			mark_anim.play("empty_anim")
			attention_time = 0
			
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

		State.STAGGER:
			animation_player.play("stagger")
			check_flip()
			current_state = State.CHASE
			# returns to State.CHASE through _on_animation_player_animation_finished()

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

# basic move to player position motion, will get stuck at walls
# will make a better pathing later
func chase():
	direction = (player.position - position).normalized()
	check_flip()
	
	velocity = direction * speed
	move_and_slide()

func randomize_direction():
	# reset direction so it always enters the while
	direction = Vector2.ZERO
	
	# direction (0, 0) would play the walk animation and not move
	# so we randomize direction until it's not (0, 0) anymore
	while direction == Vector2.ZERO:
		direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
		check_flip()

func take_damage(amount: int):
	animation_player.play("hit")
	# get angle to player and invert it so particles play opposite to player
	var angle_to_player = (player.position - position).angle()
	hit_particles.rotation = angle_to_player + PI
	
	health -= amount
	if health <= 0:
		die()

func die():
	animation_player.play("death")
	is_dead = true
	# instantiate corpe for ghost

# ==============< SIGNALS >===============
func _on_timer_timeout():
	# it means our current state's started $Timer expired
	# meaning we spent 1, 2 or 3 seconds on that state, so we change it
	match current_state:
		State.IDLE:
			current_state = State.ROAM
		State.ROAM:
			current_state = State.IDLE
	
	# also we want to reset 'can' to true only when the $Timer expires
	# because if we didn't, it'd restart $Timer infinitely 
	can = true

# use animation_looped signal because animation_finished wasn't firing
func _on_mark_animated_sprite_2d_animation_looped():
	if mark_anim.animation == "question" or mark_anim.animation == "exclamation":
		mark_anim.play("empty_anim")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit":
		current_state = State.CHASE

# ===============< COLLISIONS >===============

# =====< Area2D collisions >=====
func _on_area_2d_body_entered(body):
	if body is Player:
		if current_state != State.CHASE:
			current_state = State.ALARMED

func _on_area_2d_body_exited(body):
	if body is Player:
		current_state = State.IDLE

# =====< HitArea collisions >=====
func _on_hit_area_body_entered(body):
	if body is Player:
		body.take_damage(damage)

func _on_hit_area_body_exited(_body):
	pass # Replace with function body.
