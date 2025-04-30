extends Node

@export var timed_out_panel: Panel


var time_since_last_interacted

var timer: Timer

var time_till_idle = 30 * 60

func _ready() -> void:
    timed_out_panel.visible = false#.modulate = Color.TRANSPARENT
    timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = time_till_idle
    add_child(timer)
    timer.timeout.connect(_on_timer_timeout)


func _input(_event: InputEvent) -> void:
    timer.start(time_till_idle)
    timed_out_panel.visible = false


func _on_timer_timeout():
    timer.start(time_till_idle)
    timed_out_panel.visible = true
    track_random_dataset()


# not sure if this should only fire once every 30ish mins or what
# might need a check to see if it needs to rehome before sending off the new one
func track_random_dataset():
    var selected_dataset = get_tree().get_nodes_in_group("Dataset Button").pick_random().dataset
    Events.emit_dataset_selected(selected_dataset)
    Events.emit_functional_button(BackendService.INTERACTION.TRACK)
