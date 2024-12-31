extends Node2D

class_name GameManager

# Object: Handles pausing and dying for the entirety of the game. Not complicated. The game is set to always run, while
# the container/level is set to pausable.
#
# Global Variables:
# Control pausemenu: Pointer to the pause menu of the game.
# CharacterBody2D player: Pointer to the player character of the game.
# bool ded: If the player is dead, then true, else, false.
# bool game_paused: If this value is set, then toggle_pause is emitted with the new value.
#
# Signals:
# toggle_pause(bool is_paused): Emitted when the game_paused variable is set to a different value. Used to show 
#	pause menu.
#
# Functions:
# Function void _ready(): Called when the game starts. Connects the resume and restart button signals as well as the 
#	death signal.
# Function void _input(InputEvent event): Called when input is detected. Pauses the game when Esc/Menu is pressed.
# Function void on_resume: Connected to the resume button signal. Resumes the game.
# Function void on_player_death: Connected to the player you_died signal. Manually sets healthbar to blank.
# Function void on_restart: Connected to the restart button signal. Restarts the game.


@onready var pausemenu : Control = $CanvasLayer/Pause
@onready var deathmenu : Control = $CanvasLayer/Death
@onready var chestmenu : Control = $CanvasLayer/Chest
@onready var player : CharacterBody2D = $container/Durdan
var inventory = {'keys':0, 'coins':0}

var debug = preload("res://scenes/debug_window.tscn")
var enemy_state : String

var ded : bool = false
var game_paused : bool = false:
	get: 
		return game_paused
	set(value):
		game_paused = value
		
		emit_signal("toggle_pause", game_paused)

signal toggle_pause(is_paused : bool)
		
# Function void _ready()
# Called when the game starts. Connects resume to on_resume, restart to on_restart, and you_died to on_player_death.
func _ready():
	get_viewport().set_embedding_subwindows(false)
	pausemenu.connect("resume", on_resume)
	deathmenu.connect("restart", on_restart)
	player.connect("you_died", on_player_death)
	player.connect("open_chest", on_player_open_chest)
	var d = debug.instantiate()
	add_child(d)
	d.position = Vector2(100,100)
	

# Function void _input(InputEvent event)
# Pauses/resumes the game when escape is pressed so long as the player is alive. The pause button cannot be activated
# when the player is dead. Pauses the game itself and also sends the signal.
func _input(event : InputEvent):
	if event.is_action_pressed("cancel") and !ded:
		get_tree().paused = !get_tree().paused
		game_paused = !game_paused

# Function void on_resume()
# Connected to the signal pausemenu.resume. Unpauses the game and sends the signal.
func on_resume():
	get_tree().paused = !get_tree().paused
	game_paused = !game_paused

func on_player_open_chest(i : int):
	inventory['keys'] += $container/Chests.get_child(i).parsed['keys']
	inventory['coins'] += $container/Chests.get_child(i).parsed['coins']
	$container/Chests.get_child(i).opened = true

# Function void on_player_death(bool _died)
# Connected to the signal player.you_died. Simply manually empties the player's healthbar and sets ded to true.
func on_player_death(_died : bool):
	$container/CanvasLayer/HUD/playerhealth.value = 0
	ded = true

# Function void on_restart()
# Connected to the signal deathmenu.restart. Unpauses the game, reloads the scene, and sets ded to false.
func on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	ded = false

func _process(delta):
	$container/CanvasLayer/HUD/Inventory/keys.text = "Keys: x"+str(inventory['keys'])
	$container/CanvasLayer/HUD/Inventory/coins.text = "Coins: "+str(inventory['coins'])
	$debug_window/Control/VBoxContainer/Label.text = "Enemy State: "+$container/Enemy.States.keys()[$container/Enemy.state]
	$debug_window/Control/VBoxContainer/Label2.text = "Beta Plus: " + str($container/Enemy/beta_plus.target_position)
	$debug_window/Control/VBoxContainer/Label3.text = "Beta Minus: " + str($container/Enemy/beta_minus.target_position)
	if $container/Enemy.velocity != null:
		$debug_window/Control/VBoxContainer/Label4.text = "Velocity: " + str($container/Enemy.velocity)
