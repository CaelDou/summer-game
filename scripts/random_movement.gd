extends CharacterBody2D

# =====< FEEL FREE TO DELETE/ADD COMMENTS >=====

# references
@onready var player = get_node("/root/Game/Player")
@onready var anim = $AnimatedSprite2D
@onready var mark_anim = $MarkAnimatedSprite2D
 
enum State { IDLE, ROAM, ALARMED, CHASE }
var current_state: State
var direction: Vector2
var can: bool = true

# stats
@export var health: int = 2
@export var damage: int = 1
@export var speed: float = 150.0
@export var attention: float = 2.0 # how long enemy stays on State.ALARMED
var attention_time: float = 0 # track time that passed

# bool
var is_dead = false
var is_possessed = false # works as a second life if ghost possesses

# check boundaries so the chicken can't roam around the whole map
var initial_position
@export var boundary: float

func _ready():
	current_state = State.IDLE
	initial_position = position
	mark_anim.play("empty_anim")

func _physics_process(delta):
	if !is_dead or is_possessed:
		check_states(delta)
	else:
		pass # replace with die

func check_states(delta):
	match current_state:
		State.IDLE:
			anim.play("idle")
			mark_anim.play("empty_anim")
			attention_time = 0
			
			# always checks true, 'can' is reset to true after $Timer expires
			# we set 'can' to false so the timer is started only once
			if can:
				can = false
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.ROAM:
			anim.play("walk")
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
			anim.play("alarmed")
			mark_anim.play("question")
			
			# add time passed to attention_time
			attention_time += delta
			if(attention_time >= attention):
				# reset for the next ALARMED state and enter CHASE
				attention_time = 0
				current_state = State.CHASE

		State.CHASE:
			anim.play("walk")
			
			if mark_anim.animation != "empty_anim":
				mark_anim.play("exclamation")
				
			chase()

func check_flip():
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false

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

func _on_area_2d_body_entered(body):
	if body is Player:
		current_state = State.ALARMED

func _on_area_2d_body_exited(body):
	if body is Player:
		current_state = State.IDLE

# use animation_looped signal because animation_finished wasn't firing
func _on_mark_animated_sprite_2d_animation_looped():
	if mark_anim.animation == "question" or mark_anim.animation == "exclamation":
		mark_anim.play("empty_anim")
		print("looped")
