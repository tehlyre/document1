extends Control
class_name LogMenu


@export var dialog_menu : DialogueMenu
var current_character : Aeon.Characters = Aeon.Characters.DURDAN
var previous_character : Aeon.Characters = Aeon.Characters.DURDAN
var is_hiding = false
var current_label : Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	dialog_menu.add_to_log.connect(_on_log_add)

func _on_log_add(chars, lin):
	var l_ = Label.new()
	$VBoxContainer.add_child(l_)
	l_.add_theme_font_size_override("font_size", 20)
	l_.autowrap_mode = TextServer.AUTOWRAP_WORD
	l_.text = lin
	previous_character = current_character
	current_character = chars
	var r_ = Label.new()
	$VBoxContainer.add_child(r_)
	if previous_character != current_character:
		show()
		is_hiding = true
		current_label = l_

func add_character_label(chars : Aeon.Characters, y_pos : Label):
	var l_ = Label.new()
	$chars.add_child(l_)
	l_.add_theme_font_size_override("font_size", 20)
	l_.add_theme_color_override("font_color", Color(255,255,0))
	l_.text = Aeon.name_map[chars]
	l_.global_position.x = 324
	l_.global_position.y = y_pos.global_position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_hiding:
		hide()
		add_character_label(current_character, current_label)
		is_hiding = false
	if $VBoxContainer.get_children()[-1].global_position.y >  get_viewport_rect().size.y-60:
		print("global crisis avengers level threat neutralize irontomb")
		$VBoxContainer.global_position.y -= $VBoxContainer.get_children()[-1].global_position.y - get_viewport_rect().size.y-60
		$chars.global_position.y -= $VBoxContainer.get_children()[-1].global_position.y - get_viewport_rect().size.y-60
