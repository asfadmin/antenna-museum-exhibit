# this probably doesn't need to be a singleton, but this is easier for now
extends Node

signal data_loaded

var loaded_data

var filenames = {
    'AQUA': 'aqa.csv'
}


func _ready() -> void:
    AntennaState.current_action_changed.connect(_on_action_changed)


func _on_action_changed(action: BackendService.INTERACTION):
    if action == BackendService.INTERACTION.TRACK:
        load_data('AQUA')
        pass # load data
    elif action == BackendService.INTERACTION.REHOME or action == BackendService.INTERACTION.STOP:
        clear_data()

func load_data(dataset_id):
    load_column_data(filenames[dataset_id])
    data_loaded.emit(loaded_data)

func get_data():
    pass

func clear_data():
    loaded_data = null
    data_loaded.emit(loaded_data)

var ACTUAL_AZIMUTH_COLUMN = "Actual Az."
var ACTUAL_ELEVATION_COLUMN = "Actual El."
var COMMANDED_AZIMUTH_COLUMN = "Commanded Az."
var COMMANDED_ELEVATION_COLUMN = "Commanded El."
var AUTOTRACK_STATUS = "Autotrack Status"


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
