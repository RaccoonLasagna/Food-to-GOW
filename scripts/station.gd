extends StaticBody2D
@export var attachment_point: Node2D

func _ready() -> void:
	self.add_to_group("stations")
