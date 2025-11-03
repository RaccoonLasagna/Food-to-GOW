extends Node2D

class_name FoodObjects

@export var item_name: String
@export var sprite: Sprite2D

func _ready() -> void:
	self.add_to_group("items")
	update_texture()

func update_texture():
	var texture
	match item_name:
		"ash":
			texture = load("res://sprites/placeholders/ash.jpg")
		"pluck":
			texture = load("res://sprites/placeholders/pluck.jpg")
		"boiled_pluck":
			texture = load("res://sprites/placeholders/boiled-pluck.jpg")
		"minced_pluck":
			texture = load("res://sprites/placeholders/minced_pluck.jpg")
		"ox_bung":
			texture = load("res://sprites/placeholders/ox_bung.jpg")
		"raw_haggis":
			texture = load("res://sprites/placeholders/raw_haggis.jpg")
		"cooked_haggis":
			texture = load("res://sprites/placeholders/cooked_haggis.jpg")
		"turnip":
			texture = load("res://sprites/placeholders/turnip.jpg")
		"boiled_turnip":
			texture = load("res://sprites/placeholders/boiled_turnip.jpg")
		"neeps":
			texture = load("res://sprites/placeholders/neeps.jpg")
		"potato":
			texture = load("res://sprites/placeholders/potato.jpg")
		"boiled_potato":
			texture = load("res://sprites/placeholders/boiled-potato.jpg")
		"tatties":
			texture = load("res://sprites/placeholders/mashed-potatoes-recipe.jpg")
		"haggis_neeps_and_tatties":
			texture = load("res://sprites/placeholders/haggis_neeps_and_tatties.jpg")
		"chopped_potato":
			texture = load("res://sprites/placeholders/chopped_potato.jpg")
		"chips":
			texture = load("res://sprites/placeholders/chips.jpg")
		"haddock":
			texture = load("res://sprites/placeholders/haddock.jpg")
		"fried_fish":
			texture = load("res://sprites/placeholders/fried_fish.jpeg")
		"fish_and_chips":
			texture = load("res://sprites/placeholders/Fish_and_chips.jpg")
		"chopped_haddock":
			texture = load("res://sprites/placeholders/chopped_haddock.jpg")
		"cullen_skink":
			texture = load("res://sprites/placeholders/cullen-skinkjpg.jpg")
		"dough":
			texture = load("res://sprites/placeholders/dough.jpg")
		"shortbread":
			texture = load("res://sprites/placeholders/shortbread.jpg")
		"mars":
			texture = load("res://sprites/placeholders/mars.png")
		"deep_fried_mars":
			texture = load("res://sprites/placeholders/DeepFriedMarsBar.jpg")
		_:
			texture = load("res://icon.svg")
	var image = texture.get_image()
	var new_texture = ImageTexture.create_from_image(image)
	sprite.texture = new_texture
