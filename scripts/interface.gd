extends Control

# =====< ResourcePanel references >=====
@onready var resource_panel = $ResourcePanel
@onready var margin_container = resource_panel.get_node("MarginContainer")
@onready var grid_container = margin_container.get_node("GridContainer")

@onready var nigredo_label = grid_container.get_child(4)
@onready var citrinitas_label = grid_container.get_child(5)
@onready var albedo_label = grid_container.get_child(6)
@onready var rubedo_label = grid_container.get_child(7)

@onready var health_label = $TextureRect/Label

func _ready():
	# connect the signal through code
	GameManager.updated_resources.connect(update_resources)
	GameManager.updated_health.connect(update_health)

# the signal updated_resources passes these values
func update_resources(nigredo, citrinitas, albedo, rubedo):
	# update each label
	nigredo_label.text = str(nigredo)
	citrinitas_label.text = str(citrinitas)
	albedo_label.text = str(albedo)
	rubedo_label.text = str(rubedo)

func update_health(health):
	health_label.text = str(health)
