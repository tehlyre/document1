extends Node2D

signal cutscene_triggered(code : String)


var which_cutscene_triggered : Array = [false, "", null]:
	set(cutscene_code):
		which_cutscene_triggered = cutscene_code
		if which_cutscene_triggered[0]:
			cutscene_triggered.emit(which_cutscene_triggered[1], which_cutscene_triggered[2])
		elif !which_cutscene_triggered[0]:
			cutscene_triggered.emit("", null)
	get:
		return which_cutscene_triggered
