extends Area2D

enum VeinType { NIGREDO, CITRINITAS, ALBEDO, RUBEDO }
@export var vein_type: VeinType

# gets respective Label and ProgressBar nodes for each vein
@onready var interaction_label = $Label
@onready var progress_bar = $ProgressBar

var player_colliding: bool = false

# hardness is the time needed to harness a vein
# hold_time is compared to hardness to check if the vein should be harnessed
@export var hardness: float = 2.0
var hold_time: float = 0.0

func _on_body_entered(body):
	if body is Player:
		player_colliding = true

func _on_body_exited(body):
	if body is Player:
		player_colliding = false
		hold_time = 0.0

func _ready():
	progress_bar.max_value = hardness

func _process(delta):
	# if the player not colliding with the vein, they'll be false
	interaction_label.visible = player_colliding
	progress_bar.visible = player_colliding
	
	# increase hold_time if is colliding and pressing E
	# also update the progress bar
	if player_colliding and Input.is_action_pressed("interact"):
		hold_time += delta
		progress_bar.value = hold_time
	else:
		hold_time = 0.0
		progress_bar.value = 0.0

	if hold_time >= hardness:
		# call the function to increase ingredient values
		_harness_vein()

func _harness_vein():
	# pass this vein's to handle the match in the function
	GameManager.increase_ingredient(vein_type, 1)
	hold_time = 0.0
