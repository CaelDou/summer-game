extends Node2D

# comes from player, who calculates its dmg + its held weapon dmg
var current_damage: int

enum VeinType { NIGREDO, CITRINITAS, ALBEDO, RUBEDO }

var nigredo_count = 0
var citrinitas_count = 0
var albedo_count = 0
var rubedo_count = 0

# a signal passing data about the ingredients
# is connected to interface.gd's update_resources function
signal updated_resources(nigredo, citrinitas, albedo, rubedo)

func increase_ingredient(vein_type, amount: int):
	# update value depending on the vein type received
	match vein_type:
		VeinType.NIGREDO:
			nigredo_count += amount
		VeinType.CITRINITAS:
			citrinitas_count += amount
		VeinType.ALBEDO:
			albedo_count += amount
		VeinType.RUBEDO:
			rubedo_count += amount
	
	# activate the signal passing the counts as the paramenters
	emit_signal("updated_resources", nigredo_count, citrinitas_count, albedo_count, rubedo_count)
