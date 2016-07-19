
extends KinematicBody2D

# Member variables
const MAX_SPEED = 300.0
const IDLE_SPEED = 10.0
const ACCEL = 5.0
const VSCALE = 0.5
const SHOOT_INTERVAL = 0.3

var speed = Vector2()
var dir = Vector2()

var breath_direction = Vector2()

var flap_phase = 0
var flap_period = .08
var flap_accumulator = 0.0
var quantized_direction = 0

func _fixed_process(delta):
	_update_direction_and_speed(delta)
	_update_flap_phase(delta)
	_update_breath_direction()
	_move_and_slide_if_necessary(delta)
	_determine_and_set_sprite_frame()
	_update_breath()
	
func _update_direction_and_speed(delta):
	dir = _get_input_direction()
	speed = _get_new_speed(delta)
	if (speed.length() > IDLE_SPEED*0.1):
		# angle from (0, 1), which is , clockwise positive, between -pi and pi
		var angle = speed.angle()
		quantized_direction = _get_quantized_angle(angle)
	_set_direction_label()
	_set_speed_label()
	_set_quantized_direction_label(quantized_direction)
	
func _update_flap_phase(delta):
	flap_accumulator += delta
	if flap_accumulator > flap_period:
		flap_accumulator  = flap_accumulator - flap_period
		flap_phase += 1
		var hframes = _get_sprite().get_hframes()
		flap_phase = flap_phase % hframes
		
func _update_breath_direction():
	breath_direction = _get_breath_input_direction()
	
func _move_and_slide_if_necessary(delta):
	var motion = speed*delta
	motion.y *= VSCALE
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)

func _determine_and_set_sprite_frame():
	var key_frame = _get_sprite_key_frame(quantized_direction)
	var frame = key_frame + flap_phase
	_set_sprite_frame(frame)
	
func _update_breath():
	var b = _get_breath()
	var d = breath_direction
	if _is_breathing():
		b.set_emitting(true)
		b.set_pos(32*d)
		b.set_rot(d.angle())
	else:
		b.set_emitting(false)
		
func _is_breathing():
	return breath_direction != Vector2()
		
func _get_new_speed(delta):
	var new_speed
	new_speed = speed.linear_interpolate(dir*MAX_SPEED, delta*ACCEL)
	return new_speed

func _get_input_direction():
	var input_direction = Vector2()
	if (Input.is_action_pressed("move_up")):
		input_direction += Vector2(0, -1)
	if (Input.is_action_pressed("move_down")):
		input_direction += Vector2(0, 1)
	if (Input.is_action_pressed("move_left")):
		input_direction += Vector2(-1, 0)
	if (Input.is_action_pressed("move_right")):
		input_direction += Vector2(1, 0)
	
	if (input_direction != Vector2()):
		input_direction = input_direction.normalized()
	return input_direction
	
func _get_breath_input_direction():
	var input_direction = Vector2()
	if (Input.is_action_pressed("breathe_up")):
		input_direction += Vector2(0, -1)
	if (Input.is_action_pressed("breathe_down")):
		input_direction += Vector2(0, 1)
	if (Input.is_action_pressed("breathe_left")):
		input_direction += Vector2(-1, 0)
	if (Input.is_action_pressed("breathe_right")):
		input_direction += Vector2(1, 0)
	
	if (input_direction != Vector2()):
		input_direction = input_direction.normalized()
	return input_direction

func _get_quantized_angle(angle):
	return get_node("breath_directionalizer").compute_quantized_angle(angle)
			
func _get_sprite_key_frame(quantized_angle):
	var inc_to_frame_map = {
								0: 60, #N
								1: 50, #NW
								2: 40, #W
								3: 30, #SW
								4: 20, #S
								5: 10, #SE
								6: 0, #E
								7: 70, #NE
		}
		
	var frame = inc_to_frame_map[quantized_angle]
	return frame
	
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	var bd = get_node("breath_directionalizer")
	bd.up_command = 'breathe_up'
	bd.down_command = 'breathe_down'
	bd.left_command = 'breathe_left'
	bd.right_command = 'breathe_right'

func _set_sprite_frame(n):
	_get_sprite().set_frame(n)

func _get_sprite():
	return get_node("sprite")
	
func _get_breath():
	return get_node("breath")
	
func _set_direction_label():
	var angle = dir.angle()
	var s = "%f" % [angle]
	get_node("direction_label").set_text(s)
	
func _set_speed_label():
	var angle = speed.angle()
	var s = "%f" % [angle]
	get_node("speed_label").set_text(s)
	
func _set_quantized_direction_label(q):
	var s = "%d" % [q]
	get_node("quantized_direction_label").set_text(s)
	
