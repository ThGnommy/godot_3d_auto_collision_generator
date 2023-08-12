@tool
extends Control

# 1. Make children editable
# 2. Choose a collision type
# 	- Add the collision

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
	
	ResourceSaver.save(packed_scene, "res://prova/", ResourceSaver.FLAG_RELATIVE_PATHS)
	print(ResourceSaver.get_recognized_extensions(packed_scene))
	
func _on_button_pressed() -> void:
	var editor_selection = editor_interface.get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	
	for node in selected_nodes:
		
		var parent = node.get_tree().get_edited_scene_root()
		parent.set_editable_instance(node, true);
		
		var mesh: MeshInstance3D = node.get_child(0)
		
		# Delete previous childs
		if mesh.get_child_count() > 0:
			for child in mesh.get_children():
				child.queue_free()
		
		create_selected_collision(mesh)
		
		save_scene(node, parent)

func _on_simplified_checkbox_toggled(button_pressed: bool) -> void:
	if button_pressed == true:
		convex_collision_simplified = true
		$VBoxContainer/SimplifiedCheckbox.text = "Simplified"
	else:
		convex_collision_simplified = false
		$VBoxContainer/SimplifiedCheckbox.text = "Single"
