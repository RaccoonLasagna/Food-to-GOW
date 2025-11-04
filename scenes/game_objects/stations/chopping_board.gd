extends Station
class_name ChoppingBoard

@export var chopping_sfx: AudioStreamPlayer2D
var required_chops: int = 0
var current_chops: int = 0
var current_recipe: Dictionary = {}
var current_item: Node2D = null

func _ready() -> void:
	super._ready()

func add_item(item: Node2D) -> void:
	super.add_item(item)
	current_item = item
	_check_start_recipe()

func remove_item() -> void:
	current_item = null
	current_recipe = {}
	current_chops = 0

func _check_start_recipe() -> void:
	if attachment_point.get_child_count() == 0:
		return
	var ingredient_ids: Array = []
	for child in attachment_point.get_children():
		ingredient_ids.append(child.item_name.to_lower())
	ingredient_ids.sort()
	var recipe_manager = RecipeManager.new()
	var recipe: Dictionary = recipe_manager.get_recipe_for(station_name, ingredient_ids)
	if recipe.size() > 0:
		current_recipe = recipe
		required_chops = recipe.get("required_chops", 5)
	else:
		current_recipe = {}
	recipe_manager.queue_free()

func chop() -> void:
	if current_recipe.size() == 0:
		return
	chopping_sfx.play()
	current_chops += 1
	if current_chops >= required_chops:
		_finish_chopping()

func _finish_chopping() -> void:
	if current_item == null:
		return
	var child_scale = current_item.scale
	current_item.free()
	var result_scene = load("res://scenes/game_objects/food_objects/item.tscn")
	var result_item = result_scene.instantiate()
	result_item.scale = child_scale
	result_item.item_name = current_recipe["output"]
	result_item._set_item_frame(current_recipe["output"])
	result_item.sprite.scale = Vector2(3, 3)
	attachment_point.add_child(result_item)
	result_item.global_position = attachment_point.global_position
	current_item = result_item
	current_recipe = {}
	current_chops = 0
