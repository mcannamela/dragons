
extends Particles2D


func _ready():
	set_process(true)
	
func _process(delta):
	update()

func hide_debug_nodes():
	_get_damage_cone().hide()
	
func show_debug_nodes():
	_get_damage_cone().hide()
	
func _get_damage_cone():
	return get_node("damage_cone")