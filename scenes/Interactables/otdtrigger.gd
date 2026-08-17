extends Area2D
class_name OverToDungeonTrigger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D):
	if body.is_in_group("player"):
		get_parent().which_entry_point = [true, "fromdungeon", "overworld"]
