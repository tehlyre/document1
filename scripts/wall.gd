extends StaticBody2D
class_name h_Wall

var polygon : Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_children():
		polygon = Polygon2D.new()
		polygon.color = Color("000000")
		polygon.set_polygon(i.polygon)
		add_child(polygon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
