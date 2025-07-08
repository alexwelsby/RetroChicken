extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var game_map = get_parent()
	if game_map:
		game_map.connect_mailbox_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
