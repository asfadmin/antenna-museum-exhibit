extends Node3D


@export var horizontal_rotation_node: Node3D
@export var antenna_rotator_node: Node3D
@export var antenna_rotation_poll_rate = 0.75

var current_idx = 0
var points = []
#var timer: Timer
var azimuth_data = []
var elevation_data = []
var status = 0.0
var motion_smoothing_factor = 1 / 60.0 # TODO: This is based off the fake progress placeholder rate. May need adjusting later to smaller number when working with actual antenna
var elev_azi_poll_timer: Timer


func _ready() -> void:
	#move_to(1,1,1)
	#rehome(5.0)
	DataManager.data_loaded.connect(load_data)
	AntennaState.current_action_changed.connect(on_antenna_state_changed)
	DataManager.percent_complete_changed.connect(func (x): status=x)
	
	elev_azi_poll_timer = Timer.new()
	add_child(elev_azi_poll_timer)
	elev_azi_poll_timer.wait_time = antenna_rotation_poll_rate
	elev_azi_poll_timer.timeout.connect(_on_poll_antenna_rotation)
	elev_azi_poll_timer.start(antenna_rotation_poll_rate)

func _on_poll_antenna_rotation():
	AntennaState.ui_model_azimuth = -rad_to_deg(horizontal_rotation_node.rotation.y)
	AntennaState.ui_model_elevation = rad_to_deg(antenna_rotator_node.rotation.x) + 90.0


func on_antenna_state_changed(state: BackendService.INTERACTION):
	if state == BackendService.INTERACTION.REHOME:
		self.rehome()

func load_data(data):
	if data == null:
		current_idx = 0
		points = []
		return
	var column_data = data

	azimuth_data = column_data["actual_azimuth"]
	elevation_data = column_data["actual_elevation"]
	var autotrack_status = column_data["autotrack_status"]

	self.points = []
	for idx in range(0, len(azimuth_data)):
		self.points.append([azimuth_data[idx], elevation_data[idx]])

	var _final_path = []

func _physics_process(delta: float) -> void:
	if self.points.size() > 0:
		var idx = mini(roundi(len(self.points) * status), len(self.points) - 1)
		var azm_ele = self.points[idx]
		self.move_to(azm_ele[1], azm_ele[0], 0.0, DataManager.estimated_pass_speed * (delta / motion_smoothing_factor))

func move_to(elevation, azimuth, train, duration=1.66):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	var ele = Quaternion.from_euler(Vector3(deg_to_rad(elevation - 90.0),0.0,0)).normalized()
	var azi = Quaternion.from_euler(Vector3(0.0, deg_to_rad(-azimuth),0)).normalized()
	tween.parallel().tween_method(antenna_elevation.bind(ele), 0.0, 1.0, duration)
	tween.parallel().tween_method(azimuth_rotation.bind(azi), 0.0, 1.0, duration)

func antenna_elevation(weight: float, value: Quaternion):
	antenna_rotator_node.quaternion = antenna_rotator_node.quaternion.slerp(value, weight).normalized()

func azimuth_rotation(weight: float, value: Quaternion):
	horizontal_rotation_node.quaternion = horizontal_rotation_node.quaternion.slerp(value, weight).normalized()
	
func rehome(duration=20.0):
	# approximates the rehoming functionality of the physical antenna model
	# 1. homes azimuth
	# 2. homes elevation
	# 3. quarter-circle azimuth
	# 4. quarter-circle elevation (bird bath)
	var step_duration = duration / 4.0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	var azi = Quaternion.from_euler(Vector3(0.0, 0.0,0.0)).normalized()
	var ele = Quaternion.from_euler(Vector3(deg_to_rad(-90.0),0.0,0.0)).normalized()
	var azi_2 = Quaternion.from_euler(Vector3(0.0, deg_to_rad(-90.0),0.0)).normalized()
	var ele_2 = Quaternion.from_euler(Vector3(deg_to_rad(0.0),0.0,0.0)).normalized()
	
	tween.tween_method(azimuth_rotation.bind(azi), 0.0, 1.0, step_duration)
	tween.tween_method(antenna_elevation.bind(ele), 0.0, 1.0, step_duration)
	tween.tween_method(azimuth_rotation.bind(azi_2), 0.0, 1.0, step_duration)
	tween.tween_method(antenna_elevation.bind(ele_2), 0.0, 1.0, step_duration)
	tween.tween_callback(func (): AntennaState.set_current_action(BackendService.INTERACTION.STOWED))
	#tween.chain()
	pass
