extends Node2D
@export var player: Sprite2D
@export var map_nodes_group: Node
@export var current_stage_label: Label
@export var prev_stage_arrow: Sprite2D
@export var next_stage_arrow: Sprite2D
@onready var map_nodes := map_nodes_group.get_children()
var map_position := 0
var actual_map_pos = 0
var map_names = [
	"Botanic Gardens",
	"Kelvingrove Park",
	"Riverside Museum",
	"The Glasgow Necropolis",
	"Wellpark Brewery",
	]
var player_movement_duration := 0.2
var stages = "stage_1"
var last_dir := 0  # +1 right, -1 left, 0 none

func _ready() -> void:
	update_label()
	if Global.started:
		$CanvasGroup.visible = false
		$current_stage.visible = true
		$SpaceImage.visible = true
		$EnterText.visible = true
		map_position = clamp(Global.player_position, 0, map_nodes.size() - 1)
		actual_map_pos = _count_non_skip_up_to(map_position)
		player.global_position = map_nodes[map_position].global_position

func _process(_delta: float) -> void:
	if not Global.started:
		return
		
	var poschange := false

	if (Input.is_action_pressed("right") and map_position < map_nodes.size() - 1) \
	or (_is_skip_node(map_nodes[map_position]) and last_dir == 1 and map_position < map_nodes.size() - 1):
		last_dir = 1
		map_position += 1
		actual_map_pos = _count_non_skip_up_to(map_position)   # <-- recompute here
		poschange = true
		update_label()

	elif (Input.is_action_pressed("left") and map_position > 0) \
	or (_is_skip_node(map_nodes[map_position]) and last_dir == -1 and map_position > 0):
		last_dir = -1
		map_position -= 1
		actual_map_pos = _count_non_skip_up_to(map_position)   # <-- and here
		poschange = true
		update_label()

	elif Input.is_action_just_pressed("interact"):
		var stage_name_format = "res://scenes/stages/%s.tscn"
		var stage_name = stages
		if stage_name != null:
			Global.selected_map_index = actual_map_pos
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

func update_label():
	current_stage_label.text = map_names[actual_map_pos]
	current_stage_label.reset_size()
	var label_ends = current_stage_label.get_rect().size.x/2
	current_stage_label.position.x = -(label_ends)
	label_ends += 40
	prev_stage_arrow.global_position.x = -label_ends
	next_stage_arrow.global_position.x = label_ends

func enable_process_mode():
	process_mode = Node.PROCESS_MODE_INHERIT

func _is_skip_node(n: Node) -> bool:
	return n.name.to_lower().contains("skip")

func _count_non_skip_up_to(idx: int) -> int:
	var c := 0
	for i in range(idx + 1):                # includes idx
		if not _is_skip_node(map_nodes[i]):
			c += 1
	return max(c - 1, 0)                    # playable index at/all before idx


func _on_button_pressed() -> void:
	$CanvasGroup.visible = false
	Global.started = true
	$current_stage.visible = true
	$SpaceImage.visible = true
	$EnterText.visible = true
