class_name BackendService
extends HTTPRequest

const URL = 'http://localhost:8000'
const DEFAULT_HEADERS = []

# smap
# aura
# aqua
# scisat
# oco2
# icesat
# ic2

# API ENDPOINTS
const CUSTOM_ENDPOINT = '/custom'
const HOME_ENDPOINT = '/home'
const PATH_ENDPOINT = '/path'
const STATUS_ENDPOINT = '/status'
const SPEED_ENDPOINT = '/speed'
const RESET_ENDPOINT = '/reset'

enum AXIS {
	ALL,
	TRAIN,
	AZIMUTH,
	ELEVATION
}

enum INTERACTION {
	STOP,
	SPEED_UP,
	TRACK,
	STOWED,
	REHOME
}

var request_queue = []

var current_dataset: Dataset

func _ready() -> void:
	Events.dataset_selected.connect(_update_dataset)
	Events.functional_button_pressed.connect(_on_functional_button_pressed)

	DataManager.track_complete.connect(_on_track_complete)
	request_completed.connect(_on_request_complete)


func _on_track_complete():
	if AntennaState.current_action == INTERACTION.TRACK:
		AntennaState.set_current_action(INTERACTION.STOP) # 
		AntennaState.set_current_action(INTERACTION.STOWED) # paths include the rehoming part already
	elif AntennaState.current_action == INTERACTION.REHOME:
		AntennaState.set_current_action(INTERACTION.STOWED)

func _update_dataset(dataset: Dataset):
	current_dataset = dataset

func _on_functional_button_pressed(type: INTERACTION):
	if type == INTERACTION.STOP:
		Stop()
	elif type == INTERACTION.SPEED_UP:
		Speed()
	elif type == INTERACTION.TRACK && current_dataset:
		Path(current_dataset.dataset_id)
	elif type == INTERACTION.REHOME:
		Home()


func Custom(data: Dictionary):
	## POSTs values for train, azimuth, and elevation to /custom endpoint
	self._make_request(self.CUSTOM_ENDPOINT, HTTPClient.METHOD_POST, data)

func Home():
	## POSTs axis to zero-out to /home endpoint
	#var body = {'axis': AXIS.keys()[axis]}
	self._make_request(self.HOME_ENDPOINT, HTTPClient.METHOD_POST)
	AntennaState.set_current_action(INTERACTION.REHOME)

func Path(satellite: String, path: Array[Dictionary] = []):
	## POSTs which pre-defined path for the antenna to follow at the /path endpoint
	var body = {'satellite': satellite}
	#if satellite == SATELLITES.CUSTOM:
		#body['path'] = path

	self._make_request(self.PATH_ENDPOINT, HTTPClient.METHOD_POST, body)
	AntennaState.set_tracked_dataset(current_dataset)
	AntennaState.set_current_action(INTERACTION.TRACK)


func Status():
	## GETs the backend's status from the /status endpoint
	self._make_request(self.STATUS_ENDPOINT)

func Speed():
	## POSTs the backend to set the speed endpoint
	self._make_request(self.SPEED_ENDPOINT)


func Stop():
	self._make_request(self.RESET_ENDPOINT, HTTPClient.METHOD_POST)
	AntennaState.set_current_action(INTERACTION.STOP)


func _make_request(endpoint: String, method: HTTPClient.Method = HTTPClient.METHOD_GET, body: Dictionary = {}):
	## backend query code for helper methods

	var body_str = ''
	if len(body.keys()) > 0:
		body_str = JSON.new().stringify(body)

	var url_template = "%s%s"
	var url = url_template % [self.URL, endpoint]
	var request_status = get_http_client_status()
	if len(request_queue) > 0 or [HTTPClient.STATUS_CONNECTING,HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_REQUESTING, HTTPClient.STATUS_BODY ].has(request_status):
		var queue_object = {
			'url': url,
			'headers': PackedStringArray(DEFAULT_HEADERS),
			'method': method,
			'body': body_str
		}
		request_queue.push_back(queue_object)
		return

	var error = request(url, PackedStringArray(DEFAULT_HEADERS), method, body_str)

	if error != OK:
		push_error("An error occurred while querying the backend service.")

func _on_request_complete(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if len(request_queue) <= 0:
		return
	var params = request_queue.pop_front()
	var error = request(params['url'], params['headers'], params['method'], params['body'])

	if error != OK:
		push_error("An error occurred while querying the backend service.")
	pass