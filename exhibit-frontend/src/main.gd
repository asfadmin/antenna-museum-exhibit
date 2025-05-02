extends Node3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		DataManager.toggle_debug_mode()
