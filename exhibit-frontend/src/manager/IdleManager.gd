extends Node

@export var timed_out_panel: Panel
@export_range(0.01, 1.0, 0.05) var camera_idle_rotate_speed = 0.1

var time_since_last_interacted

var timer: Timer
var camera_idle_timer: Timer
var night_timer: Timer
var day_timer: Timer

var time_till_idle = 30 * 60
var time_till_camera_idle = 60
var night_timer_poll_rate = 11
var wakeup_poll_rate = 11

var museum_closed = false

var camera_idle = false
var camera: Camera3D

func _ready() -> void:
	timed_out_panel.visible = false#.modulate = Color.TRANSPARENT
	timer = Timer.new()
	timer.wait_time = time_till_idle
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)
	
	camera_idle_timer = Timer.new()
	camera_idle_timer.wait_time = time_till_camera_idle
	add_child(camera_idle_timer)
	
	camera_idle_timer.timeout.connect(_on_camera_idle)
	
	timer.start(time_till_idle)
	camera_idle_timer.start(time_till_camera_idle)
	
	night_timer = Timer.new()
	night_timer.wait_time = night_timer_poll_rate
	night_timer.timeout.connect(_on_poll_night_timer, CONNECT_ONE_SHOT)
	add_child(night_timer)
	night_timer.start(night_timer_poll_rate)
	
	day_timer = Timer.new()
	day_timer.wait_time = wakeup_poll_rate
	day_timer.timeout.connect(_on_poll_day_timer, CONNECT_ONE_SHOT)
	add_child(day_timer)
	day_timer.start(wakeup_poll_rate)
	
	self.camera = get_viewport().get_camera_3d()
	

func _input(_event: InputEvent) -> void:
	if not museum_closed:
		timer.start(time_till_idle)
		camera_idle_timer.start(time_till_camera_idle)
		timed_out_panel.visible = false
		self.camera_idle = false


func _on_timer_timeout():
	if not museum_closed:
		timer.start(time_till_idle)
		timed_out_panel.visible = true
		track_random_dataset()

func _process(delta: float) -> void:
	if camera_idle and not museum_closed:
		self.camera._rotation.y += camera_idle_rotate_speed*delta

func _on_camera_idle():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self.camera, '_distance', 40.0, 2.0)
	tween.parallel().tween_property(self.camera, '_rotation:x', - PI / 12, 2.0)
	self.camera_idle = true

func _on_poll_night_timer():
	if should_be_closed():
		self.shutdown_exhibit()
	else:
		if not night_timer.timeout.is_connected(_on_poll_night_timer):
			night_timer.timeout.connect(_on_poll_night_timer, CONNECT_ONE_SHOT)

func _on_poll_day_timer():
	if not should_be_closed():
		self.startup_exhibit()
	else:
		if not day_timer.timeout.is_connected(_on_poll_day_timer):
			day_timer.timeout.connect(_on_poll_day_timer, CONNECT_ONE_SHOT)


func should_be_closed():
	# The Antenna should be stowed between 7PM and 8AM
	var current_time = Time.get_time_dict_from_system()
	var hour = current_time['hour']
	var minute = current_time['minute']
	
	# var night_time = minute % 2 == 0
	return hour > 18 or hour < 8
	

func startup_exhibit():
	print('Opening time')
	if not self.timer.timeout.is_connected(_on_timer_timeout):
		self.timer.timeout.connect(_on_timer_timeout)
		self.timer.start(time_till_idle)

	if not self.night_timer.timeout.is_connected(_on_poll_night_timer):
		self.night_timer.timeout.connect(_on_poll_night_timer)

	start_day_mode()

func start_day_mode():
	museum_closed = false
	Events.emit_night_mode_toggle(false)
	pass

func shutdown_exhibit():
	print('Closing time')
	if self.timer.timeout.is_connected(_on_timer_timeout):
		self.timer.timeout.disconnect(_on_timer_timeout)
		
	if not self.day_timer.timeout.is_connected(_on_poll_day_timer):
		self.day_timer.timeout.connect(_on_poll_day_timer)
	
	start_night_mode()

func start_night_mode():
	museum_closed = true
	Events.emit_night_mode_toggle(true)

	match AntennaState.current_action:
		BackendService.INTERACTION.STOWED:
			pass
		BackendService.INTERACTION.REHOME:
			pass
		BackendService.INTERACTION.STOP:
			Events.emit_functional_button(BackendService.INTERACTION.REHOME)
		_:
			Events.emit_functional_button(BackendService.INTERACTION.STOP)
			Events.emit_functional_button(BackendService.INTERACTION.REHOME)
			pass

# not sure if this should only fire once every 30ish mins or what
# might need a check to see if it needs to rehome before sending off the new one
func track_random_dataset():
	var selected_dataset = get_tree().get_nodes_in_group("Dataset Button").pick_random().dataset
	Events.emit_dataset_selected(selected_dataset)
	Events.emit_functional_button(BackendService.INTERACTION.TRACK)
