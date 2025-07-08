extends Node2D

@onready var timer = $Timer
@onready var label = $Label
@onready var chirp = $chirp

var shop_info = {
	"name": "Incubator",
	"price": 500,
	"description": "Use to incubate an egg. Good heavens, you wouldn't trust the hens with that job, would you?",
	"texture": "res://sprites/shop/regularIncubator.png"
}

var occupied = false
var egg_instance
var start_time = 5
var cursor_onIncubator = false
var is_Nuclear = false
signal incubator_signal

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "%02d s" % start_time
	
	#used chatGPT for this. WHY ARE SIGNALS SCARY......
	#cool we can do this though and kind of crazy also.
	var game_map = get_parent()
	if game_map:
		game_map.connect_incubator_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !timer.is_stopped():
		label.text = "%02d s" % [int(timer.time_left) % 60]

func is_occupied():
	return occupied

# Begins incubating the received egg
func incubate(egg):
	occupied = true
	#print("incubating egg ", egg)
	egg_instance = egg
	timer.start(start_time) # Start timer to hatch egg in 30 seconds

func setNuclear(boolean):
	is_Nuclear = boolean

func _on_timer_timeout():
	occupied = false
	egg_instance.hatch_process()
	timer.stop()
	label.text = "%02d s" % start_time
	chirp.play()

func _on_area_2d_mouse_entered():
	emit_signal("incubator_signal", self)
