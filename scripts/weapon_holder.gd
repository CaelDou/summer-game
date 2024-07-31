extends Marker2D

var item_sprite = null

func _ready():
	get_item_sprite()

func _process(_delta):
	get_item_sprite()
	if rotation > deg_to_rad(360) or rotation < deg_to_rad(-360):
		rotation = deg_to_rad(0)
	
	if rotation < deg_to_rad(0) and rotation > deg_to_rad(-180):
		z_index = -1
	else:
		z_index = 0

func _physics_process(_delta):
	look_at(get_global_mouse_position())

func get_item_sprite():
	item_sprite = null
	for child in get_children():
		if child is Sprite2D:
			item_sprite = child
