extends CanvasGroup

@export var name_display: Label
@export var hover_regions: Area2D

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var text_to_show = "Hover for Item Name"

	for region in hover_regions.get_children():
		var region_pos = region.global_position
		var region_extent = region.shape.extents
		
		var min_x = min(region_pos.x - region_extent.x, region_pos.x + region_extent.x)
		var max_x = max(region_pos.x - region_extent.x, region_pos.x + region_extent.x)
		var min_y = min(region_pos.y - region_extent.y, region_pos.y + region_extent.y)
		var max_y = max(region_pos.y - region_extent.y, region_pos.y + region_extent.y)

		# Check if mouse is inside
		if mouse_pos.x >= min_x and mouse_pos.x <= max_x \
		and mouse_pos.y >= min_y and mouse_pos.y <= max_y:
			text_to_show = region.get("change_text_to")
			break

	name_display.text = text_to_show
