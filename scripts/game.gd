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
@onready var optionsmenu : Control = $menuLayer/optionsMenu
@onready var savemenu : Control = $menuLayer/saveMenu
@onready var dialoguemenu : Control = $menuLayer/dialogueMenu
@onready var alignmentmenu : AlignmentMenu = $menuLayer/alignmentMenu
@onready var fontsizemenu : FontSizeMenu = $menuLayer/fontsizeMenu
@onready var logmenu : Control = $menuLayer/logMenu
@onready var spotselectingmenu : Control = $menuLayer/spotSelectingMenu
@onready var mapmarkersroot : Control = $menuLayer/mapMenu/Panel/map/markers
@onready var triggerroot : Node2D = $container/Triggers
@onready var enemyroot : Node2D = $container/Room/enemies
@onready var camera : Camera2D = $container/Camera
@export var is_debugging : bool = false
@export var parentheses : PackedScene
var CAMERA_SCALE = 2
var ALIGN_MIN_OFFSETS = [0, 80, 450, 880]
var ALIGN_MAX_OFFSETS = [0, 400, 770, 1200]
var pscale : Vector2
var spot_select_reason = "none"
var player_braces_on_field = []

# @onready CharacterBody2D player: This is a pointer to the root player node in the container.
@onready var player : Player = $container/Durdan
var escale : Vector2

var disable_release_once : Array

# Dictionary inventory: This is a dictionary of the array of everything in the player's
# inventory.
var inventory : Dictionary = {'keys':1, 'coins':0}

# PackedScend debug: This is a pointer to the debug_window I tried to implement at one point.
var Debugger : PackedScene = preload("res://scenes/debug_window.tscn")
var braces : PackedScene = preload("res://scenes/Universals/curly_brace.tscn")

var special_buttons = ["special_q", "special_e", "special_2", "special_3"]

var special_map = {
	"special_q": "q",
	"special_e": "e",
	"special_2": "2",
	"special_3": "3",
}

var d_ : DebugWindow
@export var menu_state : MenuStates = MenuStates.MENU_NONE:
	get:
		return menu_state
	set(new_ms):
		match new_ms:
			MenuStates.MENU_PAUSE:
				print("uwuhpihpoihop[]")
				if (menu_state in [MenuStates.MENU_NONE, MenuStates.MENU_MAP, MenuStates.MENU_ALIGNMENT]):
					if menu_state == MenuStates.MENU_MAP:
						sig_open_map.emit(false, $container/Wall.local_to_map(player.position))
					else:
						hud_hidden = !hud_hidden
						get_tree().paused = !get_tree().paused
				elif (menu_state in [MenuStates.MENU_OPTIONS, MenuStates.MENU_SAVE]):
					optionsmenu.hide()
					savemenu.hide()
				pausemenu.show()
			MenuStates.MENU_MAP:
				hud_hidden = !hud_hidden
				get_tree().paused = !get_tree().paused
				if menu_state == MenuStates.MENU_NONE:
					sig_open_map.emit(true, $container/Wall.local_to_map(player.position))
			MenuStates.MENU_DIALOGUE:
				if menu_state == MenuStates.MENU_LOG:
					dialoguemenu.is_cutscene = true
					dialoguemenu.show()
					logmenu.hide()
					logmenu.get_node("VScrollBar").value = logmenu.get_node("VScrollBar").max_value
				else:
					hud_hidden = !hud_hidden
					player.is_cutscene_running = true
					for i in $container/Bullets.get_children():
						i.queue_free()
			MenuStates.MENU_LOG:
				menu_state = MenuStates.MENU_LOG
				dialoguemenu.is_cutscene = false
				logmenu.show()
				logmenu.get_node("VScrollBar").page = 12
				dialoguemenu.hide()
			MenuStates.MENU_SAVE:
				pausemenu.hide()
				savemenu.show()
			MenuStates.MENU_OPTIONS:
				pausemenu.hide()
				optionsmenu.show()
			MenuStates.MENU_DEATH:
				deathmenu.show()
			MenuStates.MENU_CHEST:
				chestmenu.show()
			MenuStates.MENU_ALIGNMENT:
				alignmentmenu.show()
			MenuStates.MENU_FONTSIZE:
				fontsizemenu.show()
				fontsizemenu.dropdown.show_popup()
			MenuStates.MENU_SPOT_SELECTING:
				spotselectingmenu.is_spot_selecting = true
				spotselectingmenu.show()
			MenuStates.MENU_NONE:
				pausemenu.hide()
				savemenu.hide()
				optionsmenu.hide()
				dialoguemenu.hide()
				logmenu.hide()
				alignmentmenu.hide()
				deathmenu.hide()
				fontsizemenu.hide()
				mapmenu.hide()
				spotselectingmenu.hide()
				sig_open_map.emit(false, Vector2(6,7))
				hud_hidden = false
				player.is_cutscene_running = false
				get_tree().paused = false
		if menu_state == MenuStates.MENU_NONE and new_ms != MenuStates.MENU_NONE:
			get_tree().paused = true
		elif menu_state != MenuStates.MENU_NONE and new_ms == MenuStates.MENU_NONE:
			get_tree().paused = false

		var not_remove_hud = [MenuStates.MENU_NONE, MenuStates.MENU_ALIGNMENT, MenuStates.MENU_FONTSIZE]
		if menu_state not in not_remove_hud and new_ms in not_remove_hud:
			hud_hidden = false
		elif menu_state in not_remove_hud and new_ms not in not_remove_hud:
			hud_hidden = true
		
		menu_state = new_ms
	

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
var is_deleting_cutscene_trigger_on_end = true

