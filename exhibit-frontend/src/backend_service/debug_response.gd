extends RichTextLabel


func _on_backend_service_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	self.text = body.get_string_from_utf8()
	pass # Replace with function body.
