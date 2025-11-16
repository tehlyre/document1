extends Control
class_name LogMenu


@export var dialog_menu : DialogueMenu
var current_character : Aeon.Characters = Aeon.Characters.DURDAN
var previous_character : Aeon.Characters = Aeon.Characters.DURDAN
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	dialog_menu.add_to_log.connect(_on_log_add)

func _on_log_add(chars, lin):
	var l_ = Label.new()
	$Panel/VBoxContainer.add_child(l_)
	l_.add_theme_font_size_override("font_size", 20)
	l_.autowrap_mode = TextServer.AUTOWRAP_WORD
	l_.text = lin
	previous_character = current_character
	current_character = chars
	var r_ = Label.new()
	$Panel/VBoxContainer.add_child(r_)
	if previous_character != current_character:
		show()
		hide.call_deferred()
		add_character_label.call_deferred(current_character, l_)

func add_character_label(chars : Aeon.Characters, y_pos : Label):
	print(y_pos.global_position)
	var l_ = Label.new()
	$Panel/chars.add_child(l_)
	l_.add_theme_font_size_override("font_size", 20)
	l_.add_theme_color_override("font_color", Color(255,255,0))
	l_.text = Aeon.name_map[chars]
	l_.global_position.x = 324
	l_.global_position.y = y_pos.global_position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in $Panel/VBoxContainer.get_children():
		print(i.position, i)
