extends CharacterBody2D

@export var move_speed := 5000.0
@export var sprite: AnimatedSprite2D
@export var interact_area: Area2D
@export var attachment_point: Node2D
var interactable_items: Array = []
var interactable_stations: Array = []
var held_item: Node2D = null
var last_move_dir: Vector2 = Vector2.DOWN
var _current_anim := ""

func _ready() -> void:
	interact_area.area_entered.connect(add_to_interactable)
	interact_area.area_exited.connect(remove_from_interactable)
	
func _play_anim(name: String) -> void:
	if _current_anim == name: return
	_current_anim = name
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(name):
		sprite.play(name)

func _physics_process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		last_move_dir = input_dir
		_play_anim("walk")
		if abs(input_dir.x) >= abs(input_dir.y):
			sprite.flip_h = input_dir.x < 0.0
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
		interact()
	print(interact_area.rotation)

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

func interact():
	print("interact")
	
	if held_item == null: # no held item = pick one up
		if interactable_items.is_empty():
			return
		held_item = get_closest_interactable()
		held_item.reparent(attachment_point)
		held_item.global_position = attachment_point.global_position
	else: # item: put it down on a station or floor
		if !interactable_stations.is_empty(): # station found, try all stations sorted by distance
			var sorted_stations = interactable_stations.duplicate()
			sorted_stations.sort_custom(func(a, b):
				return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
			)
			#var placed = false
			for station in sorted_stations:
				var station_attachment_point = station.attachment_point
				if station_attachment_point.get_child_count() == 0:
					held_item.reparent(station_attachment_point)
					held_item.global_position = station_attachment_point.global_position
					#placed = true
					break
		else: # no stations, put it on the ground, maybe delete this
			held_item.reparent(self.get_parent())
		held_item = null
