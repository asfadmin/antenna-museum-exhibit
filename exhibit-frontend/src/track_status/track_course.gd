extends Line2D



@export var completed_course: Line2D
@export var path_2d: Path2D
@export var sat_position: ColorRect

@export var bounding_box: Control
#var path_follow_2d: PathFollow2D
var current_idx = 0
var azimuth_data: Array[float] = []
var elevation_data: Array[float] = []
var expected_time: float = 5.0
var cursor_pos: Vector2 = Vector2.ZERO
@onready var viewport: SubViewport = get_parent() as SubViewport




func spherical_to_cartesian(azimuth:float, elevation: float) -> Vector2:
	var azi_radians = deg_to_rad(azimuth + 90)
	var ele_radians = deg_to_rad(elevation - 90)
	var x = 400 * cos(azi_radians) * sin(ele_radians)
	var y = 400 * sin(azi_radians) * sin(ele_radians)

	return Vector2(x, y)


func _ready() -> void:
	DataManager.data_loaded.connect(load_data)
	sat_position.visible = false

func load_data(data):
	if data == null:
		return
	var column_data = data
	sat_position.visible = true

	azimuth_data = column_data["commanded_azimuth"]
	elevation_data = column_data["commanded_elevation"]
	var autotrack_status = column_data["autotrack_status"]

	var azm_elev = []
	for idx in range(0, len(azimuth_data)):
		if autotrack_status[idx] != 0:
			azm_elev.append(spherical_to_cartesian(azimuth_data[idx], elevation_data[idx]))

	var _final_path = []
	# var offset = Vector2(viewport.get_parent().size.x, viewport.get_parent().size.y) / 2.0
	var offset = Vector2(bounding_box.size.x, bounding_box.size.y) * 1.3 # for some reason the scaling changes? not sure why this is different now
	for point in azm_elev:
		_final_path.append(point + offset  + Vector2.DOWN * 50)

	self.points = _final_path

	get_tree().create_timer(1.0).timeout.connect(_active_timer, CONNECT_ONE_SHOT)



func _draw() -> void:
	if azimuth_data == null:
		return
	if self.current_idx < self.points.size():
		draw_circle(self.points[self.current_idx], 15, Color.MAGENTA, false, 3)


func _active_timer():
	self.completed_course.add_point(self.points[self.current_idx])
	self.current_idx += 1
	self.queue_redraw()
	if self.points.size() != self.current_idx:
		self.sat_position.position = self.points[self.current_idx]
		get_tree().create_timer(0.1).timeout.connect(_active_timer, CONNECT_ONE_SHOT)
	else:
		self.sat_position.visible = false

