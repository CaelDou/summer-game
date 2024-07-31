extends VBoxContainer

@onready var game = get_tree().get_root().get_node("Game")
@onready var inventory = game.get_node("/root/Game/Player/Inventory_UI")

func _on_inventory_ui_item_changed():
	for recipe in get_children():
		recipe.check()
