@tool
extends EditorPlugin

var wall : Wall
var wall_rect : Rect2
var is_deselecting : bool = false
var is_resizing_x_from_right : bool = false
var is_resizing_x_from_left : bool = false
var is_resizing_y_from_top : bool = false
var is_resizing_y_from_bottom : bool = false
#var is_resizing_y : bool = false
var starting_mouse_pos : Vector2
var starting_wall_pos : Vector2
var starting_wall_scale : Vector2

var undo_redo : EditorUndoRedoManager

func _enter_tree() -> void:
	undo_redo = get_undo_redo()

func _handles(object: Object) -> bool:
	wall = object
	wall_rect = wall.get_node("wallSprite").get_rect()
	print(object is Wall)
	return object is Wall

func do_commit_resize() -> void:
	return

func undo_commit_resize(pos : Vector2, scale : Vector2, w_ : Wall) -> void:
	w_.position = pos
	w_.scale = scale

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	var mouse_pos : Vector2 = EditorInterface.get_editor_viewport_2d().get_mouse_position()
	var local_mouse_pos : Vector2 = wall.get_translated_mouse_pos(mouse_pos)
	if event is InputEventKey and event.get_keycode() == KEY_SHIFT and event.is_pressed() == true:
		is_deselecting = true
		return false
	elif event is InputEventKey and event.get_keycode() == KEY_SHIFT and event.is_released() == true:
		is_deselecting = false
		return false
	if is_deselecting:
		return false
	if !(event is InputEventMouseButton):
		return false
	if event.is_released():
		is_resizing_x_from_left = false
		is_resizing_x_from_right = false
		is_resizing_y_from_top = false
		is_resizing_y_from_bottom = false
		undo_redo.create_action("Resize Wall")
		undo_redo.add_do_method(self, "do_commit_resize")
		undo_redo.add_do_reference(wall)
		undo_redo.add_undo_method(self, "undo_commit_resize", wall.position, wall.scale, wall)
		undo_redo.commit_action()
		return false
	if event.get_button_index() != MOUSE_BUTTON_LEFT:
		return false
	if abs(wall_rect.position.x-local_mouse_pos.x) < 10:
		is_resizing_x_from_left = true
		starting_mouse_pos = mouse_pos
		starting_wall_pos = wall.position
		starting_wall_scale = wall.scale
		print('oapiehrpfoih')
		return true
	elif abs((wall_rect.position.x+wall_rect.size.x)-local_mouse_pos.x) < 10:
		is_resizing_x_from_right = true
		starting_mouse_pos = mouse_pos
		starting_wall_pos = wall.position
		starting_wall_scale = wall.scale
		print("you are gae")
		return true
	elif abs((wall_rect.position.y+wall_rect.size.y)-local_mouse_pos.y) < 10:
		is_resizing_y_from_bottom = true
		starting_mouse_pos = mouse_pos
		starting_wall_pos = wall.position
		starting_wall_scale = wall.scale
		print("is_resizing_y")
		return true
	elif abs(wall_rect.position.y-local_mouse_pos.y) < 10:
		is_resizing_y_from_top = true
		starting_mouse_pos = mouse_pos
		starting_wall_pos = wall.position
		starting_wall_scale = wall.scale
		print("ioejhrgpoqiherpgoqiuhergpoiqhergpoiqherpgoiqherg")
		return true
	return false

func rotate_around_point(target : Vector2, pivot : Vector2, angle : float):
	return (target-pivot).rotated(angle)+pivot

func _process(delta: float) -> void:
	if is_resizing_x_from_right:
		var garbage_scale : Vector2 = wall.scale
		var mouse_pos : Vector2 = EditorInterface.get_editor_viewport_2d().get_mouse_position()
		garbage_scale.x = abs(starting_wall_scale.x - (starting_mouse_pos.x-mouse_pos.x)/100)
		wall.position.x = starting_wall_pos.x-(starting_mouse_pos.x-mouse_pos.x)/2
		wall.position = wall.position.rotated(wall.rotation)
		wall.scale = garbage_scale
	elif is_resizing_x_from_left:
		var garbage_scale : Vector2 = wall.scale
		var mouse_pos : Vector2 = EditorInterface.get_editor_viewport_2d().get_mouse_position()
		garbage_scale.x = abs(starting_wall_scale.x + (starting_mouse_pos.x-mouse_pos.x)/100)
		wall.position.x = starting_wall_pos.x-(starting_mouse_pos.x-mouse_pos.x)/2
		wall.position = wall.position.rotated(wall.rotation)
		wall.scale = garbage_scale
	elif is_resizing_y_from_bottom:
		var garbage_scale : Vector2 = wall.scale
		var mouse_pos : Vector2 = EditorInterface.get_editor_viewport_2d().get_mouse_position()
		garbage_scale.y = abs(starting_wall_scale.y - (starting_mouse_pos.y-mouse_pos.y)/100)
		wall.position.y = starting_wall_pos.y-(starting_mouse_pos.y-mouse_pos.y)/2
		wall.scale = garbage_scale
	elif is_resizing_y_from_top:
		var garbage_scale : Vector2 = wall.scale
		var mouse_pos : Vector2 = EditorInterface.get_editor_viewport_2d().get_mouse_position()
		garbage_scale.y = abs(starting_wall_scale.y + (starting_mouse_pos.y-mouse_pos.y)/100)
		wall.position.y = starting_wall_pos.y-(starting_mouse_pos.y-mouse_pos.y)/2
		wall.scale = garbage_scale

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
