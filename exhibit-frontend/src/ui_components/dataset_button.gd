extends Button

@export var dataset: Dataset
@export var default = false
func _ready() -> void:
    pressed.connect(_on_pressed)
    if default:
        Events.emit_dataset_selected(dataset)


func _on_pressed():
    Events.emit_dataset_selected(dataset)