extends Node2D
class_name FoodObjects

@export var item_name: String
@onready var sprite: Sprite2D = $Sprite2D

const SHEET := preload("res://sprites/foods/foods.png")
const HFRAMES := 7
const VFRAMES := 4

const POS := {
	"pluck":             Vector2i(0, 0),
	"ox_bung":           Vector2i(1, 0),
	"dough":             Vector2i(2, 0),
	"mars":              Vector2i(3, 0),
	"potato":            Vector2i(4, 0),
	"chopped_haddock":   Vector2i(5, 0),
	"turnip":            Vector2i(6, 0),
	
	"haddock":           Vector2i(0, 1),
	"fried_fish":        Vector2i(1, 1),
	"minced_pluck":      Vector2i(2, 1),
	"ash":               Vector2i(3, 1),
	"chopped_potato":    Vector2i(4, 1),
	"cullen_skink":    Vector2i(5, 1),
	"chopped_turnips":      Vector2i(6, 1),

	"deep_fried_mars":   Vector2i(0, 2),
	"boiled_pluck":        Vector2i(1, 2),
	"raw_haggis":        Vector2i(2, 2),
	"boiled_potato":      Vector2i(3, 2),
	"tatties":            Vector2i(4, 2),
	"neeps":              Vector2i(5, 2),
	"boiled_turnip":      Vector2i(6, 2),

	"cooked_haggis":      Vector2i(0, 3),
	"cooked_haggis_and_tatties":Vector2i(1, 3),
	"chips":              Vector2i(2, 3),
	"fish_and_chips":     Vector2i(3, 3),
	"cooked_haggis_and_neeps":Vector2i(4, 3),
	"cooked_haggis_neeps_and_tatties":Vector2i(5, 3),
	"shortbread":         Vector2i(6, 3),
}

func _ready() -> void:
	add_to_group("items")
	_use_sheet()
	_set_item_frame(item_name)

func _use_sheet() -> void:
	sprite.texture = SHEET
	sprite.hframes = HFRAMES
	sprite.vframes = VFRAMES
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _set_item_frame(item: String) -> void:
	var p: Vector2i = POS.get(item, Vector2i.ZERO)
	sprite.frame = p.y * HFRAMES + p.x
