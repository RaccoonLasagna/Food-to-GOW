extends Station

@export var selector: Sprite2D
var index := 0
var ingredients := ["potato", "haddock", "turnip", "pluck", "ox_bung", "dough", "mars"]

func toggle():
	if selector.visible:
		selector.hide()
		index = 0
		selector.region_rect.position.y = 0
	else:
		selector.show()

func next():
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
