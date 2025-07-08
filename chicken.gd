extends Node2D

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var bar_hover = $BarHover
@onready var walk_timer = $WalkTimer
@onready var GlobalManager = %GlobalManager
#note that current_sprites and current_genotype NEED to have the same keys
@onready var current_sprites = { "body": $CompositeSprites/Body, "legs":  $CompositeSprites/Legs, "legfeathers": $CompositeSprites/LegFeathers, "comb": $CompositeSprites/Comb,
"beak": $CompositeSprites/Beak, "tail": $CompositeSprites/Tail } 
var current_genotype = { } #the chicken's current body parts; gets initialized in ready() with the same keys as current_sprites
#and initialized all to 0 on ready, which are the Egg values

# For eating
@onready var eat_body = $EatBody
@onready var eat_body_shape = $EatBody/EatBodyShape
@onready var detect_body_shape = $DetectBody/DetectBodyShape
@onready var dead_to_eat = $DeadToEat
@onready var dead_to_eat_shape = $DeadToEat/DeadToEatShape

# Eating
var body_target_position: Vector2 = Vector2.ZERO
var bodyFound: bool = false
var detected_bodies = []

var isEgg = true  # Chickens start as eggs

var selected = false

var hover = false
var hunger = 100.0  # Starting hunger value
var is_carnivorous = false  # Indicates if the chicken is carnivorous
var offspring_hunger_check = 0  # Tracks offspring mutation checks
var is_dead = false  # Tracks if the chicken is dead

# Walking/Movement vars
var wrng = RandomNumberGenerator.new()
var rng = RandomNumberGenerator.new()
var is_walking = false  # Tracks walking state
var walk_distance = Vector2.ZERO  # Initialize to zero for distance
var walk_duration = 1.5  # Duration of walking in seconds
var min_walk_distance = 20  # Minimum walk distance in pixels
var max_walk_distance = 100  # Maximum walk distance in pixels
var walk_burst_timer = 0.0  # Timer to control burst walking behavior

var chicken_traits = []


# Signal for selecting a chicken for breeding
signal chicken_selected(gene)
signal toggle_chicken_selected(chicken)

# Win screen variables 
var microraptor_traits = 0
var microraptor_percentage = 0
var total_traits = 6  
var win_screen 


func _process(delta):
	# Update the progress bar with the current hunger value
	progress_bar.value = hunger
	# Handle walking logic
	if !is_walking and hunger > 0 and !is_dead and bodyFound:
		#print("Chicken stalled, restarting walk")
		start_walking()
		detected_bodies = []
		bodyFound = false
	if is_walking && !is_dead:
		move_and_animate(delta)  # Continue moving if walking
		
		# Decrease the burst timer
		walk_burst_timer -= delta
		if walk_burst_timer <= 0:
			# Randomly decide whether to continue walking or stop
			if rng.randf() < 0.3:
				stop_walking()
			else:
				start_walking()  # Pick a new random direction for a new burst

func _ready():
	timer.start()  # Start timer to deplete hunger every 5 seconds
	#_not_selected()
	#get ALL possible genes from the CompositeSprites dictionary
	var all_genes_dict = $CompositeSprites.all_possible_genes;
	for gene in all_genes_dict:
		current_genotype[gene] = all_genes_dict[gene][0]; #sets us to the empty Egg value at 0 for this gene
		if (gene != "diet"): #diet doesn't exist in the current_sprites as it will have none, ergo
			current_sprites[gene].texture = current_genotype[gene]["sprite"] #updating the sprites to match our genotype
	GlobalManager = get_parent().get_node("GlobalManager")
	self.toggle_chicken_selected.connect(GlobalManager.toggle_chicken_selection)
	win_screen = preload("res://scenes/winscreen.tscn")


# Debug function to hatch chickens; will be removed eventually
func _on_change_body_button_pressed():
	hatch()
	progress_bar.value = hunger

	
func hatch_process():
	print("hatch process called")
	hatch()
	progress_bar.value = hunger
	timer.start()  # Start timer to deplete hunger every 5 seconds