enum MenuStates {
	MENU_NONE,
	MENU_PAUSE,
	MENU_OPTIONS,
	MENU_DEATH,
	MENU_CHEST,
	MENU_MAP,
	MENU_DIALOGUE,
	MENU_LOG,
	MENU_SAVE,
	MENU_ALIGNMENT,
	MENU_FONTSIZE,
	MENU_SPOT_SELECTING
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
	player.sig_set_healthbar.connect(_on_player_change_health)
	mapmarkersroot.teleportation.connect(_on_teleportation)
	triggerroot.cutscene_triggered.connect(_on_cutscene_trigger)
	dialoguemenu.cutscene_ended.connect(_on_cutscene_end)
	alignmentmenu.alignment_chosen.connect(_on_alignment_chosen)
	fontsizemenu.fontsize_chosen.connect(_on_fontsize_chosen)
	spotselectingmenu.end_spot_select.connect(_on_spot_selected)
	pscale = player.scale
	if len(enemyroot.get_children()) > 0:
		escale = enemyroot.get_child(0).scale
	if is_debugging:
		d_ = Debugger.instantiate()
		add_child(d_)
		d_.position = Vector2(20,100)
		d_.ready_labels(2)
	


# Called when an input is pressed. Pauses/resumes the game when escape is pressed so long as the 
# player is alive. The pause button cannot be activated when the player is dead. Pauses the game 
# itself and also sends the signal.
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		print(MenuStates.keys()[menu_state])
		if (menu_state in [MenuStates.MENU_NONE, MenuStates.MENU_MAP, MenuStates.MENU_ALIGNMENT]):
			sig_toggle_pause.emit(is_game_paused)
			menu_state = MenuStates.MENU_PAUSE
		elif (menu_state == MenuStates.MENU_PAUSE):
			menu_state = MenuStates.MENU_NONE
		elif (menu_state in [MenuStates.MENU_OPTIONS, MenuStates.MENU_SAVE]):
			menu_state = MenuStates.MENU_PAUSE
		
	elif event.is_action_pressed("open_map") and menu_state == MenuStates.MENU_NONE:
		menu_state = MenuStates.MENU_MAP
	elif event.is_action_released("open_map") and menu_state == MenuStates.MENU_MAP:
		menu_state = MenuStates.MENU_NONE
	elif event.is_action_pressed("open_log"):
		if menu_state == MenuStates.MENU_DIALOGUE:
			menu_state = MenuStates.MENU_LOG
		elif menu_state == MenuStates.MENU_LOG:
			menu_state = MenuStates.MENU_DIALOGUE

	for i in special_buttons:
		if (event.is_action_pressed(i)) and menu_state == MenuStates.MENU_NONE:
			match Aeon.equipped_abilities[special_map[i]]:
				Aeon.PlayerAbilities.NONE:
					pass
				Aeon.PlayerAbilities.ALIGNMENT:
					menu_state = MenuStates.MENU_ALIGNMENT
				Aeon.PlayerAbilities.FONT_SIZE:
					menu_state = MenuStates.MENU_FONTSIZE
				Aeon.PlayerAbilities.PARENTHESES:
					menu_state = MenuStates.MENU_SPOT_SELECTING
					spot_select_reason = "parentheses"
				Aeon.PlayerAbilities.BRACKETS:
					player.spawn_brackets()
				Aeon.PlayerAbilities.BRACES:
					spawn_player_braces()
		elif (event.is_action_released(i)):
			match Aeon.equipped_abilities[special_map[i]]:
				Aeon.PlayerAbilities.NONE:
					pass
				Aeon.PlayerAbilities.ALIGNMENT:
					if menu_state == MenuStates.MENU_ALIGNMENT:
						menu_state = MenuStates.MENU_NONE
				Aeon.PlayerAbilities.FONT_SIZE:
					if menu_state == MenuStates.MENU_FONTSIZE:
						menu_state = MenuStates.MENU_NONE
				Aeon.PlayerAbilities.PARENTHESES:
					if menu_state == MenuStates.MENU_SPOT_SELECTING:
						menu_state = MenuStates.MENU_NONE
						spotselectingmenu.is_spot_selecting = false


