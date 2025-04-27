extends MarginContainer

@export var graph_node: Graph2D


var x_max: int = 0
var x_min: int = -360
var x: int = x_max

var looped: bool = false

var shift_width: int = 5
var max_range: float = 0
var continue_feeding := false

var lhc_plot: PlotItem
var rhc_plot: PlotItem
var xband_plot: PlotItem

var lhc_line: Array[Variant] = []
var rhc_line: Array[Variant] = []
var xband_line: Array[Variant] = []

var lhc_column_data := []
var rhc_column_data := []
var xband_column_data := []


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
var fname := "sci.csv"
const XBAND_COLUMN_NAME := "Antenna Control Unit X-Band Strength (dB)"
const LHC_COLUMN_NAME := "Antenna Control Unit S-LHC Strength (dB)"
const RHC_COLUMN_NAME := "Antenna Control Unit S-RHC Strength (dB)"
@onready var current_1 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer1/Current1
@onready var current_2 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer2/Current2
@onready var current_3 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer3/Current3
var lhc_range := []
var rhc_range := []
var xband_range := []

var upper_bound_1
var lower_bound_1
				 
var upper_bound_2
var lower_bound_2
				 
var upper_bound_3
var lower_bound_3

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
	# print("Initializing graph")
	lhc_plot = graph_node.add_plot_item("lhc_plot", Color.THISTLE, 5.0)
	rhc_plot = graph_node.add_plot_item("rhc_plot", Color.GAINSBORO, 5.0)
	xband_plot = graph_node.add_plot_item("xband", Color.PERU, 5.0)

	lhc_range = [get_min(lhc_column_data), get_max(lhc_column_data)]
	rhc_range = [get_min(rhc_column_data), get_max(rhc_column_data)]
	xband_range = [get_min(xband_column_data), get_max(xband_column_data)]

	var lhc_length: float = lhc_range.max() - lhc_range.min()
	var rhc_length: float = rhc_range.max() - rhc_range.min()
	var xband_length: float = xband_range.max() - xband_range.min()

	# print("lhc range:   [{0}, {1}], length: {2}".format(lhc_range + [lhc_length]))
	# print("rhc range:   [{0}, {1}], length: {2}".format(rhc_range + [rhc_length]))
	# print("xband range: [{0}, {1}], length: {2}".format(xband_range + [xband_length]))

	# print("total distance: %s" % (xband_length + lhc_length + rhc_length))
	max_range = get_max([xband_length, lhc_length, rhc_length])
	# print("max range: %s" % max_range)
	
	var y_min: float = get_min([xband_range.min(), lhc_range.min(), rhc_range.min()])  # Lower y bound of the graph
	graph_node.y_min = y_min
	# Setting y_max to be 3x the max range ensures that there is no overlap between graphs
	var y_max = max_range * 3  # Upper y bound of the graph
	graph_node.y_max = y_max
	
	var y_distance: float = graph_node.y_max - graph_node.y_min

	# Distance between each vertical tick
	var y_step: float = y_distance / 6
	graph_node.y_step = y_step
	
	# print("y-distance (according to graph 2d): %s" % (graph_node.y_max - graph_node.y_min))
	# print("y-distance (according to the actual line values): %s" % (y_max - y_min))
	# print("y-step:     %s" % graph_node.y_step)
	# print("y-max:      %s" % y_max)
	# print("y-min:      %s" % y_min)
	
	upper_bound_1 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer1/UpperBound1
	lower_bound_1 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer1/LowerBound1
	
	upper_bound_2 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer2/UpperBound2
	lower_bound_2 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer2/LowerBound2
	
	upper_bound_3 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer3/UpperBound3
	lower_bound_3 = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer3/LowerBound3
	
	
	upper_bound_1.text = str(get_max(lhc_range))
	lower_bound_1.text = str(get_min(lhc_range))
	
	upper_bound_2.text = str(get_max(rhc_range))
	lower_bound_2.text = str(get_min(rhc_range))
	
	upper_bound_3.text = str(get_max(xband_range))
	lower_bound_3.text = str(get_min(xband_range))

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
	
	lhc_column_data = constrain_to_graph(column_data["lhc_column_data"], lower_bound_1.text as float, upper_bound_1.text as float)
	rhc_column_data = constrain_to_graph(column_data["rhc_column_data"], lower_bound_2.text as float, upper_bound_2.text as float)
	xband_column_data = constrain_to_graph(column_data["xband_column_data"], lower_bound_3.text as float, upper_bound_3.text as float)

	
