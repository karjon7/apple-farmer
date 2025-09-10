@tool
extends SubViewportContainer
class_name MeshViewer

const TEST_ITEM = preload("res://prefab/meshes/test_item.tscn")

@export var rotation_on: bool = true
@export_range(0.0, 1.0, 0.1, "or_greater") var rotations_per_second: float = 0.5
@export_range(0.0, 5.0, 0.1, "or_greater", "suffix:m") var cam_distance: float = 3.0 : set = _set_cam_distance
@export_range(-1, 1, 0.1, "or_greater", "or_less") var cam_pitch: float = 0.0 : set = _set_cam_pitch
@export_range(-1, 1, 0.01, "or_greater", "or_less") var cam_offset: float = 0.0 : set = _set_cam_offset
@export var mesh: PackedScene : set = _set_mesh

@onready var cam_pivot: Node3D = %CamPivot
@onready var camera: Camera3D = %Camera3D
@onready var mesh_holder: Node3D = %MeshHolder


func _process(delta: float) -> void:
	if not rotation_on: return
	
	mesh_holder.rotation_degrees.y = wrapf(
		mesh_holder.rotation_degrees.y + 360.0 * rotations_per_second * delta, 0.0, 360.0
		)


func _set_cam_distance(new_value: float) -> void:
	if not is_node_ready(): await ready
	cam_distance = new_value
	
	camera.position.z = cam_distance


func _set_cam_pitch(new_value: float) -> void:
	if not is_node_ready(): await ready
	cam_pitch = new_value
	
	cam_pivot.rotation.x = PI * cam_pitch


func _set_cam_offset(new_value: float) -> void:
	if not is_node_ready(): await ready
	cam_offset = new_value
	
	camera.position.y = cam_offset


func _set_mesh(new_value: PackedScene) -> void:
	if not is_node_ready(): await ready
	mesh = new_value
	
	for child in mesh_holder.get_children(): child.queue_free()
	mesh_holder.add_child(mesh.instantiate() if mesh else TEST_ITEM.instantiate())
	
	
