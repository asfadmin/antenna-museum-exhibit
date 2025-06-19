extends Node3D

func _ready() -> void:
	DataManager.update_pass_speed(5)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		DataManager.toggle_debug_mode()

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_1):
		DataManager.update_pass_speed(1)
	elif Input.is_key_pressed(KEY_3):
		DataManager.update_pass_speed(3)
	elif Input.is_key_pressed(KEY_5):
		DataManager.update_pass_speed(5)
	elif Input.is_key_pressed(KEY_0):
		DataManager.update_pass_speed(10)
