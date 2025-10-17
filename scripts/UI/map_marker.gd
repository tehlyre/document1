extends Control

@export var marker_type : MarkerTypes
@export var cursor : TextureRect
var original_pos : Vector2
var was_recently_selected : bool

enum MarkerTypes {
	NONE,
	DOOR,
	CHEST,
	PLAYER
}

func _ready() -> void:
	original_pos = global_position

func _process(delta: float) -> void:
	var within_y_bounds : bool = $lockSprite.global_position.y < cursor.global_position.y+cursor.size.y/2 and $lockSprite.global_position.y+$lockSprite.size.y > cursor.global_position.y+cursor.size.y/2
	var within_x_bounds : bool = $lockSprite.global_position.x < cursor.global_position.x+cursor.size.x/2 and $lockSprite.global_position.x+$lockSprite.size.x > cursor.global_position.x+cursor.size.x/2
	if within_x_bounds:
		if within_y_bounds:
			get_parent().current_marker = [true, marker_type]
			was_recently_selected = true
		elif !(within_y_bounds) and was_recently_selected:
			get_parent().current_marker = [false, 0]
			was_recently_selected = false
	elif !(within_x_bounds) and was_recently_selected:
		get_parent().current_marker = [false, 0]
		was_recently_selected = false

func switch_sprite():
	match marker_type:
		MarkerTypes.NONE:
			pass
		MarkerTypes.DOOR:
			$lockSprite.texture = preload("res://assets/textures/marker_door.png")
		MarkerTypes.CHEST:
			$lockSprite.texture = preload("res://assets/textures/marker_chest.png")
		MarkerTypes.PLAYER:
			$lockSprite.texture = preload("res://assets/textures/marker_player.png")
			
