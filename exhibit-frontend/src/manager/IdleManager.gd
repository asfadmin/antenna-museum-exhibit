extends Node

@export var timed_out_panel: Panel
@export_range(0.01, 1.0, 0.05) var camera_idle_rotate_speed = 0.1

var time_since_last_interacted

var timer: Timer
var camera_idle_timer: Timer

var time_till_idle = 30 * 60
var time_till_camera_idle = 10
var camera_idle = false
var camera: Camera3D

func _ready() -> void:
	timed_out_panel.visible = false#.modulate = Color.TRANSPARENT
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time_till_idle
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)
	
	camera_idle_timer = Timer.new()
	camera_idle_timer.one_shot = true
	camera_idle_timer.wait_time = time_till_camera_idle
	add_child(camera_idle_timer)
	
	camera_idle_timer.timeout.connect(_on_camera_idle)
	
	timer.start(time_till_idle)
	camera_idle_timer.start(time_till_camera_idle)
	
	self.camera = get_viewport().get_camera_3d()
	

func _input(_event: InputEvent) -> void:
	timer.start(time_till_idle)
	camera_idle_timer.start(time_till_camera_idle)
	timed_out_panel.visible = false
	self.camera_idle = false


func _on_timer_timeout():
	timer.start(time_till_idle)
	timed_out_panel.visible = true
	track_random_dataset()

func _process(delta: float) -> void:
	if camera_idle:
		self.camera._rotation.y += camera_idle_rotate_speed*delta

func _on_camera_idle():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self.camera, '_distance', 40.0, 2.0)
	tween.parallel().tween_property(self.camera, '_rotation:x', - PI / 12, 2.0)
	self.camera_idle = true

# not sure if this should only fire once every 30ish mins or what
# might need a check to see if it needs to rehome before sending off the new one
func track_random_dataset():
	var selected_dataset = get_tree().get_nodes_in_group("Dataset Button").pick_random().dataset
	Events.emit_dataset_selected(selected_dataset)
	Events.emit_functional_button(BackendService.INTERACTION.TRACK)
