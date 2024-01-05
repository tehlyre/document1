extends Control

# Object: Shows/hides the options menu when options is clicked from the PAUSE MENU, in contrast to optionsmenu, which
# only handles the menu from the main menu. Else they are functionally the same.
#
# Variables:
# Control pause_menu: Pointer to the pause menu.
# Button back_button: Pointer to the back button.
#
# Functions:
# void _ready(): Hides the menu and connects button pressed signal to respective function.
# void on_back_pressed(): Called when back is pressed. Hides the menu and shows the pause menu.

@export var pause_menu : Control
@onready var back_button : Button = $Panel/VBoxContainer/Back

# Function void _ready()
# Called when the game starts. Hides the menu by default. Connects button pressed signal to respective function.
func _ready():
	hide()
	back_button.connect("pressed", on_back_pressed)

# Function on_back_pressed()
# Connected to back_button.pressed. Hides the options menu and shows the pause menu.
func on_back_pressed():
	hide()
	pause_menu.show()
