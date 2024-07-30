extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	var yellow : Color = Color.KHAKI
	var green: Color = Color.GREEN
	var cyan : Color = Color.CYAN

	var origin = Vector2.ONE * 275
	var size = 275

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
