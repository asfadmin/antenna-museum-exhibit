extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AntennaState.real_azimuth_changed.connect(_on_real_azimuth_changed)
	AntennaState.real_train_changed.connect(_on_real_train_changed)
	AntennaState.real_elevation_changed.connect(_on_real_elevation_changed)

func update_stats_section(commandLabel: Label, errorLabel: Label, actualLabel: Label, sliderLabel: Label, slider: HSlider, value: float):
	commandLabel.text = str(value)
	var random_offset = randf_range(-0.05,0.05)
	errorLabel.text = str(random_offset)
	actualLabel.text = str(value + random_offset)
	sliderLabel.text = str(value) # probably round this
	slider.value = value

func _on_real_azimuth_changed(value: float):
	update_stats_section(%CommandAzimuthLabel,%ErrorAzimuthLabel,%RealAzimuthLabel, %AzimuthSliderLabel, %AzimuthSlider, value)

func _on_real_train_changed(value: float):
	update_stats_section(%CommandTrainLabel,%ErrorTrainLabel,%RealTrainLabel, %TrainSliderLabel, %TrainSlider, value)

func _on_real_elevation_changed(value: float):
	update_stats_section(%CommandElevationLabel,%ErrorElevationLabel,%RealElevationLabel, %ElevationSliderLabel, %ElevationSlider, value)

func _on_azimuth_slider(value: float):
	pass

func _on_train_slider(value: float):
	pass

func _on_elevation_slider(value: float):
	pass