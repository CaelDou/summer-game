extends HBoxContainer

@onready var craft = $Craft

@export var item: Item = null
@onready var recipe = item.recipe

func _ready():
	craft.icon = item.icon
	
	for i in range(recipe.size()):
		get_child(i).item = recipe[i]

func check():
	for i in range(recipe.size()):
		get_child(i).check()
