@tool
extends Control

@export var font: Font
@export var line_width: float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	#%background.size = Vector2(275.0 * 2.75, 275.0 * 2.75)
	pass # Replace with function body.

func _init() -> void:
	queue_redraw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func circ_pos(radius: float, angle: float):
	return Vector2(radius*cos(deg_to_rad(angle)), radius*sin(deg_to_rad(angle))) 

func _draw():
	var yellow : Color = Color.KHAKI
	var green: Color = Color.GREEN
	var cyan : Color = Color.CYAN
	var red : Color = Color.RED

	var size = self.size.x
	#var border_scale_factor = 2.5
	var origin = self.get_rect().get_center() + Vector2.DOWN * 20
	#var origin = Vector2.ONE * size * (border_scale_factor / 2.0)
	var min_radius = (size / 12) * .8
	var max_radius = (size / 2) * .8
	
	#draw_rect(Rect2(0.0, 0.0, size * border_scale_factor, size * border_scale_factor), Color.BLACK)
	# cyan circles
	for radius in range(min_radius, max_radius, min_radius):
		draw_circle(origin, radius, cyan, false, line_width, true)

	# northing
	draw_line(origin + Vector2.UP * max_radius, origin + Vector2.DOWN * max_radius, cyan, line_width)

	#easting
	draw_line(origin + Vector2.RIGHT * max_radius, origin + Vector2.LEFT * max_radius, cyan, line_width)

	# outer yellow circle
	draw_circle(origin, max_radius, yellow, false, line_width, true)

	# Draw the green semi-circles
	var start_arc = deg_to_rad(-150)
	var end_arc = deg_to_rad(175)
	
	var outer_green_arc_radius = 0.92 * max_radius
	var inner_green_arc_radius = 0.86 * max_radius
	draw_arc(origin, outer_green_arc_radius, start_arc, end_arc, 75, green, line_width)
	draw_arc(origin, inner_green_arc_radius, end_arc, 7 * PI / 6.0, 10, green, line_width)
	
	var l1p1 = circ_pos(outer_green_arc_radius, -150) + origin
	var l1p2 = circ_pos(inner_green_arc_radius, -150) + origin
	draw_line(l1p1, l1p2, green, line_width)
	var l2p1 = circ_pos(outer_green_arc_radius, 175) + origin
	var l2p2 = circ_pos(inner_green_arc_radius, 175) + origin
	draw_line(l2p1, l2p2, green, line_width)

	var font_size = 18
	# draw_string(font, Vector2.ONE * 10, 'SMP', 0, -1, font_size, cyan)
	# draw_string(font, Vector2.ONE * 10 + Vector2.DOWN * font_size, 'Peak EL: %s' % 'PLACEHOLDER', 0, -1, font_size, cyan)
	
	# draw_string(font, (Vector2.DOWN * font_size) + 2.0 * size * Vector2.RIGHT, 'Limit', 0, -1, font_size, red)
	# draw_string(font, (Vector2.DOWN * font_size * 2) + 2.0 * size * Vector2.RIGHT, 'Track', 0, -1, font_size, yellow)
	# draw_string(font, (Vector2.DOWN * font_size * 3) + 2.0 * size * Vector2.RIGHT, 'Autotrack', 0, -1, font_size, green)
	
	# draw_string(font, (Vector2.UP * font_size) + size * Vector2.ONE, 'Azimuth %s' % 'PLACEHOLDER', 0, -1, font_size, green, HORIZONTAL_ALIGNMENT_RIGHT)
