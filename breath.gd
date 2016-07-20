
extends Particles2D

const burn_time = .5

var _breathing = false

var _bodies_in_damage_cone = {}
var _burn_time_remaining_by_body = {}

func set_breathing(breathing):
	_breathing = breathing
	self.set_emitting(_breathing)
	if not _breathing:
		_get_burnination_indicator().hide()
		
func is_burning(body):
	return _bodies_in_damage_cone.has(body)
	
func has_burn_time_remaining(body):
	return _burn_time_remaining_by_body.has(body)

func get_burn_time_remaining(body):
	return _burn_time_remaining_by_body[body]
	
func _update_burn_time(delta):
	for body in _burn_time_remaining_by_body.keys():
		_burn_time_remaining_by_body[body] -= burn_time
		
	for body in _bodies_in_damage_cone.keys():
		_burn_time_remaining_by_body[body] = burn_time
	
	var extinguished_bodies = []
	for body in _burn_time_remaining_by_body.keys():
		if _burn_time_remaining_by_body[body]<=0:
			extinguished_bodies.append(body)
	
	for body in extinguished_bodies:
		_burn_time_remaining_by_body.erase(body)

func _ready():
	set_process(true)
	
func _process(delta):
	_update_burn_time(delta)
	
	if _bodies_in_damage_cone.empty():
		_get_burnination_indicator().hide()
	elif _breathing:
		_get_burnination_indicator().show() 
		
		
	
func hide_debug_nodes():
	_get_damage_cone().hide()
	
func show_debug_nodes():
	_get_damage_cone().hide()
	
func _get_damage_cone():
	return get_node("damage_cone")

func _on_damage_cone_body_enter( body ):
	_bodies_in_damage_cone[body] = null
	
func _on_damage_cone_body_exit( body ):
	if _bodies_in_damage_cone.has(body):
		_bodies_in_damage_cone.erase(body)
	
func _get_burnination_indicator():
	return get_node("burnination_indicator")



