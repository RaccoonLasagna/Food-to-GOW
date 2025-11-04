extends Node2D
class_name Customer

@export var anim_speed_scale: float = 1.0
@export var speed := 120.0
@export var icon_offset := Vector2(0, -180)
@export var item_scene: PackedScene = preload("res://scenes/game_objects/food_objects/item.tscn")

@export var desired_food: String = ""      # set by controller
var order_icon: FoodObjects = null        

@onready var outline: AnimatedSprite2D = $outline
@onready var skin:    AnimatedSprite2D = $skin
@onready var clothe:  AnimatedSprite2D = $clothe
@onready var pant:    AnimatedSprite2D = $pant
@onready var shoes:   AnimatedSprite2D = $shoes
@onready var hair:    AnimatedSprite2D = $hair

var _target: Vector2
var _arrive_epsilon := 2.0
var state := "queue_left"  # "ordering", "queue_right", "serving", "exit"
var _is_moving := false

func _ready() -> void:
	randomize()
	_randomize_colors()
	_play_all_synced()

func set_order(food: String) -> void:
	desired_food = food

func _show_order_icon() -> void:
	var item_name = desired_food
	# Remove previous icon if any
	if order_icon and is_instance_valid(order_icon):
		order_icon.queue_free()

	order_icon = item_scene.instantiate() as FoodObjects
	order_icon.item_name = item_name
	order_icon.sprite.scale = Vector2(50, 50)
	order_icon.position = icon_offset
	order_icon.z_index = 5
	add_child(order_icon)

func move_to(p: Vector2) -> void:
	_target = p
	
func _process(delta: float) -> void:
	var d := (_target - global_position)
	var will_move := d.length() > _arrive_epsilon

	if will_move != _is_moving:
		_set_anim_playing(will_move)
		_is_moving = will_move

	if will_move:
		global_position += d.normalized() * speed * delta

func arrived() -> bool:
	return global_position.distance_to(_target) <= _arrive_epsilon

func hide_icon():
	if order_icon:
		order_icon.queue_free()
		order_icon = null
# --------------------------------------------
# 🎨 Color randomization
# --------------------------------------------
func _randomize_colors() -> void:
	# --- Skin tones from reference (converted H,S,V to 0–1 range) ---
	var skin_palette: Array[Color] = [
		Color.ANTIQUE_WHITE,
		Color.BISQUE,
		Color.BLANCHED_ALMOND,
		Color.DARK_SALMON,
		Color.MISTY_ROSE,
		Color.CHOCOLATE,
		Color.SADDLE_BROWN,
		Color.SIENNA,
		Color.BURLYWOOD
	]
	skin.modulate = skin_palette[randi() % skin_palette.size()]
	
	var hair_palette: Array[Color] = [
		Color.ALICE_BLUE,
		Color.BLACK,
		Color.BLUE,
		Color.DARK_GREEN,
		Color.FIREBRICK,
		Color.DARK_GOLDENROD,
		Color.GOLDENROD,
		Color.GRAY,
		Color.BROWN,
		Color.DIM_GRAY,
		Color.BLACK
	] 

	# --- Other parts ---
	clothe.modulate = _rand_color_hsv(0.0, 1.0, 0.6, 1.0, 0.8, 1.0)
	pant.modulate   = _rand_color_hsv(0.0, 1.0, 0.2, 0.6, 0.5, 0.9)
	shoes.modulate  = _rand_color_hsv(0.0, 1.0, 0.0, 0.2, 0.2, 0.6)
	hair.modulate   = hair_palette[randi() % hair_palette.size()]
	outline.modulate = Color(0, 0, 0, 1)


func _rand_color_hsv(h_lo: float, h_hi: float, s_lo: float, s_hi: float, v_lo: float, v_hi: float) -> Color:
	var h = randf_range(h_lo, h_hi)
	var s = randf_range(s_lo, s_hi)
	var v = randf_range(v_lo, v_hi)
	return Color.from_hsv(h, s, v, 1.0)


# --------------------------------------------
# 🕺 Animation sync
# --------------------------------------------
func _play_all_synced() -> void:
	var gender_is_male := (randi() & 1) == 0
	var hair_anim := "man_hair" if gender_is_male else "women_hair"

	_safe_play(outline, "outline")
	_safe_play(skin, "skin")
	_safe_play(clothe, "clothe")
	_safe_play(pant, "pants")
	_safe_play(shoes, "shoes")
	_safe_play(hair, hair_anim)

	for s in [outline, skin, clothe, pant, shoes, hair]:
		if s:
			s.stop()
			s.frame = 0
			s.speed_scale = anim_speed_scale
			s.play()

func _safe_play(sprite: AnimatedSprite2D, anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.animation = anim_name

func reroll() -> void:
	_randomize_colors()
	_play_all_synced()
	
func _set_anim_playing(moving: bool) -> void:
	for s in [outline, skin, clothe, pant, shoes, hair]:
		if s == null:
			continue
		if moving:
			# only call if not already playing
			if not s.is_playing():
				s.speed_scale = anim_speed_scale
				s.play()
		else:
			# stop and optionally snap to first frame
			if s.is_playing():
				s.stop()
			# comment out the next line if you want to freeze on the current frame
			s.frame = 0
			# speed_scale doesn't matter when stopped, but set to 0 for clarity
			s.speed_scale = 0.0
