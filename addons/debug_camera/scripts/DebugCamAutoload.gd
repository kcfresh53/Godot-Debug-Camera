extends Node

const DebugCam2d = preload("res://addons/debug_camera/scripts/DebugCamera2D.gd")
const DebugCam3d = preload("res://addons/debug_camera/scripts/DebugCamera3D.gd")
const GizmoManger3d = preload("res://addons/debug_camera/scripts/GizmoManger3D.gd")
const DEBUG_GUI = preload("res://addons/debug_camera/scenes/debug_gui.tscn")

var cam_2d: DebugCamera2D = DebugCam2d.new()
var cam_3d: DebugCamera3D = DebugCam3d.new()
var gizmo_manager_3d: GizmoManager3D = GizmoManger3d.new()
var gui_instance := DEBUG_GUI.instantiate()


func _ready() -> void:
	get_tree().current_scene.tree_exited.connect(_new_scene)
	
	if get_viewport().get_camera_2d() != null:
		get_tree().current_scene.add_child(cam_2d)
	elif get_viewport().get_camera_3d() != null:
		get_tree().current_scene.add_child(cam_3d)
		get_tree().current_scene.add_child(gizmo_manager_3d)
	
	get_tree().current_scene.add_child(gui_instance)


func _new_scene() -> void:
	if get_tree() != null:
		await get_tree().node_added
		await get_tree().get_current_scene().ready
		_ready()
