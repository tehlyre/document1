extends Node

@export var player : Player
var game

# Called when the node enters the scene tree for the first time.
func _ready():
	var game = get_tree().get_root().get_node("Game") # Replace with function body.
	print(game.inventory)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$playerhealth.value = player.health
