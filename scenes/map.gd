extends Node2D
@export var player: Sprite2D
@export var map_nodes_group: Node
@onready var map_nodes := map_nodes_group.get_children()
var map_position := 0
var player_movement_duration := 0.2
var stages = "stage_1"
var last_dir := 0  # +1 right, -1 left, 0 none

func _ready() -> void:
	if Global.started:
		$CanvasGroup.visible = false
		map_position = Global.player_position
		var target_node = map_nodes[map_position]
		player.global_position = target_node.global_position

func _process(delta: float) -> void:
	if not Global.started:
		return
		
	var poschange := false

	if (Input.is_action_pressed("right") and map_position < map_nodes.size() - 1) \
	or (_is_skip_node(map_nodes[map_position]) and last_dir == 1 and map_position < map_nodes.size() - 1):
		last_dir = 1
		map_position += 1
		poschange = true

	elif (Input.is_action_pressed("left") and map_position > 0) \
	or (_is_skip_node(map_nodes[map_position]) and last_dir == -1 and map_position > 0):
		last_dir = -1
		map_position -= 1
		poschange = true

	elif Input.is_action_just_pressed("interact"):
		var stage_name_format = "res://scenes/stages/%s.tscn"
		var stage_name = stages
		if stage_name != null:
			Global.selected_map_index = map_position
			Global.player_position = map_position
			var stage_file = stage_name_format % stage_name
			get_tree().change_scene_to_file(stage_file)

	if poschange:
		var target_position = map_nodes[map_position].global_position
		player.flip_h = (player.global_position.x < target_position.x)

		process_mode = Node.PROCESS_MODE_DISABLED
		var pos_tween = get_tree().create_tween()
		pos_tween.tween_property(player, "global_position", target_position, player_movement_duration)
		pos_tween.finished.connect(enable_process_mode)

func enable_process_mode():
	process_mode = Node.PROCESS_MODE_INHERIT

func _is_skip_node(n: Node) -> bool:
	return n.name.to_lower().contains("skip")

func _on_button_pressed() -> void:
	$CanvasGroup.visible = false
	Global.started = true
