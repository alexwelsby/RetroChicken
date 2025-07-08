extends Node2D

# Node reference
@onready var animation_player = $AnimationPlayer


func _on_menu_pressed():
	# Change scene to the main menu
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")


func _on_replay_button_pressed():
	animation_player.stop()
	animation_player.play()
