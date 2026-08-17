extends Node2D

signal cutscene_triggered(code : String)
signal switch_level(code : String, domain : String)


var which_cutscene_triggered : Array = [false, "", null]:
	set(cutscene_code):
		which_cutscene_triggered = cutscene_code
		if which_cutscene_triggered[0]:
			cutscene_triggered.emit(which_cutscene_triggered[1], which_cutscene_triggered[2])
		elif !which_cutscene_triggered[0]:
			cutscene_triggered.emit("", null)
	get:
		return which_cutscene_triggered

var which_entry_point : Array = [false, "", ""]:
	set(entry_point_code):
		which_entry_point = entry_point_code
		if which_entry_point[0]:
			switch_level.emit(which_entry_point[1], which_entry_point[2])
		elif !which_entry_point[0]:
			switch_level.emit("", "")
	get:
		return which_entry_point
