@tool
extends TextureButton

signal changed_editor_status(status : int)
@export var object : int

func _ready() -> void:
	toggled.connect(_on_toggle)



func _on_toggle(is_on : bool) -> void:
	if is_on:
		for i in get_parent().get_children():
			if i != self:
				i.button_pressed = false
		changed_editor_status.emit(object)
	else:
		changed_editor_status.emit(0)
