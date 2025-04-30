extends Line2D



@export var completed_course: Line2D
@export var path_2d: Path2D
@export var sat_position: ColorRect

@export var bounding_box: Control
#var path_follow_2d: PathFollow2D
var current_idx = 0
var azimuth_data: Array[float] = []
var elevation_data: Array[float] = []
var autotrack_status: Array[float] = []
var autotrack_mask: Array = []
var expected_time: float = 5.0
var cursor_pos: Vector2 = Vector2.ZERO
var _unmasked_points = []
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
	DataManager.percent_complete_changed.connect(_on_percent_complete_changed)

func _on_percent_complete_changed(value: float):
	update_track(value)

func _physics_process(delta: float) -> void:
	pass

func load_data(data):
	if data == null:
		current_idx = 0
		points = []
		completed_course.points = []
		sat_position.visible = false
		return
	var column_data = data

	azimuth_data = column_data["commanded_azimuth"]
	elevation_data = column_data["commanded_elevation"]
	autotrack_status = column_data["autotrack_status"]
	
	autotrack_mask = autotrack_status.map(func (x): return x != 0)
	#var autotrack_indices = autotrack_status.map(x => return x != 0)
	var azm_elev = []
	for idx in range(0, len(azimuth_data)):
		#if autotrack_status[idx] != 0:
			azm_elev.append(spherical_to_cartesian(azimuth_data[idx], elevation_data[idx]))

	var _final_path = []
	_unmasked_points = []
	# var offset = Vector2(viewport.get_parent().size.x, viewport.get_parent().size.y) / 2.0
	var offset = Vector2(bounding_box.size.x, bounding_box.size.y) * 1.3 # for some reason the scaling changes? not sure why this is different now
	
	for point_idx in len(azm_elev):
		var p = azm_elev[point_idx] + offset  + Vector2.DOWN * 50
		if autotrack_status[point_idx] != 0:
			_final_path.append(p)
		_unmasked_points.append(p)
	current_idx = 0
	
	self.points = _final_path
	if len(points) > 0:
		sat_position.position = self._unmasked_points[self.current_idx] #TODO: This sometimes crashes saying invalid index of 0
	sat_position.visible = true



func _draw() -> void:
	if azimuth_data == null:
		return
	if self.current_idx < len(self.autotrack_mask) and self.autotrack_mask[self.current_idx]:
		draw_circle(self._unmasked_points[self.current_idx], 15, Color.MAGENTA, false, 3)


func update_track(percent: float):
	var index_of_percent = min(int(len(self._unmasked_points) * percent), len(self._unmasked_points) - 1)
	current_idx = index_of_percent
	if self.autotrack_mask[current_idx]:
		self.sat_position.visible = true
		var completed_track = []
		for point_idx in range(0, current_idx):
			if autotrack_mask[point_idx]:
				completed_track.append(_unmasked_points[point_idx])
		
		completed_course.points = completed_track
		
		
		self.queue_redraw()
		#if self.points.size() != self.current_idx:
		self.sat_position.position = self._unmasked_points[self.current_idx] - Vector2(7.5,7.5) # center the dot on the line
	else:
		self.sat_position.visible = false
