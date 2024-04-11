extends Node

var debug_cam_2d = preload("res://addons/debug_camera/scripts/DebugCamera2D.gd")
var debug_cam_3d = preload("res://addons/debug_camera/scripts/DebugCamera3D.gd")


func _ready() -> void:
	var cam_2d := debug_cam_2d.new()
	var cam_3d := debug_cam_3d.new()
	
	get_tree().current_scene.tree_exited.connect(_new_scene)
	
	if get_viewport().get_camera_2d() != null:
		get_tree().current_scene.add_child(cam_2d)
	elif get_viewport().get_camera_3d() != null:
		get_tree().current_scene.add_child(cam_3d)


func _new_scene():
	if get_tree() != null:
		await get_tree().node_added
		await get_tree().get_current_scene().ready
		_ready()
