extends Area2D
class_name Room

@export var player : Player
var is_player_in_room = true


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_player_body_entered)
	body_exited.connect(_on_player_body_exited)

func _on_player_body_entered(body):
	if body == player:
		var is_player_in_room = true

func _on_player_body_exited(body):
	if body == player:
		var is_player_in_room = false
		print(":0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in $enemies.get_children():
		if overlaps_body(player):
			i.DO_NOT_COME = false
		else:
			i.DO_NOT_COME = true
	pass
