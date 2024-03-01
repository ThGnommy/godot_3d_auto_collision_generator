@tool
extends Tree

var root_path: String = "res://"

var selected_text

func _ready() -> void:
	create_directory_tree()

func create_directory_tree() -> void:
	clear()
	var root: TreeItem = create_item()
	hide_root = true
	
	var base_folder = create_item(root)
	base_folder.set_text(0, "res://")
	base_folder.select(0)
	
	set_directories(root_path, root)

func set_directories(path: String, root_tree: TreeItem) -> void:
	var dir = DirAccess.open(path)
 
	if dir:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			
			if file == "":
				break
			
			# Ignore addons and hidden folders
			elif file.contains("addons") or file.begins_with("."):
				continue
			elif dir.current_is_dir():
				
				var sub_path: String
				
				if path == root_path:
					sub_path = path + file
				else: 
					sub_path = path + "/" + file
				
				var item = create_item(root_tree)
				item.set_text(0, sub_path)
				set_directories(sub_path, item)
  
		dir.list_dir_end()

func _on_refresh_directories_pressed() -> void:
	create_directory_tree()
