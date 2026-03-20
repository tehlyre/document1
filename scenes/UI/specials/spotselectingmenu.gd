extends Control

var is_spot_selecting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide() # Replace with function body.

signal end_spot_select(position)



func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and is_spot_selecting:
		end_spot_select.emit(event.position)
		is_spot_selecting = false
	
