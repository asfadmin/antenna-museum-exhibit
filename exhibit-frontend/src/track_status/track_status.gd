extends Node2D

@export var font: Font
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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

	var size = 275
	var border_scale_factor = 2.5
	var origin = Vector2.ONE * size * (border_scale_factor / 2.0)

	draw_rect(Rect2(0.0, 0.0, size * border_scale_factor, size * border_scale_factor), Color.BLACK)
	# cyan circles
	for radius in range(25, size, 50):
		draw_circle(origin, radius, cyan, false, 1.0, true)

	# northing
	draw_line(origin + Vector2.UP * size, origin + Vector2.DOWN * size, cyan, 1.0)

	#easting
	draw_line(origin + Vector2.RIGHT * size, origin + Vector2.LEFT * size, cyan, 1.0)

	# outer yellow circle
	draw_circle(origin, 275, yellow, false, 1.0, true)

	# Draw the green semi-circles
	var start_arc = deg_to_rad(-150)
	var end_arc = deg_to_rad(175)
	draw_arc(origin, 260, start_arc, end_arc, 75, green, 1.0)
	draw_arc(origin, 240, end_arc, 7 * PI / 6.0, 10, green, 1.0)
	
	var l1p1 = circ_pos(260, -150) + origin
	var l1p2 = circ_pos(240, -150) + origin
	draw_line(l1p1, l1p2, green, 1.0)
	var l2p1 = circ_pos(260, 175) + origin
	var l2p2 = circ_pos(240, 175) + origin
	draw_line(l2p1, l2p2, green, 1.0)

	var font_size = 18
	draw_string(font, Vector2.ONE * 10, 'SMP', 0, -1, font_size, cyan)
	draw_string(font, Vector2.ONE * 10 + Vector2.DOWN * font_size, 'Peak EL: %s' % 'PLACEHOLDER', 0, -1, font_size, cyan)
	
	draw_string(font, (Vector2.DOWN * font_size) + 2.0 * size * Vector2.RIGHT, 'Limit', 0, -1, font_size, red)
	draw_string(font, (Vector2.DOWN * font_size * 2) + 2.0 * size * Vector2.RIGHT, 'Track', 0, -1, font_size, yellow)
	draw_string(font, (Vector2.DOWN * font_size * 3) + 2.0 * size * Vector2.RIGHT, 'Autotrack', 0, -1, font_size, green)
	
	draw_string(font, (Vector2.UP * font_size) + 2.0 * size * Vector2.ONE, 'Azimuth %s' % 'PLACEHOLDER', 0, -1, font_size, green, HORIZONTAL_ALIGNMENT_LEFT)
