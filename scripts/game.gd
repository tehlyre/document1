extends Node2D

class_name GameManager









func debug(debugger : DebugWindow) -> void:
	debugger.display_text(str(menu_state), 1)
	














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
@onready var mapmenu : Control = $menuLayer/mapMenu
@onready var dialoguemenu : Control = $menuLayer/dialogue_menu
@onready var logmenu : Control = $menuLayer/logMenu
@onready var mapmarkersroot : Control = $menuLayer/mapMenu/Panel/map/markers
@onready var triggerroot : Node2D = $container/Triggers
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
var is_on_options : bool = false
var is_opening_map : bool = false
var menu_state : MenuStates = MenuStates.MENU_NONE

var hud_hidden : bool = false:
	set(is_hidden):
		hud_hidden = is_hidden
		if is_hidden:
			$hud.hide()
		elif !is_hidden:
			$hud.show()
	get:
		return hud_hidden


# bool is_game_paused: Whether or not the game is paused. When this variable is set, the level
# automatically pauses.
var is_game_paused : bool = false

signal sig_toggle_pause(is_paused : bool)
signal sig_open_map(is_opening : bool, player_position : Vector2)

var current_cutscene_trigger
var delete_trigger_on_end = true

enum MenuStates {
	MENU_NONE,
	MENU_PAUSE,
	MENU_OPTIONS,
	MENU_DEATH,
	MENU_CHEST,
	MENU_MAP,
	MENU_DIALOGUE,
	MENU_LOG
}


# AUTOMATICS



# Called when the game starts. Connects all connections to their proper callbacks.
func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	get_viewport().set_embedding_subwindows(false)
	mapmenu.player = player
	pausemenu.resume.connect(_on_game_resume)
	deathmenu.restart.connect(_on_game_restart)
	player.sig_you_died.connect(_on_player_death)
	player.sig_open_chest.connect(_on_player_open_chest)
	player.sig_change_inventory.connect(_on_change_inventory)
	player.sig_query_inventory.connect(_on_player_query_inventory)
	player.sig_set_healthbar.connect(_on_player_change_health)
	mapmarkersroot.teleportation.connect(_on_teleportation)
	triggerroot.cutscene_triggered.connect(_on_cutscene_trigger)
	dialoguemenu.cutscene_ended.connect(_on_cutscene_end)
	if is_debugging:
		d_ = Debugger.instantiate()
		add_child(d_)
		d_.position = Vector2(20,100)
		d_.ready_labels(2)
	

func can_pause_game() -> bool:
	return !is_player_dead and !is_opening_chest and !is_on_options and !is_opening_map
func can_open_map() -> bool:
	return !is_game_paused and !is_player_dead and !is_opening_chest and !is_on_options

# Called when an input is pressed. Pauses/resumes the game when escape is pressed so long as the 
# player is alive. The pause button cannot be activated when the player is dead. Pauses the game 
# itself and also sends the signal.
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("cancel") and (menu_state in [MenuStates.MENU_NONE, MenuStates.MENU_PAUSE, MenuStates.MENU_MAP]):
		if menu_state == MenuStates.MENU_MAP:
			sig_open_map.emit(false, $container/Wall.local_to_map(player.position))
			is_opening_map = !is_opening_map
		else:
			hud_hidden = !hud_hidden
			get_tree().paused = !get_tree().paused
		is_game_paused = !is_game_paused
		sig_toggle_pause.emit(is_game_paused)
		
	elif event.is_action_pressed("open_map") and (menu_state in [MenuStates.MENU_NONE, MenuStates.MENU_MAP]):
		is_opening_map = !is_opening_map
		hud_hidden = !hud_hidden
		print(hud_hidden)
		get_tree().paused = !get_tree().paused
		if is_opening_map:
			sig_open_map.emit(true, $container/Wall.local_to_map(player.position))
			menu_state = MenuStates.MENU_MAP
		else:
			sig_open_map.emit(false, Vector2(6,7))
			menu_state = MenuStates.MENU_NONE
	elif event.is_action_pressed("open_log"):
		if menu_state == MenuStates.MENU_DIALOGUE:
			menu_state = MenuStates.MENU_LOG
			dialoguemenu.is_cutscene = false
			logmenu.show()
			logmenu.get_node("VScrollBar").page = 80
			dialoguemenu.hide()
		elif menu_state == MenuStates.MENU_LOG:
			menu_state = MenuStates.MENU_DIALOGUE
			dialoguemenu.is_cutscene = true
			dialoguemenu.show()
			logmenu.hide()
			logmenu.get_node("VScrollBar").value = logmenu.get_node("VScrollBar").max_value
		






# PROCESS




# Serves the rudimentary inventory that is a placeholder for things to come.
func _process(_delta : float) -> void:
	$hud/playerInventory/keys.text = "Keys: x"+str(int(inventory['keys']))
	$hud/playerInventory/coins.text = "Coins: "+str(int(inventory['coins']))
	if is_debugging: debug(d_)
	#print(is_opening_map)



func _on_cutscene_trigger(code : String, trigger):
	hud_hidden = !hud_hidden
	dialoguemenu.spawn_dialogue(code)
	current_cutscene_trigger = trigger
	menu_state = MenuStates.MENU_DIALOGUE
	player.cutscene_running = true
	for i in $container/Bullets.get_children():
		i.queue_free()

func _on_cutscene_end():
	hud_hidden = !hud_hidden
	if delete_trigger_on_end:
		current_cutscene_trigger.queue_free()
	menu_state = MenuStates.MENU_NONE
	player.cutscene_running = false




# SIGNAL RESPONSES




# Fired when the game is to resume, connected to the signal pausemenu.resume. Unpauses the game and
# sends the signal.
func _on_game_resume() -> void:
	get_tree().paused = !get_tree().paused
	is_game_paused = !is_game_paused
	sig_toggle_pause.emit(false)


# Fired when the player opens a chest, connected to player.opened_chest. Puts the contents of the 
# chest into the player's inventory and then deletes it by setting the chest's is_opened to true.
func _on_player_open_chest(chest : Chest) -> void:
	inventory['keys'] += chest.parsed['keys']
	inventory['coins'] += chest.parsed['coins'] if chest.parsed['coins'] != null else 0
	inventory['coins'] = int(inventory['coins'])
	menu_state = MenuStates.MENU_CHEST


# Connected to the signal player.you_died, fired when the player dies. Simply manually empties the 
# player's healthbar and kills the player.
func _on_player_death() -> void:
	$hud/playerHealthBar.value = 0
	menu_state = MenuStates.MENU_DEATH
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

func _on_teleportation(pos) -> void:
	if pos is Vector2:
		sig_open_map.emit(false, $container/Wall.local_to_map(player.position))
		is_opening_map = !is_opening_map
		prints(is_opening_map, "owo", pos)
		get_tree().paused = !get_tree().paused
		menu_state = MenuStates.MENU_NONE


	
