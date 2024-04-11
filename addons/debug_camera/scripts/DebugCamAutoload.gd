extends Node

var debug_cam_2d = preload("res://addons/debug_camera/scripts/DebugCamera2D.gd")
var debug_cam_3d = preload("res://addons/debug_camera/scripts/DebugCamera3D.gd")


func _ready() -> void:
	var cam_2d := debug_cam_2d.new()
	var cam_3d := debug_cam_3d.new()
	get_tree().current_scene.tree_exited.connect(_new_scene)
	
	if find_camera_2d_or_null(get_tree().current_scene.get_children()) != null:
		get_tree().current_scene.add_child(cam_2d)
	elif find_camera_3d_or_null(get_tree().current_scene.get_children()) != null:
		get_tree().current_scene.add_child(cam_3d)


func _new_scene():
	if get_tree() != null:
		await get_tree().node_added
		await get_tree().get_current_scene().ready
		_ready()


func find_camera_2d_or_null(nodes: Array[Node]) -> Camera2D:
	var camera: Camera2D
	
	for node in nodes:
		if node is Camera2D:
			camera = node as Camera2D
			break
			
	return camera


func find_camera_3d_or_null(nodes: Array[Node]) -> Camera3D:
	var camera: Camera3D
	
	for node in nodes:
		if node is Camera3D:
			camera = node as Camera3D
			break
			
	return camera
