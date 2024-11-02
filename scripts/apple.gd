extends Node2D


var shop_info = {
	"name": "Nuclear Incubator",
	"price": 200,
	"description": "Increases chance of mutation",
	"texture": "res://sprites/shop/nuclearIncubator.png"
}


func _on_apple_area_entered(area):
	if area.name == "EatBody": #checking if we have a chicken
		var chicken = area.get_parent()
		print("is_carnivorous:", chicken.is_carnivorous)
		if chicken.is_carnivorous == false: #only omnivores can eat pumpkin
			chicken.detected_bodies = [] #resetting things
			chicken.bodyFound = false
			self.queue_free()
