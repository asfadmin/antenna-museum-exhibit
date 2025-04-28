# this probably doesn't need to be a singleton, but this is easier for now
extends Node

signal data_loaded

var loaded_data

## 0-1.0 scale of track or stow being complete
var percent_complete = 0.0

signal percent_complete_changed(percent: float)

var filenames = {
    'AQUA': 'aqa.csv'
}

var backend: BackendService
var request_timer: Timer

func _ready() -> void:
    AntennaState.current_action_changed.connect(_on_action_changed)
    # BackendService.request_completed.connect(_on_request_completed)
    backend = get_tree().get_first_node_in_group("BackendService")
    backend.request_completed.connect(_on_request_completed)
    request_timer = Timer.new()
    request_timer.autostart = false
    add_child(request_timer)
    request_timer.timeout.connect(_on_request_timer_timeout)


func _on_action_changed(action: BackendService.INTERACTION):
    if action == BackendService.INTERACTION.TRACK:
        load_data('AQUA')
        start_tracking()
    elif action == BackendService.INTERACTION.REHOME or action == BackendService.INTERACTION.STOP:
        clear_data()
        AntennaState.set_tracked_dataset(null)
        stop_tracking() # stopping should pause this, rehoming should reset and start tracking again, for now tho this works

func load_data(dataset_id):
    load_column_data(filenames[dataset_id])
    data_loaded.emit(loaded_data)

func get_data():
    return loaded_data

func clear_data():
    loaded_data = null
    data_loaded.emit(loaded_data)

var ACTUAL_AZIMUTH_COLUMN = "Actual Az."
var ACTUAL_ELEVATION_COLUMN = "Actual El."
var COMMANDED_AZIMUTH_COLUMN = "Commanded Az."
var COMMANDED_ELEVATION_COLUMN = "Commanded El."
var AUTOTRACK_STATUS = "Autotrack Status"
const XBAND_COLUMN_NAME := "Antenna Control Unit X-Band Strength (dB)"
const LHC_COLUMN_NAME := "Antenna Control Unit S-LHC Strength (dB)"
const RHC_COLUMN_NAME := "Antenna Control Unit S-RHC Strength (dB)"

func get_csv(filename: String) -> Dictionary:
    var file: FileAccess = FileAccess.open("res://%s" % filename, FileAccess.READ)

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


var fake_progress = 0.0

# this can show even if it fails, will need some error checking possibly
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    var converted = body.get_string_from_utf16() # this should give us a JSON response?

    # this is definitely not what the response is but the idea should continue
    var test = {
        'progress': fake_progress # this will probably be some math later
    }

    fake_progress += 0.01
    if fake_progress >= 1.0:
        stop_tracking()
    percent_complete = fake_progress
    percent_complete_changed.emit(percent_complete)
    print(percent_complete)


func _on_request_timer_timeout():
    backend.Status()

func start_tracking():
    fake_progress = 0.0
    request_timer.start(0.5)

func stop_tracking():
    request_timer.stop()
