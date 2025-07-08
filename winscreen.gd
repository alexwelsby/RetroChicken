extends Control

var chicken_sprite
#var microraptor_percentage
var chicken_traits = []

var chicken_image
var percentage_label
var traits_label
var continue_button
var congrats_label

var whole_panel

func _ready():
	chicken_image = $VBoxContainer/TextureRect
	percentage_label = $panel/MicrorapterPercentLabel
	traits_label = $panel/traits  # Updated path for traits_label
	continue_button = $panel/ContinueButton  # Ensure this matches the button's name
	congrats_label = $panel/CongratsLabel
	whole_panel = $Panel
	
	

	# Connect the "pressed" signal of the continue button to a function
	#continue_button.connect("pressed", self, "_on_continue_button_pressed")

func display_win_screen(microraptor_traits, microraptor_percentage):
	# Display the chicken's traits and microraptor percentage
	if percentage_label:
		$panel/MicrorapterPercentLabel.text = "Microraptor Percentage: " + str(microraptor_percentage) + "%"
	else:
		print("Error: percentage_label node not found")
	if traits_label:
		traits_label.text = "Microraptor traits : " + str(microraptor_traits) 
	else:
		print("Error: traits_label node not found")

	

	# Make the win screen visible
	visible = true

func _on_continue_button_pressed():
	# Hide the win screen and allow the player to continue
	visible = false
	queue_free()  # Remove the win screen from the scene
	# Change to the main game scene if needed
	# get_tree().change_scene("res://scenes/gameMap.tscn")
