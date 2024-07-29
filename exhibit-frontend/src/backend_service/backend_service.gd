class_name BackendService extends HTTPRequest

const URL = 'http://localhost:8080'

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
	self._make_request(self.CUSTOM_ENDPOINT, HTTPClient.METHOD_POST, data)

func Home(axis: AXIS):
	var body = {'axis': AXIS.keys()[axis]}
	self._make_request(self.HOME_ENDPOINT, HTTPClient.METHOD_POST, body)

func Path(path: int):
	var body = {'q': path}
	self._make_request(self.PATH_ENDPOINT, HTTPClient.METHOD_POST, body)

func Status():
	self._make_request(self.STATUS_ENDPOINT)

func Stow():
	self._make_request(self.STOW_ENDPOINT)

func _make_request(endpoint: String, method: HTTPClient.Method = HTTPClient.METHOD_GET, body: Dictionary = {}):
	var body_str = ''
	if len(body.keys()) > 0:
		body_str = JSON.new().stringify(body)
	
	var url_template = "%s%s"
	var url = url_template % [self.URL, endpoint]
	
	var error = self.request(url, PackedStringArray(), method, body_str)

	if error != OK:
		push_error("An error occurred in the HTTP request.")
