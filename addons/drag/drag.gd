@tool
extends EditorPlugin

var toolbar : Control
var undo_redo : EditorUndoRedoManager
var enemy = preload("res://scenes/Characters/enemigo.tscn")
#var chest = preload("res://scenes/Hazards/chest.tscn")
#var wall = preload("res://scenes/Hazards/wall.tscn")
var instance : Node2D
var mouse_pressed : bool = false
var editor_state : EditorState = 0
var wall_handler : WallHandler
var marker : PackedScene = preload("res://scenes/UI/map_marker.tscn")

enum EditorState {
	NONE,
	WALL,
	ENEMY,
	CHEST,
	GOO
}
var obj : Object

var button_connections : Array[Callable] = [_on_map_button_pressed, _on_train_button_pressed]

func _enter_tree() -> void:
	toolbar = preload("res://addons/drag/drag.tscn").instantiate()
	for i in toolbar.get_child(0).get_children():
		i.pressed.connect(button_connections[i.get_index()])
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, toolbar)

func _on_map_button_pressed():
	if obj is not Level:
		return
	var wall_node = get_tree().edited_scene_root.get_node("Wall")
	var chests_node = get_tree().edited_scene_root.get_node("Chests")
	OS.execute("python", ["yay.py", wall_node.get_used_cells_by_id(0), "stupid.png"])
	var w_x = []
	var w_y = []
	for i in wall_node.get_used_cells_by_id(0):
		w_x.append(i.x)
		w_y.append(i.y)
	prints(w_x.min(), w_y.min())
	get_editor_interface().open_scene_from_path("res://scenes/UI/map_menu.tscn")
	for old_marker in get_tree().edited_scene_root.get_node("Panel/map/markers").get_children():
		old_marker.queue_free()
	get_tree().edited_scene_root.xmin = w_x.min()
	get_tree().edited_scene_root.ymin = w_y.min()
	for door in wall_node.get_used_cells_by_id(1):
		var m_ = marker.instantiate()
		get_tree().edited_scene_root.get_node("Panel/map/markers").add_child(m_)
		m_.owner = get_tree().edited_scene_root
		
		m_.position = Vector2((door.x-w_x.min())*2,(door.y-w_y.min())*2)
		m_.cursor = get_tree().edited_scene_root.get_node("Panel/cursor")
		m_.marker_type = 1
	for chest in chests_node.get_children():
		var m_ = marker.instantiate()
		get_tree().edited_scene_root.get_node("Panel/map/markers").add_child(m_)
		m_.owner = get_tree().edited_scene_root
		prints(chest.position.x/40, chest.position.y/40, "six seven")
		m_.position = Vector2((chest.position.x/40-w_x.min()*2),(chest.position.y/40-w_y.min()*2))
		m_.cursor = get_tree().edited_scene_root.get_node("Panel/cursor")
		m_.marker_type = 2
	for stamp in wall_node.get_used_cells_by_id(3):
		print(wall_node.get_used_cells_by_id(3))
		var m_ = marker.instantiate()
		get_tree().edited_scene_root.get_node("Panel/map/markers").add_child(m_)
		m_.owner = get_tree().edited_scene_root
		m_.position = Vector2((stamp.x-w_x.min())*2,(stamp.y-w_y.min())*2)
		m_.cursor = get_tree().edited_scene_root.get_node("Panel/cursor")
		m_.marker_type = 4
		print(wall_node.map_to_local(stamp))
		m_.extra_info = wall_node.map_to_local(stamp)
		#print(stamp)
	print("lmao")
	for door in wall_node.get_used_cells_by_id(3):
		print("ooooh")

func _on_train_button_pressed():
	print(obj)
	if obj is not WordTracks:
		return
	var train = obj.train
	print(train.global_position)
	train.global_position = obj.get_node("origin_marker").global_position
	train.rotation = obj.rotation
	train.scale = obj.scale

#func do_make_enemy(event : InputEventMouseButton) -> void:
	#instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	#instance.player = get_tree().edited_scene_root.get_node("Durdan")
	#get_tree().edited_scene_root.get_node("Room/enemies").add_child(instance)
	#instance.owner = get_tree().edited_scene_root
#
#func undo_make_enemy(node : Enemy) -> void:
	#get_tree().edited_scene_root.get_node("Room/enemies").remove_child(node)
#
#func do_make_chest(event : InputEventMouseButton) -> void:
	#instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	#get_tree().edited_scene_root.get_node("Chests").add_child(instance)
	#instance.owner = get_tree().edited_scene_root
#
#func undo_make_chest(node : Interactable) -> void:
	#get_tree().edited_scene_root.get_node("Chests").remove_child(node)
#
#func do_make_wall(event : InputEventMouseButton) -> void:
	#instance.position = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	#get_tree().edited_scene_root.get_node("Level/Walls").add_child(instance)
	#instance.owner = get_tree().edited_scene_root

#func undo_make_wall(node : Wall) -> void:
	#get_tree().edited_scene_root.get_node("Level/Walls").remove_child(node)

## Consumes InputEventMouseMotion and forwards other InputEvent types.
#func _forward_canvas_gui_input(event : InputEvent) -> bool:
	#if (event is InputEventMouseButton):
		#if mouse_pressed and editor_state == EditorState.ENEMY:
			#instance = enemy.instantiate()
			#undo_redo.create_action("Instantiate Enemy")
			#undo_redo.add_do_method(self, "do_make_enemy", event)
			#undo_redo.add_do_reference(instance)
			#undo_redo.add_undo_method(self, "undo_make_enemy", instance)
			#undo_redo.commit_action()
		#if mouse_pressed and editor_state == EditorState.CHEST:
			#instance = chest.instantiate()
			#undo_redo.create_action("Instantiate Chest")
			#undo_redo.add_do_method(self, "do_make_chest", event)
			#undo_redo.add_do_reference(instance)
			#undo_redo.add_undo_method(self, "undo_make_chest", instance)
			#undo_redo.commit_action()
		#if mouse_pressed and editor_state == EditorState.WALL:
			#instance = wall.instantiate()
			#undo_redo.create_action("Instantiate Wall")
			#undo_redo.add_do_method(self, "do_make_wall", event)
			#undo_redo.add_do_reference(instance)
			#undo_redo.add_undo_method(self, "undo_make_wall", instance)
			#undo_redo.commit_action()
		#return true
	#return false

func _handles(object: Object) -> bool:
	obj = object
	return object is Level or object is WordTracks

#func _change_editor_state(state : int):
	#editor_state = state

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
