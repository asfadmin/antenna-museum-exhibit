extends Line2D

var completed_course: Line2D
var path_2d: Path2D
var sat_position: ColorRect
#var path_follow_2d: PathFollow2D
var current_idx = 0
var azimuth_data: Array[float] = []
var elevation_data: Array[float] = []
var expected_time: float = 5.0
var cursor_pos: Vector2 = Vector2.ZERO
@onready var viewport: SubViewport = get_parent() as SubViewport

var fname := "aqa.csv"
var ACTUAL_AZIMUTH_COLUMN = "Actual Az."
var ACTUAL_ELEVATION_COLUMN = "Actual El."
var COMMANDED_AZIMUTH_COLUMN = "Commanded Az."
var COMMANDED_ELEVATION_COLUMN = "Commanded El."
var AUTOTRACK_STATUS = "Autotrack Status"

#var full_points = []
# Called when the node enters the scene tree for the first time.

func spherical_to_cartesian(azimuth:float, elevation: float) -> Vector2:
	var azi_radians = deg_to_rad(azimuth - 90)
	var ele_radians = deg_to_rad(elevation - 90)
	var x = 250 * cos(azi_radians) * sin(ele_radians)
	var y = -250 * sin(azi_radians) * sin(ele_radians)
	#var z = 1.0 * sin(lat)
	
	return Vector2(x, y)
func _ready() -> void:
	var column_data := load_column_data()
	azimuth_data = column_data["commanded_azimuth"]
	elevation_data = column_data["commanded_elevation"]
	var autotrack_status = column_data["autotrack_status"]

	# print(azimuth_data)
	self.completed_course = get_child(0)
	
	self.path_2d = get_child(1)
	self.sat_position = get_node('sat_pos')
	#self.path_follow_2d = self.path_2d.get_child(0)
	
	var azm_elev = []
	for idx in range(0, len(azimuth_data)):
		if autotrack_status[idx] != 0:
			azm_elev.append(spherical_to_cartesian(azimuth_data[idx], elevation_data[idx]))

	var _final_path = []
	var viewport_parent = viewport.get_parent()
	var offset = Vector2(viewport.get_parent().size.x, viewport.get_parent().size.y) / 2.0
	for point in azm_elev:
		#var offset = Vector2(viewport.size.x, viewport.size.y) / 2.0
		#print(viewport.size.x)
		#print(offset)
		_final_path.append(point + offset  + Vector2.DOWN * 50)
	
	self.points = _final_path
	#self.path_2d.curve.get_closest_point()
	
	get_tree().create_timer(1.0).timeout.connect(_active_timer, CONNECT_ONE_SHOT)
	#var tween = get_tree().create_tween().set_loops(5)
	#tween.tween_property($Sprite, "modulate", Color.RED, 1)
	#tween.tween_property(self, "cursor_pos", Vector2(), 1)
	#tween.tween_callback($Sprite.queue_free)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	if self.current_idx < self.points.size():
		draw_circle(self.points[self.current_idx], 15, Color.MAGENTA, false, 3)
func _active_timer():
	#var l := Line2D.new()   
	#self.default_color = Color(1,1,1,1)  
	#l.width = 20
	self.completed_course.add_point(self.points[self.current_idx])
	self.current_idx += 1
	self.queue_redraw()
	if self.points.size() != self.current_idx:
		self.sat_position.position = self.points[self.current_idx]
		get_tree().create_timer(0.1).timeout.connect(_active_timer, CONNECT_ONE_SHOT)
	else:
		self.sat_position.visible = false

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

func load_column_data() -> Dictionary:
	var csv := get_csv(fname)
	
	var column_data := {
		"actual_azimuth": get_csv_column_data(csv["headers"][ACTUAL_AZIMUTH_COLUMN], csv["content"]),
		"actual_elevation": get_csv_column_data(csv["headers"][ACTUAL_ELEVATION_COLUMN], csv["content"]),
		"commanded_azimuth": get_csv_column_data(csv["headers"][COMMANDED_AZIMUTH_COLUMN], csv["content"]),
		"commanded_elevation": get_csv_column_data(csv["headers"][COMMANDED_ELEVATION_COLUMN], csv["content"]),
		"autotrack_status": get_csv_column_data(csv["headers"][AUTOTRACK_STATUS], csv["content"]),
	}

	# The csv data is heavy
	csv = {}
	
	return column_data


## Takes `column_index` and returns the column at that index in the 2d Array `content`.
func get_csv_column_data(column_index: int, content: Array) -> Array[float]:
	var column_data: Array[float] = []
	var content_size: int = content.size()

	column_data.resize(content_size)

	for i in range(0, content_size):
		column_data[i] = float(content[i][column_index])

	return column_data
	
