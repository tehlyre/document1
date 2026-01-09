extends Control
class_name AlignmentMenu

@onready var left : Button = $HBoxContainer/left
@onready var right : Button = $HBoxContainer/right
@onready var center : Button = $HBoxContainer/center

signal alignment_chosen(alignment)
var alignment = Aeon.AlignmentTypes.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left.pressed.connect(_on_left_connect)
	right.pressed.connect(_on_right_connect)
	center.pressed.connect(_on_center_connect)

func _on_left_connect():
	alignment = "left"
	print("uwuwijqpoiejfpoqiwjepfoiqjpeiojqpowiejfpowqijef")
	alignment_chosen.emit(Aeon.AlignmentTypes.LEFT)

func _on_right_connect():
	alignment = "right"
	alignment_chosen.emit(Aeon.AlignmentTypes.RIGHT)

func _on_center_connect():
	alignment = "center"
	alignment_chosen.emit(Aeon.AlignmentTypes.CENTER)
