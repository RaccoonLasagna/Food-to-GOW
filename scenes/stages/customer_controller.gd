extends Node
class_name CustomerController

@export var spawn_point: Node2D
@export var left_line_anchor: Node2D      # front of LEFT line
@export var right_line_anchor: Node2D     # front of RIGHT line
@export var exit_point: Node2D

@export var line_spacing := 18.0
@export var customer_scene: PackedScene
@export var menu_items: PackedStringArray = ["haddock", "chips", "fried_fish", "shortbread"]

var left_queue: Array[Customer] = []
var right_queue: Array[Customer] = []

func _ready():
	assert(customer_scene, "Assign a Customer scene to CustomerController.customer_scene")

func spawn_customer() -> Customer:
	var c: Customer = customer_scene.instantiate()
	get_tree().current_scene.add_child(c)
	c.global_position = spawn_point.global_position
	c.scale = Vector2(0.1, 0.1)
	c.z_index = 2
	c.set_order(Array(menu_items).pick_random())
	c.state = "queue_left"
	left_queue.append(c)
	_reflow_left()
	return c

func _process(_dt): # no auto-moving to order/serve points anymore
	pass

func _reflow_left():
	for i in range(left_queue.size()):
		var c := left_queue[i]
		var tgt := left_line_anchor.global_position + Vector2(0, i * line_spacing)
		c.move_to(tgt)

func _reflow_right():
	for i in range(right_queue.size()):
		var c := right_queue[i]
		var tgt := right_line_anchor.global_position + Vector2(0, i * line_spacing)
		c.move_to(tgt)

# === API used by stations ===

# OrderStation: move the person at the front of LEFT line to the RIGHT line
func move_front_left_to_right() -> Customer:
	if left_queue.is_empty(): return null
	var c = left_queue.pop_front()
	_reflow_left()
	c.state = "queue_right"
	c._show_order_icon()
	right_queue.append(c)
	_reflow_right()
	return c

# ServeStation: peek the person at the front of RIGHT line
func peek_front_right() -> Customer:
	if right_queue.is_empty(): return null
	return right_queue.front()

# ServeStation: after serving, send front RIGHT line person to EXIT and free later
func exit_front_right() -> void:
	if right_queue.is_empty(): return
	var c = right_queue.pop_front()
	_reflow_right()
	c.state = "exit"
	c.move_to(exit_point.global_position)
	c.hide_icon()
	await get_tree().create_timer(1.0).timeout
	c.queue_free()
