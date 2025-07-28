extends Camera2D

@onready var size : Vector2 = get_viewport_rect().size*2
@export var player : Player
var current_cell : Vector2i

func update_position() -> void:
	current_cell = player.global_position / size
	position = Vector2(current_cell) * size
	print(global_position)
#
func _process(delta: float) -> void:
	update_position()
