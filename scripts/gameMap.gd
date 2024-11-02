extends Node2D

@onready var take_genetic_sample_button = $TakeGeneticSampleButton
@onready var ui_layer = $UILayer_GeneticSample
@onready var chicken = preload("res://scenes/chicken.tscn")
@onready var shop = preload("res://scenes/shop.tscn")
@onready var incubator = %Incubator
@onready var GlobalManager = %GlobalManager
@onready var ui_currency = $Currency

# sounds
@onready var cluck = $SF/cluck
@onready var place = $SF/place

var shopWindow: Node = null

var geneticUI_enabled = false
var egg
var cursor_hasEgg = false
var cursor_onIncubator = false
var cursor_onMailbox = false

var picked_up = false


var selected_chickens = []
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	instantChicken()
	instantChicken()
	instantChicken()
	instantChicken()
	instantChicken()
	updateCurrency()
	
	

	
func updateCurrency():
	var currency = PlayerCurrency.get_Currency()
	ui_currency.text = "$" + str(currency)
	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("mouse_left"):
		if cursor_hasEgg == true && egg != null:
			if cursor_onIncubator:
				if !incubator.is_occupied():
					incubator.incubate(egg)
					egg.position = incubator.position
					egg.visible = true
					resetCursorEgg(egg)
					place.play()
				else:
					print("Incubator already occupied!")
			elif cursor_onMailbox:
				sellEgg(egg)
		else:
			var cursor_texture = preload("res://sprites/Mouse.png")
			Input.set_custom_mouse_cursor(cursor_texture)

# Instantiates a new chicken and sets its position randomly within the view.
func instantChicken():
	var newChicken = chicken.instantiate()
	var position = get_random_position_in_view()
	newChicken.set_position(position)

	# Connect signals for the new chicken instance
	#signals are so scary... cross-referenced with existing signal code and gpt, again
	newChicken.toggle_chicken_selected.connect(GlobalManager.toggle_chicken_selection)
	newChicken.chicken_selected.connect(_on_chicken_selected)
	#adds our new chicken to the game tree
	add_child(newChicken)
	
	#gives our new chicken random genetics
	newChicken.randomizeGenetics()
	newChicken.hatch()
	

# Called when a chicken is selected; allows selection of up to two chickens for breeding.
func _on_chicken_selected(chicken):
	if chicken.is_dead == false && chicken.isEgg == false:
		if geneticUI_enabled:
			if selected_chickens.size() < 2:
				selected_chickens.append(chicken)
				#putting our chicken into the UI so we know who we're breeding
				updateGeneticUISprites(chicken)
				#if we got two chickens. get them breeding!
				if selected_chickens.size() == 2:
					var extra_carnivory_rolls = 0;
					for selected_chicken in selected_chickens:
						#if either chicken has less than 33 hunger, you get one extra roll
						if selected_chicken.hunger < 33:
							extra_carnivory_rolls += 1
					#if BOTH chickens have less than 50 hunger left, you get a bonus roll
					if selected_chickens[0].hunger < 50 && selected_chickens[1].hunger < 50:
						extra_carnivory_rolls += 1
					#meaning if both chickens are at 32 or less hunger, you get the best of 3 rolls to mutate carnivory in total
					_perform_breeding(selected_chickens[0].current_genotype, selected_chickens[1].current_genotype, extra_carnivory_rolls)
	
func updateGeneticUISprites(chicken):
	if $UILayer_GeneticSample/UI_Parent1/Sprite/body.texture == null:
		for child in $UILayer_GeneticSample/UI_Parent1/Sprite.get_children():
			child.texture = chicken.current_sprites[child.name].texture
	elif $UILayer_GeneticSample/UI_Parent2/Sprite/body.texture == null:
		for child in $UILayer_GeneticSample/UI_Parent2/Sprite.get_children():
			child.texture = chicken.current_sprites[child.name].texture
	cluck.play()
	
		
func removeGeneticUISprites():
	var geneticUI_selected_sprites = [ $UILayer_GeneticSample/UI_Parent1/Sprite, $UILayer_GeneticSample/UI_Parent2/Sprite ]
	for sprite in geneticUI_selected_sprites:
		for child in sprite.get_children():
			child.texture = null