func redraw(line: Array[Variant], plot: PlotItem, offset):
	plot.remove_all()
	for point in line:
		plot.add_point(point)


func shift(line) -> Array[Variant]:
	# Sub shift_width from each x in the line
	var shifted: Array[Variant] = []
	for point in line:
		point.x -= shift_width
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
		
	
func constrain_to_graph(column_data: Array, lower_bound: float, upper_bound: float):
	for i in len(column_data):
		var d: float = column_data[i] as float
		if d < lower_bound:
			column_data[i] = lower_bound as String
		elif d > upper_bound:
			column_data[i] = upper_bound as String
	return column_data
	
func feed(xband_column_data: Array, lhc_column_data: Array, rhc_column_data: Array, offset: float):
	var lhc_offset   := offset * 2 + (offset - get_max(lhc_range))
	var rhc_offset   := offset * 1 + (offset - get_max(rhc_range))
	var xband_offset := offset * 0
	
	var lhc_front: float = lhc_column_data.pop_front() as float
	var rhc_front: float = rhc_column_data.pop_front() as float
	var xband_front: float = xband_column_data.pop_front() as float
	
	var lhc_current_val: float = lhc_front
	var rhc_current_val: float = rhc_front
	var xband_current_val: float = xband_front
	
	if x > x_min:
		if looped:
			lhc_line = shift(lhc_line)
			lhc_current_val = lhc_front
			lhc_line.push_front(Vector2(x_max, lhc_current_val + lhc_offset))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			rhc_current_val = rhc_front
			rhc_line.push_front(Vector2(x_max, rhc_current_val + rhc_offset))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			xband_current_val = xband_front
			xband_line.push_front(Vector2(x_max, xband_current_val + xband_offset))
			xband_line.pop_back()
			
			x = x_max
		else:
			lhc_line.push_back(Vector2(x, lhc_front + lhc_offset))
			rhc_line.push_back(Vector2(x, rhc_front + rhc_offset))
			xband_line.push_back(Vector2(x, xband_front + xband_offset))
		
		x -= shift_width
		
	elif x == x_min:
		lhc_line.push_back(Vector2(x, lhc_front + lhc_offset))
		rhc_line.push_back(Vector2(x, rhc_front + rhc_offset))
		xband_line.push_back(Vector2(x_max, xband_front + xband_offset))
		
		looped = true
		x = x_max

	current_1.text = "%0.2f" % lhc_current_val
	current_2.text = "%0.2f" % rhc_current_val
	current_3.text = "%0.2f" % xband_current_val

	redraw(lhc_line, lhc_plot,  0)
	redraw(rhc_line, rhc_plot,  offset)
	redraw(xband_line, xband_plot,  offset*2)

	
func _on_timer_timeout() -> void:
	if is_out_of_data(xband_column_data, lhc_column_data, rhc_column_data):
		print("Ran out of data, reloading arrays and continuing to feed")
		var column_data := load_column_data()
		lhc_column_data = constrain_to_graph(column_data["lhc_column_data"], lower_bound_1.text as float, upper_bound_1.text as float)
		rhc_column_data = constrain_to_graph(column_data["rhc_column_data"], lower_bound_2.text as float, upper_bound_2.text as float)
		xband_column_data = constrain_to_graph(column_data["xband_column_data"], lower_bound_3.text as float, upper_bound_3.text as float)
	feed(xband_column_data, lhc_column_data, rhc_column_data, max_range)
