extends BoxContainer

@export var current_label: Label
@export var elevation_label: Label
@export var azimuth_label: Label
@export var debug_label: Label

var azimuth = []
var elevation = []

var azimuth_format_string = "Azimuth: %s"
var elevation_format_string = "Elevation: %s"

var status = 0.0
func _ready() -> void:
	AntennaState.current_action_changed.connect(_on_current_action_changed)
	
	# Fall back to UI model's actual rotation values while not actively tracking
	AntennaState.ui_model_azimuth_changed.connect(_on_azimuth_changed)
	AntennaState.ui_model_elevation_changed.connect(_on_elevation_changed)
	
	DataManager.data_loaded.connect(_load_data)
	DataManager.percent_complete_changed.connect(func (x): status=x)
	DataManager.debug_mode_toggled.connect(func (debug_mode): debug_label.visible = debug_mode)

func _load_data(data) -> void:
	if data == null:
		self.azimuth = []
		self.elevation = []
		return
	
	var column_data = data
	self.azimuth = column_data["commanded_azimuth"]
	self.elevation = column_data["commanded_elevation"]
	
func _process(delta: float) -> void:
	if len(azimuth) > 0:
		var idx = mini(roundi(len(azimuth) * status), len(azimuth) - 1)
		self.azimuth_label.text = azimuth_format_string % azimuth[idx]
		self.elevation_label.text = elevation_format_string % elevation[idx]
	#else:
		#self.azimuth_label.text = azimuth_format_string % 0.0
		#self.elevation_label.text = elevation_format_string % 0.0
func _on_current_action_changed(action: BackendService.INTERACTION):
	if action == BackendService.INTERACTION.TRACK:
		current_label.text = 'Tracking ' + AntennaState.tracked_dataset.dataset_id
	elif action == BackendService.INTERACTION.STOP:
		current_label.text = 'Stopped'
	elif action == BackendService.INTERACTION.STOWED:
		current_label.text = 'Stowed'
	elif action == BackendService.INTERACTION.REHOME:
		current_label.text = 'Going back to home'

func _on_azimuth_changed(val: float):
	if AntennaState.current_action != BackendService.INTERACTION.TRACK:
		self.azimuth_label.text = azimuth_format_string % snapped(val, 0.001)

func _on_elevation_changed(val: float):
	if AntennaState.current_action != BackendService.INTERACTION.TRACK:
		self.elevation_label.text = elevation_format_string % snapped(val, 0.001)
