extends Node2D

var shop_info = {
	"name": "Chicken feed",
	"price": 50,
	"description": "Feed your omnivorous chickens.",
}

func _on_feed_to_eat_area_entered(area):
	if area.name == "EatBody": #checking if we have a chicken
		var chicken = area.get_parent()
		print("is_carnivorous:", chicken.is_carnivorous)
		if chicken.is_carnivorous == false: #only omnivores can eat seed
			chicken.detected_bodies = [] #resetting things
			chicken.bodyFound = false
			self.queue_free()
