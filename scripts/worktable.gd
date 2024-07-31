extends Node2D

var player
@onready var level_label = $LevelLabel
@onready var upgrade_label = $Button/UpgradeLabel
@onready var upgrade_info = $Button/Control

@onready var button = $Button

@onready var nigredo_label = $Button/Control/Panel/MarginContainer/GridContainer/Label
@onready var citrinitas_label = $Button/Control/Panel/MarginContainer/GridContainer/Label2
@onready var albedo_label = $Button/Control/Panel/MarginContainer/GridContainer/Label3
@onready var rubedo_label = $Button/Control/Panel/MarginContainer/GridContainer/Label4

@export var worktable_level: int = 0
var player_close: bool = false

var current_nigredo: int = 0
var current_citrinitas: int = 0
var current_albedo: int = 0
var current_rubedo: int = 0

var nigredo_count: int
var citrinitas_count: int
var albedo_count: int
var rubedo_count: int

func _process(_delta):
	check_requirements()
	
	current_nigredo = GameManager.nigredo_count
	current_citrinitas = GameManager.citrinitas_count
	current_albedo = GameManager.albedo_count
	current_rubedo = GameManager.rubedo_count
	
	if player_close:
		if worktable_level != 4:
			button.visible = true
		else:
			button.visible = false
	else:
		button.visible = false
	
	if player_close and Input.is_action_just_pressed("interact"):
		check_upgrade()

func check_requirements():
	match worktable_level:
		0:
			nigredo_count = 5
			citrinitas_count = 5
			albedo_count = 2
			rubedo_count = 2
			level_label.text = "LVL 0"
		1:
			nigredo_count = 10
			citrinitas_count = 10
			albedo_count = 6
			rubedo_count = 6
			level_label.text = "LVL 1"
		2:
			nigredo_count = 15
			citrinitas_count = 15
			albedo_count = 10
			rubedo_count = 10
			level_label.text = "LVL 2"
		3:
			nigredo_count = 20
			citrinitas_count = 20
			albedo_count = 21
			rubedo_count = 21
			level_label.text = "LVL 3"
	
	nigredo_label.text = str(nigredo_count)
	citrinitas_label.text = str(citrinitas_count)
	albedo_label.text = str(albedo_count)
	rubedo_label.text = str(rubedo_count)

func check_upgrade():
	match worktable_level:
		0:
			if current_nigredo >= 5 and current_citrinitas >= 5 and current_albedo >= 2 and current_rubedo >= 2:
				GameManager.nigredo_count -= 5
				GameManager.citrinitas_count -= 5
				GameManager.albedo_count -= 2
				GameManager.rubedo_count -= 2
				worktable_level += 1
				player.health += 5
				player.base_damage += 1
		1:
			if current_nigredo >= 10 and current_citrinitas >= 10 and current_albedo >= 6 and current_rubedo >= 6:
				GameManager.nigredo_count -= 10
				GameManager.citrinitas_count -= 10
				GameManager.albedo_count -= 6
				GameManager.rubedo_count -= 6
				worktable_level += 1
				player.health += 10
				player.base_damage += 1
				player.base_stagger += 1
		2:
			if current_nigredo >= 15 and current_citrinitas >= 15 and current_albedo >= 10 and current_rubedo >= 10:
				GameManager.nigredo_count -= 15
				GameManager.citrinitas_count -= 15
				GameManager.albedo_count -= 10
				GameManager.rubedo_count -= 10
				worktable_level += 1
				player.health += 10
				player.base_damage += 3
				player.base_stagger += 1
		3:
			if current_nigredo >= 20 and current_citrinitas >= 20 and current_albedo >= 21 and current_rubedo >= 21:
				GameManager.nigredo_count -= 20
				GameManager.citrinitas_count -= 20
				GameManager.albedo_count -= 21
				GameManager.rubedo_count -= 21
				worktable_level += 1
		4:
			get_tree().change_scene_to_file("res://scenes/end_game.tscn")

func _on_area_2d_area_entered(area):
	if area.owner is Player:
		player = area.owner
		player_close = true

func _on_area_2d_area_exited(area):
	if area.owner is Player:
		player_close = false
