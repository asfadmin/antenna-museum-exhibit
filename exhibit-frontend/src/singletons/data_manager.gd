# this probably doesn't need to be a singleton, but this is easier for now
extends Node

signal data_loaded

var loaded_data

## 0-1.0 scale of track or stow being complete
var percent_complete = 0.0
var percent_change = 0.0
signal percent_complete_changed(percent: float)
signal debug_mode_toggled(val: bool)

var filenames = {
	'AQUA': 'aqa.csv',
	'AURA': 'aur.csv',
	'IC2': 'ic2.csv',
	'ICESAT': 'ic2.csv',
	'OCO2': 'oc2.csv',
	'SCISAT': 'sci.csv',
	'SMAP': 'aqa.csv' # not seeing smap in files?
}

var request_timer: Timer
var current_dataset: Dataset
var debug_mode: bool = false
var pass_speed: int = 1
var estimated_pass_speed: float = 1.0

signal track_complete

func _ready() -> void:
	AntennaState.current_action_changed.connect(_on_action_changed)
	Events.dataset_selected.connect(_update_dataset)

	request_timer = Timer.new()
	request_timer.autostart = false
	add_child(request_timer)
	request_timer.timeout.connect(_on_request_timer_timeout)
	await get_tree().create_timer(0.1).timeout # get the plot to shift into the correct layout since idk what's going on with it
	load_data('AQUA')
	clear_data()
	DataManager.track_complete.connect(_on_track_complete)
	Events.functional_button_pressed.connect(_on_functional_button_pressed)


func _update_dataset(dataset: Dataset):
	current_dataset = dataset


func _on_functional_button_pressed(type: BackendService.INTERACTION):
	var backend = BackendService.new()
	add_child(backend)
	backend.request_completed.connect(_on_request_completed.bind(backend))
	if type == BackendService.INTERACTION.STOP:
		backend.Stop()
	elif type == BackendService.INTERACTION.SPEED_UP:
		backend.Speed()
	elif type == BackendService.INTERACTION.TRACK && current_dataset:
		AntennaState.set_tracked_dataset(current_dataset)
		backend.Path(current_dataset.dataset_id)
	elif type == BackendService.INTERACTION.REHOME:
		backend.Home()

func _on_track_complete():
	if AntennaState.current_action == BackendService.INTERACTION.TRACK:
		AntennaState.set_current_action(BackendService.INTERACTION.STOP) # 
		AntennaState.set_current_action(BackendService.INTERACTION.STOWED) # paths include the rehoming part already
	elif AntennaState.current_action == BackendService.INTERACTION.REHOME:
		AntennaState.set_current_action(BackendService.INTERACTION.STOWED)

func _on_action_changed(action: BackendService.INTERACTION):
	if action == BackendService.INTERACTION.TRACK:
		load_data(current_dataset.dataset_id)
		start_tracking()
	elif action == BackendService.INTERACTION.STOP:
		clear_data()
		AntennaState.set_tracked_dataset(null)
		stop_tracking() # stopping should pause this, rehoming should reset and start tracking again, for now tho this works
	elif action == BackendService.INTERACTION.REHOME:
		clear_data()
		AntennaState.set_tracked_dataset(null)
		stop_tracking()
		#start_tracking()

func load_data(dataset_id):
	load_column_data(filenames[dataset_id])
	data_loaded.emit(loaded_data)

func get_data():
	return loaded_data

func clear_data():
	loaded_data = null
	data_loaded.emit(loaded_data)

var TIMESTAMP = "Timestamp"
var ACTUAL_AZIMUTH_COLUMN = "Actual Az."
var ACTUAL_ELEVATION_COLUMN = "Actual El."
var COMMANDED_AZIMUTH_COLUMN = "Commanded Az."
var COMMANDED_ELEVATION_COLUMN = "Commanded El."
var AUTOTRACK_STATUS = "Autotrack Status"
const XBAND_COLUMN_NAME := "Antenna Control Unit X-Band Strength (dB)"
const LHC_COLUMN_NAME := "Antenna Control Unit S-LHC Strength (dB)"
const RHC_COLUMN_NAME := "Antenna Control Unit S-RHC Strength (dB)"

func get_csv(filename: String) -> Dictionary:
	var file: FileAccess = FileAccess.open("res://assets/data/%s" % filename, FileAccess.READ)

	# Get headers to index into content using column names
	var headers := file.get_csv_line()
	var header_dict := {}

	for i in headers.size():
		header_dict[headers[i]] = i

	var content := []
	# Get the data itself (csv rows)
	while file.get_position() < file.get_length():
		var csv_line := file.get_csv_line()

		if csv_line != null and csv_line.size() > 0:
			content.append(csv_line)
		else:
			print("Empty line")

	file.close()
	return {
		"headers": header_dict,
		"content": content,
	}

