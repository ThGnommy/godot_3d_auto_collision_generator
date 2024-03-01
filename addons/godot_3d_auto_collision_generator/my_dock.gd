@tool
extends Control

enum CollisionType {
	Convex,
	Multiple,
	Trimesh
}

enum FormatType {
	GLTF,
	FBX,
	OBJ
}

var editor_interface

var default_collision: CollisionType = CollisionType.Convex
var default_format_type: FormatType = FormatType.GLTF

var convex_collision_simplified: bool = false
var multiple_convex_collisions_custom_settings: bool = false

func _ready() -> void:
	$VBoxContainer/ItemList.select(0)
	$VBoxContainer/SimplifiedSwitch.text = "Single"

func _on_item_list_item_selected(index: int) -> void:
	if index == 0:
		default_collision = CollisionType.Convex
	elif index == 1:
		default_collision = CollisionType.Trimesh

	# Show SimplifiedSwitch only if Create Convex Collision is selected
	if index == 0:
		$VBoxContainer/SimplifiedSwitch.show()
	else:
		$VBoxContainer/SimplifiedSwitch.hide()

func create_selected_collision(mesh: MeshInstance3D) -> void:
	match(default_collision):
		CollisionType.Convex:
			mesh.create_convex_collision(false, convex_collision_simplified)
		CollisionType.Multiple:
			mesh.create_multiple_convex_collisions()
		CollisionType.Trimesh:
			mesh.create_trimesh_collision()
		_:
			printerr("Error: Something goes wrong.")

func save_scene(node, root) -> void:
	# Make the instance owner of itself
	node.scene_file_path = ""
	node.set_owner(root)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(node)
	
	var dirname = %DirectoryTree.get_selected().get_text(0) + "/"
	
	var base_dir = DirAccess.open("res://")
	var folder_exist = base_dir.dir_exists(dirname)
	
	if !folder_exist:
		printerr("Error: " + dirname + " does not exist. Refresh the directory list.")
	
	var folder = dirname + node.name + ".tscn"
	
	ResourceSaver.save(packed_scene, folder, ResourceSaver.FLAG_RELATIVE_PATHS)

func select_format_type_to_handle(node) -> void:
	match(default_format_type):
		FormatType.GLTF:
			handle_gltf_file_format(node)
		FormatType.FBX:
			handle_fbx_file_format(node)
		FormatType.OBJ:
			handle_obj_file_format(node)
		_:
			printerr("Error: Something goes wrong.")

func _on_create_and_save_pressed() -> void:
	var editor_selection = editor_interface.get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	
	if selected_nodes.size() == 0:
		printerr("You should select an object.")
		return

	# Each file type has to be handled differently
	for node in selected_nodes:
		if node.get_child_count() > 0 and node.get_child(0) is MeshInstance3D:
			default_format_type = FormatType.GLTF
			select_format_type_to_handle(node)
		elif node.get_child_count() > 0 and node.get_child(0) is Node3D:
			default_format_type = FormatType.FBX
			select_format_type_to_handle(node)
		elif node.get_child_count() == 0:
			default_format_type = FormatType.OBJ
			select_format_type_to_handle(node)

func _on_simplified_checkbox_toggled(button_pressed: bool) -> void:
	if button_pressed == true:
		convex_collision_simplified = true
		$VBoxContainer/SimplifiedSwitch.text = "Simplified"
	else:
		convex_collision_simplified = false
		$VBoxContainer/SimplifiedSwitch.text = "Single"

func handle_obj_file_format(node: Node3D) -> void:
	var parent = node.get_tree().get_edited_scene_root()
	create_selected_collision(node)
	var static_body = node.get_child(0)
	ACC_Utility.recursive_set_owner(static_body, node, parent)
	
	# Reset position
	node.position = Vector3.ZERO
	
	save_scene(node, parent)

func handle_gltf_file_format(node: Node3D) -> void:
	var parent = node.get_tree().get_edited_scene_root()
	parent.set_editable_instance(node, true);
	var mesh: MeshInstance3D = node.get_child(0)
	# Delete previous childs
	if mesh.get_child_count() > 0:
		for child in mesh.get_children():
			child.queue_free()
	
	create_selected_collision(mesh)
	
	# Reset position
	node.position = Vector3.ZERO

	save_scene(node, parent)

func handle_fbx_file_format(node: Node3D) -> void:
	var parent = node.get_tree().get_edited_scene_root()
	parent.set_editable_instance(node, true);
	
	var root_node = node.get_child(0)
	var child_mesh = root_node.get_child(0)
	
	child_mesh.reparent(node)
	child_mesh.set_owner(node)
	
	node.remove_child(root_node)
	root_node.queue_free()
	
	create_selected_collision(child_mesh)
	
	# Reset position
	node.position = Vector3.ZERO
	save_scene(node, parent)
