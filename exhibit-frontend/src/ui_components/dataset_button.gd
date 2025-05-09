extends Button

@export var dataset: Dataset
@export var default = false

var is_tracked_dataset: bool
var is_selected_dataset: bool

var default_color: Color

func _ready() -> void:
    pressed.connect(_on_pressed)
    if default:
        Events.emit_dataset_selected(dataset)
    AntennaState.tracked_dataset_changed.connect(_on_tracked_dataset_changed)
    Events.dataset_selected.connect(_on_selected_dataset_changed)
    default_color = get_theme_stylebox("normal").bg_color


func _on_tracked_dataset_changed(tracked_dataset: Dataset):
    if tracked_dataset:
        is_tracked_dataset = tracked_dataset.dataset_id == dataset.dataset_id
    else:
        is_tracked_dataset = false
    _update_background()

func _on_selected_dataset_changed(selected_dataset: Dataset):
    if selected_dataset:
        is_selected_dataset = selected_dataset.dataset_id == dataset.dataset_id

    else:
        is_selected_dataset = false
    _update_background()


func _update_background():
    var temp = get_theme_stylebox("normal").duplicate()
    if is_tracked_dataset:
        temp.bg_color = Color.DARK_GREEN
    elif is_selected_dataset:
        temp.bg_color = default_color.lightened(0.1)
    else:
        temp.bg_color = default_color
    add_theme_stylebox_override("normal", temp)

func _on_pressed():
    Events.emit_dataset_selected(dataset)
    Events.emit_audio_event(AudioManager.Type.SELECT_DATASET)