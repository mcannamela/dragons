
extends Particles2D

const burn_time = .5

var _breathing = false

var _bodies_in_damage_cone = {}
var _burn_time_remaining_by_body = {}
var _damage_per_second = 10.0
var _hide_debug_bodies = false

signal burn_notice(damage, burning_body_id)

func _ready():
	set_process(true)
	
func _process(delta):
	_burninate_as_necessary(delta)
	_show_burnination_indicator_if_necessary()
	_set_igniting_body_ids_label()
		
func hide_debug_nodes():
	_get_damage_cone().hide()
	
func show_debug_nodes():
	_get_damage_cone().hide()
	
func get_damage_per_second():
	return _damage_per_second
	
func set_damage_per_second(dps):
	_damage_per_second = dps
	
func set_breathing(breathing):
	_breathing = breathing
	self.set_emitting(_breathing)
	if not _breathing:
		_get_burnination_indicator().hide()
		
func is_being_ignited(body):
	return _bodies_in_damage_cone.has(body)
	
func has_burn_time_remaining(body):
	return _burn_time_remaining_by_body.has(body) and get_burn_time_remaining(body) > 0

func get_burn_time_remaining(body):
	return _burn_time_remaining_by_body[body]
	
func _burninate_as_necessary(delta):
	_decrement_burn_time_remaining(delta)
	_reignite_bodies_if_necessary()
	_extinguish_bodies_if_necessary()
	
func _decrement_burn_time_remaining(delta):
	for body in _burn_time_remaining_by_body.keys():
		_send_burn_notice(delta, body)
		_burn_time_remaining_by_body[body] -= delta
		
func _reignite_bodies_if_necessary():
	for body in _bodies_in_damage_cone.keys():
		_burn_time_remaining_by_body[body] = burn_time
		
func _extinguish_bodies_if_necessary():
	var extinguished_bodies = []
	for body in _burn_time_remaining_by_body.keys():
		if _burn_time_remaining_by_body[body]<=0:
			extinguished_bodies.append(body)
	
	for body in extinguished_bodies:
		_burn_time_remaining_by_body.erase(body)
		
func _send_burn_notice(delta, body):
	var remaining_burn = _burn_time_remaining_by_body[body]
	var burn_damage = min(delta, remaining_burn)*_damage_per_second
	emit_signal('burn_notice', burn_damage, body.get_instance_ID())
	
func _show_burnination_indicator_if_necessary():
	if _bodies_in_damage_cone.empty():
		_get_burnination_indicator().hide()
	elif _breathing and not _bodies_in_damage_cone.empty() and not _hide_debug_bodies:
		_get_burnination_indicator().show()
			
func _get_damage_cone():
	return get_node("damage_cone")

func _on_damage_cone_body_enter( body ):
	_bodies_in_damage_cone[body] = null
	
func _on_damage_cone_body_exit( body ):
	if _bodies_in_damage_cone.has(body):
		_bodies_in_damage_cone.erase(body)
	
func _get_burnination_indicator():
	return get_node("burnination_indicator")
	
func _set_igniting_body_ids_label():
	var s = ""
	for body in _bodies_in_damage_cone.keys():
		s = str(s, ", ", body.get_instance_ID())
		
	get_node("igniting_body_ids").set_text(s)



