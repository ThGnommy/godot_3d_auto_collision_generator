@tool
extends Control

enum CollisionType {
	Convex,
	Multiple,
	Trimesh
}

var editor_interface

var default_collision: CollisionType = CollisionType.Convex

var convex_collision_simplified: bool = false

func _ready() -> void:
	$VBoxContainer/ItemList.select(0)
	$VBoxContainer/SimplifiedCheckbox.text = "Single"

func _on_item_list_item_selected(index: int) -> void:
	if index == 0:
		default_collision = CollisionType.Convex
		$VBoxContainer/SimplifiedCheckbox.show()
	elif index == 1:
		default_collision = CollisionType.Multiple
		$VBoxContainer/SimplifiedCheckbox.hide()
	elif index == 2:
		default_collision = CollisionType.Trimesh
		$VBoxContainer/SimplifiedCheckbox.hide()

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
	
	var folder = $VBoxContainer/DirectoryName.text + node.name + ".tscn"
	
	ResourceSaver.save(packed_scene, folder, ResourceSaver.FLAG_RELATIVE_PATHS)

func _on_create_and_save_pressed() -> void:
	var editor_selection = editor_interface.get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	
	if selected_nodes.size() == 0:
		printerr("You should select an object.")
		return

	for node in selected_nodes:
		#handle_gltf_file_format(node)
		handle_obj_file_format(node)
		#handle_fbx_file_format(node)

func _on_simplified_checkbox_toggled(button_pressed: bool) -> void:
	if button_pressed == true:
		convex_collision_simplified = true
		$VBoxContainer/SimplifiedCheckbox.text = "Simplified"
	else:
		convex_collision_simplified = false
		$VBoxContainer/SimplifiedCheckbox.text = "Single"

func _on_select_directory_pressed() -> void:
	var selected_directory: String = editor_interface.get_current_directory()
	$VBoxContainer/DirectoryName.text = selected_directory

func handle_obj_file_format(mesh: MeshInstance3D) -> void:
	var parent = mesh.get_tree().get_edited_scene_root()
	
	if mesh.get_child_count() == 0:
		create_selected_collision(mesh)
		
		var static_body = mesh.get_child(0)
		
		ACC_Utility.recursive_set_owner(static_body, mesh, parent)
		
		save_scene(mesh, parent)

	else: return

func handle_gltf_file_format(node: Node3D) -> void:
	if node.get_child_count(true) > 0 and node.get_child(0).get_child_count() == 0:
		var parent = node.get_tree().get_edited_scene_root()
		parent.set_editable_instance(node, true);
		var mesh: MeshInstance3D = node.get_child(0)
		# Delete previous childs
		if mesh.get_child_count() > 0:
			for child in mesh.get_children():
				child.queue_free()
		
		create_selected_collision(mesh)

		save_scene(node, parent)

func handle_fbx_file_format(node: Node3D) -> void:
	var parent = node.get_tree().get_edited_scene_root()
	
	if node.get_child(0).get_child_count() > 0:
		parent.set_editable_instance(node, true);
		var mesh: MeshInstance3D = node.get_child(0).get_child(0)
		# Delete previous childs
		if mesh.get_child_count() > 0:
			for child in mesh.get_children():
				child.queue_free()
		
		create_selected_collision(mesh)
		save_scene(node, parent)
