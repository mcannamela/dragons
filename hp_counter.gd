
extends ProgressBar

func _ready():
	set_process(true)
	self.set_percent_visible(true)
	set_max(100.0)
	set_min(0.0)
	set_unit_value(1.0)
	
func _process(delta):
	update()

	
func _decrement(hp):
	var new_val = get_value() - hp
	set_value(hp)
	
func _increment(hp):
	var new_val = get_value() + hp
	set_value(hp)
	