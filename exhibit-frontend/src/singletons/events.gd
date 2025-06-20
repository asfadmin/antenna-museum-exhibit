extends Node


signal dataset_selected(dataset: Dataset)

signal functional_button_pressed(type: BackendService.INTERACTION)

signal audio_event(type: AudioManager.Type)

signal night_mode_toggled(type: bool)

func emit_dataset_selected(dataset: Dataset):
	dataset_selected.emit(dataset)

func emit_functional_button(type: BackendService.INTERACTION):
	functional_button_pressed.emit(type)

func emit_audio_event(type: AudioManager.Type):
	audio_event.emit(type)

func emit_night_mode_toggle(val: bool):
	night_mode_toggled.emit(val)
