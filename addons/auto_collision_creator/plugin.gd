@tool
extends EditorPlugin


var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/auto_collision_creator/my_dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)
	dock.editor_interface = get_editor_interface()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
