extends Node

var gameCurrency = 1500;

func get_Currency():
	return gameCurrency
	
func set_Currency(i):
	gameCurrency = i
	
func subtract_Currency(i):
	gameCurrency -= i
	
func add_Currency(i):
	gameCurrency += i
	
func checkIfPositive(i):
	if gameCurrency - i < 0:
		return -1
	else:
		return 0
