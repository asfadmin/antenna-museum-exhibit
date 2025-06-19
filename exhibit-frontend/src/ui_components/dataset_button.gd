extends Button

@export var dataset: Dataset
@export var default = false

var is_tracked_dataset: bool
var is_selected_dataset: bool

var default_color: Color
var default_text_color: Color
var default_border_color = Color('f2c138FF')
var alpha_color = Color('00000000')

func _ready() -> void:
	pressed.connect(_on_pressed)
	if default:
		Events.emit_dataset_selected(dataset)
	AntennaState.tracked_dataset_changed.connect(_on_tracked_dataset_changed)
	Events.dataset_selected.connect(_on_selected_dataset_changed)
	default_color = get_theme_stylebox("normal").bg_color
	default_text_color = get_theme_color("font_color")
	#tween.tween_property()

func _process(delta: float) -> void:
	pass
	#temp.border_color  = default_border_color.lerp(alpha_color, t)
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
	var temp: StyleBox = get_theme_stylebox("normal").duplicate()
	if is_tracked_dataset:
		temp.bg_color = 'f2c138'
		self.set("theme_override_colors/font_color",'236192')
	elif is_selected_dataset:
		temp.bg_color = default_color.lightened(0.1)
		self.set("theme_override_colors/font_color", default_text_color)
	else:
		temp.bg_color = default_color
		self.set("theme_override_colors/font_color", default_text_color)
	add_theme_stylebox_override("normal", temp)

func _on_pressed():
	Events.emit_dataset_selected(dataset)
	Events.emit_audio_event(AudioManager.Type.SELECT_DATASET)
