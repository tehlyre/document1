extends RayCast2D

var player : CharacterBody2D
var number = 0

signal player_clear()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func cart_to_polar_from_object(coords: Vector2, obj: Vector2):
	var x = coords.x - obj.x
	var y = coords.y - obj.y
	var coordr = sqrt(pow(x, 2)+pow(y, 2))
	var coordphi = atan(y/x)
	if x < 0:
		coordphi = coordphi+PI
	elif x > 0 and y < 0:
		coordphi = coordphi+2*PI
	
	return Vector2(coordr, coordphi)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target_position = to_local(player.position)
	var collision
	if is_colliding():
		if get_collider() == player:
			emit_signal("player_clear")
		number+=1
