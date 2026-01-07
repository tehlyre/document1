extends Node2D
class_name TabPusher

@export var is_colliding : bool = true

func _process(_delta: float) -> void:
	if is_colliding:
		$TabBody/CollisionShape2D.disabled = false
	else:
		$TabBody/CollisionShape2D.disabled = true
