extends CharacterBody2D

# =====< FEEL FREE TO DELETE/ADD COMMENTS >=====

# reference to the AnimatedScript2D node
@onready var anim = $AnimatedSprite2D
 
enum State { IDLE, WALK }
var current_state: State

@export var speed: float = 150.0
var direction: Vector2

# check boundaries so the chicken can't roam around the whole map
var initial_position
@export var boundary: float

# idk what else to call this, feel free to rename it
var can: bool = true

func _ready():
	current_state = State.IDLE
	initial_position = position

func _physics_process(_delta):
	match current_state:
		State.IDLE:
			anim.play("idle")
			
			# always checks true, 'can' is reset to true after $Timer expires
			# we set 'can' to false so the timer is started only once
			if can:
				can = false
				var time = randi_range(1, 3)
				$Timer.start(time)

		State.WALK:
			anim.play("walk")
			move()
			
			# always checks true, 'can' is reset to true after $Timer expires
			# randomize direction only once after setting to WALK
			if can:
				can = false
				randomize_direction()
				var time = randi_range(1, 3)
				$Timer.start(time)

func check_flip():
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false

func move():
	velocity = direction * speed
	move_and_slide()
	
	# check boundaries, e.g. initial_position is (0, 0) and boundary is 50:
	# if position.x is 50 or higher, it shouldn't keep going to the right
	# so we randomize the direction again
	var distance = position.distance_to(initial_position)
	if distance >= boundary:
		direction = (initial_position - position).normalized()
		check_flip()

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
			current_state = State.WALK
		State.WALK:
			current_state = State.IDLE
	
	# also we want to reset 'can' to true only when the $Timer expires
	# because if we didn't, it'd restart $Timer infinitely 
	can = true
