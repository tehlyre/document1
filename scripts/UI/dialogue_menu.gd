extends Control
class_name DialogueMenu

var actual_vis_char : float = 0
var at_max : bool = false
@onready var dialogue : Label = $MarginContainer/Panel/MarginContainer/Panel/dialogue
@onready var next_prompt : Sprite2D = $MarginContainer/Panel/MarginContainer/Panel/EnterSprite
var dialogue_file_res = "res://assets/dialogue.txt"
var dialogue_file : FileAccess
var dialogue_array : Array[String]
var character : Aeon.Characters
var line : String
# Called when the node enters the scene tree for the first time.

var char_map = {"a" : Aeon.Characters.DURDAN, "c" : Aeon.Characters.CELIA, "J" : Aeon.Characters.JOSEPHUS}
var sprite_map = {Aeon.Characters.DURDAN: "", Aeon.Characters.CELIA: preload("res://assets/textures/sprites/celia_sprite.png"), Aeon.Characters.JOSEPHUS: preload("res://assets/textures/sprites/josephus_sprite.png")}

var perfect_y_coords = [0, 83, 132, 178]
var is_cutscene : bool = false

signal cutscene_ended()
signal add_to_log(character : Aeon.Characters, quote : String)



func spawn_dialogue(code : String):
	dialogue_file = FileAccess.open(dialogue_file_res, FileAccess.READ)
	var codee = dialogue_file.get_line()
	while codee != "{" + code + "}":
		print(codee)
		codee = dialogue_file.get_line()
	is_cutscene = true
	show()
	parse_dialogue()

func parse_dialogue():
	if dialogue_file.get_position() < dialogue_file.get_length():
		var new_line : String
		new_line = dialogue_file.get_line()
		if len(new_line.strip_edges()) == 0:
			new_line = dialogue_file.get_line()
		elif new_line.strip_edges()[0] == "{":
			end_cutscene()
			return
		var name_start : int
		var name_end : int
		for i in new_line.length():
			if new_line[i-1] == '[':
				name_start = i
			elif new_line[i-1] == ']':
				name_end = i-1
		character = char_map[new_line.substr(name_start, name_end-name_start)]
		line = new_line.substr(name_end+2)
		advance_dialogue(character, line)

func check_word_size():
	var font = dialogue.get_theme_font("font")
	var words = dialogue.text.split(" ",false)
	var the_string = [""]
	var string_pointer : int = 0
	for i in words:
		if font.get_string_size(the_string[string_pointer]+i, HORIZONTAL_ALIGNMENT_LEFT, -1, dialogue.get_theme_font_size("font_size")).x > dialogue.get_rect().size.x:
			string_pointer += 1
			the_string.append("")
		the_string[string_pointer] += i
		the_string[string_pointer] += " "
	return font.get_string_size(the_string[-1], HORIZONTAL_ALIGNMENT_LEFT, -1, dialogue.get_theme_font_size("font_size")).x
		

func advance_dialogue(chars : Aeon.Characters, lin : String):
	dialogue.visible_characters = 0
	actual_vis_char = 0
	at_max = false
	next_prompt.hide()
	dialogue.text = lin
	$MarginContainer/Panel/character_name.text = Aeon.name_map[chars]
	$MarginContainer/sprite.texture = sprite_map[chars]
	add_to_log.emit(chars, lin)

func _ready() -> void:
	hide()
	#spawn_dialogue("Demo")

func end_cutscene():
	is_cutscene = false
	cutscene_ended.emit()
	hide()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click") or event.is_action_pressed("confirm"):
		if is_cutscene:
			if not at_max:
				dialogue.visible_characters = len(dialogue.text)
				at_max = true
				print("six seven")
			elif at_max:    # To move on to the next line
				parse_dialogue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_cutscene:
		if not at_max:
			actual_vis_char += 0.75
			dialogue.visible_characters = floor(actual_vis_char)
			if dialogue.visible_characters == len(dialogue.text):
				at_max = true
		else:
			next_prompt.position.x = check_word_size()+dialogue.position.x+20
			next_prompt.position.y = perfect_y_coords[dialogue.get_line_count()]
			next_prompt.show()