	#elif (event.is_action_pressed("special_e")) and menu_state == MenuStates.MENU_NONE:
		#match Aeon.equipped_abilities["e"]:
			#Aeon.PlayerAbilities.NONE:
				#pass
			#Aeon.PlayerAbilities.ALIGNMENT:
				#menu_state = MenuStates.MENU_ALIGNMENT
			#Aeon.PlayerAbilities.FONT_SIZE:
				#menu_state = MenuStates.MENU_FONTSIZE
			#Aeon.PlayerAbilities.PARENTHESES:
				#menu_state = MenuStates.MENU_SPOT_SELECTING
				#spot_select_reason = "parentheses"
			#Aeon.PlayerAbilities.BRACKETS:
				#player.spawn_brackets()
			#Aeon.PlayerAbilities.BRACES:
				#spawn_player_braces()
	#elif (event.is_action_released("special_e")):
		#match Aeon.equipped_abilities["e"]:
			#Aeon.PlayerAbilities.NONE:
				#pass
			#Aeon.PlayerAbilities.ALIGNMENT:
				#if menu_state == MenuStates.MENU_ALIGNMENT:
					#menu_state = MenuStates.MENU_NONE
			#Aeon.PlayerAbilities.FONT_SIZE:
				#if menu_state == MenuStates.MENU_FONTSIZE:
					#menu_state = MenuStates.MENU_NONE
			#Aeon.PlayerAbilities.PARENTHESES:
				#if menu_state == MenuStates.MENU_SPOT_SELECTING:
					#menu_state = MenuStates.MENU_NONE
					#spotselectingmenu.is_spot_selecting = false
#
#
	#elif (event.is_action_pressed("special_2")) and menu_state == MenuStates.MENU_NONE:
		#match Aeon.equipped_abilities["2"]:
			#Aeon.PlayerAbilities.NONE:
				#pass
			#Aeon.PlayerAbilities.ALIGNMENT:
				#menu_state = MenuStates.MENU_ALIGNMENT
			#Aeon.PlayerAbilities.FONT_SIZE:
				#menu_state = MenuStates.MENU_FONTSIZE
			#Aeon.PlayerAbilities.PARENTHESES:
				#menu_state = MenuStates.MENU_SPOT_SELECTING
				#spot_select_reason = "parentheses"
			#Aeon.PlayerAbilities.BRACKETS:
				#player.spawn_brackets()
			#Aeon.PlayerAbilities.BRACES:
				#spawn_player_braces()
	#elif (event.is_action_released("special_2")):
		#match Aeon.equipped_abilities["2"]:
			#Aeon.PlayerAbilities.NONE:
				#pass
			#Aeon.PlayerAbilities.ALIGNMENT:
				#if menu_state == MenuStates.MENU_ALIGNMENT:
					#menu_state = MenuStates.MENU_NONE
			#Aeon.PlayerAbilities.FONT_SIZE:
				#if menu_state == MenuStates.MENU_FONTSIZE:
					#menu_state = MenuStates.MENU_NONE
			#Aeon.PlayerAbilities.PARENTHESES:
				#if menu_state == MenuStates.MENU_SPOT_SELECTING:
					#menu_state = MenuStates.MENU_NONE
					#spotselectingmenu.is_spot_selecting = false



func spawn_player_braces():
	var b_ = braces.instantiate()
	var front_of_player = Vector2(100*cos(player.rotation), 100*sin(player.rotation))
	b_.position = player.position+front_of_player
	b_.owner = self
	$container/Bullets.add_child(b_)
	b_.rotation = player.rotation+PI/2
	player_braces_on_field.append(b_)
	if len(player_braces_on_field) > 2:
		player_braces_on_field[0].queue_free()
		player_braces_on_field.pop_front()


# PROCESS




# Serves the rudimentary inventory that is a placeholder for things to come.
func _process(_delta : float) -> void:
	if is_debugging: debug(d_)
	#print(is_opening_map)



func _on_cutscene_trigger(code : String, trigger):
	dialoguemenu.spawn_dialogue(code)
	current_cutscene_trigger = trigger
	menu_state = MenuStates.MENU_DIALOGUE

func _on_cutscene_end():
	if is_deleting_cutscene_trigger_on_end:
		current_cutscene_trigger.queue_free()
	menu_state = MenuStates.MENU_NONE




# SIGNAL RESPONSES




# Fired when the game is to resume, connected to the signal pausemenu.resume. Unpauses the game and
# sends the signal.
func _on_game_resume() -> void:
	menu_state = MenuStates.MENU_NONE


# Fired when the player opens a chest, connected to player.opened_chest. Puts the contents of the 
#  into the player's inventory and then deletes it by setting the chest's is_opened to true.
func _on_player_open_chest(chest : Chest) -> void:
	Aeon.player_inventory['keys'] += chest.parsed['keys']
	Aeon.player_inventory['coins'] += chest.parsed['coins'] if chest.parsed['coins'] != null else 0
	Aeon.player_inventory['coins'] = int(Aeon.player_inventory['coins'])
	menu_state = MenuStates.MENU_CHEST


# Connected to the signal player.you_died, fired when the player dies. Simply manually empties the 
# player's healthbar and kills the player.
func _on_player_death() -> void:
	$hud/hudRoot/playerHealthBar.value = 0
	menu_state = MenuStates.MENU_DEATH
	Aeon.player_inventory = {'keys':0, 'coins':0}
	


# Fired when the player restarts the game after death. Connected to the signal deathmenu.restart. 
# Unpauses the game, reloads the scene, and unkills the player.
func _on_game_restart() -> void:
	print("eopjqpijfpqoiwjepoiqwjf")
	get_tree().paused = false
	get_tree().reload_current_scene()



func _on_spot_selected(pos : Vector2) -> void:
	player.cutscene_firing_buffer = 1
	if spot_select_reason == "parentheses":
		var p_ = parentheses.instantiate()
		p_.owner = $container
		p_.firee = player
		$container/Bullets.add_child(p_)
		p_.position = CAMERA_SCALE*pos+camera.position
	spot_select_reason = "none"
	menu_state = MenuStates.MENU_NONE
	print(pos)

func _on_player_change_health(health : float) -> void:
	$hud/hudRoot/playerHealthBar.value = health

func _on_teleportation(pos) -> void:
	if pos is Vector2:
		sig_open_map.emit(false, $container/Wall.local_to_map(player.position))
		#is_opening_map = !is_opening_map
		#prints(is_opening_map, "owo", pos)
		get_tree().paused = !get_tree().paused
		menu_state = MenuStates.MENU_NONE
		hud_hidden = false
		camera.update_position()

func _on_alignment_chosen(alignment : Aeon.AlignmentTypes):
	get_tree().paused = !get_tree().paused
	alignmentmenu.hide()
	if alignment == Aeon.AlignmentTypes.NONE: 
		return
	enemyroot.enemies_on_screen.sort_custom(_sort_enemies_by_x)
	if len(enemyroot.enemies_on_screen) == 0:
		return
	print(enemyroot.enemies_on_screen)
	var minimum_enemy_x = (enemyroot.enemies_on_screen[0].global_position.x-camera.position.x)/2
	print(minimum_enemy_x)
	var maximum_enemy_x = (enemyroot.enemies_on_screen[-1].global_position.x-camera.position.x)/2
	
