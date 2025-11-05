extends VBoxContainer
class_name KeyHint

const KB_ICONS := {
	"SPACE": preload("res://sprites/ui/space.png"),
	"F": preload("res://sprites/ui/f.png"),
	"A": preload("res://sprites/ui/a.png"),
	"D": preload("res://sprites/ui/d.png"),
}

# Clear current hint and show one
func set_hint(verb: String, action: String) -> void:
	clear_hints()
	add_hint(verb, action)
	visible = true

func set_multi_hint(actions: Array) -> void:
	clear_hints()
	for a in actions:
		var verb := String(a.get("verb", ""))
		var act  := String(a.get("action", ""))
		if verb != "" and act != "":
			add_hint(verb, act)
	visible = get_child_count() > 0


# Add one hint element
func add_hint(verb: String, action: String) -> void:
	var icon_tex := _find_icon_for_action(action)
	var box := HBoxContainer.new()

	var tex := TextureRect.new()
	tex.texture = icon_tex
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if action == "interact":
		tex.custom_minimum_size = Vector2(80, 80)
	else:
		tex.custom_minimum_size = Vector2(48, 48)
	var lbl := Label.new()
	lbl.text = verb
	lbl.add_theme_font_size_override("font_size", 25)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	lbl.add_theme_constant_override("outline_size", 10)  # try 2–6
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	box.add_child(tex)
	box.add_child(lbl)
	add_child(box)


func hide_hint() -> void:
	visible = false

func clear_hints() -> void:
	for c in get_children():
		c.queue_free()

func _find_icon_for_action(action: String) -> Texture2D:
	var evs := InputMap.action_get_events(action)
	for e in evs:
		if e is InputEventKey:
			var name := OS.get_keycode_string(e.physical_keycode).to_upper()
			if KB_ICONS.has(name):
				return KB_ICONS[name]
	return KB_ICONS.get("SPACE", null)
