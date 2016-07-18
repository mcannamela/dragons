
extends KinematicBody2D

# Member variables
const MAX_SPEED = 300.0
const IDLE_SPEED = 10.0
const ACCEL = 5.0
const VSCALE = 0.5
const SHOOT_INTERVAL = 0.3

var speed = Vector2()
var dir = Vector2()
var flap_phase = 0
var current_anim = ""
var current_mirror = false

var shoot_countdown = 0


#func _input(event):
#	if (event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.pressed and shoot_countdown <= 0):
#		var pos = get_canvas_transform().affine_inverse()*event.pos
#		var dir = (pos - get_global_pos()).normalized()
#		var bullet = preload("res://shoot.tscn").instance()
#		bullet.advance_dir = dir
#		bullet.set_pos(get_global_pos() + dir*60)
#		get_parent().add_child(bullet)
#		shoot_countdown = SHOOT_INTERVAL




func _fixed_process(delta):
	_update_direction_and_speed(delta)
	_move_and_slide_if_necessary(delta)
	_determine_and_set_sprite_frame()
	
func _update_direction_and_speed(delta):
	dir = _get_input_direction()
	speed = _get_new_speed(delta)
	_set_direction_label()
	_set_speed_label()
	
func _move_and_slide_if_necessary(delta):
	var motion = speed*delta
	motion.y *= VSCALE
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)

func _determine_and_set_sprite_frame():
	if (speed.length() > IDLE_SPEED*0.1):
		# angle from (0, 1), which is , clockwise positive, between -pi and pi
		var angle = speed.angle()
		var quantized_angle = _get_quantized_angle(angle)
		
		_set_quantized_direction_label(quantized_angle)
		
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
		_set_sprite_frame(frame)
		
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

func _get_quantized_angle(angle):
	# angle as from atan2, between -pi and pi
	var angle_inc = PI/4.0	
	
	
	# eliminate edge case
	if angle < -7*PI/8 or angle > 7*PI/8:
		return 0
		
	# all other cones contained in interval
	var angle_lower_bound = -7*PI/8
	var	angle_upper_bound = angle_lower_bound + angle_inc
	
	for i in range(7):
		if angle >= angle_lower_bound and angle < angle_upper_bound:
			return i + 1
		else:
			angle_lower_bound += angle_inc
			angle_upper_bound += angle_inc
	

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _set_sprite_frame(n):
	_get_sprite().set_frame(n)

func _get_sprite():
	return get_node("sprite")
	
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
	
	
