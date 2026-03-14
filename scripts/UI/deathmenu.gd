extends Control

# Object: Shows the death menu when the player dies. Also restarts the game when restart is pressed and returns to
# the main menu when quit is pressed.
#
# Variables:
# Node2D container: Pointer to the level container.
# Button restart_button: Pointer to the restart button.
# Button quit_button: Pointer to the quit button.
#
# Signals:
# restart(): Emitted when restart is pressed. Used by game manager to restart the game.
#
# Functions:
# void _ready(): Hides the menu and connects all used signals to respective functions.
# void on_player_death(bool died): Called when player dies. Pauses the game and shows the death menu.
# void on_restart(): Called when restart is pressed. Emits the restart signal.
# void on_quit_pressed(): Called when quit is pressed. Returns to main menu.

@export var container : Node2D

@onready var restart_button : Button = $Panel/VBoxContainer/Restart
@onready var quit_button : Button = $Panel/VBoxContainer/Quit

signal restart()

# Function void _ready()
# Hides the menu by default. Connects player.you_died to on_player_death and all button pressed signals to their
# respective functions.
func _ready():
	hide()
	
	container.get_node("Durdan").connect("sig_you_died", on_player_death)
	
	restart_button.connect("pressed", on_restart_pressed)
	quit_button.connect("pressed", on_quit_pressed)

# Function void on_player_death(bool died)
# Connected to player.you_died. Pauses the tree and shows the death menu if the player is dead.
func on_player_death():
	get_tree().paused = true
	show()

# Function void on_restart_pressed()
# Connected to restart_button.pressed. Emits the restart signal. This signal is used by the game manager to restart 
# the main scene.
func on_restart_pressed():
	restart.emit()

# Function void on_quit_pressed()
# Connected to quit_button.pressed. Unpauses the tree and switches the main scene to the main menu scene.
func on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/startmenu.tscn")