# Breeds two selected chickens 
func _perform_breeding(genotype1_dict, genotype2_dict, carnivory_rolls): #would love to refactor this for less redundant code but there's more pressing tickets open rn
	#print("Breeding chickens with genes:", genotype1_dict, genotype2_dict)
	var current_genotype = { } #our new chickennnnnn
	var newChicken = chicken.instantiate() #this is insane and stupid but I'm doing this just so I can access all_possible_genes to avoid the 10% break if you breed when all chickens are dead
	var compositeSprites = newChicken.get_node("CompositeSprites");
	var all_genes_dict = compositeSprites.all_possible_genes; #getting the array of all body part variables 
	for gene in genotype1_dict: #both genotypes will have the same number of genes, so this is fine
		#print(genotype1_dict[gene])
		var rand = rng.randi_range(0, 10)
		if rand <= 4: #if our rng is 0-4, we get the gene from the first parent... unless current gene is diet, where special rules apply
			#print("Genotype1 selected: body " + str(genotype1_dict[gene])) since we have more than 1 gene these are kinda spammy
			if carnivory_rolls == 0 || gene != "diet":
				current_genotype[gene] = genotype1_dict[gene]
				if gene == "beak":
					if genotype1_dict["beak"]["name"] == "Broad beak" && genotype2_dict["beak"]["name"] == "Toothed beak" || genotype1_dict["beak"]["name"] == "Toothed beak" && genotype2_dict["beak"]["name"] == "Broad beak" :
						var r = rng.randi_range(1, 4) #punnett square if we assume broad is BB and Toothed is bb and these are codominant genesand broad toothed snout is Bb 
						if r == 1: current_genotype[gene] = all_genes_dict[gene][5] #broad beak position
						if r == 2 || r == 3: current_genotype[gene] = all_genes_dict[gene][6] #broad toothed beak position
						if r == 4: current_genotype[gene] = all_genes_dict[gene][7] #toothed beak position
			else: 
				#if we have bonus carnivorous rolls due to hunger, and one of the parents is carnivorous,
				#the offspring WILL roll carnivory
				if genotype2_dict["diet"]["name"] == "Carnivorous":
					current_genotype[gene] = genotype2_dict[gene]
				else: #if the second parent isn't carnivorous, there's only one other parent to inherit from
					current_genotype[gene] = genotype1_dict[gene]
		elif rand > 4 and rand <= 9: #if our rng is 5-9, we get the gene from the second parent... 
			#unless current gene is diet, where special rules apply
			if carnivory_rolls == 0 || gene != "diet":
				current_genotype[gene] = genotype2_dict[gene]
				if gene == "beak":
					if genotype1_dict["beak"]["name"] == "Broad beak" && genotype2_dict["beak"]["name"] == "Toothed beak" || genotype1_dict["beak"]["name"] == "Toothed beak" && genotype2_dict["beak"]["name"] == "Broad beak" :
						var r = rng.randi_range(1, 4) #punnett square if we assume broad is BB and Toothed is bb and broad and toothed are Bb and these are codominant genes
						if r == 1: current_genotype[gene] = all_genes_dict[gene][5] #broad beak position
						if r == 2 || r == 3: current_genotype[gene] = all_genes_dict[gene][6] #broad toothed beak position
						if r == 4: current_genotype[gene] = all_genes_dict[gene][7] #toothed beak position
			else: 
				#if we have bonus carnivorous rolls due to hunger, and one of the parents is carnivorous,
				#the offspring WILL roll carnivory
				if genotype1_dict["diet"]["name"] == "Carnivorous":
					current_genotype[gene] = genotype1_dict[gene]
				else: #if the first parent isn't carnivorous, there's only one other parent to inherit it from
					current_genotype[gene] = genotype2_dict[gene]
		else: #else, if we get a nat10, we get a random 'mutated' gene from the range
			rand = rng.randi_range(1, all_genes_dict[gene].size() - 1)
			#if gene == "beak": print("mutated beak")
			current_genotype[gene] = all_genes_dict[gene][rand]
			#if you have not already mutated carnivory, and either parent was hungry when bred
			#roll up to three extra times to see if you get to mutate carnivory
			#if you roll carnivory once, stop rolling
			if gene == "diet" && carnivory_rolls > 0 && rand != 1:
				while carnivory_rolls > 0:
					rand = rng.randi_range(1, all_genes_dict[gene].size() - 1)
					current_genotype[gene] = all_genes_dict[gene][rand]
					if rand == 1: #if you rolled a carnivory mutation, STOP ROLLING AND LEAVE. elsewise continue
						break
					carnivory_rolls -= 1 #iterating down the carnivory rolls
					
		##end of genetic rolls
	
	#final leg feather checks
	#the leg feathers aren't initially stored in the compositeSprite as you can only have one or the other and the variants are tied to the body color gene
	if current_genotype["legfeathers"]["name"] == "Covert feathers" || current_genotype["legfeathers"]["name"] == "Flighted feathers":
		var legs_dict = compositeSprites.variant_legs
		var ourLegs_dict = legs_dict[current_genotype["legfeathers"]["name"]]
		var bodyColor = current_genotype["body"]["name"]
		current_genotype["legfeathers"]["sprite"] = ourLegs_dict[bodyColor]
	#same for tails
	if current_genotype["tail"]["name"] != "Lizard tail" && current_genotype["tail"]["name"] != "Egg":
		var all_tails_dict = compositeSprites.variant_tails
		var ourTail_dict = all_tails_dict[current_genotype["tail"]["name"]]
		var bodyColor = current_genotype["body"]["name"]
		current_genotype["tail"]["sprite"] = ourTail_dict[bodyColor]
		
	newChicken.queue_free() # delete our stupid hack chicken we took the reference dicts from
	
	bredChicken(current_genotype) #instantiates our new chicken (starts as an egg) with our new genotype dict
	
	selected_chickens.clear()  # Reset for the next selection
	GlobalManager.clear_selection()
	

