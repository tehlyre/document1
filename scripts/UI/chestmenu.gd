extends Control

@export var container : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	container.get_child(0).connect("open_chest", on_player_open_chest)
	$Panel/VBoxContainer/Quit.pressed.connect(on_quit_button_pressed)

func on_player_open_chest(i:int):
	print("qowipehf")
	get_tree().paused = true
	show()

func on_quit_button_pressed():
	get_tree().paused = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
