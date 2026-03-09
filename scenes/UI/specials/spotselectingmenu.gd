extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal end_spot_select(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hide()

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		print(event.position)
		end_spot_select.emit(event.position)
	
