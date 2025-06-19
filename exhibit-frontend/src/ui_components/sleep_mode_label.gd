extends Label

var stowing_text = "Stowing Antenna Exhibit For the night.
Will resume at 8AM"

var stowed_text = "Antenna Exhibit stowed For the night.
Will resume at 8AM"
func _ready() -> void:
	self.visible = false
	Events.night_mode_toggled.connect(func (is_night_mode): self.visible = is_night_mode)
	AntennaState.current_action_changed.connect(_on_antenna_change)
	
func _on_antenna_change(antenna_state: BackendService.INTERACTION):
	if antenna_state == BackendService.INTERACTION.STOP or antenna_state == BackendService.INTERACTION.REHOME:
		self.text = stowing_text
	else:
		self.text = stowed_text
