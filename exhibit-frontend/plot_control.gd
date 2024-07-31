extends MarginContainer


@export var graph_node: Graph2D
var lhc_plot: PlotItem
var rhc_plot: PlotItem
var xband_plot: PlotItem
var lhc_line = []
var rhc_line = []
var xband_line = []
var x := 360
var looped = false


func _ready() -> void:
	lhc_plot = graph_node.add_plot_item("lhc_plot", Color.THISTLE, 5.0)
	rhc_plot = graph_node.add_plot_item("rhc_plot", Color.GAINSBORO, 5.0)
	xband_plot = graph_node.add_plot_item("xband", Color.PERU, 5.0)


func redraw(line, plot: PlotItem):
	plot.remove_all()
	for point in line:
		plot.add_point(point)


func shift(line):
	# Sub 60 from each x in the line
	var shifted = []
	for point in line:
		point.x -=  60
		shifted.append(point)

	return shifted


func _on_timer_timeout() -> void:
	if x > 0:
		if looped:
			lhc_line = shift(lhc_line)
			lhc_line.push_front(Vector2(360, randf_range(0, 2)))
			lhc_line.pop_back()

			rhc_line = shift(rhc_line)
			rhc_line.push_front(Vector2(360, randf_range(2, 4)))
			rhc_line.pop_back()

			xband_line = shift(xband_line)
			xband_line.push_front(Vector2(360, randf_range(4, 6)))
			xband_line.pop_back()
			x = 360
		else:
			lhc_line.append(Vector2(x, randf_range(0, 2)))
			rhc_line.append(Vector2(x, randf_range(2, 4)))
			xband_line.append(Vector2(x, randf_range(4, 6)))
		x -= 60
	elif x == 0:
		lhc_line.append(Vector2(x, randf_range(0, 2)))
		rhc_line.append(Vector2(x, randf_range(2, 4)))
		xband_line.append(Vector2(x, randf_range(4, 6)))
		looped = true
		x = 360

	redraw(lhc_line, lhc_plot)
	redraw(rhc_line, rhc_plot)
	redraw(xband_line, xband_plot)
