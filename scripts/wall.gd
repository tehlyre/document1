extends TileMapLayer

@export var player : Player

#func _ready() -> void:
	#player.sig_open_door.connect(_on_door_open)
	#for i in get_used_cells():
		#
