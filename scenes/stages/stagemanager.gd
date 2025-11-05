extends Node2D

@export var background_node: CanvasItem
@export var bg_textures: Array[Texture2D] = []

@export var customer_controller: Node
@export var auto_spawn_customers := true
@export var spawn_interval_sec := 6.0 
@export var timer_label: Label
@export var timer_start = false

@export var target_customers := 3

var current_time: float = 0.0
var _spawn_timer: Timer
var _served_count := 0
var _spawned_count := 0

func _ready() -> void:

	_apply_bg()

	if customer_controller and customer_controller.has_signal("customer_completed"):
		customer_controller.customer_completed.connect(_on_customer_completed)

	if customer_controller and auto_spawn_customers:
		_spawn_timer = Timer.new()
		_spawn_timer.wait_time = spawn_interval_sec
		_spawn_timer.autostart = true
		_spawn_timer.one_shot = false
		add_child(_spawn_timer)
		_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _process(delta: float) -> void:
	if timer_start:
		timer_label.visible = true
		current_time += delta
		update_timer_label()

func _on_spawn_timer_timeout() -> void:
	_spawn_one_customer()

func _spawn_one_customer() -> void:
	# stop once we’ve spawned 20 total
	if _spawned_count >= target_customers:
		if _spawn_timer: _spawn_timer.stop()
		return

	if customer_controller and customer_controller.has_method("spawn_customer"):
		var c = customer_controller.spawn_customer()
		if c:
			_spawned_count += 1
			
			if _spawned_count >= target_customers and _spawn_timer:
				_spawn_timer.stop()

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
	timer_start = false
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

func update_timer_label():
	var minutes = int(current_time) / 60
	var seconds = int(current_time) % 60
	var milliseconds = int((current_time - int(current_time)) * 100)
	timer_label.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]


func _on_customer_completed() -> void:
	_served_count += 1

	if _served_count >= target_customers:
		_on_run_complete()

func _on_run_complete() -> void:

	if _spawn_timer: _spawn_timer.stop()
	auto_spawn_customers = false
	timer_start = false

	if has_node("CanvasGroup"):
		$CanvasGroup.visible = true
		if $CanvasGroup.has_node("Title"):
			$CanvasGroup/Title.visible = true
		if $CanvasGroup.has_node("ContinueButton"):
			$CanvasGroup/ContinueButton.visible = false
		if $CanvasGroup.has_node("ExitButton"):
			$CanvasGroup/ExitButton.visible = true

	if has_node("PauseButton"):
		$PauseButton.visible = false

	get_tree().paused = true
