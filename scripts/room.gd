extends Area2D
class_name Room

@export var player : Player
var _is_player_in_room : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_player_body_entered)
	body_exited.connect(_on_player_body_exited)

func _on_player_body_entered(body : Node2D) -> void:
	if body == player:
		_is_player_in_room = true

func _on_player_body_exited(body : Node2D):
	if body == player:
		_is_player_in_room = false
