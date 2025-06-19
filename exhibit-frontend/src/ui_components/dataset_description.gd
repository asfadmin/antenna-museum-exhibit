extends Label

func _ready() -> void:
    Events.dataset_selected.connect(_on_dataset_selected)

func _on_dataset_selected(dataset: Dataset):
    text = dataset.description