@tool
extends EditorPlugin

var toolbar
var scene

signal homosaxual(event:InputEventMouseButton)

func _enter_tree() -> void:
	homosaxual.connect(_on_homosaxual)
	toolbar = preload("res://scenes/drag.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, toolbar)
	scene_changed.connect(func(new_root : Node):
		if new_root:
			print("Scene changed to: ", new_root)
			scene = new_root
	)


func _on_homosaxual(event : InputEventMouseButton) -> void:
	var enemy = preload("res://scenes/Characters/enemigo.tscn")
	var instance = enemy.instantiate()
	print(enemy)
	instance.position = get_viewport().get_mouse_position()
	get_tree().edited_scene_root.add_child(instance)
	instance.owner = get_tree().edited_scene_root
	print(get_tree().edited_scene_root.get_children())
	

# Consumes InputEventMouseMotion and forwards other InputEvent types.
func _forward_canvas_gui_input(event : InputEvent) -> bool:
	if (event is InputEventMouseButton):
		homosaxual.emit(event)
		print("heheheheeheheheheheheheheheheheheheheheheheheheheheheheeheheheheheheehehehehehehe")
		return true
	return false

func _handles(object: Object) -> bool:
	print(object is Level)
	return object is Level

func _input(event) -> void:
	pass
	#if event is InputEventMouseButton:
		#if EditorInterface.get_editor_viewport_2d().get_visible_rect().has_point(event.position) and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			#var mouse_position = get_viewport().get_mouse_position()
			#print(scene)
			
			

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(toolbar)
	
	toolbar.free()
