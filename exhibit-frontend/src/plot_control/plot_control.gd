extends MarginContainer
@export var graph_node: Graph2D


var is_paused: bool = false
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

var flat_lhc_line: Array
var flat_rhc_line: Array
var flat_xband_line: Array


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
@export var current_1: Label
@export var current_2: Label
@export var current_3: Label
var lhc_range := []
var rhc_range := []
var xband_range := []

@export var upper_bound_1: Label
@export var lower_bound_1: Label
				 
@export var upper_bound_2: Label
@export var lower_bound_2: Label
				 
@export var upper_bound_3: Label
@export var lower_bound_3: Label

@export var timer: Timer

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


func pause():
	is_paused = true


func initialize_graph(lhc_column_data: Array, rhc_column_data: Array, xband_column_data: Array):
	# Initialize the three lines to plot 
	lhc_plot = graph_node.add_plot_item("lhc_plot", Color.THISTLE, 5.0)
	rhc_plot = graph_node.add_plot_item("rhc_plot", Color.GAINSBORO, 5.0)
	xband_plot = graph_node.add_plot_item("xband", Color.PERU, 5.0)

	lhc_range = [get_min(lhc_column_data), get_max(lhc_column_data)]
	rhc_range = [get_min(rhc_column_data), get_max(rhc_column_data)]
	xband_range = [get_min(xband_column_data), get_max(xband_column_data)]

	var lhc_length: float = lhc_range.max() - lhc_range.min()
	var rhc_length: float = rhc_range.max() - rhc_range.min()
	var xband_length: float = xband_range.max() - xband_range.min()


	max_range = get_max([xband_length, lhc_length, rhc_length])
	
	var y_min: float = get_min([xband_range.min(), lhc_range.min(), rhc_range.min()])  # Lower y bound of the graph
	graph_node.y_min = y_min
	# Setting y_max to be 3x the max range ensures that there is no overlap between graphs
	var y_max = max_range * 3  # Upper y bound of the graph
	graph_node.y_max = y_max
	
	var y_distance: float = graph_node.y_max - graph_node.y_min

	# Distance between each vertical tick
	var y_step: float = y_distance / 6
	graph_node.y_step = y_step

	upper_bound_1.text = str(get_max(lhc_range))
	lower_bound_1.text = str(get_min(lhc_range))
	
	upper_bound_2.text = str(get_max(rhc_range))
	lower_bound_2.text = str(get_min(rhc_range))
	
	upper_bound_3.text = str(get_max(xband_range))
	lower_bound_3.text = str(get_min(xband_range))



func _ready() -> void:
	pause()
	DataManager.data_loaded.connect(data_changed)
	timer.timeout.connect(_on_timer_timeout)

	
func data_changed(data):
	if data == null:
		reset_graph()
		return
	# var column_data = load_column_data(data)
	reset_graph()
	lhc_column_data = data["lhc_column_data"].duplicate()
	rhc_column_data = data["rhc_column_data"].duplicate()
	xband_column_data = data["xband_column_data"].duplicate()
	
	initialize_graph(lhc_column_data, rhc_column_data, xband_column_data)
	
	timer.start(timer.wait_time)

	print("graph_node.y_min: %s" % graph_node.y_min)
	print("graph_node.y_step: %s" % graph_node.y_step)

	# Hard-code for the sake of getting this done
	var dataset: String
	if AntennaState.tracked_dataset != null:
		dataset = AntennaState.tracked_dataset.dataset_id
	else:
		dataset = 'AQUA'
	flat_lhc_line = []
	flat_rhc_line = []
	flat_xband_line = []
	if dataset == "AQUA":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("90")
			flat_rhc_line.append("50")
			flat_xband_line.append("10")
	elif dataset == "AURA":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("90")
			flat_rhc_line.append("50")
			flat_xband_line.append("10")
	elif dataset == "IC2":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("170")
			flat_rhc_line.append("90")
			flat_xband_line.append("10")
	elif dataset == "ICESAT":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("170")
			flat_rhc_line.append("90")
			flat_xband_line.append("10")
	elif dataset == "OCO2":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("106.7")
			flat_rhc_line.append("60")
			flat_xband_line.append("13.3")
	elif dataset == "SCISAT":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("90")
			flat_rhc_line.append("50")
			flat_xband_line.append("10")
	elif dataset == "SMAP":
		for i in range(len(lhc_column_data)):
			flat_lhc_line.append("90")
			flat_rhc_line.append("50")
			flat_xband_line.append("10")
	
	print("Dataset: " + dataset)
	print("flat_lhc_line: " + flat_lhc_line[0])
	print("flat_rhc_line: " + flat_rhc_line[0])
	print("flat_xband_line: " + flat_xband_line[0])

	lhc_column_data = flat_lhc_line
	rhc_column_data = flat_rhc_line
	xband_column_data = flat_xband_line



