extends Station

func add_item(item: Node2D) -> void:
	item.queue_free()
