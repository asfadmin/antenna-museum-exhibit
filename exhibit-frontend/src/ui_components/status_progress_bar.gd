extends ProgressBar

# should update with progress from data_manager
# should have unique look for rehoming vs tracking
# should reset

func _ready() -> void:
    DataManager.percent_complete_changed.connect(_on_percent_complete_changed)

func _on_percent_complete_changed(percent: float):
    value = percent # might need reworking later
