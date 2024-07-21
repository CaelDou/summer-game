extends Marker2D

var weapon_sprite = null

func _ready():
	get_weapon_sprite()

func _process(_delta):
	if weapon_sprite != null:
		if rotation > deg_to_rad(360) or rotation < deg_to_rad(-360):
			rotation = deg_to_rad(0)
		
		if rotation < deg_to_rad(-90) and rotation > deg_to_rad(-270):
			weapon_sprite.flip_v = true
		elif rotation > deg_to_rad(90) and rotation < deg_to_rad(270):
			weapon_sprite.flip_v = true
		else:
			weapon_sprite.flip_v = false
		
		if rotation < deg_to_rad(0) and rotation > deg_to_rad(-180):
			z_index = -1
		else:
			z_index = 0

func _physics_process(_delta):
	look_at(get_global_mouse_position())

func get_weapon_sprite():
	weapon_sprite = null
	for child in get_children():
		if child is Sprite2D:
			weapon_sprite = child