func load_column_data(filename) -> Dictionary:
	var csv := get_csv(filename)

	var column_data := {
		"timestamp": get_csv_column_timestamp_data(csv["headers"][TIMESTAMP], csv["content"]),
		"actual_azimuth": get_csv_column_data(csv["headers"][ACTUAL_AZIMUTH_COLUMN], csv["content"]),
		"actual_elevation": get_csv_column_data(csv["headers"][ACTUAL_ELEVATION_COLUMN], csv["content"]),
		"commanded_azimuth": get_csv_column_data(csv["headers"][COMMANDED_AZIMUTH_COLUMN], csv["content"]),
		"commanded_elevation": get_csv_column_data(csv["headers"][COMMANDED_ELEVATION_COLUMN], csv["content"]),
		"autotrack_status": get_csv_column_data(csv["headers"][AUTOTRACK_STATUS], csv["content"]),
		"lhc_column_data": get_csv_column_data(csv["headers"][LHC_COLUMN_NAME], csv["content"]),
		"rhc_column_data": get_csv_column_data(csv["headers"][RHC_COLUMN_NAME], csv["content"]),
		"xband_column_data": get_csv_column_data(csv["headers"][XBAND_COLUMN_NAME], csv["content"]),
	}

	# The csv data is heavy
	csv = {}
	loaded_data = column_data
	return column_data


## Takes `column_index` and returns the column at that index in the 2d Array `content`.
func get_csv_column_data(column_index: int, content: Array) -> Array[float]:
	var column_data: Array[float] = []
	var content_size: int = content.size()

	column_data.resize(content_size)

	for i in range(0, content_size):
		column_data[i] = float(content[i][column_index])

	return column_data

## Takes `column_index` and returns the column at that index in the 2d Array `content`.
func get_csv_column_timestamp_data(column_index: int, content: Array) -> Array[Dictionary]:
	var column_data: Array[Dictionary] = []
	var content_size: int = content.size()

	column_data.resize(content_size)

	for i in range(0, content_size):
		var year_day_time = content[i][column_index].split(' ')
		var output = {}
		output['year'] = year_day_time[0]
		output['day'] = year_day_time[1]
		
		var hour_min_sec = year_day_time[-1].split(':')
		output['time'] = {}
		output['time']['hour'] = hour_min_sec[0]
		output['time']['minute'] = hour_min_sec[1]
		output['time']['second'] = hour_min_sec[2]
		column_data[i] = output

	return column_data

var fake_progress = 0.0

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node: Node, is_status=false):
	var converted = body.get_string_from_utf8() # this should give us a JSON response?
	var json_body = {}
	# if theI response is bad, seamlessly swap to debug data
	if len(converted) > 0 and response_code == 200:
		json_body = JSON.parse_string(converted)
	if is_status:
		# if the api is using the debug port or not
		var is_debug_api = false
		if json_body != null:
			is_debug_api = json_body.get('message', 'not') == 'DEBUG'
		if self.debug_mode or is_debug_api or response_code != 200:
			fake_progress += (1.0 / len(self.loaded_data['timestamp'])) * self.pass_speed
			if fake_progress >= 1.0:
				stop_tracking()
				movement_complete()
			percent_change = fake_progress - percent_complete
			percent_complete = fake_progress
		else:
			self.pass_speed = 1
			var percentage = json_body.get('progress', 0.0)
			if percentage >= 1.0:
				stop_tracking()
				movement_complete()
			
			percent_change = percentage - percent_complete
			percent_complete = percentage
			fake_progress = percentage # if the API loses contact with the hardware, resume from last percentage
		
		self.estimated_pass_speed = _estimate_speed_scale()
		percent_complete_changed.emit(percent_complete)
			
	node.queue_free()

func _estimate_speed_scale() -> float:
	if self.loaded_data != null:
		if len(self.loaded_data['timestamp']) > 1:
			var last_idx = len(self.loaded_data['timestamp']) - 1
			var current_complete_idx = floor(min(self.percent_complete, 1.0) * last_idx)
			
			return (DataManager.percent_change * 100) / ((1.0 / last_idx) * 100)
	return 1.0

func _on_request_timer_timeout():
	var backend = BackendService.new()
	add_child(backend)
	backend.request_completed.connect(_on_request_completed.bind(backend,true))
	backend.Status()

func start_tracking():
	fake_progress = 0.0
	request_timer.start(1.0)

func stop_tracking():
	request_timer.stop()
	percent_complete_changed.emit(0.0)

func movement_complete():
	track_complete.emit()

func toggle_debug_mode():
	self.debug_mode = !self.debug_mode
	self.debug_mode_toggled.emit(self.debug_mode)

func update_pass_speed(val: int):
	self.pass_speed = val


class DateObject:
	"""Date helper class for checking time intervals intervals"""
	var year: int
	var day: int
	var hour: int
	var minute: int
	var second: int

	func _init(dict: Dictionary) -> void:
		self.year = dict['year']
		self.day = dict['day']
		self.hour = dict['time']['hour']
		self.minute = dict['time']['minute']
		self.second = dict['time']['second']
	
	func time_span(other_date: DateObject) -> int:
		"""Returns the timespan in seconds"""
		var minutes = 0

		var abs_minutes =  hour * 60 + minute
		var other_abs_minutes = other_date.hour * 60 + other_date.minute
		
		var abs_seconds = abs_minutes * 60 + second
		var other_abs_seconds = other_abs_minutes * 60 +other_date.second
		
		return abs(abs_seconds - other_abs_seconds)
