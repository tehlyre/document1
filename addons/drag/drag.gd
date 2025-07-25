@tool
extends EditorPlugin

var toolbar : Control
var undo_redo : EditorUndoRedoManager
var enemy = preload("res://scenes/Characters/enemigo.tscn")
var chest = preload("res://scenes/Hazards and Helps/chest.tscn")
var wall = preload("res://scenes/Hazards and Helps/wall.tscn")
var instance : Node2D
var mouse_pressed : bool = false
var editor_state : EditorState = 0
var wall_handler : WallHandler

enum EditorState {
	NONE,
	WALL,
	ENEMY,
	CHEST,
	GOO
}

func _enter_tree() -> void:
	toolbar = preload("res://scenes/drag.tscn").instantiate()
	for i in toolbar.get_child(0).get_children():
		i.changed_editor_status.connect(_change_editor_state)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, toolbar)
	scene_changed.connect(func(new_root : Node):
		if new_root:
			print("Scene changed to: ", new_root)
	)
	undo_redo = get_undo_redo()
	wall_handler = WallHandler.new()
	add_child(wall_handler)


func do_make_enemy(event : InputEventMouseButton) -> void:
	instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	instance.player = get_tree().edited_scene_root.get_node("Durdan")
	get_tree().edited_scene_root.get_node("Room/enemies").add_child(instance)
	instance.owner = get_tree().edited_scene_root

func undo_make_enemy(node : Enemy) -> void:
	get_tree().edited_scene_root.get_node("Room/enemies").remove_child(node)

func do_make_chest(event : InputEventMouseButton) -> void:
	instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	get_tree().edited_scene_root.get_node("Chests").add_child(instance)
	instance.owner = get_tree().edited_scene_root

func undo_make_chest(node : Interactable) -> void:
	get_tree().edited_scene_root.get_node("Chests").remove_child(node)

func do_make_wall(event : InputEventMouseButton) -> void:
	instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	get_tree().edited_scene_root.get_node("Level/Walls").add_child(instance)
	instance.owner = get_tree().edited_scene_root

func undo_make_wall(node : Wall) -> void:
	get_tree().edited_scene_root.get_node("Level/Walls").remove_child(node)

# Consumes InputEventMouseMotion and forwards other InputEvent types.
func _forward_canvas_gui_input(event : InputEvent) -> bool:
	if (event is InputEventMouseButton):
		if mouse_pressed and editor_state == EditorState.ENEMY:
			instance = enemy.instantiate()
			undo_redo.create_action("Instantiate Enemy")
			undo_redo.add_do_method(self, "do_make_enemy", event)
			undo_redo.add_do_reference(instance)
			undo_redo.add_undo_method(self, "undo_make_enemy", instance)
			undo_redo.commit_action()
		if mouse_pressed and editor_state == EditorState.CHEST:
			instance = chest.instantiate()
			undo_redo.create_action("Instantiate Chest")
			undo_redo.add_do_method(self, "do_make_chest", event)
			undo_redo.add_do_reference(instance)
			undo_redo.add_undo_method(self, "undo_make_chest", instance)
			undo_redo.commit_action()
		if mouse_pressed and editor_state == EditorState.WALL:
			instance = wall.instantiate()
			undo_redo.create_action("Instantiate Wall")
			undo_redo.add_do_method(self, "do_make_wall", event)
			undo_redo.add_do_reference(instance)
			undo_redo.add_undo_method(self, "undo_make_wall", instance)
			undo_redo.commit_action()
		return true
	return false

func _handles(object: Object) -> bool:
	return object is Level

func _change_editor_state(state : int):
	editor_state = state

func _process(delta: float) -> void:
	var mouse_press = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if mouse_press and not mouse_pressed:
		mouse_pressed = true
	elif not mouse_press or not mouse_pressed:
		mouse_pressed = false

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(toolbar)
	
	toolbar.free()
