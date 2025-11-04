extends CharacterBody2D

@export var move_speed := 4000.0
@export var sprite: AnimatedSprite2D
@export var interact_area: Area2D
@export var attachment_point: Node2D
var interactable_items: Array = []
var interactable_stations: Array = []
var held_item: Node2D = null
var last_move_dir: Vector2 = Vector2.DOWN
var _current_anim := ""

var fridge: Station = null

func _ready() -> void:
	interact_area.area_entered.connect(add_to_interactable)
	interact_area.area_exited.connect(remove_from_interactable)
	
func _play_anim(name: String) -> void:
	if _current_anim == name: return
	_current_anim = name
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(name):
		sprite.play(name)

func _physics_process(delta: float) -> void:
	if !fridge:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			last_move_dir = input_dir
			if abs(input_dir.x) > abs(input_dir.y):
				_play_anim("walk_side")
				sprite.flip_h = input_dir.x < 0
			else:
				_play_anim("walk_up" if input_dir.y < 0 else "walk_down")
		else:
			_play_anim("idle")
		velocity = input_dir * move_speed * delta
		move_and_slide()
		if abs(last_move_dir.x) > abs(last_move_dir.y):
			if last_move_dir.x > 0:
				interact_area.rotation_degrees = 270
			else:
				interact_area.rotation_degrees = 90
		else:
			if last_move_dir.y > 0:
				interact_area.rotation_degrees = 0
			else:
				interact_area.rotation_degrees = 180

		if held_item:
			held_item.global_rotation_degrees = 0

		if Input.is_action_just_pressed("interact"):
#            interact with serve or order
			var station = get_closest_station()
			if station and station.name == "order_station":
				station.on_interact(self)
				print("line 63 player.gd interact order")
			else:
				interact()

		if Input.is_action_just_pressed("use"):
			var station = get_closest_station()
			if station and station.has_method("chop"):
				station.chop()
	else:
		if Input.is_action_just_pressed("left"):
			fridge.previous()
		if Input.is_action_just_pressed("right"):
			fridge.next()
		if Input.is_action_just_pressed("use"):
			fridge.toggle()
			fridge = null
		if Input.is_action_just_pressed("interact"):
			var ingredient_name = fridge.ingredients[fridge.index]
			var item_scene = load("res://scenes/game_objects/food_objects/item.tscn")
			var new_item = item_scene.instantiate()
			get_tree().current_scene.add_child(new_item)

			new_item.item_name = ingredient_name
			new_item.sprite.scale = Vector2(3, 3)
			new_item._set_item_frame(ingredient_name)
			new_item.reparent(attachment_point)
			new_item.global_position = attachment_point.global_position
			held_item = new_item
			fridge.toggle()
			fridge = null
			print("taking out ", ingredient_name)
			print("ingredient position ", new_item.global_position)



func add_to_interactable(area: Area2D):
	var target_object = area.get_parent()
	if target_object.is_in_group("items"):
		interactable_items.append(target_object)
	if target_object.is_in_group("stations"):
		interactable_stations.append(target_object)

func remove_from_interactable(area: Area2D):
	var target_object = area.get_parent()
	if target_object.is_in_group("items"):
		interactable_items.erase(target_object)
	if target_object.is_in_group("stations"):
		interactable_stations.erase(target_object)

func get_closest_interactable() -> Node2D:
	var closest_item: Node2D = null
	var closest_dist: float = INF
	for item in interactable_items:
		var dist: float = self.global_position.distance_to(item.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_item = item
	return closest_item

func get_closest_station() -> Node2D:
	var closest_station: Node2D = null
	var closest_dist: float = INF
	for station in interactable_stations:
		var dist: float = self.global_position.distance_to(station.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_station = station
	return closest_station

func interact():
	if held_item == null: # no held item = pick one up or fridge
		if interactable_items.is_empty():
			for station in interactable_stations:
				if station.station_name == "fridge":
					station.toggle()
					fridge = station
					return
		held_item = get_closest_interactable()
		if !held_item:
			return
		var item_parent = held_item.get_parent()
		if item_parent != get_parent(): # not the same parent = item in station
			print("picking up item from station")
			item_parent.get_parent().remove_item()
		else:
			print("picking up item from ground")
		held_item.reparent(attachment_point)
		held_item.global_position = attachment_point.global_position
	else: # item: put it down on a station or floor
		if !interactable_stations.is_empty():
			var sorted_stations = interactable_stations.duplicate()
			sorted_stations.sort_custom(func(a, b):
				return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
			)
			var recipe_manager = RecipeManager.new()
			for station in sorted_stations:
				if station.attachment_point.get_child_count() > 0:
					var existing_item = station.attachment_point.get_child(0)
					var recipe = recipe_manager.get_recipe_for(
						"mix", [
						existing_item.item_name.to_lower(),
						held_item.item_name.to_lower()
						]
					)
					# combine item
					if recipe.size() > 0:
						var existing_scale = existing_item.scale
						existing_item.free()
						held_item.free()
						var result_scene = load("res://scenes/game_objects/food_objects/item.tscn")
						var result_item = result_scene.instantiate()
						result_item.scale = existing_scale
						result_item.item_name = recipe["output"]
						result_item.sprite.scale = Vector2(3, 3)
						result_item._set_item_frame(recipe["output"])
						station.attachment_point.add_child(result_item)
						result_item.global_position = station.attachment_point.global_position
						held_item = null
						recipe_manager.queue_free()
						return
			for station in sorted_stations:
				if station.can_place():
					station.add_item(held_item)
					held_item = null
					recipe_manager.queue_free()
					return
			recipe_manager.queue_free()
		#held_item.reparent(self.get_parent())
		#held_item = null
