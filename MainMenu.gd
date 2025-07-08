extends Control

func _on_start_pressed(): # Start button pressed
	get_tree().change_scene_to_file("res://UI/Story.tscn")

func _on_credits_pressed(): # Credits Button pressed
	get_tree().change_scene_to_file("res://UI/Credits.tscn")
	
func _on_quit_pressed(): # Quit button pressed
	get_tree().quit()



func _on_start_mouse_entered():
	$MarginContainer/Buttons/VBoxContainer/Start/Egg.visible = true
func _on_start_mouse_exited():
	$MarginContainer/Buttons/VBoxContainer/Start/Egg.visible = false


func _on_credits_mouse_entered():
	$MarginContainer/Buttons/VBoxContainer/Credits/Egg.visible = true
func _on_credits_mouse_exited():
	$MarginContainer/Buttons/VBoxContainer/Credits/Egg.visible = false


func _on_quit_mouse_entered():
	$MarginContainer/Buttons/VBoxContainer/Quit/Egg.visible = true
func _on_quit_mouse_exited():
	$MarginContainer/Buttons/VBoxContainer/Quit/Egg.visible = false
