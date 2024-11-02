extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_viewport().get_mouse_position()
	
