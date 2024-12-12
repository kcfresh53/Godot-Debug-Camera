extends CanvasLayer

@onready var pause_game_check_box: CheckBox = %PauseGameCheckBox
@onready var selectable_areas_check_box: CheckBox = %SelectableAreasCheckBox
@onready var selected_node_label: Label = %SelectedNodeLabel
@onready var node_properties_container: BoxContainer = %NodePropertiesContainer
@onready var selected_node_name_label: Label = %SelectedNodeNameLabel
@onready var selected_node_position_label: Label = %SelectedNodePositionLabel
@onready var selected_node_rotation_label: Label = %SelectedNodeRotationLabel
@onready var selected_node_scale_label: Label = %SelectedNodeScaleLabel
@onready var fps_label: Label = %FPSLabel
@onready var process_label: Label = %ProcessLabel
@onready var physics_process_label: Label = %PhysicsProcessLabel
@onready var cpu_frame_time_label: Label = %CPUFrameTimeLabel
@onready var gpu_frame_time_label: Label = %GPUFrameTimeLabel
@onready var static_memory_label: Label = %StaticMemoryLabel
@onready var objects_label: Label = %ObjectsLabel

var _selected_node: Node
var _show_debug_collisions_hint: bool:
	set(visible):
		print("Set show_debug_collisions_hint: ", visible)
		var tree: SceneTree = get_tree()
		# https://github.com/godotengine/godot-proposals/issues/2072
		tree.debug_collisions_hint = visible

		# Traverse tree to call toggle collision visibility
		var node_stack: Array[Node] = [tree.get_root()]
		while not node_stack.is_empty():
			var node: Node = node_stack.pop_back()
			if is_instance_valid(node):
				if   node is CollisionShape2D \
					or node is CollisionPolygon2D \
					or node is CollisionObject2D:
					# queue_redraw on instances of
					node.queue_redraw()
				elif node is TileMap:
					# use visibility mode to force redraw
					node.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
					node.collision_visibility_mode = TileMap.VISIBILITY_MODE_DEFAULT
				elif node is RayCast3D \
					or node is CollisionShape3D \
					or node is CollisionPolygon3D \
					or node is CollisionObject3D \
					or node is GPUParticlesCollision3D \
					or node is GPUParticlesCollisionBox3D \
					or node is GPUParticlesCollisionHeightField3D \
					or node is GPUParticlesCollisionSDF3D \
					or node is GPUParticlesCollisionSphere3D:
					# remove and re-add the node to the tree to force a redraw
					# https://github.com/godotengine/godot/blob/26b1fd0d842fa3c2f090ead47e8ea7cd2d6515e1/scene/3d/collision_object_3d.cpp#L39
					var parent: Node = node.get_parent()
					if parent:
						parent.remove_child(node)
						parent.add_child(node)
				node_stack.append_array(node.get_children())
	get:
		return get_tree().debug_collisions_hint


func _ready() -> void:
	visible = false
	process_mode = PROCESS_MODE_ALWAYS
	DebugCam.gizmo_manager_3d.object_selected.connect(_on_3d_object_selected)
	DebugCam.gizmo_manager_3d.gizmo_updated_transform.connect(func():
		if _selected_node != null:
			_update_properties_text(_selected_node))


func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	process_label.text = "Process: " + str(Engine.get_process_frames())
	physics_process_label.text = "Physics Process: " + str(Engine.get_physics_frames())
	cpu_frame_time_label.text = "CPU Frame Time (ms): " + str(RenderingServer.viewport_get_measured_render_time_cpu(get_tree().root.get_viewport_rid())  + RenderingServer.get_frame_setup_time_cpu())
	gpu_frame_time_label.text = "GPU Frame Time (ms): " + str(RenderingServer.viewport_get_measured_render_time_gpu(get_tree().root.get_viewport_rid()))
	static_memory_label.text = "Static Memory: " + str(Performance.get_monitor(Performance.MEMORY_STATIC))
	objects_label.text = "Objects: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))


func _on_3d_object_selected(node: Node3D) -> void:
	_selected_node = node
	_update_properties_text(node)


func _update_properties_text(node: Node) -> void:
	if node:
		node_properties_container.visible = true
		selected_node_name_label.text = "Name: " + node.name
		selected_node_position_label.text = "Position: " + str(node.global_position)
		selected_node_rotation_label.text = "Rotation: " + str(node.rotation)
		selected_node_scale_label.text = "Scale: " + str(node.scale)


func _on_visibility_changed() -> void:
	if not visible:
		_selected_node = null
	else:
		pause_game_check_box.button_pressed = get_tree().paused
		selectable_areas_check_box.button_pressed = DebugCam.gizmo_manager_3d.selectable_areas
		if _selected_node == null:
			node_properties_container.visible = false


func _on_pause_game_check_box_toggled(toggled_on: bool) -> void:
	get_tree().paused = toggled_on


func _on_visible_collision_check_box_toggled(toggled_on: bool) -> void:
	_show_debug_collisions_hint = toggled_on


func _on_gizmo_option_button_item_selected(index: int) -> void:
	DebugCam.gizmo_manager_3d.update_gizmo_mode(index)


func _on_selectable_areas_check_box_toggled(toggled_on: bool) -> void:
	DebugCam.gizmo_manager_3d.selectable_areas = toggled_on
