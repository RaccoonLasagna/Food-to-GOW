extends Node2D
class_name Station

@export var station_name: String
@export var attachment_point: Node2D
@export var max_attachment: int = 1

func _ready():
	add_to_group("stations")

func can_place() -> bool:
	if attachment_point.get_child_count() < max_attachment:
		return true
	return false

func add_item(item: Node2D) -> void:
	item.reparent(attachment_point)
	item.global_position = attachment_point.global_position

func remove_item():
	print("an item has been removed")
