extends Node2D

@export var background_node: CanvasItem                 
@export var bg_textures: Array[Texture2D] = []   

func _ready() -> void:
	_apply_bg()

func _apply_bg() -> void:
	if background_node == null or bg_textures.is_empty():
		return
	var idx = clamp(Global.selected_map_index, 0, bg_textures.size() - 1)
	var tex = bg_textures[idx]

	if background_node is Sprite2D:
		(background_node as Sprite2D).texture = tex
	elif background_node is TextureRect:
		(background_node as TextureRect).texture = tex

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$CanvasGroup.visible = true 
	$PauseButton.visible = false

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	$CanvasGroup.visible = false
	$PauseButton.visible = true

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	$PauseButton.disabled = true
	$CanvasGroup.visible = false
	if $SceneAnimation and $SceneAnimation.has_animation("out_scene"):
		$SceneAnimation.play("out_scene")
		await $SceneAnimation.animation_finished
	get_tree().change_scene_to_file("res://scenes/map.tscn")
