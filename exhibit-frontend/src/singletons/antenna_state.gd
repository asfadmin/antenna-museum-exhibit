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

signal real_azimuth_changed(value: float)
signal real_train_changed(value: float)
signal real_elevation_changed(value: float)