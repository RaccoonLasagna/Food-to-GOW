extends Station

@export var selector: Sprite2D
@onready var tilemap: TileMap = self.get_parent().get_parent().get_child(0)

var index := 0
var ingredients := ["potato", "haddock", "turnip", "pluck", "ox_bung", "dough", "mars"]

func toggle():
	if selector.visible: #close fridge
		selector.hide()
		index = 0
		selector.region_rect.position.y = 0
		#tilemap.set_cell()
	else: # open fridge
		selector.show()

func next():
	print("tile: ", tilemap.local_to_map(position))
	if index < 6:
		index += 1
		selector.region_rect.position.y += 32
	else:
		index = 0
		selector.region_rect.position.y = 0
	
func previous():
	if index > 0:
		index -= 1
		selector.region_rect.position.y -= 32
	else:
		index = 6
		selector.region_rect.position.y = 192
