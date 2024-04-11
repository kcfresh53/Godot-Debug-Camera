@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("DebugCam", "res://addons/debug_camera/scripts/DebugCamAutoload.gd")


func _exit_tree():
	remove_autoload_singleton("DebugCam")
