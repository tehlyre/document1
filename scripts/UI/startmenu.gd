extends Control

# Object: Controls the logic in the main menu. The main menu is usually set to the main scene, but for testing purposes
# the main scene is set to the game scene.
#
# Variables:
# Button start_button: Pointer to the start button
# Button options_button: Pointer to the options button
# Button quit_button: Pointer to the quit button
#
# Functions:
# void _ready(): Connects signals to respective functions.
# void on_start_pressed(): Called when start button is pressed. Starts the game.
# void on_options_pressed(): Called when options button is pressed. Opens the options menu.
# void on_quit_pressed(): Called when quit button is pressed. Quits the program and ends the game.

@onready var start_button : Button = $Panel/VBoxContainer/Start
@onready var options_button : Button = $Panel/VBoxContainer/Options
@onready var quit_button : Button = $Panel/VBoxContainer/Quit

# Function void _ready()
# Connects all button pressed signals to their respective on_pressed functions.
func _ready():
	start_button.connect("pressed", on_start_pressed)
	options_button.connect("pressed", on_options_pressed)
	quit_button.connect("pressed", on_quit_pressed)

# Function void on_start_pressed()
# Connected to start_button.pressed. Changes the main scene from the start menu to the main game scene.
func on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Function void on_options_pressed()
# Connected to options_button.pressed. Changes the main scene from the start menu to the options menu scene.
func on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/optionsmenu.tscn")

# Function void on_quit_pressed()
# Connected to quit_button.pressed. Quits the program.
func on_quit_pressed():
	get_tree().quit()
