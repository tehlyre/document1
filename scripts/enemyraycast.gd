extends RayCast2D

signal wall_in_front()
signal wall_not_in_front()

var body : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = body.rotation
	if is_colliding():
		emit_signal("wall_in_front")
	else:
		emit_signal("wall_not_in_front")
