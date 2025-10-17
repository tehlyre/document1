extends Control

signal selection(index : int)
var youarehere : int

func _ready() -> void:
	for i in get_children():
		i.switch_sprite()

var current_marker : Array = [false, 0]:
	set(new_marker):
		current_marker = new_marker
		if current_marker[0] == true:
			selection.emit(current_marker[1])
		elif !current_marker[0]:
			selection.emit(0)
	get:
		return current_marker
