extends "res://base_directionalizer.gd"

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
	update_direction_from_input()
	
func update_direction_from_input():
	var input_direction = _compute_input_direction()
	set_direction(input_direction)

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