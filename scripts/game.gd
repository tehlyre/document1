extends Node2D

class_name GameManager









func debug(debugger : DebugWindow) -> void:
	for i in range(0, len($container/Room/enemies.get_children())):
		var j : = $container/Room/enemies.get_children()
		debugger.display_text("Enemy "+str(i+1)+":", i*5)
		debugger.display_text(j[i].mover.get_move_state(), i*5+1)
		debugger.display_text(str(j[i].mover.current_action), i*5+2)
		debugger.display_text(" ", i*5+3)
	














# Object: Handles pausing, dying, and interactions for the entirety of the game. Not complicated. 
# The game is set to always run, while the container/level is set to pausable.
#
# Node Structure:
# gameManager
# |_ container: Node2D that holds the contents of the level.
# |_ menuLayer: The CanvasLayer node.
#    |_ Pause: Control for the pause menu
#    |_ Options: Control for the options menu
#    |_ Death: Control for the death menu
#    |_ Chest: Control for the chest menu
#
# GLOBAL VARIABLES
#
# @onready Control pausemenu, deathmenu, chestmenu: These are pointers to the menus that handle 
# pausing, dying, and opening chests, respectively.
@onready var pausemenu : Control = $menuLayer/pauseMenu
@onready var deathmenu : Control = $menuLayer/deathMenu
@onready var chestmenu : Control = $menuLayer/chestMenu
@export var is_debugging : bool = false

# @onready CharacterBody2D player: This is a pointer to the root player node in the container.
@onready var player : Player = $container/Durdan

# Dictionary inventory: This is a dictionary of the array of everything in the player's
# inventory.
var inventory : Dictionary = {'keys':0, 'coins':0}

# PackedScend debug: This is a pointer to the debug_window I tried to implement at one point.
var Debugger : PackedScene = preload("res://scenes/debug_window.tscn")

# bool is_player_dead: Whether or not the player has died in this current timespace continuum.
var is_player_dead : bool = false
var d_ : DebugWindow
var is_opening_chest : bool = false


# bool is_game_paused: Whether or not the game is paused. When this variable is set, the level
# automatically pauses.
var is_game_paused : bool = false:
	get: 
		return is_game_paused
	set(value):
		is_game_paused = value
		sig_toggle_pause.emit(is_game_paused)

signal sig_toggle_pause(is_paused : bool)
		



# AUTOMATICS



# Called when the game starts. Connects all connections to their proper callbacks.
func _ready() -> void:
	get_viewport().set_embedding_subwindows(false)
	pausemenu.resume.connect(_on_game_resume)
	deathmenu.restart.connect(_on_game_restart)
	player.sig_you_died.connect(_on_player_death)
	player.sig_open_chest.connect(_on_player_open_chest)
	player.sig_change_inventory.connect(_on_change_inventory)
	player.sig_query_inventory.connect(_on_player_query_inventory)
	player.sig_set_healthbar.connect(_on_player_change_health)
	if is_debugging:
		d_ = Debugger.instantiate()
		add_child(d_)
		d_.position = Vector2(20,100)
		d_.ready_labels(12)
	


# Called when an input is pressed. Pauses/resumes the game when escape is pressed so long as the 
# player is alive. The pause button cannot be activated when the player is dead. Pauses the game 
# itself and also sends the signal.
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("cancel") and !is_player_dead and !is_opening_chest:
		get_tree().paused = !get_tree().paused
		is_game_paused = !is_game_paused






# PROCESS




# Serves the rudimentary inventory that is a placeholder for things to come.
func _process(_delta : float) -> void:
	$hud/playerInventory/keys.text = "Keys: x"+str(int(inventory['keys']))
	$hud/playerInventory/coins.text = "Coins: "+str(int(inventory['coins']))
	if is_debugging: debug(d_)








# SIGNAL RESPONSES




# Fired when the game is to resume, connected to the signal pausemenu.resume. Unpauses the game and
# sends the signal.
func _on_game_resume() -> void:
	get_tree().paused = !get_tree().paused
	is_game_paused = !is_game_paused


# Fired when the player opens a chest, connected to player.opened_chest. Puts the contents of the 
# chest into the player's inventory and then deletes it by setting the chest's is_opened to true.
func _on_player_open_chest(chest : Chest) -> void:
	inventory['keys'] += chest.parsed['keys']
	inventory['coins'] += chest.parsed['coins'] if chest.parsed['coins'] != null else 0
	inventory['coins'] = int(inventory['coins'])
	chest.is_opened = true


# Connected to the signal player.you_died, fired when the player dies. Simply manually empties the 
# player's healthbar and kills the player.
func _on_player_death() -> void:
	$hud/playerHealthBar.value = 0
	is_player_dead = true
	inventory = {'keys':0, 'coins':0}
	


# Fired when the player restarts the game after death. Connected to the signal deathmenu.restart. 
# Unpauses the game, reloads the scene, and unkills the player.
func _on_game_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	is_player_dead = false

func _on_change_inventory(type : String, bywhat : int) -> void:
	inventory[type] = inventory[type] + bywhat

func _on_player_query_inventory() -> void:
	player.inventory = inventory

func _on_player_change_health(health : float) -> void:
	$hud/playerHealthBar.value = health
