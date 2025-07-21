extends Window
class_name DebugWindow

func ready_labels(number : int) -> void:
	for i in range(0, number):
		var t = Label.new()
		$debugWindowControl.get_child(0).add_child(t)

func _on_close_requested() -> void:
	queue_free()

func display_text(text : String, label_index : int) -> void:
	$debugWindowControl/VBoxContainer.get_child(label_index).text = str(text)
