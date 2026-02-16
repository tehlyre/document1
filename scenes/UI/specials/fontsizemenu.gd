extends Control
class_name FontSizeMenu

@onready var dropdown : OptionButton = $OptionButton

signal fontsize_chosen(fontsize)
var fontsize = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dropdown.item_selected.connect(_on_item_selected)

func _on_item_selected(idx : int):
	fontsize = dropdown.get_item_text(idx)
	fontsize_chosen.emit(fontsize)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
