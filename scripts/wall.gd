@tool
extends StaticBody2D
class_name Wall

var previous_location : Vector2 = position

#func _input(event: InputEvent) -> void:
	#if (event is InputEventMouseButton and Engine.is_editor_hint()):
		#if $wallSprite.get_rect().has_point(event.position):
			#print("what the sigma")
	#print($wallSprite.get_rect())

func _process(delta: float) -> void:
	pass

func get_translated_mouse_pos(mouse_pos : Vector2) -> Vector2:
	var local_mouse_pos = mouse_pos-position
	local_mouse_pos = local_mouse_pos.rotated(rotation)
	local_mouse_pos.x /= scale.x
	local_mouse_pos.y /= scale.y
	return local_mouse_pos
