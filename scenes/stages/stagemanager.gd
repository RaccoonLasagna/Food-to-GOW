extends Node2D

@export var background_node: CanvasItem
@export var bg_textures: Array[Texture2D] = []

@export var customer_controller: Node  # set to your CustomerController node in the scene
@export var auto_spawn_customers := true
@export var spawn_interval_sec := 6.0  # how often to spawn

var _spawn_timer: Timer

func _ready() -> void:
	_apply_bg()

	if customer_controller and auto_spawn_customers:
		_spawn_timer = Timer.new()
		_spawn_timer.wait_time = spawn_interval_sec
		_spawn_timer.autostart = true
		_spawn_timer.one_shot = false
		add_child(_spawn_timer)
		_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	_spawn_one_customer()

func _spawn_one_customer() -> void:
	if customer_controller and customer_controller.has_method("spawn_customer"):
		customer_controller.spawn_customer()

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
	$RecipeButton.visible = false
	$stations.free()
	if $SceneAnimation and $SceneAnimation.has_animation("out_scene"):
		$SceneAnimation.play("out_scene")
		await $SceneAnimation.animation_finished
	get_tree().change_scene_to_file("res://scenes/map.tscn")


func _on_recipe_button_pressed() -> void:
	$RecipeGroup.visible = true
	$RecipeButton.visible = false


func _on_close_button_pressed() -> void:
	$RecipeGroup.visible = false
	$RecipeButton.visible = true
