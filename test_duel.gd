
extends Node2D


func _ready():
	get_dragon(1).bind_controls(null)
	for d in get_dragons():
		d.hide_debug_nodes()

func get_dragon(dragon_id):
	return get_node("dragon_%d"%(dragon_id))

func get_dragons():
	var dragons = []
	for i in range(2):
		dragons.append(get_dragon(i))
	return dragons
		

