extends ScrollContainer

const apple_menu_button = preload("uid://dpdk5gsrj2qjm")

@onready var grid_container: GridContainer = $GridContainer


func _ready() -> void:
	refresh_menu()
	GameManager.apple_discovered.connect(refresh_menu)


func refresh_menu() -> void:
	for child in grid_container.get_children(): child.queue_free()
	
	for apple: AppleData in GameManager.get_discovered_apples():
		var apple_button_instance: AppleMenuButton = apple_menu_button.instantiate()
		
		apple_button_instance.apple_data = apple
		apple_button_instance.pressed.connect(GameManager.set_current_apple.bind(apple))
		grid_container.add_child(apple_button_instance)
