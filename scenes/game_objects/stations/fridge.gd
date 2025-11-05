extends Station

@export var selector: Sprite2D
@export var click: AudioStreamPlayer2D
@export var interact: AudioStreamPlayer2D

var index := 0
var ingredients := ["potato", "haddock", "turnip", "pluck", "ox_bung", "dough", "mars"]

func toggle():
	interact.play()
	if selector.visible: #close fridge
		selector.hide()
		index = 0
		selector.region_rect.position.y = 0
		#tilemap.set_cell()
	else: # open fridge
		selector.show()

func next():
	click.play()
	if index < 6:
		index += 1
		selector.region_rect.position.y += 32
	else:
		index = 0
		selector.region_rect.position.y = 0
	
func previous():
	click.play()
	if index > 0:
		index -= 1
		selector.region_rect.position.y -= 32
	else:
		index = 6
		selector.region_rect.position.y = 192
