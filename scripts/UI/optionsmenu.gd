extends Control

# Object: Shows/hides the options menu when options is clicked from the MAIN MENU, in contrast to optionsmenuoverlay,
# which only deals with options from the pause menu. Other than that, they are functionally the same.
#
# Variables:
# Button back_button: Pointer to the back button.
#
# Functions:
# void _ready(): Connects button pressed signal to respective function.
# void on_back_pressed: Called when the back button is pressed. Goes back to the main menu.

@onready var back_button : Button = $Panel/VBoxContainer/Back

# Function void _ready()
# Connects the back_button.pressed signal to the on_back_pressed function.
func _ready():
	back_button.connect("pressed", on_back_pressed)

# Function void on_back_pressed()
# Connected to back_button.pressed. Switches the main scene from the options menu to the main menu.
func on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/startmenu.tscn")
