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


func _ready() -> void:
	lhc_plot = graph_node.add_plot_item("lhc_plot", Color.THISTLE, 5.0)
	rhc_plot = graph_node.add_plot_item("rhc_plot", Color.GAINSBORO, 5.0)
	xband_plot = graph_node.add_plot_item("xband", Color.PERU, 5.0)

	var fname := "test_data.csv"
	var column := "foos"
	var csv := get_csv(fname)
	var column_data := get_csv_column(csv["headers"][column], csv["content"])
	print(column_data)


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


## Takes a filename `fname` and returns to memory a dictionaray containing the headers and the CSV
## content of the file represented in `headers` and `content`. 
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

	return {
		"headers": header_dict,
		"content": content,
	}


## Takes `column_index` and returns the column at that index in the CSV dictionary `content`.
func get_csv_column(column_index: int, content: Dictionary) -> Array:
	var column_data := []
	var content_size: int = content.size()

	column_data.resize(content_size)

	for i in range(0, content_size):
		column_data[i] = content[i][column_index]

	return column_data

	
func do_demo():
	if x > x_min:
		if looped:
			lhc_line = shift(lhc_line)
			lhc_line.push_front(Vector2(x_max, randf_range(RANGES["lhc"]["low"], RANGES["lhc"]["high"])))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			rhc_line.push_front(Vector2(x_max, randf_range(RANGES["rhc"]["low"], RANGES["rhc"]["high"])))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			xband_line.push_front(Vector2(x_max, randf_range(RANGES["xband"]["low"], RANGES["xband"]["high"])))
			xband_line.pop_back()
			x = x_max
		else:
			lhc_line.push_back(Vector2(x, randf_range(RANGES["lhc"]["low"], RANGES["lhc"]["high"])))
			rhc_line.push_back(Vector2(x, randf_range(RANGES["rhc"]["low"], RANGES["rhc"]["high"])))
			xband_line.push_back(Vector2(x, randf_range(RANGES["xband"]["low"], RANGES["xband"]["high"])))
		x -= shift_width
	elif x == x_min:
		lhc_line.push_back(Vector2(x, randf_range(RANGES["lhc"]["low"], RANGES["lhc"]["high"])))
		rhc_line.push_back(Vector2(x, randf_range(RANGES["rhc"]["low"], RANGES["rhc"]["high"])))
		xband_line.push_back(Vector2(x_max, randf_range(RANGES["xband"]["low"], RANGES["xband"]["high"])))
		looped = true
		x = x_max

	redraw(lhc_line, lhc_plot)
	redraw(rhc_line, rhc_plot)
	redraw(xband_line, xband_plot)


func _on_timer_timeout() -> void:
	do_demo()
