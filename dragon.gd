
extends KinematicBody2D

# Member variables
const MAX_SPEED = 300.0
const IDLE_SPEED = 10.0
const ACCEL = 5.0
const VSCALE = 0.5
const SHOOT_INTERVAL = 0.3

var speed = Vector2()
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
	shoot_countdown -= delta
	var dir = Vector2()
	if (Input.is_action_pressed("up")):
		dir += Vector2(0, -1)
	if (Input.is_action_pressed("down")):
		dir += Vector2(0, 1)
	if (Input.is_action_pressed("left")):
		dir += Vector2(-1, 0)
	if (Input.is_action_pressed("right")):
		dir += Vector2(1, 0)
	
	if (dir != Vector2()):
		dir = dir.normalized()
	speed = speed.linear_interpolate(dir*MAX_SPEED, delta*ACCEL)
	var motion = speed*delta
	motion.y *= VSCALE
	motion = x(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)

	var next_anim = ""
	
	
	if (dir == Vector2() and speed.length() < IDLE_SPEED):
		next_anim = "idle"
	
	elif (speed.length() > IDLE_SPEED*0.1):
		var angle = atan2(speed.x, speed.y)
		
	
		
		inc_to_frame_map = {
								0: 10, #E
								1: 10, #NE
								2: 10, #N
								3: 10, #NW
								4: 10, #W
								5: 10, #SW
								6: 10, #S
								7: 10, #SE
		}
		
				
		
		# east
		if (angle > -angle_inc and angle < angle_inc):
			next_anim = "bottom"
		# northeast
		elif (angle > angle_inc and angle < 2*angle_inc):
			next_anim = "bottom_left"
		elif (angle < PI*2/4 + PI/8):
			next_anim = "left"
		elif (angle < PI*3/4 + PI/8):
			next_anim = "top_left"
		else:
			next_anim = "top"
	
	
#	if (next_anim != current_anim or next_mirror != current_mirror):
#		get_node("frames").set_flip_h(next_mirror)
#		get_node("anim").play(next_anim)
#		current_anim = next_anim
#		current_mirror = next_mirror

func _get_quantized_angle(angle):
	var angle_inc = PI/8
	var angle_lower_bound = -angle_inc
	var	angle_upper_bound = angle_inc
		for i in range(8):
			if angle >= angle_lower_bound and angle < angle_upper_bound:
				return i
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
	
	
