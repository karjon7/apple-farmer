extends ScrollContainer
class_name SideMenu


@export var button_text: String = ""


func _ready() -> void:
	if button_text.is_empty(): button_text = "Menu %s" % get_index()
