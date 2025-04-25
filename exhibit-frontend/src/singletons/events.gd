extends Node


signal dataset_selected(dataset: Dataset)

signal functional_button_pressed(type: BackendService.INTERACTION)

func emit_dataset_selected(dataset: Dataset):
    dataset_selected.emit(dataset)

func emit_functional_button(type: BackendService.INTERACTION):
    functional_button_pressed.emit(type)