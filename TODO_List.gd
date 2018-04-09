tool
extends EditorPlugin

var dock # A class member to hold the dock during the plugin lifecycle
var r
var vsplit
var hbox
var todo_button
var done_button
var scroll 
var vscroll
var todos = [] 
var dones = []
var todos_to_search = ["#TODO:"]
var dones_to_search = ["#TODO-DONE:"]



func _enter_tree():
	# Initialization of the plugin goes here
	# First load the dock scene and instance it:
	dock = preload("res://addons/TODO_Lister/List.tscn").instance()
	vsplit = VSplitContainer.new()
	vsplit.anchor_bottom = 1
	vsplit.anchor_right = 1
	
	hbox = HBoxContainer.new()
	
	todo_button = Button.new()
	todo_button.text = "TODO"
	
	done_button = Button.new()
	done_button.text = "DONE"
	
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = 3
	
	vscroll = GridContainer.new()
	vscroll.columns = 2
	
	scroll.add_child(vscroll)
	hbox.add_child(todo_button)
	hbox.add_child(done_button)
	vsplit.add_child(hbox)
	vsplit.add_child(scroll)
	dock.add_child(vsplit)
	
	todo_button.connect("pressed", self, "update_entries_todo")
	done_button.connect("pressed", self, "update_entries_done")
	
	# Add the loaded scene to the docks:
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)
	


func _exit_tree():
	# Clean-up of the plugin goes here
	# Remove the scene from the docks:
	remove_control_from_docks(dock) # Remove the dock

func update_entries_done():
	dir_contents()
	for i in range(0, vscroll.get_child_count()):
		vscroll.get_child(i).queue_free()
	
	var lc1 = Label.new()
	lc1.autowrap = true
	lc1.rect_min_size = Vector2(150,25)
	lc1.text = "Content"
	var lc2 = Label.new()
	lc2.text = "Context"
	vscroll.add_child(lc1)
	vscroll.add_child(lc2)

	for t in dones:
		var l = Label.new()
		l.autowrap = true
		l.rect_min_size = Vector2(150,25)
		l.text = t["line"].split(":")[1]
		var l2 = Label.new()
		l2.text = t["path"]
		
		vscroll.add_child(l)
		vscroll.add_child(l2)

func update_entries_todo():
	dir_contents()
	for i in range(0, vscroll.get_child_count()):
		vscroll.get_child(i).queue_free()
	
	var lc1 = Label.new()
	lc1.autowrap = true
	lc1.rect_min_size = Vector2(150,25)
	lc1.text = "Content"
	var lc2 = Label.new()
	lc2.text = "Context"
	vscroll.add_child(lc1)
	vscroll.add_child(lc2)
	
	for t in todos:
		var l = Label.new()
		l.autowrap = true
		l.rect_min_size = Vector2(150,25)
		l.text = t["line"].split(":")[1]
		var l2 = Label.new()
		l2.text = t["path"]
		
		vscroll.add_child(l)
		vscroll.add_child(l2)


func dir_contents():
	todos = []
	dones = []
	var dir = Directory.new()
	var current_dir = dir.get_current_dir()
	
	if dir.open(dir.get_current_dir()) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				dir_found(file_name)
			else:
				#print("Found file: " + file_name)
				found_file(file_name)
					
			file_name = dir.get_next()
	else:
	    print("An error occurred when trying to access the path.")
	#print(todos)


func dir_found(path):
	var s_dir = Directory.new()
	if s_dir.open(path) == OK:
		s_dir.list_dir_begin(true, true)
		var fn = s_dir.get_next()
		while fn != "":
			if s_dir.current_is_dir():
				#print("Found directory: " + fn)
				dir_found(fn)
			else:
				#print("Found file: " + fn)
				found_file(fn)
			fn = s_dir.get_next()

func found_file(path):
	if path.match("*.gd*"):
		var file = File.new()
		file.open(path, file.READ)
		var line = ""
		while !file.eof_reached():
			line = file.get_line()
			#print(line)
			for i in todos_to_search:
				var s = line.findn(i)
				if s>=0:
					todos.append({"line":line, "prefix_length":i.length(), "begin":s, "path":path})
			for i in dones_to_search:
				var s = line.findn(i)
				if s>=0:
					dones.append({"line":line, "prefix_length":i.length(), "begin":s, "path":path})














