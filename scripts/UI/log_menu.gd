extends Control
class_name LogMenu


@export var dialog_menu : DialogueMenu
var current_character : Aeon.Characters = Aeon.Characters.DURDAN
var previous_character : Aeon.Characters = Aeon.Characters.DURDAN
var is_hiding = false
var current_label : Label
var vbox_init_posy : float
var char_init_posy : float
var is_adding_dialogue : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	dialog_menu.add_to_log.connect(_on_log_add)
	$VScrollBar.min_value = 0
	$VScrollBar.max_value = 0
	vbox_init_posy = $VBoxContainer.global_position.y
	char_init_posy = $chars.global_position.y

func _input(event : InputEvent):
	if event.is_pressed() and event is InputEventMouseButton and is_visible_in_tree():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$VScrollBar.value -= 25
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$VScrollBar.value += 25

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
	is_adding_dialogue = true

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
	if $VBoxContainer.get_children()[-1].global_position.y > get_viewport_rect().size.y-60 and is_adding_dialogue:
		print("global crisis avengers level threat neutralize irontomb")
		$VScrollBar.max_value += $VBoxContainer.get_children()[-1].global_position.y - get_viewport_rect().size.y+60
		$chars.global_position.y -= $VBoxContainer.get_children()[-1].global_position.y - get_viewport_rect().size.y+60
		$VBoxContainer.global_position.y -= $VBoxContainer.get_children()[-1].global_position.y - get_viewport_rect().size.y+60
		$VScrollBar.value = $VScrollBar.max_value
		is_adding_dialogue = false
	$chars.global_position.y = char_init_posy - $VScrollBar.value
	$VBoxContainer.global_position.y = vbox_init_posy - $VScrollBar.value
	
