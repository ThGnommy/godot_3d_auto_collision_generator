@tool
extends CheckButton

func _ready() -> void:
	hide()

func _on_toggled(button_pressed: bool) -> void:
	if button_pressed == true:
		$"../MultipleConvexCollisionsSettings".show()
	else:
		$"../MultipleConvexCollisionsSettings".hide()
