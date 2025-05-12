extends Button

@export var type: BackendService.INTERACTION

## Time in seconds
@export var debounce_time:float = 0

@export var default_text = ''
@export var disabled_text = ''

var timer: Timer


func _ready() -> void:
	pressed.connect(_on_pressed)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_timer_ended)


func _timer_ended():
	disabled = false
	text = default_text


func _on_pressed():
	if debounce_time > 0:
		disabled = true
		text = disabled_text
		timer.start(debounce_time)
	Events.emit_functional_button(type)
	if type == BackendService.INTERACTION.STOP:
		Events.emit_audio_event(AudioManager.Type.STOP)