	var disabled_hitbox_enemies = []
	for i in len(enemyroot.enemies_on_screen):
		enemyroot.enemies_on_screen[i].is_being_forced = true
		enemyroot.enemies_on_screen[i].collider.disabled = true
		disabled_hitbox_enemies.append(enemyroot.enemies_on_screen[i])
		var tween_i = create_tween()
		var new_x : float
		if i == 0:
			new_x = CAMERA_SCALE*ALIGN_MIN_OFFSETS[alignment]+camera.position.x
		elif i == len(enemyroot.enemies_on_screen)-1:
			new_x = CAMERA_SCALE*ALIGN_MAX_OFFSETS[alignment]+camera.position.x
		else:
			var new_enemy_offset = (enemyroot.enemies_on_screen[i].get_global_transform_with_canvas().origin.x-minimum_enemy_x)*(ALIGN_MAX_OFFSETS[alignment]-ALIGN_MIN_OFFSETS[alignment])/(maximum_enemy_x-minimum_enemy_x)
			new_x = CAMERA_SCALE*(ALIGN_MIN_OFFSETS[alignment]+new_enemy_offset)+camera.position.x
		tween_i.tween_property(enemyroot.enemies_on_screen[i], "position:x", new_x, 0.5)
	await get_tree().create_timer(0.5).timeout
	for i in disabled_hitbox_enemies:
		i.collider.disabled = false
		i.is_being_forced = false

func _on_fontsize_chosen(fontsize):
	menu_state = MenuStates.MENU_NONE
	print(fontsize)
	if fontsize == "8":
		player.scale = pscale*Vector2(0.75,0.75)
	elif fontsize == "12":
		player.scale = pscale
	elif fontsize == "32":
		player.scale = pscale*Vector2(2, 2)
	elif fontsize == "72":
		player.scale = pscale*Vector2(6.25,6.25)



func _sort_enemies_by_x(a, b):
	return a.position.x < b.position.x
