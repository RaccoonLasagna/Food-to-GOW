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
			"ingredients": ["potato", "haddock"],
			"output": "cullen_skink",
			"time": 20.0
		}
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
