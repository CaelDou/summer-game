extends Control
class_name Inventory

signal item_changed

@onready var grid_container: GridContainer = $NinePatchRect/GridContainer
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

@export var item1: Item
@export var item2: Item

var is_open: bool = false

func _ready():
	await get_tree().create_timer(4).timeout
	add_item(item1)
	await get_tree().create_timer(2).timeout
	add_item(item2)
	
	#close_inventory()

func add_item(item):
	for s in slots:
		if s.item == null:
			s.item = item
			item_changed.emit()
			return

func remove_item(item):
	for s in slots:
		if s.item == item:
			s.item = null
			item_changed.emit()
			return

func is_available(item):
	for i in grid_container.get_children():
			if i.item == item:
				i.item = null
				return

func open_inventory():
	visible = true
	is_open = true

func close_inventory():
	visible = false
	is_open = false
