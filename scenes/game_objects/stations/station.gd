extends Node2D
class_name Station

@export var station_name: String
@export var attachment_point: Node2D
@export var max_attachment: int = 1
@export var hint_point: Node2D

func _ready():
	add_to_group("stations")

func can_place() -> bool:
	if attachment_point.get_child_count() < max_attachment:
		return true
	return false

func add_item(item: Node2D) -> void:
	item.reparent(attachment_point)
	item.global_position = attachment_point.global_position

func remove_item(player):
	var held_item = attachment_point.get_child(0)
	held_item.reparent(player.attachment_point)
	held_item.global_position = player.attachment_point.global_position
	return_sprite_to_node(held_item)
	print("an item has been removed")

func on_interact(_player: Node) -> void:
	pass

func return_sprite_to_node(node):
	node.z_index = 0
	node.sprite.global_position = node.global_position
