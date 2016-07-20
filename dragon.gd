
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

func bind_controls(player_id):
	if player_id == null:
		_get_breath_directionalizer().unbind_commands()
		_get_move_directionalizer().unbind_commands()
		
func hide_debug_nodes():
	_get_breath_directionalizer().hide()
	_get_move_directionalizer().hide()
	
func show_debug_nodes():
	_get_breath_directionalizer().show()
	_get_move_directionalizer().show()
	
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	_bind_breath_directionalizer()
	_bind_move_directionalizer()
	_bind_on_burn_notice()

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
	_update_quantized_direction_if_necessary()
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
		b.set_breathing(true)
		b.set_pos(32*d)
		b.set_rot(d.angle())
	else:
		b.set_breathing(false)
		
func _update_quantized_direction_if_necessary():
	if (speed.length() > IDLE_SPEED*0.1):
		var angle = speed.angle()
		quantized_direction = _get_quantized_angle(angle)

func _bind_breath_directionalizer():
	var d = _get_breath_directionalizer()
	d.up_command = 'breathe_up'
	d.down_command = 'breathe_down'
	d.left_command = 'breathe_left'
	d.right_command = 'breathe_right'

	d.set_process_input(false)
	d.set_process(false)
	d.set_fixed_process(false)

func _bind_move_directionalizer():
	var d = _get_move_directionalizer()
	d.up_command = 'move_up'
	d.down_command = 'move_down'
	d.left_command = 'move_left'
	d.right_command = 'move_right'

	d.set_process_input(false)
	d.set_process(false)
	d.set_fixed_process(false)
	
func _bind_on_burn_notice():
	_get_breath().connect("burn_notice", self, "_on_burn_notice")
	
func _on_burn_notice(damage, body_id):
	var hitbox_id = _get_hitbox().get_instance_ID()
	var dragon_id = self.get_instance_ID()
	if body_id == dragon_id:
		_get_hp_bar().decrement(damage)
		
func _is_breathing():
	return _get_breath_directionalizer().has_direction()
		
func _get_new_speed(delta):
	var new_speed
	new_speed = speed.linear_interpolate(dir*MAX_SPEED, delta*ACCEL)
	return new_speed

func _get_input_direction():
	var d = _get_move_directionalizer()
	d.update_direction_from_input()
	return d.get_direction()

func _get_breath_input_direction():
	var d = _get_breath_directionalizer()
	d.update_direction_from_input()
	return d.get_direction()

func _get_quantized_angle(angle):
	return _get_breath_directionalizer().compute_quantized_angle(angle)
			
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
	
func _set_sprite_frame(n):
	_get_sprite().set_frame(n)

func _get_sprite():
	return get_node("sprite")
	
func _get_breath():
	return get_node("breath")

func _get_breath_directionalizer():
	return get_node("breath_directionalizer")

func _get_move_directionalizer():
	return get_node("move_directionalizer")
	
func _get_hitbox():
	return get_node("hitbox")
	
func _get_hp_bar():
	return get_node("hp_bar")
	
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
	
