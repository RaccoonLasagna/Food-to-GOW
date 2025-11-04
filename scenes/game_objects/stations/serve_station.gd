extends Station
class_name ServeStation

@export var controller: CustomerController

func add_item(item: Node2D) -> void:
	super.add_item(item)
	if controller == null: return

	var c := controller.peek_front_right()
	if c == null:
		return # nobody to serve yet

	var food_name = item.get("item_name") if item.has_method("get") else ( item.item_name if "item_name" in item else "" )
	if food_name.to_lower() == c.desired_food.to_lower():
		item.queue_free()             # consume food
		await controller.exit_front_right()  # send customer away
	else:
		# wrong order; leave item or give feedback
		item.modulate = Color.RED
		pass
