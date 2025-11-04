extends Control

signal selection(marker)
signal teleportation(pos)
var youarehere : int

func _ready() -> void:
	for i in get_children():
		i.switch_sprite()

var current_marker : Array = [false, 0, 0]:
	set(new_marker):
		current_marker = new_marker
		if current_marker[0]:
			selection.emit(current_marker[2])
		elif !current_marker[0]:
			selection.emit(0)
	get:
		return current_marker

var to_move_player : Array = [false, Vector2(0,0)]:
	set(new_position):
		to_move_player = new_position
		if to_move_player[0]:
			teleportation.emit(to_move_player[1])
		elif !to_move_player[0]:
			teleportation.emit(0)
	get:
		return to_move_player
