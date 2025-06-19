extends Label

var timestamps = []
const display_str = "{} minutes {} seconds"

func _ready() -> void:
	DataManager.data_loaded.connect(_on_data_loaded)
	DataManager.percent_complete_changed.connect(_update_text)

func _on_data_loaded(data):
	if data == null:
		self.timestamps = []
	else:
		self.timestamps = data['timestamp']

func _update_text(val: float):
	if len(self.timestamps) > 1 and DataManager.estimated_pass_speed > 0.0:
		var last_idx = len(self.timestamps) - 1
		var current_complete_idx = floor(min(val, 1.0) * last_idx)

		var current_time = DateObject.new(self.timestamps[current_complete_idx])
		var end = DateObject.new(self.timestamps[last_idx])
		var time_remaining = current_time.time_span(end) / DataManager.estimated_pass_speed

		self.text= "Estimate: " + seconds_to_string(time_remaining) + " (" + str(roundi(DataManager.estimated_pass_speed)) + "x speed)"
	else:
		self.text = ''


func seconds_to_string(val: int):
	var display_minutes = floori(val / 60.0)
	var display_seconds = val % 60
	
	return self.display_str.format([display_minutes, display_seconds], "{}")

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

		var abs_minutes =  hour * 60 + minute
		var other_abs_minutes = other_date.hour * 60 + other_date.minute
		
		var abs_seconds = abs_minutes * 60 + second
		var other_abs_seconds = other_abs_minutes * 60 +other_date.second
		
		return abs(abs_seconds - other_abs_seconds)


		
