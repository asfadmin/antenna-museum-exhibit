extends Node3D


@export var horizontal_rotation_node: Node3D
@export var antenna_rotator_node: Node3D

func _ready() -> void:
    move_to(1,1,1)


func move_to(elevation, azimuth, train):
    # horizontal_rotation_node.rotate()
    var tween = get_tree().create_tween()
    # tween.tween_property(horizontal_rotation, 'rotation'
    tween.tween_property(horizontal_rotation_node, "rotation", Vector3(0,deg_to_rad(230),0), 2)
    tween.tween_property(antenna_rotator_node, "rotation", Vector3(deg_to_rad(-40),0,0), 2)