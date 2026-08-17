extends Node2D
class_name Asterisk

var atk_power : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init_guns() -> void:
	for i in get_children():
		i.atk_power = atk_power

func fire(target : Vector2) -> void:
	for i in get_children():
		i.fire(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
