extends Button

@export var type: BackendService.INTERACTION

## Time in seconds
@export var debounce_time = 0

@export var default_text = ''
@export var disabled_text = ''

var timer: Timer

var tracked_dataset: Dataset
var selected_dataset: Dataset
var current_action: BackendService.INTERACTION = BackendService.INTERACTION.STOWED
var night_mode = false

func _ready() -> void:
	pressed.connect(_on_pressed)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_timer_ended)
	AntennaState.tracked_dataset_changed.connect(_on_tracked_dataset_changed)
	Events.dataset_selected.connect(_on_dataset_selected)
	AntennaState.current_action_changed.connect(_on_current_action_changed)
	var first_dataset = get_tree().get_nodes_in_group("Dataset Button")[0].dataset
	Events.emit_dataset_selected(first_dataset)
	DataManager.track_complete.connect(update_text)
	Events.night_mode_toggled.connect(func (is_night_mode): self.night_mode = is_night_mode)

func _on_tracked_dataset_changed(dataset: Dataset):
	tracked_dataset = dataset
	update_text()

func _on_current_action_changed(action: BackendService.INTERACTION):
	current_action = action
	update_text()


func _on_dataset_selected(dataset: Dataset):
	selected_dataset = dataset
	update_text()

func update_text():
	if current_action == BackendService.INTERACTION.STOWED:
		disabled = false
		text = 'Track'
	elif tracked_dataset and tracked_dataset.dataset_id == selected_dataset.dataset_id:
		# the dataset selected is the one we are currently tracking, don't give the option to retrack it
		disabled = true
		text = 'Tracking'
	elif current_action == BackendService.INTERACTION.STOP or current_action == BackendService.INTERACTION.TRACK:
		disabled = false
		text = 'Rehome'
	elif current_action == BackendService.INTERACTION.REHOME:
		disabled = true
		text = 'Rehoming'
	else:
		disabled = false
		text = 'Track'
	if !timer.is_stopped():
		text = 'Waiting'
		disabled = true

	if self.night_mode:
		disabled = true


func _timer_ended():
	disabled = false
	update_text()


func _on_pressed():
	if debounce_time > 0:
		disabled = true
		text = disabled_text
		timer.start(debounce_time)
	if AntennaState.current_action == BackendService.INTERACTION.TRACK or current_action == BackendService.INTERACTION.STOP:
		Events.emit_functional_button(BackendService.INTERACTION.REHOME)
		Events.emit_audio_event(AudioManager.Type.REHOME)
	else:
		Events.emit_functional_button(BackendService.INTERACTION.TRACK)
		Events.emit_audio_event(AudioManager.Type.TRACK)
