extends MarginContainer

@export var graph_node: Graph2D

var lhc_plot: PlotItem
var rhc_plot: PlotItem
var xband_plot: PlotItem
var lhc_line: Array[Variant] = []
var rhc_line: Array[Variant] = []
var xband_line: Array[Variant] = []
var x_max: int = 0
var x_min: int = -360
var x: int = x_max
var looped: bool = false
var shift_width: int = 5
var xband_column_data := []
var lhc_column_data := []
var rhc_column_data := []
var max_range := 0
var continue_feeding := false
const RANGES: Dictionary = {
	"lhc": {
		"low": 1,
		"high": 1.25,
	},
	"rhc": {
		"low": 3,
		"high": 3.25,
	},
	"xband": {
		"low": 5,
		"high": 5.25,
	},
}
# var fname := "test_data.csv"
var fname := "aqa.csv"
const XBAND_COLUMN_NAME := "Antenna Control Unit X-Band Strength (dB)"
const LHC_COLUMN_NAME := "Antenna Control Unit S-LHC Strength (dB)"
const RHC_COLUMN_NAME := "Antenna Control Unit S-RHC Strength (dB)"


func get_min(data: Array) -> float:
	var m: float = data[0] as float
	
	for d in data:
		d = d as float
		if d < m:
			m = d
		
	return m
	
	
func get_max(data: Array) -> float:
	var m: float = data[0] as float

	for d in data:
		d = d as float
		if d > m:
			m = d

	return m
	
	
func initialize_graph(lhc_column_data: Array, rhc_column_data: Array, xband_column_data: Array):
	# Initialize the three lines to plot 
	print("Initializing graph")
	lhc_plot = graph_node.add_plot_item("lhc_plot", Color.THISTLE, 5.0)
	rhc_plot = graph_node.add_plot_item("rhc_plot", Color.GAINSBORO, 5.0)
	xband_plot = graph_node.add_plot_item("xband", Color.PERU, 5.0)

	var xband_range := [get_min(xband_column_data), get_max(xband_column_data)]
	var lhc_range := [get_min(lhc_column_data), get_max(lhc_column_data)]
	var rhc_range := [get_min(rhc_column_data), get_max(rhc_column_data)]

	var xband_length: float = xband_range.max() - xband_range.min()
	var lhc_length: float = lhc_range.max() - lhc_range.min()
	var rhc_length: float = rhc_range.max() - rhc_range.min()

	print("xband range: [{0}, {1}], length: {2}".format(xband_range + [xband_length]))
	print("lhc range:   [{0}, {1}], length: {2}".format(lhc_range + [lhc_length]))
	print("rhc range:   [{0}, {1}], length: {2}".format(rhc_range + [rhc_length]))

	max_range = get_max([xband_length, lhc_length, rhc_length])
	
	graph_node.y_min = get_min([xband_range.min(), lhc_range.min(), rhc_range.min()])  # Lower y bound of the graph
	# Setting y_max to be 3x the max range ensures that there is no overlap between graphs
	graph_node.y_max = max_range * 3  # Upper y bound of the graph
	
	var y_distance: float = graph_node.y_max - graph_node.y_min

	# Distance between each vertical tick
	graph_node.y_step = y_distance / 6
	
	print("y-distance: %s" % (graph_node.y_max - graph_node.y_min))
	print("y-step:     %s" % graph_node.y_step)
	

func load_column_data() -> Dictionary:
	var csv := get_csv(fname)
	
	var column_data := {
		"lhc_column_data": get_csv_column_data(csv["headers"][LHC_COLUMN_NAME], csv["content"]),
		"rhc_column_data": get_csv_column_data(csv["headers"][RHC_COLUMN_NAME], csv["content"]),
		"xband_column_data": get_csv_column_data(csv["headers"][XBAND_COLUMN_NAME], csv["content"]),
	}

	# The csv data is heavy
	csv = {}
	
	return column_data


func _ready() -> void:
	var column_data := load_column_data()
	lhc_column_data = column_data["lhc_column_data"]
	rhc_column_data = column_data["rhc_column_data"]
	xband_column_data = column_data["xband_column_data"]
	
	initialize_graph(lhc_column_data, rhc_column_data, xband_column_data)

	
func redraw(line, plot: PlotItem):
	plot.remove_all()
	for point in line:
		plot.add_point(point)


func shift(line) -> Array[Variant]:
	# Sub shift_width from each x in the line
	var shifted: Array[Variant] = []
	for point in line:
		point.x -=  shift_width
		shifted.append(point)

	return shifted


## Takes `column_index` and returns the column at that index in the 2d Array `content`.
func get_csv_column_data(column_index: int, content: Array) -> Array:
	var column_data := []
	var content_size: int = content.size()

	column_data.resize(content_size)

	for i in range(0, content_size):
		column_data[i] = content[i][column_index]

	return column_data
	
	
## Takes a filename `fname` and returns to memory a dictionary containing the headers and the CSV
## content of the file represented in `headers` (a Dictionary) and `content` (an Array). 
## TODO(gjclark): Godot 4.4. will allow us to bind types to the dictionary so
## that we can type hint the return to Dictionary[Dictionary, Array].
func get_csv(fname: String) -> Dictionary:
	var file: FileAccess = FileAccess.open("res://%s" % fname, FileAccess.READ)

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
	
	
func is_out_of_data(xband_column_data: Array, lhc_column_data: Array, rhc_column_data: Array) -> bool:
	return xband_column_data.size() == 0 or lhc_column_data.size() == 0 or rhc_column_data.size() == 0
		
	
func feed(xband_column_data: Array, lhc_column_data: Array, rhc_column_data: Array, offset: float):
	if x > x_min:
		if looped:
			lhc_line = shift(lhc_line)
			var lhc_front = lhc_column_data.pop_front()
			lhc_line.push_front(Vector2(x_max, lhc_front as float))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			var rhc_front = rhc_column_data.pop_front()
			rhc_line.push_front(Vector2(x_max, rhc_front as float + offset))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			var xband_front = xband_column_data.pop_front()
			xband_line.push_front(Vector2(x_max, xband_front as float + offset*2))
			xband_line.pop_back()
			x = x_max
		else:
			lhc_line.push_back(Vector2(x, lhc_column_data.pop_front() as float))
			rhc_line.push_back(Vector2(x, rhc_column_data.pop_front() as float + offset))
			xband_line.push_back(Vector2(x, xband_column_data.pop_front() as float + offset*2))
		x -= shift_width
	elif x == x_min:
		lhc_line.push_back(Vector2(x, lhc_column_data.pop_front() as float))
		rhc_line.push_back(Vector2(x, rhc_column_data.pop_front() as float + offset))
		xband_line.push_back(Vector2(x_max, xband_column_data.pop_front() as float + offset*2))
		looped = true
		x = x_max

	redraw(lhc_line, lhc_plot)
	redraw(rhc_line, rhc_plot)
	redraw(xband_line, xband_plot)

	
func _on_timer_timeout() -> void:
	if is_out_of_data(xband_column_data, lhc_column_data, rhc_column_data):
		print("Ran out of data, reloading arrays and continuing to feed")
		var column_data := load_column_data()
		lhc_column_data = column_data["lhc_column_data"]
		rhc_column_data = column_data["rhc_column_data"]
		xband_column_data = column_data["xband_column_data"]
	feed(xband_column_data, lhc_column_data, rhc_column_data, max_range)
