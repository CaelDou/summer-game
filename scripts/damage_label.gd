extends Control

@onready var label = $Label

var pos: Vector2
var points_left = []
var points_right = []

var p0: Vector2
var p1: Vector2
var p2: Vector2

var time: float = 0.0

func _ready():
	label.text = str(GameManager.current_damage)

func _physics_process(delta):
	time += delta
	if time >= 1.2:
		queue_free()
	position = bezier(time)

func bezier(t):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

# I'm going insane
func set_spawn_position(spawn_position):
	pos = spawn_position
	p0 = pos
	points_left = [Vector2(pos.x - 110, pos.y - 110), Vector2(pos.x - 180, pos.y)]
	points_right = [Vector2(pos.x + 110, pos.y - 110), Vector2(pos.x + 180, pos.y)]
	
	var n = randf()
	if n > 0.5:
		p1 = points_left[0]
		p2 = points_left[1]
	else:
		p1 = points_right[0]
		p2 = points_right[1]
