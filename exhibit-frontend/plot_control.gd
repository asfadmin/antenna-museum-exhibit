extends MarginContainer


@export var graph_node: Graph2D
var lhc_plot: PlotItem
var rhc_plot: PlotItem
var xband_plot: PlotItem
var lhc_line = []
var rhc_line = []
var xband_line = []
var x_max = 0
var x_min = -360
var x = x_max
var looped = false
var shift_width = 5

var ranges = {
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


func redraw(line, plot: PlotItem):
	plot.remove_all()
	for point in line:
		plot.add_point(point)


func shift(line):
	# Sub shift_width from each x in the line
	var shifted = []
	for point in line:
		point.x -=  shift_width
		shifted.append(point)

	return shifted


func _on_timer_timeout() -> void:
	if x > x_min:
		if looped:
			lhc_line = shift(lhc_line)
			lhc_line.push_front(Vector2(x_max, randf_range(ranges["lhc"]["low"], ranges["lhc"]["high"])))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			rhc_line.push_front(Vector2(x_max, randf_range(ranges["rhc"]["low"], ranges["rhc"]["high"])))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			xband_line.push_front(Vector2(x_max, randf_range(ranges["xband"]["low"], ranges["xband"]["high"])))
			xband_line.pop_back()
			x = x_max
		else:
			lhc_line.push_back(Vector2(x, randf_range(ranges["lhc"]["low"], ranges["lhc"]["high"])))
			rhc_line.push_back(Vector2(x, randf_range(ranges["rhc"]["low"], ranges["rhc"]["high"])))
			xband_line.push_back(Vector2(x, randf_range(ranges["xband"]["low"], ranges["xband"]["high"])))
		x -= shift_width
	elif x == x_min:
		lhc_line.push_back(Vector2(x, randf_range(ranges["lhc"]["low"], ranges["lhc"]["high"])))
		rhc_line.push_back(Vector2(x, randf_range(ranges["rhc"]["low"], ranges["rhc"]["high"])))
		xband_line.push_back(Vector2(x_max, randf_range(ranges["xband"]["low"], ranges["xband"]["high"])))
		looped = true
		x = x_max

	redraw(lhc_line, lhc_plot)
	redraw(rhc_line, rhc_plot)
	redraw(xband_line, xband_plot)
