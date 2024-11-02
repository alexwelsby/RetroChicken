extends Node

signal chickens_selected_for_breeding(chicken1, chicken2)
signal breeding_completed
signal chicken_selection_changed(selected_chickens)

var selected_chickens = []
const MAX_SELECTED_CHICKENS = 2

func toggle_chicken_selection(chicken):
	print("Toggle called with: ", chicken)
	if chicken in selected_chickens:
		selected_chickens.erase(chicken)
	elif selected_chickens.size() < MAX_SELECTED_CHICKENS:
		selected_chickens.append(chicken)
	for chick in selected_chickens:
		print("Selected: ", chick)
	print(len(selected_chickens))
	emit_signal("chicken_selection_changed", selected_chickens)
	
	if len(selected_chickens) == MAX_SELECTED_CHICKENS:
		emit_signal("chickens_selected_for_breeding", selected_chickens[0], selected_chickens[1])

func clear_selection():
	selected_chickens.clear()
	emit_signal("chicken_selection_changed", selected_chickens)
	emit_signal("breeding_completed")

func is_chicken_selected(chicken):
	return chicken in selected_chickens

func can_select_more_chickens():
	return len(selected_chickens) < MAX_SELECTED_CHICKENS
