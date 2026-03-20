extends AnimatableBody2D


var in_blastRadius = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BlastRadius.body_entered.connect(_on_blastRadius_area_entered)
	$BlastRadius.body_exited.connect(_on_blastRadius_area_exited)
	set_timer()

func _on_blastRadius_area_entered(body):
	in_blastRadius.append(body)

func _on_blastRadius_area_exited(body):
	in_blastRadius.erase(body)

func set_timer():
	var tweeny = create_tween()
	tweeny.tween_property(self, "position:y", position.y-700, 4)
	await get_tree().create_timer(5).timeout
	explode()
	queue_free()

func explode():
	for i in in_blastRadius:
		i.thingy_damage(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(in_blastRadius)
