class_name GizmoManager3D
extends Node3D

var ray_length: float = 1000.0
var active: bool = false:
	set(value):
		active = value
		if _gizmo.target:
			_gizmo.visible = active
var selectable_areas: bool = false

var _gizmo: Gizmo3D = Gizmo3D.new()

signal object_selected(node: Node3D)
signal gizmo_updated_transform


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_gizmo.visible = active
	_gizmo.updated_transform.connect(func(): gizmo_updated_transform.emit())
	get_tree().get_root().add_child.call_deferred(_gizmo)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT\
	and not _gizmo.editing and active:
		_process_mouse_click(event)


func _process_mouse_click(event: InputEventMouseButton) -> void:
	if not (get_viewport().get_camera_3d()):
		return  # Ensure there's a Camera3D in the viewport
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	var from: Vector3 = camera.project_ray_origin(event.position)
	var to: Vector3 = from + camera.project_ray_normal(event.position) * ray_length
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collide_with_areas = selectable_areas
	ray_query.collide_with_bodies = true
	ray_query.collision_mask = 0xFFFFFFFF  # Check all layers

	var result: Dictionary = space_state.intersect_ray(ray_query)
	
	if result and result.has("collider"):
		var collider: Node3D = result.collider
		#print("Clicked on object:", collider.name)
		_manage_gizmo(collider)
		return
	else:
		#print("Deselected object")
		_manage_gizmo(null)
	
	# Fallback to geometry-based detection if no physics collision
	var mouse_pos: Vector2 = event.position
	var camera_ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var camera_ray_normal: Vector3 = camera.project_ray_normal(mouse_pos)
	
	var closest_object: Node3D = _find_closest_object_under_mouse(camera_ray_origin, camera_ray_normal)
	if closest_object:
		#print("Clicked on object:", closest_object.name)
		_manage_gizmo(closest_object)


# Custom AABB ray intersection check
func _ray_intersects_aabb(ray_origin: Vector3, ray_dir: Vector3, aabb: AABB) -> Vector3:
	var t1: float = (aabb.position.x - ray_origin.x) / ray_dir.x
	var t2: float = (aabb.position.x + aabb.size.x - ray_origin.x) / ray_dir.x
	var t3: float = (aabb.position.y - ray_origin.y) / ray_dir.y
	var t4: float = (aabb.position.y + aabb.size.y - ray_origin.y) / ray_dir.y
	var t5: float = (aabb.position.z - ray_origin.z) / ray_dir.z
	var t6: float = (aabb.position.z + aabb.size.z - ray_origin.z) / ray_dir.z
	
	var tmin: float = max(max(min(t1, t2), min(t3, t4)), min(t5, t6))
	var tmax: float = min(min(max(t1, t2), max(t3, t4)), max(t5, t6))
	
	# Check if ray intersects AABB
	if tmax < 0 or tmin > tmax:
		return Vector3.ZERO
	
	# Calculate intersection point
	var intersection_point: Vector3 = ray_origin + ray_dir * tmin
	return intersection_point


# Dedicated recursive method for finding the closest object
func _find_closest_object_under_mouse(ray_origin: Vector3, ray_normal: Vector3) -> Node3D:
	return _recursive_object_search(get_tree().root, ray_origin, ray_normal)


# Recursive search method
func _recursive_object_search(node: Node, ray_origin: Vector3, ray_normal: Vector3) -> Node3D:
	var closest_object: Node3D = null
	var closest_distance: float = INF
	
	# Handle CSGShape3D and MeshInstance3D nodes
	if node is CSGShape3D or node is MeshInstance3D:
		var aabb: AABB = node.global_transform * node.get_aabb()
		var intersection_point: Vector3 = _ray_intersects_aabb(ray_origin, ray_normal, aabb)
		
		if intersection_point != Vector3.ZERO:
			closest_object = node
			closest_distance = ray_origin.distance_to(intersection_point)
	
		# Additional triangle intersection for MeshInstance3D
		if node is MeshInstance3D:
			var mesh: Mesh = node.mesh
			if mesh and mesh.get_surface_count() > 0:
				# Safely check surface count and arrays
				for surface_idx in mesh.get_surface_count():
					var arrays: Array = mesh.surface_get_arrays(surface_idx)
					
					# Check if vertex array exists and is of correct type
					if arrays.size() > Mesh.ARRAY_VERTEX and \
					   arrays[Mesh.ARRAY_VERTEX] is PackedVector3Array and \
					   arrays[Mesh.ARRAY_VERTEX].size() > 2:
						var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
						
						# Check each triangle in the mesh
						for i in range(0, vertices.size() - 2, 3):
							var v0: Vector3 = node.global_transform * vertices[i]
							var v1: Vector3 = node.global_transform * vertices[i + 1]
							var v2: Vector3 = node.global_transform * vertices[i + 2]
							
							var intersection: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_normal, v0, v1, v2)
							
							if intersection != null:
								var distance: float = ray_origin.distance_to(intersection)
								if distance < closest_distance:
									closest_distance = distance
									closest_object = node
									break
	
	# Recursively search child nodes
	for child in node.get_children():
		var child_result: Node3D = _recursive_object_search(child, ray_origin, ray_normal)
		if child_result:
			var distance: float = ray_origin.distance_to(child_result.global_position)
			if distance < closest_distance:
				closest_object = child_result
				closest_distance = distance
	
	return closest_object


func _manage_gizmo(node: Node3D) -> void:
	if node:
		_gizmo.visible = true
	else:
		_gizmo.visible = false
	
	_gizmo.target = node
	object_selected.emit(node)


func update_gizmo_mode(mode: int) -> void:
	_gizmo.mode = mode
