@tool
extends EditorPlugin


func _enter_tree():
	# remove gizmo 3d from appearing in the editor node tree
	remove_custom_type("Gizmo3D")
	
	# add debug camera autoload script
	if not ProjectSettings.has_setting("autoload/DebugCam"):
		add_autoload_singleton("DebugCam", "res://addons/debug_camera/scripts/DebugCamAutoload.gd")


func _exit_tree():
	if ProjectSettings.has_setting("autoload/DebugCam"):
		remove_autoload_singleton("DebugCam")
