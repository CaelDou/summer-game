extends Node2D

@onready var sprite2D: Sprite2D = $Sprite2D
@export var item_name: String = ""

func _on_area_2d_area_entered(area):
	if area.owner is Player:
		#add this item to player inventory
		queue_free()
