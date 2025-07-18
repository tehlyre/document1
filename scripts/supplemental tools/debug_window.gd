extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ready_labels(number : int):
	for i in range(0, number):
		var t = Label.new()
		$debugWindowControl.get_child(0).add_child(t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_close_requested():
	queue_free()

func display_variable(text, index):
	
	$debugWindowControl/VBoxContainer.get_child(index).text = str(text)

func clear_screen():
	$debugWindowControl.get_child(0).queue_free()
	var v = VBoxContainer.new()
	$debugWindowControl.add_child(v)
