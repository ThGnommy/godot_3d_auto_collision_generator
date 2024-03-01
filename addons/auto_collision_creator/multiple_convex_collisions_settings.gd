@tool
extends Control

# docs: https://docs.godotengine.org/en/4.1/classes/class_meshconvexdecompositionsettings.html

func _ready() -> void:
	#hide()
	
	var meshStruct = MeshConvexDecompositionSettings.new()
	
	var class_props = meshStruct.get_property_list()
	for prop in class_props:
		var prop_name = prop.name
		var prop_value = meshStruct.get(prop_name)
		print("Property:", prop_name, "Value:", prop_value)
