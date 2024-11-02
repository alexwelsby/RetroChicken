extends Control

@onready var chicken_feed = preload("res://scenes/chicken_feed.tscn")
@onready var incubator = preload("res://scenes/incubator.tscn")
@onready var apple = preload("res://scenes/apple.tscn")

@onready var chicken_feed_button = $ChickenFeedButton
@onready var incubator_button = $IncubatorButton
@onready var apple_button = $AppleButton
@onready var sprite_2d_debt = $ChickenFeedButton/Sprite2DDebt
@onready var sprite_2d = $ChickenFeedButton/Sprite2D
@onready var place = $place

var cursor_onIncubator = false

var item_selected = null;
var debt = false

var shop_inventory 

var scale_factor = Vector2(2.5, 2.5) # Store scale factor for global use

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to the screen resized signal
	get_tree().connect("screen_resized", Callable(self, "_on_screen_resized"))
	_on_screen_resized()  # Call initially to set scale based on current screen size

	initializeShopInventory()
	
func initializeShopInventory():
	shop_inventory = { 
	"feed": {
		"button": chicken_feed_button,
		"scene": chicken_feed 
		},
	"incubator": { 
		"button": incubator_button, 
		"scene": incubator
		},
	"apple": {
		"button": apple_button,
		"scene": apple
		}
	}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#lets people 'cancel' their purchase by hitting delete/escape
	if Input.is_action_pressed("delete") && item_selected != null || Input.is_action_pressed("escape") && item_selected != null:
		get_parent().remove_child(item_selected)
		change_cursor(null)
		item_selected = null
	#left click with an item selected = purchasing
	if Input.is_action_pressed("mouse_left") && item_selected != null:
		if PlayerCurrency.checkIfPositive(item_selected.shop_info["price"]) == -1:
			pass
		else:
			item_selected.position = item_selected.get_parent().get_global_mouse_position() #moves our invisible item to our mouse position
			#print("item placed at ", item_selected.position)
			ifCollisionUnhide()
			#print("item_selected", item_selected.name)
			item_selected.visible = true #unhides it
			update_Currency(item_selected) #subtracts the cost of our item from our global currency var
			update_Shop() #decides if other items should be redrawn as red (unaffordable) or not
			place.play()
			var cursor_texture = preload("res://sprites/Mouse.png")
			Input.set_custom_mouse_cursor(cursor_texture)
			item_selected = null
			
			

func update_Currency(item_selected):
	PlayerCurrency.subtract_Currency(item_selected.shop_info["price"])
	get_parent().ui_currency.text = "$" + str(PlayerCurrency.get_Currency())
	
	#enables collision for newly placed purchased items
func ifCollisionUnhide(): #this is some truly ugly code but she'll be right
	var children = item_selected.get_children()
	for child in children:
		if is_instance_of(child, Area2D):
			child.monitoring = true
			child.monitorable = true
			for grandchild in child.get_children():
				if is_instance_of(grandchild, CollisionShape2D):
					grandchild.disabled = false
			
func update_Shop():
	for key in shop_inventory:
		#print(shop_inventory[key])
		var itemScene = shop_inventory[key]["scene"]
		var children = shop_inventory[key]["button"].get_children()
		itemScene = itemScene.instantiate()
		if PlayerCurrency.checkIfPositive(itemScene.shop_info["price"]) == -1:
			children[1].visible = false #sprite2D is always the second one in the tree. dirty and gross but works for timecrunch
		else:
			children[1].visible = true #sprite2D is always the second one in the tree
		itemScene.queue_free() #we don't want thousands of items piling up just so we could check their price lmao
		
	
	
func _on_chicken_feed_button_pressed():
	instantiate_item(chicken_feed)
	if debt == true:
		$ChickenFeedButton/Sprite2D.visible = false
	else:
		change_cursor($ChickenFeedButton/Sprite2D.texture)
	

func _on_incubator_button_pressed():
	instantiate_item(incubator)
	if debt == true:
		$IncubatorButton/Sprite2D.visible = false
	else:
		change_cursor($IncubatorButton/Sprite2D.texture)
	
func _on_nuclear_incubator_button_pressed():
	instantiate_item(apple)
	if debt == true:
		$AppleButton/Sprite2D.visible = false
	else:
		change_cursor($AppleButton/Sprite2D.texture)
	
	
func instantiate_item(passed_item):
	var item = passed_item.instantiate()
	if item != null:
		item.visible = false
		get_parent().add_child(item)
		item_selected = item #exposes item so _process(delta) can access it
		if PlayerCurrency.checkIfPositive(item.shop_info["price"]) == -1:
			debt = true
		else:
			debt = false

	

func change_cursor(sprite):
	Input.set_custom_mouse_cursor(sprite)
	

	
# screen size change
func _on_screen_resized():
	# Apply the scale to each sprite
	sprite_2d_debt.scale = scale_factor
	sprite_2d.scale = scale_factor

