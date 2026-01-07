extends Control
class_name AlignmentMenu

@onready var left : Button = $HBoxContainer/left
@onready var right : Button = $HBoxContainer/right
@onready var center : Button = $HBoxContainer/center

signal alignment_chosen(alignment)
var alignment = "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left.pressed.connect(_on_left_connect)
	right.pressed.connect(_on_right_connect)
	center.pressed.connect(_on_center_connect)

func _on_left_connect():
	alignment = "left"
	alignment_chosen.emit("left")

func _on_right_connect():
	alignment = "right"
	alignment_chosen.emit("right")

func _on_center_connect():
	alignment = "center"
	alignment_chosen.emit("center")
