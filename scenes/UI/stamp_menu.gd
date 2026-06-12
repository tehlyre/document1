extends Control

@onready var opciones_root = $Panel/Opciones

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, len(opciones_root.get_children())):
		var dropdown = opciones_root.get_children()[i]
		for player_ability in Aeon.player_abilities_map.values():
			dropdown.add_item(player_ability)
		dropdown.select(Aeon.equipped_abilities.values()[i])
	opciones_root.get_children()[0].item_selected.connect(_on_q_item_selected)
	opciones_root.get_children()[1].item_selected.connect(_on_e_item_selected)
	opciones_root.get_children()[2].item_selected.connect(_on_2_item_selected)
	opciones_root.get_children()[3].item_selected.connect(_on_3_item_selected)

func _on_q_item_selected(index : int):
	Aeon.equipped_abilities['special_q'] = index
func _on_e_item_selected(index : int):
	Aeon.equipped_abilities['special_e'] = index
func _on_2_item_selected(index : int):
	Aeon.equipped_abilities['special_2'] = index
func _on_3_item_selected(index : int):
	Aeon.equipped_abilities['special_3'] = index
