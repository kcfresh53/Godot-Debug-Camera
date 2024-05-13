@tool
extends EditorPlugin


func _enter_tree():
	if not ProjectSettings.has_setting("autoload/DebugCam"):
		add_autoload_singleton("DebugCam", "res://addons/debug_camera/scripts/DebugCamAutoload.gd")


func _exit_tree():
	if ProjectSettings.has_setting("autoload/DebugCam"):
		remove_autoload_singleton("DebugCam")