func reset_graph():
	graph_node.remove_all() # this seems to not actually remove everything rn
	timer.stop()
	lhc_line = []
	rhc_line = []
	xband_line = []
	looped = false
	redraw(lhc_line, lhc_plot,  0)
	redraw(rhc_line, rhc_plot,  0)
	redraw(xband_line, xband_plot, 0 )
	current_1.text = "0"
	current_2.text = "0"
	current_3.text = "0"



func redraw(line: Array[Variant], plot: PlotItem, _offset):
	if plot == null:
		return
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


func is_out_of_data(xband_column_data: Array, lhc_column_data: Array, rhc_column_data: Array) -> bool:
	return xband_column_data.size() == 0 or lhc_column_data.size() == 0 or rhc_column_data.size() == 0


func normalize(line_name, value, is_paused):
	if is_paused:
		return value
	if line_name == 'lhc':
		var new_max = graph_node.y_max
		var new_min = graph_node.y_max - 2 * graph_node.y_step
		var old_max = lhc_range[0]
		var old_min = lhc_range[1]
		
		return ((value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min
	elif line_name == 'rhc':
		var new_max = graph_node.y_max - 2 * graph_node.y_step
		var new_min = graph_node.y_max - 4 * graph_node.y_step
		var old_max = rhc_range[0]
		var old_min = rhc_range[1]

		return ((value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min
	else:
		var new_max = graph_node.y_max - 4 * graph_node.y_step
		var new_min = graph_node.y_max - 6 * graph_node.y_step
		var old_max = xband_range[0]
		var old_min = xband_range[1]

		return ((value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min


func feed(lhc_column_data: Array, rhc_column_data: Array, xband_column_data: Array, offset: float, is_paused: bool):
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
			lhc_line.push_front(Vector2(x_max, normalize('lhc', lhc_current_val, is_paused)))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			rhc_current_val = rhc_front
			rhc_line.push_front(Vector2(x_max, normalize('rhc', rhc_current_val, is_paused)))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			xband_current_val = xband_front
			xband_line.push_front(Vector2(x_max, normalize('xband', xband_current_val, is_paused)))
			xband_line.pop_back()
			
			x = x_max
		else:
			lhc_line.push_back(Vector2(x, normalize('lhc', lhc_current_val, is_paused)))
			rhc_line.push_back(Vector2(x, normalize('rhc', rhc_current_val, is_paused)))
			xband_line.push_back(Vector2(x, normalize('xband', xband_current_val, is_paused)))
		
		x -= shift_width
		
	elif x == x_min:
		lhc_line.push_back(Vector2(x, normalize('lhc', lhc_current_val, is_paused)))
		rhc_line.push_back(Vector2(x, normalize('rhc', rhc_current_val, is_paused)))
		xband_line.push_back(Vector2(x_max, normalize('xband', xband_current_val, is_paused)))
		
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
		var column_data = DataManager.get_data()
		
		lhc_column_data = column_data["lhc_column_data"]
		rhc_column_data = column_data["rhc_column_data"]
		xband_column_data = column_data["xband_column_data"]
		
		print("Arrays reloaded")
		is_paused = false
	if is_paused:
		print("Paused and feeding flat lines")
		feed(flat_lhc_line, flat_rhc_line, flat_xband_line, 0, is_paused)
	else:
		print("Not paused and feeding real lines")
		feed(lhc_column_data, rhc_column_data, xband_column_data, max_range, is_paused)
