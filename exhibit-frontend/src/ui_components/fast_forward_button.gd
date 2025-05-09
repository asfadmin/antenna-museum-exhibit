extends Button

var type: BackendService.INTERACTION = BackendService.INTERACTION.SPEED_UP

## Time in seconds
@export var debounce_time: float = 0

var timer: Timer

var going_fast = false
@export var icon_button: FontIcon

var base_icon = 'fast-forward'

func _ready() -> void:
    pressed.connect(_on_pressed)
    timer = Timer.new()
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(_timer_ended)


func _timer_ended():
    disabled = false


func update_label():
    var output = base_icon
    if !going_fast:
        output += '-outline'
    icon_button.icon_settings.icon_name = output

func _on_pressed():
    if debounce_time > 0:
        disabled = true
        timer.start(debounce_time)
    Events.emit_functional_button(type)
    going_fast = !going_fast
    update_label()
    Events.emit_audio_event(AudioManager.Type.FAST_FORWARD)
