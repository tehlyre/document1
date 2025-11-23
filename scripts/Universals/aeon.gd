extends Node

enum Characters {
	DURDAN,
	CELIA,
	JOSEPHUS
}

enum MapMarkerTypes {
	NONE,
	DOOR,
	CHEST,
	PLAYER,
	STAMP
}

enum BulletTypes {
	NONE,
	BASIC,
	RICOCHET
}

var name_map = {Aeon.Characters.DURDAN: "Durdan", Aeon.Characters.CELIA: "Celia", Aeon.Characters.JOSEPHUS: "Josephus"}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
