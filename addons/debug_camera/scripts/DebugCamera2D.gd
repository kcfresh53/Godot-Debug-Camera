extends Camera2D
class_name DebugCamera2D

# Lower cap for the `_zoom_level`.
@export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
@export var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
@export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
@export var zoom_duration := 0.2

# The camera's target zoom level.
var _zoom_level : float = 1.0 :
	set(value):
		var tween = get_tree().create_tween()
		# We limit the value between `min_zoom` and `max_zoom`
		_zoom_level = clamp(value, min_zoom, max_zoom)
		tween.tween_property(self, "zoom", Vector2(_zoom_level, _zoom_level), zoom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

var _previousPosition: Vector2 = Vector2(0, 0)
var _moveCamera: bool = false


func _process(_delta: float) -> void:
	if !enabled:
		position = find_camera_2d_or_null(get_tree().current_scene.get_children()).position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# zoom out
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_level = _zoom_level - zoom_factor
		# zoom in
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_level = _zoom_level + zoom_factor
	
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			_previousPosition = event.position
			_moveCamera = true
		else:
			_moveCamera = false
	elif event is InputEventMouseMotion && _moveCamera:
		position += (_previousPosition - event.position)
		_previousPosition = event.position
	
	# Toggle cameras
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_MINUS:
			var cam := find_camera_2d_or_null(get_tree().current_scene.get_children())
			cam.enabled = !cam.enabled
			enabled = !cam.enabled


func find_camera_2d_or_null(nodes: Array[Node]) -> Camera2D:
	var camera: Camera2D
	
	for node in nodes:
		if node is Camera2D:
			camera = node as Camera2D
			break
			
	return camera
