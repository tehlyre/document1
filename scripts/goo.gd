extends Area2D

var polygon : Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_children():
		polygon = Polygon2D.new()
		polygon.color = Color("5f6e70")
		polygon.set_polygon(i.polygon)
		add_child(polygon)
	connect("body_entered", on_Goo_body_entered)
	connect("body_exited", on_Goo_body_exited)
	
func on_Goo_body_entered(body : Node2D):
	if body.is_in_group("enemies") or body.is_in_group("player"):
		body.in_goo = true

func on_Goo_body_exited(body : Node2D):
	if body.is_in_group("enemies") or body.is_in_group("player"):
		body.in_goo = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
