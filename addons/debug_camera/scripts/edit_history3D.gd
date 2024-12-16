class_name EditHistory3D
extends Node

# I plan to make a Typed Dictionary in Godot 4.4 and make this
# one array
var _transform_history: Array[Transform3D]
var _object_history: Array[Node3D]


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func undo_last_action() -> void:
	# Ensure both histories have the same number of elements and are not empty
	if _transform_history.size() > 1 and _object_history.size() > 1 and _transform_history.size() == _object_history.size():
		var last_object: Node3D = _object_history.pop_at(-2)
		var last_transform: Transform3D = _transform_history.pop_at(-2)
		
		# Apply the full transform to the last object
		if last_object:
			last_object.transform = last_transform
	else:
		print("No actions to undo or mismatched history.")

# Optional: Method to record an action
func record_action(object: Node3D) -> void:
	_object_history.append(object)
	_transform_history.append(object.transform)
