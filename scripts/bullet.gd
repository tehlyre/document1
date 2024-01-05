extends Area2D

# Bullet Script
#
# Object: Moves the bullets and hits enemies.
#
# Clarifications: N/A
#
# Signals:
# _on_Bullet_body_entered attached to signal body_entered
#
# Global Variables:
# float speed: Controls the overall speed of the bullet. Set to be relatively low so it is easy to dodge.
#
# Functions:
# void _ready(): Called when the bullet is fired. Connects body_entered to on_body_entered.
# void _physics_process(delta): Called every frame give or take. Applies physics to the bullet.
# void _on_Bullet_body_entered(body): Called every time the bullet intersects another body. Deals damage to objects.

@export var speed : float = 10

# Function void _ready()
# Calls when bullet is fired. Connects the body_entered signal to on_body_entered().
func _ready():
	connect("body_entered", on_body_entered)

# Function void _physics_process(float _delta)
# Changes the position of the bullet by the speed of the bullet.
func _physics_process(_delta : float):
	position += transform.x * speed

# Function on_body_entered(Node2D body)
# Connected to self.body_entered. Can damage enemies and players differently, and unalives itself afterwords.
func on_body_entered(body : Node2D):
	print(get_parent())
	if(body.is_in_group("enemies")):
		body.damage_thingy(10*1/body.scle)
	elif(body.is_in_group("player")):
		body.damage_thingy(10*1)
	queue_free()
