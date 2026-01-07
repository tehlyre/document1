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
@export var game : GameManager
@onready var back_button : Button = $Whiteness/Back
@onready var audio : Control = $Whiteness/Audio
@onready var video : Control = $Whiteness/Video
@onready var controls : Control = $Whiteness/Controls
@onready var left : Control = $Whiteness/Left
@onready var right : Control = $Whiteness/Right
var options_menu_state : OptionsMenuState = OptionsMenuState.AUDIO:
	get:
		return options_menu_state
	set(new_state):
		options_menu_state = new_state
		#swapped_state(options_menu_state)

enum OptionsMenuState {
	VIDEO,
	AUDIO,
	CONTROLS
}

# Function void _ready()
# Called when the game starts. Hides the menu by default. Connects button pressed signal to respective function.
func _ready():
	options_menu_state = OptionsMenuState.AUDIO
	hide()
	back_button.connect("pressed", on_back_pressed)
	#right.connect("pressed", on_right_pressed)
	#left.connect("pressed", on_left_pressed)

# Function on_back_pressed()
# Connected to back_button.pressed. Hides the options menu and shows the pause menu.
func on_back_pressed():
	hide()
	pause_menu.show()
	game.menu_state = game.MenuStates.MENU_PAUSE

func on_right_pressed():
	left.disabled = false
	left.show()
	@warning_ignore("int_as_enum_without_cast")
	options_menu_state += 1
	if options_menu_state == OptionsMenuState.CONTROLS:
		right.disabled = true
		right.hide()

func on_left_pressed():
	right.disabled = false
	right.show()
	@warning_ignore("int_as_enum_without_cast")
	options_menu_state -= 1
	if options_menu_state == OptionsMenuState.VIDEO:
		left.disabled = true
		left.hide()

func swapped_state(new_state):
	match new_state:
		OptionsMenuState.VIDEO:
			audio.hide()
			controls.hide()
			video.show()
		OptionsMenuState.AUDIO:
			video.hide()
			controls.hide()
			audio.show()
		OptionsMenuState.CONTROLS:
			video.hide()
			audio.hide()
			controls.show()
