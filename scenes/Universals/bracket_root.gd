extends Node2D
class_name Brackets

var host

signal busted()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func switch_brackets():
	for i in get_children():
		i.position.x *= -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(get_children()) == 0:
		busted.emit()
		queue_free()
