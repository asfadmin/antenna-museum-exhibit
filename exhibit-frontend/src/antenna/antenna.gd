extends Node3D


@export var horizontal_rotation_node: Node3D
@export var antenna_rotator_node: Node3D

var current_idx = 0
var points = 0.0
var timer: Timer
var azimuth_data = []
var elevation_data = []

func _ready() -> void:
	#move_to(1,1,1)
	DataManager.data_loaded.connect(load_data)
	
	timer = Timer.new()
	timer.autostart = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func load_data(data):
	if data == null:
		current_idx = 0
		points = []
		#completed_course.points = []
		#sat_position.visible = false
		timer.stop()
		move_to(0.0, 0.0, 0.0, 5.0)
		return
	var column_data = data

	azimuth_data = column_data["commanded_azimuth"]
	elevation_data = column_data["commanded_elevation"]
	var autotrack_status = column_data["autotrack_status"]

	self.points = []
	for idx in range(0, len(azimuth_data)):
		#if autotrack_status[idx] != 0:
		self.points.append([azimuth_data[idx], elevation_data[idx]])

	var _final_path = []
	# var offset = Vector2(viewport.get_parent().size.x, viewport.get_parent().size.y) / 2.0
	#var offset = Vector2(bounding_box.size.x, bounding_box.size.y) * 1.3 # for some reason the scaling changes? not sure why this is different now
	#for point in azm_elev:
		#_final_path.append(point + offset  + Vector2.DOWN * 50)
	#current_idx = 0
	#self.points = _final_path

	#sat_position.position = self.points[self.current_idx]
	#sat_position.visible = true
	
	timer.start(0.1)

func _on_timer_timeout():
	_active_timer()
func _active_timer():
	#self.completed_course.add_point(self.points[self.current_idx])
	self.current_idx += 1
	#self.queue_redraw()
	if self.points.size() != self.current_idx:
		var azm_ele = self.points[self.current_idx]
		self.move_to(azm_ele[1], azm_ele[0], 0.0)
		#self.sat_position.position = self.points[self.current_idx]
		timer.start(0.1)
	else:
		self.move_to(0.0, 0.0, 0.0)
		timer.stop()

func move_to(elevation, azimuth, train, duration=0.5):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	var ele = Quaternion.from_euler(Vector3(deg_to_rad(elevation),0.0,0)).normalized()
	var azi = Quaternion.from_euler(Vector3(0.0, deg_to_rad(azimuth),0)).normalized()
	#horizontal_rotation_node.quaternion.slerp(horiz, 0.1)
	tween.tween_method(antenna_elevation.bind(ele), 0.0, 1.0, duration)
	tween.tween_method(azimuth_rotation.bind(azi), 0.0, 1.0, duration)

	#tween.tween_property(horizontal_rotation_node, "rotation", Vector3(0,deg_to_rad(elevation),0), 0.1)
	#tween.tween_property(antenna_rotator_node, "rotation", Vector3(deg_to_rad(azimuth),0,0), 0.1)

func antenna_elevation(weight: float, value: Quaternion):
	antenna_rotator_node.quaternion = antenna_rotator_node.quaternion.slerp(value, weight).normalized()
	
func azimuth_rotation(weight: float, value: Quaternion):
	horizontal_rotation_node.quaternion = horizontal_rotation_node.quaternion.slerp(value, weight).normalized()