# Instantiates a new chicken with specified genetics and sets its position randomly within the view.
func bredChicken(selected_genotype):
	egg = chicken.instantiate() #we're calling chickens eggs now because this ties to the egg global variable which the genetics mode uses for the egg button
	
	#gives us an illusion of being able to place the egg
	egg.visible = false

	# Connect signals for the new chicken instance.
	egg.chicken_selected.connect(_on_chicken_selected)
	add_child(egg)

	egg.setGenetics(selected_genotype)
	loadChildButton(egg)
	
func loadChildButton(egg):
	#since this is an egg just loading the body sprite is fine
	$UILayer_GeneticSample/UI_Child/Sprite.texture = egg.current_sprites["body"].texture

# Generates a random position within the visible screen bounds.
#used chatGPT for this but it gave me code that didn't work so I had to tear it apart
func get_random_position_in_view() -> Vector2:
	# Get the camera's visible rect in world coordinates
	var top_left = get_viewport_rect().position  # Top-left corner of the camera
	var bottom_right = get_viewport_rect().end  # Bottom-right corner of the camera

	# Generate random x and y within the defined screen bounds
	var random_x = rng.randi_range(-540, 540)
	var random_y = rng.randi_range(-285, 285)

	return Vector2(random_x, random_y)


# Handles button press event for taking genetic samples.
func _on_take_genetic_sample_button_pressed():
	if !geneticUI_enabled:
		geneticUI_enabled = true
		ui_layer.visible = true
		$TakeGeneticSampleButton.text = "Exit genetic sample mode"
		for child in ui_layer.get_children():
			child.visible = true
	else:
		geneticUI_enabled = false
		ui_layer.visible = false
		$TakeGeneticSampleButton.text = "Enter genetic sample mode"
		selected_chickens.clear()
	



# Menu UI
@onready var ui_menu_ani = $UIMenuAni
@onready var home = $MenuUI/Home

func _on_open_pressed():
	ui_menu_ani.play("OpenMenu")
	if !geneticUI_enabled:
		geneticUI_enabled = true
		ui_layer.visible = true
		$TakeGeneticSampleButton.text = "Exit genetic sample mode"
		for child in ui_layer.get_children():
			child.visible = true
	await get_tree().create_timer(1.6).timeout
	shopWindow = shop.instantiate()
	add_child(shopWindow)
	shopWindow.z_index = 2


