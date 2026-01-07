extends Control


@onready var back = $Whiteness/Back
var save_file_res_root : String = "res://saves/save"
@export var pause_menu : Control
@export var game : GameManager
var save_file : FileAccess
@onready var name_lbl : Label = $Whiteness/Name
@onready var hours_lbl : Label = $Whiteness/Hours
@onready var level_lbl : Label = $Whiteness/Level
var save_menu_state : SaveMenuState:
	get:
		return save_menu_state
	set(sms):
		save_menu_state = sms
		set_sms(sms)
@onready var left : Control = $Whiteness/Left
@onready var right : Control = $Whiteness/Right
@onready var save_root : Control = $Whiteness/Savees

enum SaveMenuState {
	TRIBBIE,
	MYDEI,
	AGLAEA,
	ANAXA,
	DANHENG,
	CERYDRA,
	CIPHER,
	CASTORICE,
	HYACINE,
	CYRENE,
	EVERNIGHT,
	HYSILENS,
	PHAINON,
	DELIVERER
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	back.pressed.connect(_on_back_pressed)
	right.pressed.connect(on_right_pressed)
	left.pressed.connect(on_left_pressed)
	spawn_save(0)

func _on_back_pressed():
	hide()
	pause_menu.show()
	game.menu_state = game.MenuStates.MENU_PAUSE

func spawn_save(save_idx : int):
	print(save_idx)
	save_file = FileAccess.open(save_file_res_root+str(save_idx)+".txt", FileAccess.READ)
	if save_file == null:
		name_lbl.text = "Empty"
		level_lbl.text = ""
		hours_lbl.text = ""
		return
	var codee = save_file.get_line()
	while codee != "":
		match codee[0]:
			"N":
				name_lbl.text = codee.substr(1, -1)
			"L":
				level_lbl.text = "Level "+codee.substr(1,-1)
			"H":
				hours_lbl.text = codee.substr(1,-1)
			_: pass
		print(codee)
		codee = save_file.get_line()
	print("owo")

func on_right_pressed():
	left.disabled = false
	left.show()
	@warning_ignore("int_as_enum_without_cast")
	var new_sms = (save_menu_state + 1)%14
	save_menu_state = new_sms

func on_left_pressed():
	right.disabled = false
	right.show()
	@warning_ignore("int_as_enum_without_cast")
	var new_sms = (save_menu_state - 1)%14
	if new_sms < 0: new_sms += 14
	save_menu_state = new_sms

	
func set_sms(sms : SaveMenuState):
	for i in save_root.get_children():
		i.hide()
	save_root.get_child(sms).show()
	spawn_save(sms)

func _process(delta: float) -> void:
	pass
	#print(save_menu_state)
