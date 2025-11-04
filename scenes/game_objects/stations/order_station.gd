extends Station
class_name OrderStation

@export var controller: CustomerController

func on_interact(_player: Node) -> void:
	if controller == null: return
	controller.move_front_left_to_right()
