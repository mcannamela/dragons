
extends Node2D

var _direction = Vector2()

static func compute_quantized_angle(angle):
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

func set_direction(d):
	_direction = d
	_set_direction_label()
	_set_quantized_direction_label()
	_set_arrow_rot()

func get_direction():
	return Vector2(_direction)

func has_direction():
	return _direction != Vector2()
	
func get_quantized_angle():
	return compute_quantized_angle(_direction.angle())
	
func _set_direction_label():
	var angle = _direction.angle()
	var s = "%f" % [angle]
	get_node("direction").set_text(s)
	
func _set_quantized_direction_label():
	var q = get_quantized_angle()
	var s = "%d" % [q]
	get_node("quantized_direction").set_text(s)

func _set_arrow_rot():
	get_node('arrow').set_rot(_direction.angle())