func _on_close_pressed():
	ui_menu_ani.play("CloseMenu")
	if shopWindow != null:
		remove_child(shopWindow)
		shopWindow.queue_free() #delete it forevaaaaa
		shopWindow = null #resetting 

func _on_b_1_pressed():
	var all_sprites = $UILayer_GeneticSample/UI_Parent1/Sprite.get_children()
	var num_matches = 0;
	for i in selected_chickens.size():
			for child in all_sprites:
				if selected_chickens[i].current_sprites[child.name].texture == child.texture:
					num_matches += 1
				else: 
					num_matches = 0
					break #breaks our all_sprites loop if we met a mismatch
			if num_matches == all_sprites.size():
				num_matches = i #didn't want to declare a new variable for this; just saving which index we got a match
				break #breaks our selected_chickens loop if we found a match
	selected_chickens.remove_at(num_matches)
	for child in all_sprites:
		child.texture = null


func _on_b_2_pressed():
	var all_sprites = $UILayer_GeneticSample/UI_Parent2/Sprite.get_children()
	var num_matches = 0;
	for i in selected_chickens.size():
			for child in all_sprites:
				if selected_chickens[i].current_sprites[child.name].texture == child.texture:
					num_matches += 1
				else: 
					num_matches = 0
					break #breaks our all_sprites loop if we met a mismatch
			if num_matches == all_sprites.size():
				num_matches = i #didn't want to declare a new variable for this; just saving which index we got a match
				break #breaks our selected_chickens loop if we found a match
	selected_chickens.remove_at(num_matches)
	for child in all_sprites:
		child.texture = null


#works together with code in process(delta) to let us 'pick up' the egg and 'drop' it where-ever
func _on_eb_pressed():
	if egg != null:
		selected_chickens.clear()
		removeGeneticUISprites()
		cursor_hasEgg = true
		Input.set_custom_mouse_cursor($UILayer_GeneticSample/UI_Child/Sprite.texture)
		$UILayer_GeneticSample/UI_Child/Sprite.texture = null


# Shop


# Home Menu Pop up
@onready var home_menu = $MenuUI/MenuPopUp/HomeMenu

func _on_home_pressed():
	home_menu.visible = true
	Engine.time_scale = 0

func _on_close_home_pressed():
	home_menu.visible = false
	Engine.time_scale = 1


func _on_quit_pressed():
	get_tree().quit()

func _on_end_pressed():
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")

	
func resetCursorEgg(egg):
	Input.set_custom_mouse_cursor(null)
	cursor_hasEgg = false
	egg = null
	
func sellEgg(egg):
	PlayerCurrency.add_Currency(10)
	updateCurrency()
	resetCursorEgg(egg)
	
# To connect to the incubator_signal
func connect_mailbox_signals(mailbox):
	var mailboxArea = mailbox.get_node("Area2D")
	mailboxArea.connect("mouse_entered", Callable(self, "_on_mailbox_mouse_entered"))
	mailboxArea.connect("mouse_exited", Callable(self, "_on_mailbox_mouse_exited"))
	
func _on_mailbox_mouse_entered():
	cursor_onMailbox = true
	
func _on_mailbox_mouse_exited():
	cursor_onMailbox = false

func connect_incubator_signals(incubator):
	incubator.incubator_signal.connect(_on_incubator_signal)
	var incubatorArea = incubator.get_node("Area2D")
	incubatorArea.monitoring = true
	incubatorArea.monitorable = true
	var collisionShape = incubatorArea.get_child(0)
	collisionShape.disabled = false
	incubatorArea.connect("mouse_entered", Callable(self, "_on_incubator_mouse_entered"))
	incubatorArea.connect("mouse_exited", Callable(self, "_on_incubator_mouse_exited"))
	incubatorArea.connect("incubator_signal", Callable(self, "_on_incubator_signal"))

func _on_incubator_mouse_entered():
	#print("incubator mouse entered")
	cursor_onIncubator = true

func _on_incubator_mouse_exited():
	#print("incubator mouse exited")
	cursor_onIncubator = false
	
#setting our incubator so the egg lands in the right one
func _on_incubator_signal(incubator_instance):
	incubator = incubator_instance
