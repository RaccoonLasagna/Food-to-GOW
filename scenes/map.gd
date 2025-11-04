extends Node2D
@export var player: Sprite2D
@export var map_nodes_group: Node
@onready var map_nodes := map_nodes_group.get_children()
var map_position := 0
var player_movement_duration := .2
var stages = [null, "stage_1"]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var poschange = false
	if Input.is_action_pressed("right") and map_position < map_nodes.size() - 1:
		map_position += 1
		poschange = true
	elif Input.is_action_pressed("left") and map_position > 0:
		map_position -= 1
		poschange = true
	elif Input.is_action_just_pressed("interact"):
		var stage_name_format = "res://scenes/stages/%s.tscn"
		if map_position > stages.size() - 1:
			return
		var stage_name = stages[map_position]
		if stage_name != null:
			var stage_file = stage_name_format % stage_name
			get_tree().change_scene_to_file(stage_file)
	if poschange:
		var target_position = map_nodes[map_position].global_position
		if player.global_position.x < target_position.x:
			player.flip_h = false
		else:
			player.flip_h = true
		self.process_mode = Node.PROCESS_MODE_DISABLED
		var duration := .2
		var pos_tween = get_tree().create_tween()
		pos_tween.tween_property(player, "global_position", target_position, duration)
		pos_tween.finished.connect(enable_process_mode)
		
	
func enable_process_mode():
	self.process_mode = Node.PROCESS_MODE_INHERIT
