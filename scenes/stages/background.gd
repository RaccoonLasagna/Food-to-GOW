extends Node2D

@export var background_node: CanvasItem          
@export var bg_textures: Array[Texture2D] = []   

func _ready() -> void:
	_apply_bg()

func _apply_bg() -> void:
	if background_node == null or bg_textures.is_empty():
		return
	var idx = clamp(Global.selected_map_index, 0, bg_textures.size() - 1)
	var tex = bg_textures[idx]

	if background_node is Sprite2D:
		(background_node as Sprite2D).texture = tex
	elif background_node is TextureRect:
		(background_node as TextureRect).texture = tex
