extends Line2D

var completed_course: Line2D
var path_2d: Path2D
var sat_position: ColorRect
#var path_follow_2d: PathFollow2D
var current_idx = 0

var expected_time: float = 5.0
var cursor_pos: Vector2 = Vector2.ZERO
@onready var viewport: SubViewport = get_parent() as SubViewport
#var full_points = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.completed_course = get_child(0)
	
	self.path_2d = get_child(1)
	self.sat_position = get_node('sat_pos')
	#self.path_follow_2d = self.path_2d.get_child(0)
	
	var _final_path = []
	var viewport_parent = viewport.get_parent()
	#var offset = Vector2(viewport.get_parent().size.x / 2, -viewport.get_parent().size.y) / 2.0
	for point in self.path_2d.curve.get_baked_points():
		#var offset = Vector2(viewport.size.x, viewport.size.y) / 2.0
		#print(viewport.size.x)
		#print(offset)
		_final_path.append(point) # + offset)
	
	self.points = _final_path
	#self.path_2d.curve.get_closest_point()
	
	get_tree().create_timer(1.0).timeout.connect(_active_timer, CONNECT_ONE_SHOT)
	#var tween = get_tree().create_tween().set_loops(5)
	#tween.tween_property($Sprite, "modulate", Color.RED, 1)
	#tween.tween_property(self, "cursor_pos", Vector2(), 1)
	#tween.tween_callback($Sprite.queue_free)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	if self.current_idx < self.points.size():
		draw_circle(self.points[self.current_idx], 15, Color.MAGENTA, false, 3)
func _active_timer():
	#var l := Line2D.new()   
	#self.default_color = Color(1,1,1,1)  
	#l.width = 20
	self.completed_course.add_point(self.points[self.current_idx])
	self.current_idx += 1
	self.queue_redraw()
	if self.points.size() != self.current_idx:
		self.sat_position.position = self.points[self.current_idx]
		get_tree().create_timer(0.1).timeout.connect(_active_timer, CONNECT_ONE_SHOT)
	else:
		self.sat_position.visible = false