# Assigns random genetics to the chicken; used to generate starter chickens. does not update the sprite
func randomizeGenetics():
	var all_genes_dict = $CompositeSprites.all_possible_genes;
	#for gene in all_genes_dict: #for testing win screen WHY CAN GIT SMELL FEAR?
		#current_genotype[gene] = all_genes_dict[gene][all_genes_dict[gene].size() - 1] #winning value is always the last value
	for gene in all_genes_dict:
		if (gene == "body" || gene == "beak" || gene == "tail"):
			#grab 1, 2, or 3, and that's it; brown or white chickens, mutate for win-state of black feathers (our biologist might be a commercial egg laying breed fan...)
			#with regular beaks, long beaks, or crossbeaks (deleterious mutation) only
			#and with a short tail, average tail, or long tail only
			current_genotype[gene] = all_genes_dict[gene][rng.randi_range(1, 3)]
			if gene == "tail":
				var tails_dict = $CompositeSprites.variant_tails[current_genotype[gene]["name"]]
				current_genotype[gene]["sprite"] = tails_dict[current_genotype["body"]["name"]]
		elif (gene == "diet"): #forcing omnivory for your starter chickens
			current_genotype[gene] = all_genes_dict[gene][0]
		elif (gene == "comb"):
			#grab 1, 2, 3, 4 only; no combless as that's a win state
			current_genotype[gene] = all_genes_dict[gene][rng.randi_range(1, 4)]
		elif (gene == "legfeathers"):
			#grab 0 only; no leg feathers until they're mutated for
			current_genotype[gene] = all_genes_dict[gene][0]
		elif (gene == "legs"):
			#grab any legs
			current_genotype[gene] = all_genes_dict[gene][rng.randi_range(1, all_genes_dict[gene].size() - 1)]
	

func setGenetics(passed_genotype):
	# Set genetics and update sprite if not an egg
	print("passed genotype: ", passed_genotype)
	if !isEgg:
		for gene in current_genotype:
			current_genotype[gene] = passed_genotype[gene] #updating our current dictionary with the passed one
			if (gene != "diet"):
				current_sprites[gene].texture = current_genotype[gene]["sprite"] #updating all our sprites
			elif (gene == "diet" && passed_genotype[gene]["name"] == "Carnivorous"): # if this chicken is carnivorous
				is_carnivorous = true
	else: #if not an egg
		for gene in current_genotype:
			current_genotype[gene] = passed_genotype[gene]
			if (gene == "diet" && passed_genotype[gene]["name"] == "Carnivorous"):
				is_carnivorous = true
		#print("Genetics set, but the sprite is still an egg! Call hatch() to update.")

# Hatch the egg into a chicken; updates the sprite accordingly
func hatch():
	if isEgg:
		isEgg = false
		for gene in current_genotype:
			if (gene != "diet"):
				current_sprites[gene].texture = current_genotype[gene]["sprite"] #updating our displayed sprites from our stored gene sprites
				
		for gene in current_genotype:
			if(current_genotype[gene]["percentage"] >0):
				microraptor_percentage+= current_genotype[gene]["percentage"]
			if(current_genotype[gene]["percentage"] > 0):
				microraptor_traits += 1
				
			
				
		if microraptor_percentage >= 0.75:
			print(microraptor_percentage)
			await get_tree().create_timer(1).timeout
			show_win_screen()  # Call the function to show the win screen		
		else:
			pass#print("Chicken hatched with less than 75% microraptor traits")
			
		start_walking()  # Start walking when hatched
		
	else:
		print("This is already a chicken!")
		
	await get_tree().create_timer(2).timeout
	# Only enable detection if the chicken can eat meat (carnivorous or omnivorous)
	if current_genotype["diet"]["percentage"] <= 0.25:  # This covers both 0 (omni) and 0.25 (carnivorous)
		detect_body_shape.disabled = false
	else:
		detect_body_shape.disabled = true

#just grabs the stored percentages from each gene in the chicken's stored genotype and adds them up
#called for checking if we should display a win-screen after the chicken hatches
func calculateMicroRaptorPercent():
	var f = 0.0
	for gene in current_genotype:
		f += current_genotype[gene]["percentage"] 
	return f
		
		
