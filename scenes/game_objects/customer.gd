extends Node2D

@export var anim_speed_scale: float = 1.0

@onready var outline: AnimatedSprite2D = $outline
@onready var skin:    AnimatedSprite2D = $skin
@onready var clothe:  AnimatedSprite2D = $clothe
@onready var pant:    AnimatedSprite2D = $pant
@onready var shoes:   AnimatedSprite2D = $shoes
@onready var hair:    AnimatedSprite2D = $hair


func _ready() -> void:
	randomize()
	_randomize_colors()
	_play_all_synced()


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
