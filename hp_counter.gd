
extends ProgressBar

func _ready():
	
	self.set_percent_visible(true)
	set_max(100.0)
	set_min(0.0)
	set_unit_value(1.0)
	
func decrement(hp):
	var new_val = max(get_value() - hp, get_min())
	set_value(new_val)
	
func increment(hp):
	var new_val = min(get_value() + hp, get_max())
	set_value(new_val)
	