extends TextureRect

@export var attract_mode_timeout = 10.0

var border_color = Color('eacc00')
var empty_color = Color('000000', 0.0)
var full_color = Color('ffffff', 1.0)

var timer: Timer

var attract_mode = false
func  _ready() -> void:
	self.modulate = empty_color
	self.timer = Timer.new()
	self.add_child(self.timer)
	self.timer.start(self.attract_mode_timeout)
	self.timer.timeout.connect(self._on_attract_mode)
	Events.functional_button_pressed.connect(_on_function_pressed)

	#tween.parallel().tween_property(temp, 'border_width_left', 5.0, 5.0)
	#tween.parallel().tween_property(temp, 'border_width_top', 5.0, 5.0)
	#tween.parallel().tween_property(temp, 'border_width_bottom', 5.0, 5.0)
	#tween.parallel().tween_property(temp, 'border_width_rigth', 5.0, 5.0)


func _physics_process(delta: float) -> void:
	if self.attract_mode and AntennaState.current_action == BackendService.INTERACTION.STOWED:
		self.modulate = self.empty_color.lerp(self.full_color, abs(sin(Time.get_unix_time_from_system() / 1.5)))

func _on_attract_mode():
	self.attract_mode = true

func _on_function_pressed(type: BackendService.INTERACTION):
	self.attract_mode = false
	self.timer.start(self.attract_mode_timeout)
	self.modulate = self.empty_color
	pass
