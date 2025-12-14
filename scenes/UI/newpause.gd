extends Control

# Object: Handles the logic of the pause menu. Enables when the Esc/Menu button is pressed. Options opens the options
#	menu, Resume resumes the game, and Quit returns to the main menu.
#
# Variables:
# GameManager game: Pointer to main node/game manager.
# Node2D level: Pointer to the level container node.
# Control options_menu: Pointer to the options menu overlay. Emphasis on overlay.
# Button options_button: Pointer to the options button.
# Button resume_button: Pointer to the resume button.
# Button quit_button: Pointer to the quit button.
# bool died: Holds whether or not the player is dead.
#
# Signals:
# resume(): Emitted when the resume button is pressed. Used by the game manager to unpause the game.
#
# Functions:
# void _ready(): Hides the pause menu by default, then connects toggle_pause as well as all button pressed signals.
# void on_game_paused(bool is_paused): Called when game is paused/resumed. Handles showing and hiding the menu.
# void on_resume_pressed(): Called when resume is pressed. Emits the resume signal.
# void on_options_pressed(): Called when options is pressed. Shows options menu overlay.
# void on_quit_pressed(): Called when quit is pressed. Returns to start menu.

@export var game : GameManager
@export var level : Node2D
@onready var options_menu : Control = $Panel/Menus/Options

@onready var options_button : TextureButton = $Panel/VBoxContainer/Options
@onready var resume_button : TextureButton = $Panel/VBoxContainer/Resume
@onready var quit_button : TextureButton = $Panel/VBoxContainer/MainMenu
@onready var formatting_button : TextureButton = $Panel/VBoxContainer/Formatting
@onready var save_button : TextureButton = $Panel/VBoxContainer/Save
@onready var load_button : TextureButton = $Panel/VBoxContainer/Load

@onready var resume_menu : Control = $Panel/Menus/Resume
@onready var save_menu : Control = $Panel/Menus/Save

enum PauseMenuTabs {
	NONE,
	RESUME,
	SAVE,
	LOAD,
	FORMATTING,
	OPTIONS,
	MAIN_MENU
}
@export var pause_menu_tab : PauseMenuTabs = PauseMenuTabs.NONE


var died : bool = false

signal resume()

# Function void _ready(): Called when the game starts. Hides the menu and connects toggle_pause and button signals
# to their respective functions.
func _ready() -> void:
	hide()
	game.connect("sig_toggle_pause", on_game_paused)
	#options_button.connect("pressed", on_options_pressed)
	resume_button.connect("pressed", on_resume_pressed)
	quit_button.connect("pressed", on_quit_pressed)
	resume_button.connect("toggled", on_toggled.bind(PauseMenuTabs.RESUME))
	save_button.connect("toggled", on_toggled.bind(PauseMenuTabs.SAVE))
	load_button.connect("toggled", on_toggled.bind(PauseMenuTabs.LOAD))
	formatting_button.connect("toggled", on_toggled.bind(PauseMenuTabs.FORMATTING))
	options_button.connect("toggled", on_toggled.bind(PauseMenuTabs.OPTIONS))
	quit_button.connect("toggled", on_toggled.bind(PauseMenuTabs.MAIN_MENU))

func on_toggled(which_one : PauseMenuTabs):
	pause_menu_tab = which_one
	for i in $Panel/VBoxContainer.get_children():
		if i is TextureButton: i.button_pressed = false

# Function void on_game_paused(bool is_paused): Connected to game.toggle_paused. If the game is paused, show the menu,
# else, hide the menu.
func on_game_paused(is_paused : bool) -> void:
	if (is_paused):
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game.menu_state = game.MenuStates.MENU_PAUSE
	else:
		hide()
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		game.menu_state = game.MenuStates.MENU_NONE

# Function void on_resume_pressed(): Connected to resume_button.pressed. Simply emits the resume signal for the game
# manager to unpause the game.
func on_resume_pressed() -> void:
	resume.emit()
	pause_menu_tab = PauseMenuTabs.NONE

# Function void on_options_pressed(): Connected to options_button.pressed. Simply hides the pause menu and shows the
# options menu.
func on_options_pressed() -> void:
	hide()
	options_menu.show()
	game.menu_state = game.MenuStates.MENU_OPTIONS

# Function void on_quit_pressed(): Connected to quit_button.pressed. Unpauses the tree and switches the main scene from
# the game scene to the start menu scene.
func on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/startmenu.tscn")

func _process(_delta: float) -> void:
	for i in $Panel/VBoxContainer.get_children():
		if i is TextureButton:
			i.texture_normal = i.textnorm
	for i in $Panel/Menus.get_children():
		i.hide()
	match pause_menu_tab:
		PauseMenuTabs.NONE:
			resume_menu.show()
		PauseMenuTabs.RESUME:
			resume_menu.show()
		PauseMenuTabs.LOAD: pass
		PauseMenuTabs.SAVE:
			save_menu.show()
		PauseMenuTabs.FORMATTING: pass
		PauseMenuTabs.OPTIONS:
			options_menu.show()
		PauseMenuTabs.MAIN_MENU: pass
