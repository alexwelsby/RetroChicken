extends Node2D

var all_possible_genes = { 
	"body": {
		0: {
			"name": "Egg",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/Egg.png")
		},
		1: { "name": "White",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/White.png")
		},
		2: { "name": "Red",
			"percentage": 0.05,
			"sprite": preload("res://sprites/chickens/base_colors/DarkBrown.png")
		},
		3: { "name": "Buff",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/LightBrown.png")
		},
		4: { "name": "Lavender",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/Grey.png")
		},
		5: { "name": "Blue",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/Blue.png")
		},
		6: { "name": "Black",
			"percentage": 0.15,
			"sprite": preload("res://sprites/chickens/base_colors/Black.png")
		}
	}, #end of chicken bodies
	"legs": {
		0: { "name": "Egg",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: { "name": "White legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/White.png")
		},
		2: { "name": "Blue legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Blue.png")
		},
		3: { "name": "Slate legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Slate.png")
		},
		4: { "name": "Yellow legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Yellow.png")
		},
		5: { "name": "Downy legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Downy.png")
		},
		6: { "name": "Black legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Black.png")
		},
		7: { "name": "Grey legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Grey.png")
		},
		8: { "name": "Red legs",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Legs/Red.png")
		}
	}, #end of chicken legs
	"legfeathers": {
		0: {
			"name": "No leg feathers",
			"percentage": 0.00,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: {
			"name": "Covert feathers",
			"percentage": 0.05,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png") #gets populated later from the covert/flighted dicts
		},
		2: {
			"name": "Flighted feathers",
			"percentage": 0.15,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png") #gets populated later from the covert/flighted dicts
		}
	},
	"comb": {
		0: { 
			"name": "Egg",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: { 
			"name": "Single comb",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Combs/Single.png")
		},
		2: { 
			"name": "Rose comb",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Combs/Rose.png")
		},
		3: { 
			"name": "V-shaped comb",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Combs/VShape.png")
		},
		4: { 
			"name": "Pea comb",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Combs/Pea.png")
		},
		5: { #no comb
			"name": "Combless",
			"percentage": 0.10,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		}
	}, #end of chicken combs
	"diet": {
		0: { 
			"name": "Omnivorous",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: { #carnivory
			"name": "Carnivorous",
			"percentage": 0.25,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		}
	}, #end of chicken diet
	"beak": {
		0: { 
			"name": "Egg",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: { 
			"name": "Average beak",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Beaks/Regular.png")
		},
		2: { 
			"name": "Long beak",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Beaks/Long.png")
		},
		3: { 
			"name": "Crossbeak",
			"percentage": -0.15,
			"sprite": preload("res://sprites/chickens/Beaks/Crossed.png")
		},
		4: { 
			"name": "Curved beak",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/Beaks/Curved.png")
		},
		5: { #broad
			"name": "Broad beak",
			"percentage": 0.05,
			"sprite": preload("res://sprites/chickens/Beaks/Broad.png")
		},
		6: { #toothed
			"name": "Toothed beak",
			"percentage": 0.05,
			"sprite": preload("res://sprites/chickens/Beaks/Toothed.png")
		},
		7: { #broad & toothed
			"name": "Broad toothed snout",
			"percentage": 0.20,
			"sprite": preload("res://sprites/chickens/Beaks/BroadToothed.png")
		}
	}, #end of chicken beaks
	"tail": {
		0: { 
			"name": "Egg",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		1: { 
			"name": "Short tail",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		2: { 
			"name": "Average tail",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		3: { 
			"name": "Long tail",
			"percentage": 0.0,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		},
		4: { #lizard like
			"name": "Lizard tail",
			"percentage": 0.05,
			"sprite": preload("res://sprites/chickens/Tails/Lizard/Lizard.png")
		},
		5: { #lizard-like with feathers
			"name": "Feathered lizard tail",
			"percentage": 0.15,
			"sprite": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png")
		}
	} #end of chicken tails
}

var covert_legs = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Legs/Covert/White Covert.png"),
	"Red": preload("res://sprites/chickens/Legs/Covert/DarkBrown Covert.png"),
	"Buff": preload("res://sprites/chickens/Legs/Covert/LightBrown Covert.png"),
	"Lavender": preload("res://sprites/chickens/Legs/Covert/Grey Covert.png"),
	"Blue": preload("res://sprites/chickens/Legs/Covert/Blue Covert.png"),
	"Black": preload("res://sprites/chickens/Legs/Covert/Black Covert.png")
}

#meant to match up with the body sprite color exactly
var flighted_legs = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Legs/Flighted/White Flighted.png"),
	"Red": preload("res://sprites/chickens/Legs/Flighted/DarkBrown Flighted.png"),
	"Buff": preload("res://sprites/chickens/Legs/Flighted/LightBrown Flighted.png"),
	"Lavender": preload("res://sprites/chickens/Legs/Flighted/Grey Flighted.png"),
	"Blue": preload("res://sprites/chickens/Legs/Flighted/Blue Flighted.png"),
	"Black": preload("res://sprites/chickens/Legs/Flighted/Black Flighted.png")
}

var long_tails = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Tails/Long/White.png"),
	"Red": preload("res://sprites/chickens/Tails/Long/DarkBrown.png"),
	"Buff": preload("res://sprites/chickens/Tails/Long/LightBrown.png"),
	"Lavender": preload("res://sprites/chickens/Tails/Long/Grey.png"),
	"Blue": preload("res://sprites/chickens/Tails/Long/Blue.png"),
	"Black": preload("res://sprites/chickens/Tails/Long/Black.png")
}

var short_tails = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Tails/Short/White.png"),
	"Red": preload("res://sprites/chickens/Tails/Short/DarkBrown.png"),
	"Buff": preload("res://sprites/chickens/Tails/Short/LightBrown.png"),
	"Lavender": preload("res://sprites/chickens/Tails/Short/Grey.png"),
	"Blue": preload("res://sprites/chickens/Tails/Short/Blue.png"),
	"Black": preload("res://sprites/chickens/Tails/Short/Black.png")
}

var regular_tails = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Tails/Regular/White.png"),
	"Red": preload("res://sprites/chickens/Tails/Regular/DarkBrown.png"),
	"Buff": preload("res://sprites/chickens/Tails/Regular/LightBrown.png"),
	"Lavender": preload("res://sprites/chickens/Tails/Regular/Grey.png"),
	"Blue": preload("res://sprites/chickens/Tails/Regular/Blue.png"),
	"Black": preload("res://sprites/chickens/Tails/Regular/Black.png")
}

var feathered_lizard_tails = {
	"Egg": preload("res://sprites/chickens/base_colors/EMPTY-SPRITE.png"),
	"White": preload("res://sprites/chickens/Tails/LizardFeathers/White.png"),
	"Red": preload("res://sprites/chickens/Tails/LizardFeathers/DarkBrown.png"),
	"Buff": preload("res://sprites/chickens/Tails/LizardFeathers/LightBrown.png"),
	"Lavender": preload("res://sprites/chickens/Tails/LizardFeathers/Grey.png"),
	"Blue": preload("res://sprites/chickens/Tails/LizardFeathers/Blue.png"),
	"Black": preload("res://sprites/chickens/Tails/LizardFeathers/Black.png")
}

var variant_legs = {  "Covert feathers": covert_legs, "Flighted feathers": flighted_legs }
var variant_tails = { "Long tail": long_tails, "Short tail": short_tails, "Average tail": regular_tails, "Feathered lizard tail": feathered_lizard_tails }

func _ready():
	pass
	
