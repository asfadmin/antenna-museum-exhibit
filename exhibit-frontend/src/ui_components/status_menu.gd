extends BoxContainer

@export var current_label: Label
@export var track_label: Label
@export var azimuth_label: Label

func _ready() -> void:
    AntennaState.current_action_changed.connect(_on_current_action_changed)


func _on_current_action_changed(action: BackendService.INTERACTION):
    if action == BackendService.INTERACTION.TRACK:
        current_label.text = 'Tracking ' + AntennaState.tracked_dataset.dataset_id
    elif action == BackendService.INTERACTION.STOP:
        current_label.text = 'Stopped'
    elif action == BackendService.INTERACTION.STOWED:
        current_label.text = 'Stowed'
    elif action == BackendService.INTERACTION.REHOME:
        current_label.text = 'Going back to home'