extends PanelContainer

@onready var game = get_tree().get_root().get_node("Game")
@onready var inventory = game.get_node("/root/Game/Player/Inventory_UI")

@onready var panel = $Panel
@onready var texture_rect: TextureRect = $TextureRect

var item: Item = null:
	set(value):
		item = value
		
		if value != null:
			texture_rect.texture = value.icon
		else:
			texture_rect.texture = null

func enable(value = true):
	if value != null:
		panel.show_behind_parent = value
		return value

func check():
	if item != null:
		return enable(inventory.is_available(item))
