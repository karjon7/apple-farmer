extends Control

const side_menu_button_packed = preload("uid://dqpdqcvh3nurr")

@onready var side_menu_button_holder: VBoxContainer = %SideMenuButtonHolder


func _ready() -> void:
	for child in side_menu_button_holder.get_children(): child.queue_free()
	
	for child in get_children():
		if not child is SideMenu:
			child.queue_free()
			continue
		
		var side_menu_button_instance: SideMenuButton = side_menu_button_packed.instantiate()
		
		side_menu_button_instance.text = child.button_text.to_upper()
		side_menu_button_instance.pressed.connect(change_menu.bind(child.get_index()))
		side_menu_button_instance.focus_mode = Control.FOCUS_NONE
		side_menu_button_holder.add_child(side_menu_button_instance)
	
	change_menu(0)


func change_menu(menu_index: int) -> void:
	for menu in get_children(): menu.hide()
	
	get_child(menu_index).show()