func show_win_screen():
	var win_screen_scene = preload("res://scenes/winscreen.tscn")
	var win_screen_instance = win_screen_scene.instantiate()

	# Add the win screen to the current scene
	get_tree().current_scene.add_child(win_screen_instance)
	win_screen_instance.display_win_screen(microraptor_traits, microraptor_percentage)


# Emits the genome signal for breeding when the chicken is selected
func _on_button_button_down():
	GlobalManager.toggle_chicken_selection(self)
	emit_signal("chicken_selected", self)

func _on_timer_timeout():
	if !isEgg:
		hunger -= 0.25  # Decrease hunger over time
		if hunger <= 0 && !is_dead:
			die()  # Call die if hunger reaches 0

func die():
	is_dead = true  # Mark the chicken as dead
	for key in current_sprites:
		current_sprites[key].frame = 3 + 3  # Update sprite to dead state
	stop_walking()
	await get_tree().create_timer(0.2).timeout
	dead_to_eat_shape.disabled = false
	detect_body_shape.disabled = true
	eat_body_shape.disabled = true


# Control progress bar visibility based on mouse interaction
func _on_bar_hover_mouse_entered():
	if !isEgg or !is_dead:
			hover = true
			_update_appearance()

func _on_bar_hover_mouse_exited():
	if !isEgg or !is_dead:
		hover = false
		_update_appearance()

func _on_button_mouse_entered():
	if !isEgg or !is_dead:
		hover = true
		_update_appearance()

func _on_button_mouse_exited():
	if !isEgg or !is_dead:
		hover = false
		_update_appearance()

# Start walking in a random direction
func start_walking():
	if !isEgg and !is_dead: #and !bodyFound: #removed bodyFound as it was stalling out chickens
		for key in current_sprites:
			current_sprites[key].frame = 1  # Set to first walking frame
		if !hover:
			is_walking = true
			
		# Random walking
		walk_burst_timer = rng.randf_range(0.5, 2.0)  # Random burst duration
		var angle = rng.randf_range(0, 2 * PI)  # Randomize direction
		var distance = rng.randf_range(min_walk_distance, max_walk_distance)
		walk_distance = Vector2(cos(angle), sin(angle)) * distance  # Random distance
		walk_timer.start(walk_burst_timer)  # Start walk timer

# Stop the walking logic and reset the sprite
func stop_walking():
	if !isEgg and !is_dead and is_walking:
		is_walking = false
		for key in current_sprites:
			current_sprites[key].frame = 0  # Set to standing frame
		walk_timer.stop()  # Stop the walk timer		
		if !hover and !selected:
			await get_tree().create_timer(rng.randf_range(0.5, 2.0)).timeout
			start_walking()  # Call start walking after a random interval

# Move the chicken and update the animation
func move_and_animate(delta):
	if !isEgg and !is_dead and !hover:
		if is_walking:
			if bodyFound:
				if detected_bodies.size() > 0 && detected_bodies[0] != null:
					var target_body = detected_bodies[0]
					body_target_position = target_body.global_position
					# Get the offset from our eat_body_shape to our position (in case it's not centered)
					var eat_shape_offset = eat_body_shape.global_position - global_position
						
					# Calculate the position we need to move to, accounting for the offset
					var target_position = body_target_position
					global_position.distance_to(body_target_position)
						
					# Calculate direction and move
					var direction = (target_position - position).normalized()
					position += (direction * max_walk_distance) * delta #i have no idea why multiply
						
					# Check if we've reached the target (using the actual shapes' positions)
					var distance_between_shapes = eat_body_shape.global_position.distance_to(body_target_position)
					#helps reset our chicken so they don't get stuck getting food
					if (distance_between_shapes < 10):
						stop_walking()
				else:
					bodyFound = false  # Reset if no bodies are detected
			else:
				# Update position while clamping within allowed bounds
				position += walk_distance * (delta / walk_duration)
				position.x = clamp(position.x, -540, 540)
				position.y = clamp(position.y, -240, 240)

				# Update animation frames
				for key in current_sprites:
					var current_frame = current_sprites[key].frame
					if current_frame != 1 and current_frame != 3:
						current_sprites[key].frame = 1  # Start with first walking frame
					elif Engine.get_frames_drawn() % 30 == 0:  # Switch every 30 frames (adjust as needed)
						current_sprites[key].frame = 3 if current_frame == 1 else 1

			#  the sprite based on movement direction
			for key in current_sprites:
				current_sprites[key].flip_h = walk_distance.x > 0  # Flip if moving right
		else:
			for key in current_sprites:
				current_sprites[key].frame = 0  # Standing frame when not walking


