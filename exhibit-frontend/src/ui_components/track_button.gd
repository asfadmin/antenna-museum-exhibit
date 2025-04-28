extends Button

@export var type: BackendService.INTERACTION

## Time in seconds
@export var debounce_time = 0

@export var default_text = ''
@export var disabled_text = ''

var timer: Timer

var tracked_dataset: Dataset
var selected_dataset: Dataset

func _ready() -> void:
    pressed.connect(_on_pressed)
    timer = Timer.new()
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(_timer_ended)
    AntennaState.tracked_dataset_changed.connect(_on_tracked_dataset_changed)
    Events.dataset_selected.connect(_on_dataset_selected)


func _on_tracked_dataset_changed(dataset: Dataset):
    tracked_dataset = dataset
    update_text()

func _on_dataset_selected(dataset: Dataset):
    selected_dataset = dataset
    update_text()

func update_text():
    if tracked_dataset and tracked_dataset.dataset_id == selected_dataset.dataset_id:
        # the dataset selected is the one we are currently tracking, don't give the option to retrack it
        disabled = true
        text = 'Tracking'
    else:
        disabled = false
        text = 'Track'
    if !timer.is_stopped():
        text = 'Waiting'
        disabled = true

func _timer_ended():
    disabled = false
    update_text()


func _on_pressed():
    if debounce_time > 0:
        disabled = true
        text = disabled_text
        timer.start(debounce_time)
    Events.emit_functional_button(type)
