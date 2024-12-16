extends Node

const DEBUG_GUI = preload("res://addons/debug_camera/scenes/debug_gui.tscn")

var cam_2d: DebugCamera2D = DebugCamera2D.new()
var cam_3d: DebugCamera3D = DebugCamera3D.new()
var gizmo_manager_3d: GizmoManager3D = GizmoManager3D.new()
var edit_history_3d: EditHistory3D = EditHistory3D.new()
var gui_instance := DEBUG_GUI.instantiate()


func _ready() -> void:
	get_tree().current_scene.tree_exited.connect(_new_scene)
	
	if get_viewport().get_camera_2d() != null:
		get_tree().current_scene.add_child(cam_2d)
	elif get_viewport().get_camera_3d() != null:
		get_tree().current_scene.add_child(cam_3d)
		get_tree().current_scene.add_child(gizmo_manager_3d)
		get_tree().current_scene.add_child(edit_history_3d)
	
	get_tree().current_scene.add_child(gui_instance)


func _new_scene() -> void:
	if get_tree() != null:
		await get_tree().node_added
		await get_tree().get_current_scene().ready
		_ready()