# Connect the timeout signal of the WalkTimer in the editor or code
func _on_WalkTimer_timeout():
	if !isEgg and !is_dead and !bodyFound:
		is_walking = false
		for key in current_sprites:
			current_sprites[key].frame = 0  # Set to standing frame
		if !is_dead and !hover:
			stop_walking()  # Call stop walking when the timer times out
			# Start walking again if not hovering
			
			
func _on_chicken_selection_changed(selected_chickens):
	selected = self in selected_chickens
	_update_appearance()

func _update_appearance():
	if !bodyFound:
		stop_walking()
	if !is_dead and !isEgg:
		if selected or hover:
			for key in current_sprites:
				current_sprites[key].frame = 2 * 4 + 3  # sitting
			progress_bar.visible = true
		else:
			for key in current_sprites:
				current_sprites[key].frame = 0  # standing
			progress_bar.visible = false
			if !hover:
				start_walking()


# For Eating
func _on_eat_body_area_entered(area):
	if area.name == dead_to_eat.name && is_carnivorous: #carnivorous chickens can only eat dead chickens
		hunger = 100
		detect_body_shape.disabled = false
		bodyFound = false
	if area.name == "FeedToEat" && !is_carnivorous: #omnivorous chickens can only eat feed
		hunger += 20 # Add 20 helth for seed
		detect_body_shape.disabled = false
		bodyFound = false
	elif area.name == "Apple" && !is_carnivorous: #omnivorous chickens can only eat feed
		hunger += 75
		detect_body_shape.disabled = false
		bodyFound = false

func _on_detect_body_area_entered(area):
	if area.name == dead_to_eat.name && is_carnivorous && !is_dead:
		detect_body_shape.disabled = true
		if !detected_bodies.has(area) or detected_bodies.size() == 0:  # Prevent adding duplicates
			detected_bodies.append(area)
			body_target_position = area.global_position  # Set target position to the first detected body
			bodyFound = true
			#print("Detected body at coordinates: ", body_target_position)
		detect_body_shape.disabled = false
		start_walking()
	if area.name == "FeedToEat" && !is_carnivorous && !is_dead || area.name == "Apple" && !is_carnivorous && !is_dead:
		detect_body_shape.disabled = true
		if !detected_bodies.has(area) or detected_bodies.size() == 0:  # Prevent adding duplicates
			detected_bodies.append(area)
			body_target_position = area.global_position  # Set target position to the first detected body
			bodyFound = true
			#print("Detected feed at coordinates: ", body_target_position)
		detect_body_shape.disabled = false
		start_walking()

func _on_dead_to_eat_area_entered(area):
	# Ensure the area is valid and matches the body to be eaten
	if area.name == eat_body.name:
		var chicken = area.get_parent()
		if chicken.is_carnivorous == true && chicken.isEgg == false: #we should NOT have carnivorous eggs that explode our dead chickens
			print("EAT MEEEEEEEEEE")
			$BloodSplatter.visible = true
			$BloodSplatter/AnimationPlayer.active = true
			$BloodSplatter/AnimationPlayer.play("BloodSplatter") 
			$CompositeSprites.visible = false
			chicken.detected_bodies = []
			chicken.detect_body_shape.disabled = false
			chicken.bodyFound = false
			await get_tree().create_timer(0.2).timeout
			queue_free()
		
