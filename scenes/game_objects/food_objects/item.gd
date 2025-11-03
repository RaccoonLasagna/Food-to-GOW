extends Node2D

class_name FoodObjects

@export var item_name: String

func _ready() -> void:
	self.add_to_group("items")
