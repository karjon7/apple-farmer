extends Button
class_name AppleMenuButton


@export var apple_data: AppleData : set = _set_apple_data

@onready var label: Label = $MarginContainer/Label
@onready var mesh_viewer: MeshViewer = $MeshViewer


func update_quantity_label() -> void:
	label.text = "x" + apple_data.quantity.to_short_string(3)


func _set_apple_data(new_value: AppleData) -> void:
	if not is_node_ready(): await ready
	apple_data = new_value
	
	apple_data.quantity_updated.connect(update_quantity_label)
	mesh_viewer.mesh = apple_data.mesh
	update_quantity_label()
