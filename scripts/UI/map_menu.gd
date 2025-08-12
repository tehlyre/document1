extends Control

@export var game : GameManager
@onready var map = $Panel/map

func _ready() -> void:
	hide()
	game.sig_open_map.connect(_on_open_map)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion: 
		map.position -= event.screen_relative

func _on_open_map(is_opening : bool) -> void:
	if is_opening: 
		show()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
