extends Level
class_name Dungeon

@onready var entrypoints : Dictionary = {
	"fromoverworld": $EntrancePoints/FromOverworld
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
