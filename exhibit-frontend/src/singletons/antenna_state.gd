extends Node

var real_azimuth: float :
	set(value):
		real_azimuth_changed.emit(value)
var real_train: float :
	set(value):
		real_train_changed.emit(value)
var real_elevation: float :
	set(value):
		real_elevation_changed.emit(value)

# when we're not tracking anything, use these to report the ui model's rotations
var ui_model_azimuth: float :
	set(value):
		ui_model_azimuth_changed.emit(value)
var ui_model_elevation: float :
	set(value):
		ui_model_elevation_changed.emit(value)

var current_action: BackendService.INTERACTION = BackendService.INTERACTION.STOP
var tracked_dataset: Dataset = null

signal real_azimuth_changed(value: float)
signal real_train_changed(value: float)
signal real_elevation_changed(value: float)

signal ui_model_azimuth_changed(value: float)
signal ui_model_elevation_changed(value: float)

signal current_action_changed(action: BackendService.INTERACTION)
signal tracked_dataset_changed(dataset: Dataset)

func set_current_action(action: BackendService.INTERACTION):
	current_action = action
	current_action_changed.emit(action)

func set_tracked_dataset(dataset: Dataset):
	tracked_dataset = dataset
	tracked_dataset_changed.emit(dataset)
