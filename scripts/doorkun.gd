extends Interactable

class_name Door

var is_opened : bool = false

func _ready() -> void:
	init("door")

func _process(_delta : float) -> void:
	if is_opened:
		queue_free()
