extends Resource
class_name Item

@export var icon: Texture2D
@export var name: String

@export var recipe: Array[Item]

@export_enum("Weapon", "Resource")
var type = "Resource"
