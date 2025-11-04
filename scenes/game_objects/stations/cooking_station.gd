extends Station
class_name CookingStation

@export var burnable: bool
@export var timer_node: Timer
var current_recipe: Dictionary

func _ready() -> void:
	super._ready()
	timer_node.timeout.connect(_on_cook_finished)

func add_item(item: Node2D) -> void:
	super.add_item(item)
	print("Contains: ", attachment_point.get_children())
	if timer_node.time_left > 0:
		timer_node.stop()
		print("stopped cooking", current_recipe["output"])
		current_recipe = {}
	_check_start_recipe()

func remove_item() -> void:
	if timer_node.time_left > 0:
		timer_node.stop()
		print("stopped cooking", current_recipe["output"])
		current_recipe = {}

func _check_start_recipe() -> void:
	var ingredient_ids: Array = []
	for child in attachment_point.get_children():
		ingredient_ids.append(child.item_name.to_lower())
	ingredient_ids.sort()
	var recipe_manager = RecipeManager.new()
	var recipe: Dictionary = recipe_manager.get_recipe_for(station_name, ingredient_ids)
	if recipe.size() > 0:
		start_food_timer(recipe)
	elif burnable: # no recipe, station can burn food
		recipe = {
			"output": "ash",
			"time": 20.0
		}
		start_food_timer(recipe)
	recipe_manager.queue_free()

func start_food_timer(recipe):
	timer_node.wait_time = recipe.get("cook_time", recipe["time"])
	timer_node.start()
	current_recipe = recipe
	print("recipe started for %s" % recipe["output"])

func _on_cook_finished() -> void:
	var recipe: Dictionary = current_recipe
	if recipe.size() == 0:
		return
	var child_scale = attachment_point.get_child(0).scale
	print("child scale", child_scale)
	for child in attachment_point.get_children():
		child.free()
	var result_scene = load("res://scenes/game_objects/food_objects/item.tscn")
	var result_item = result_scene.instantiate()
	result_item.scale = child_scale
	result_item.item_name = recipe["output"]
	result_item.update_texture()
	attachment_point.add_child(result_item)
	result_item.global_position = attachment_point.global_position
	current_recipe = {}
	_check_start_recipe()

func debug():
	print(attachment_point.get_children(), current_recipe)
