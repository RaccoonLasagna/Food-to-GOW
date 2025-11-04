extends CharacterBody2D

const HINT_RADIUS := 56.0

@export var move_speed := 4000.0
@export var sprite: AnimatedSprite2D
@export var interact_area: Area2D
@export var attachment_point: Node2D

@export var keyhint_scene: PackedScene = preload("res://scenes/game_objects/stations/key_hint.tscn")

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
	print(held_item)
	if !fridge:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			last_move_dir = input_dir
			if abs(input_dir.x) > abs(input_dir.y):
				if held_item:
					_play_anim("walk_side_holding")
				else:
					_play_anim("walk_side")
				sprite.flip_h = input_dir.x < 0
			else:
				if held_item:
					_play_anim("walk_up_holding" if input_dir.y < 0 else "walk_down_holding")
				else:
					_play_anim("walk_up" if input_dir.y < 0 else "walk_down")
		else:
			if held_item:
				_play_anim("idle_holding")
			else:
				_play_anim("idle")
		velocity = input_dir * move_speed * delta
		move_and_slide()
		
		interact_area.z_index = 0
		interact_area.position.x = 0
		
		if abs(last_move_dir.x) > abs(last_move_dir.y):
			if last_move_dir.x > 0:
				interact_area.position.x = 0
			else:
				interact_area.position.x = -20
		else:
			if last_move_dir.y > 0:
				interact_area.position.x = 0
			else:
				interact_area.position.x = 0
				interact_area.z_index = -1
				last_move_dir.y = 1

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
		_show_station_hint(fridge)
		
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
			
			_show_station_hint(fridge)
			
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
		# -------- HINT ON ENTER (base_station only) --------
		_show_station_hint(target_object)

func remove_from_interactable(area: Area2D):
	var target_object = area.get_parent()
	if target_object.is_in_group("items"):
		interactable_items.erase(target_object)
	if target_object.is_in_group("stations"):
		interactable_stations.erase(target_object)
		# -------- HINT OFF ON EXIT (base_station only) -----
		_hide_station_hint(target_object)

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
			
		held_item.reparent(attachment_point)
		
		_show_station_hint(item_parent.get_parent())
			
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
					
					_show_station_hint(station)
					
					recipe_manager.queue_free()
					return
			recipe_manager.queue_free()
		#held_item.reparent(self.get_parent())
		#held_item = null
		
# Spawns/updates a KeyHint as a child of the station's attachment_point
func _show_station_hint(station: Station) -> void:
	if station == null or station.hint_point == null:
		return

	var hint := station.hint_point.get_node_or_null("AttachmentHint")
	if hint == null:
		hint = keyhint_scene.instantiate()
		hint.name = "AttachmentHint"
		station.hint_point.add_child(hint)

		hint.position = Vector2(-70, 0)
	#if station.name.to_lower().begins_with("station"):
	var have_food_on_station := station.attachment_point.get_child_count() > 0
	var player_holding := held_item != null
	
	if station.name == "order_station":
		hint.set_hint("Take Order", "interact")
	elif station.name == "fridge" and fridge != null and not player_holding:
		hint.set_multi_hint([
			{"verb": "Get ingredients", "action": "interact"},
			{"verb": "left", "action": "left"},
			{"verb": "right", "action": "right"},
		])
	elif station.name == "fridge" and not player_holding:
		hint.set_hint("Get ingredients", "interact")
	elif station.name == "chopping_board" and have_food_on_station and not player_holding:
		hint.set_multi_hint([
			{"verb": "Pick up", "action": "interact"},
			{"verb": "Chop", "action": "use"}
		])
	else:
		if have_food_on_station and not player_holding:
			hint.set_hint("Pick up", "interact")
		elif player_holding and station.can_place():
			if station.name == "bin":
				hint.set_hint("Throw", "interact")
			elif station.name == "serve_station":
				hint.set_hint("Serve", "interact")
			else:
				hint.set_hint("Place", "interact")
		else:
			hint.hide_hint()

func _hide_station_hint(station: Station) -> void:
	if station and station.hint_point:
		var hint := station.hint_point.get_node_or_null("AttachmentHint")
		if hint:
			hint.queue_free()
