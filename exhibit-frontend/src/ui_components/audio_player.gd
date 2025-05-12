class_name AudioManager
extends AudioStreamPlayer

enum Type {
	SELECT,
	REHOME,
	SELECT_DATASET,
	TRACK,
	STOP,
	FAST_FORWARD
}

@export var select_button_press: AudioStream
@export var rehome_button_press: AudioStream
@export var select_dataset_button_press: AudioStream
@export var track_button_press: AudioStream
@export var stop_button_press: AudioStream
@export var fast_forward_button_press: AudioStream


func _ready() -> void:
	Events.audio_event.connect(_on_audio_event)

func _on_audio_event(type: Type):
	play_audio(type)

func play_audio(selected_type: Type):
	if selected_type == Type.REHOME:
		stream = rehome_button_press
	elif selected_type == Type.SELECT_DATASET:
		stream = select_dataset_button_press
	elif selected_type == Type.TRACK:
		stream = track_button_press
	elif selected_type == Type.STOP:
		stream = stop_button_press
	elif selected_type == Type.FAST_FORWARD:
		stream = fast_forward_button_press
	else:
		stream = select_button_press
	play()
