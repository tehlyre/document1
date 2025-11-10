extends Control

@export var container : Node2D
@export var game : GameManager
@onready var menu : VBoxContainer = $Panel/VBoxContainer
@onready var b_quit : Button = $Panel/VBoxContainer/Quit
var delete_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	container.get_node("Durdan").connect("sig_open_chest", on_player_open_chest)
	b_quit.pressed.connect(on_quit_button_pressed)

func on_player_open_chest(chest : Chest):
	var stuff = chest.parsed
	for i in range(0, len(stuff)):
		var l_ : Label = Label.new()
		menu.add_child(l_)
		menu.move_child(l_, 1+i)
		
	if stuff["keys"] > 0: menu.get_child(2).text = "Keys +"+str(stuff["keys"])
	if stuff["coins"] > 0: menu.get_child(3).text = "Coins +"+str(stuff["coins"])
	get_tree().paused = true
	show()

func on_quit_button_pressed():
	get_tree().paused = false
	for i in range(0, len(menu.get_children())-4):
		menu.get_child(i+2).queue_free()
	game.menu_state = game.MenuStates.MENU_NONE
	hide()
