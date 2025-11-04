extends Station
class_name CookingStation

@export var burnable: bool
@export var timer_node: Timer
@export var progress_bar: Sprite2D
@export var pb_left: Node2D
@export var pb_mid: Node2D
@export var pb_right: Node2D
var current_recipe: Dictionary
var max_time := -1.

func _ready() -> void:
	super._ready()
	timer_node.timeout.connect(_on_cook_finished)

func _process(_delta: float) -> void:
	if attachment_point.get_child_count() > 0:
		progress_bar.show()
		if max_time > 0:
			var time_remaining_ratio = floor(timer_node.time_left/max_time * 12)
			var rect_x = 0
			if current_recipe["output"] == "ash":
				rect_x = 16
			progress_bar.region_rect.position = Vector2(rect_x, 240 - (20*time_remaining_ratio))
		else:
			progress_bar.region_rect.position = Vector2(0, 0)
	else:
		progress_bar.hide()

func add_item(item: Node2D) -> void:
	super.add_item(item)
	print("Contains: ", attachment_point.get_children())
	if timer_node.time_left > 0:
		timer_node.stop()
		print("stopped cooking", current_recipe["output"])
		current_recipe = {}
	_check_start_recipe()
	center_sprite_on_progress_bar()

func remove_item(player) -> void:
	super.remove_item(player)
	if timer_node.time_left > 0:
		timer_node.stop()
		print("stopped cooking", current_recipe["output"])
		current_recipe = {}
		max_time = -1
		#progress_bar.hide()
	center_sprite_on_progress_bar()
	_check_start_recipe()

func _check_start_recipe() -> void:
	var ingredient_ids: Array = []
	var ingr = attachment_point.get_children()
	print(ingr)
	if ingr.is_empty():
		return
	print("this code is somehow ran")
	for child in ingr:
		var ingredient_id = child.item_name.to_lower()
		ingredient_ids.append(ingredient_id)
	ingredient_ids.sort()
	var recipe_manager = RecipeManager.new()
	var recipe: Dictionary = recipe_manager.get_recipe_for(station_name, ingredient_ids)
	if recipe.is_empty():
		if burnable:
			if ingredient_ids == ["ash"]:
				#progress_bar.hide()
				max_time = -1.
				return
			recipe = {
				"output": "ash",
				"time": 20.0
			}
			start_food_timer(recipe)
			max_time = recipe["time"]
			#progress_bar.show()
		else:
			#progress_bar.hide()
			max_time = -1.
		return

	start_food_timer(recipe)
	max_time = recipe["time"]
	#progress_bar.show()
	recipe_manager.queue_free()

func start_food_timer(recipe):
	timer_node.wait_time = recipe["time"]
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
	print("line 62 cooking station: ", recipe["output"])
	result_item._set_item_frame(recipe["output"])
	result_item.sprite.scale = Vector2(3, 3)
	attachment_point.add_child(result_item)
	result_item.global_position = attachment_point.global_position
	current_recipe = {}
	max_time = -1.
	center_sprite_on_progress_bar()
	_check_start_recipe()

func center_sprite_on_progress_bar() -> void:
	var children = attachment_point.get_children()
	match children.size():
		1:
			children[0].z_index = 2
			children[0].sprite.global_position = pb_mid.global_position
		2:
			children[0].z_index = 2
			children[0].sprite.global_position = pb_left.global_position
			children[1].z_index = 2
			children[1].sprite.global_position = pb_right.global_position
		3:
			children[0].z_index = 2
			children[0].sprite.global_position = pb_left.global_position
			children[1].z_index = 2
			children[1].sprite.global_position = pb_mid.global_position
			children[2].z_index = 2
			children[2].sprite.global_position = pb_right.global_position
