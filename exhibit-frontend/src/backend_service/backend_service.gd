class_name BackendService extends HTTPRequest

const URL = 'http://localhost:8080'
const DEFAULT_HEADERS = []

# API ENDPOINTS
const CUSTOM_ENDPOINT = '/custom'
const HOME_ENDPOINT = '/home'
const PATH_ENDPOINT = '/path'
const STATUS_ENDPOINT = '/status'
const STOW_ENDPOINT = '/stow'


enum AXIS {
	ALL,
	TRAIN,
	AZIMUTH,
	ELEVATION
}

func Custom(data: Dictionary):
	## POSTs values for train, azimuth, and elevation to /custom endpoint
	self._make_request(self.CUSTOM_ENDPOINT, HTTPClient.METHOD_POST, data)

func Home(axis: AXIS):
	## POSTs axis to zero-out to /home endpoint
	var body = {'axis': AXIS.keys()[axis]}
	self._make_request(self.HOME_ENDPOINT, HTTPClient.METHOD_POST, body)

func Path(path: int):
	## POSTs which pre-defined path for the antenna to follow at the /path endpoint
	var body = {'q': path}
	self._make_request(self.PATH_ENDPOINT, HTTPClient.METHOD_POST, body)

func Status():
	## GETs the backend's status from the /status endpoint
	self._make_request(self.STATUS_ENDPOINT)

func Stow():
	## GETs the backend to return the antenna to the "bird bath" position using the /stow endpoint
	self._make_request(self.STOW_ENDPOINT)

func _make_request(endpoint: String, method: HTTPClient.Method = HTTPClient.METHOD_GET, body: Dictionary = {}):
	## backend query code for helper methods

	var body_str = ''
	if len(body.keys()) > 0:
		body_str = JSON.new().stringify(body)

	var url_template = "%s%s"
	var url = url_template % [self.URL, endpoint]

	var error = self.request(url, PackedStringArray(DEFAULT_HEADERS), method, body_str)

	if error != OK:
		push_error("An error occurred while querying the backend service.")
