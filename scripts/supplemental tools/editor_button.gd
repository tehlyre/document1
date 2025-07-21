@tool
extends TextureButton

func _ready() -> void:
	pressed.connect(test)
	toggled.connect(_on_toggle)

func test() -> void:
	print('gay')

func _on_toggle(is_on : bool) -> void:
	if is_on:
		for i in get_parent().get_children():
			if i != self:
				i.button_pressed = false
