extends Button

@export var type: BackendService.INTERACTION


func _ready() -> void:
    pressed.connect(_on_pressed)


func _on_pressed():
    Events.emit_functional_button(type)