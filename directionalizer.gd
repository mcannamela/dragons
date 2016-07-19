extends "res://base_directionalizer.gd"

var input_direction = Vector2()

var up_command = 'move_up'
var down_command = 'move_down'
var left_command = 'move_left'
var right_command = 'move_right'

const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)


func _ready():
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
 
func _process(delta):
	update_input_direction()
	
func update_input_direction():
	input_direction = _compute_input_direction()
	_set_direction_label()
	_set_quantized_direction_label(get_quantized_angle())
	get_node('arrow').set_rot(input_direction.angle())

func has_direction():
	return input_direction != Vector2()
	
func get_quantized_angle():
	return compute_quantized_angle(input_direction.angle())
	
func _compute_input_direction():
	var input_direction = Vector2()
	
	if _is_pressed(up_command):
		input_direction += up
	if _is_pressed(down_command):
		input_direction += down
	if _is_pressed(left_command):
		input_direction += left
	if _is_pressed(right_command):
		input_direction += right
	
	if input_direction != Vector2():
		input_direction = input_direction.normalized()
	return input_direction

func _is_pressed(command):
	return Input.is_action_pressed(command)

func _set_direction_label():
	var angle = input_direction.angle()
	var s = "%f" % [angle]
	get_node("direction").set_text(s)
	
func _set_quantized_direction_label(q):
	var s = "%d" % [q]
	get_node("quantized_direction").set_text(s)