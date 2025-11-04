extends Node
class_name RecipeManager

var recipes = {
	"oven": [
		{
			"ingredients": ["dough"],
			"output": "shortbread",
			"time": 1.0
		},
	],
	"pot": [
		{
			"ingredients": ["potato"],
			"output": "boiled_potato",	
			"time": 10.0
		},
		{
			"ingredients": ["turnip"],
			"output": "boiled_turnip",	
			"time": 10.0
		},
		{
			"ingredients": ["potato", "haddock"],
			"output": "cullen_skink",
			"time": 20.0
		},
		{
			"ingredients": ["raw_haggis"],
			"output": "cooked_haggis",	
			"time": 10.0
		},
		{
			"ingredients": ["pluck"],
			"output": "boiled_pluck",	
			"time": 10.0
		},
	],
	"deep_fryer" :[
		{
			"ingredients": ["mars"],
			"output": "deep_fried_mars",	
			"time": 10.0
		},
		{
			"ingredients": ["haddock"],
			"output": "fried_fish",	
			"time": 10.0
		},
		{
			"ingredients": ["chopped_potato"],
			"output": "chips",
			"time": 10.0
		},
	],
	"chopping_board" :[
		{
			"ingredients": ["haddock"],
			"output": "chopped_haddock",	
			"chops": 5
		},
		{
			"ingredients": ["potato"],
			"output": "chopped_potato",
			"chops": 5
		},
		{
			"ingredients": ["boiled_potato"],
			"output": "tatties",	
			"chops": 5
		},
		{
			"ingredients": ["boiled_turnip"],
			"output": "neeps",	
			"chops": 5
		},
		{
			"ingredients": ["boiled_pluck"],
			"output": "minced_pluck",	
			"chops": 5
		},
	],
	"mix": [
		{
			"ingredients": ["fried_fish", "chips"],
			"output": "fish_and_chips",	
		},
		{
			"ingredients": ["minced_pluck", "ox_bung"],
			"output": "raw_haggis",	
		},
	]
}

func get_recipe_for(station_type: String, ingredients: Array) -> Dictionary:
	if not recipes.has(station_type):
		print("station type not found")
		return {}

	var input_sorted = ingredients.duplicate()
	input_sorted.sort()
	
	for recipe in recipes[station_type]:
		var recipe_ingredients = recipe["ingredients"].duplicate()
		recipe_ingredients.sort()
		if input_sorted == recipe_ingredients:
			return recipe
	
	print("recipe not found")
	return {}
