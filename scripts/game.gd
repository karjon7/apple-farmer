extends Control

const APPLE_BUTTON_TWEEN_TIME: float = 0.2

var apple_button_pressed: bool = false : set = _set_apple_button_pressed
var apple_button_tween: Tween
var apple_button_default_distance: float
var flash_stamina_tween: Tween

@onready var apple_label: Label = %AppleLabel
@onready var money_label: Label = %MoneyLabel
@onready var mesh_viewer: MeshViewer = %MeshViewer
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var required_stamina_bar: ProgressBar = %RequiredStamina
@onready var stamina_wait_time_label: Label = %StaminaWaitTimeLabel


func _ready() -> void:
	GameManager.current_apple_changed.connect(_change_apple_button_mesh)
	GameManager.insufficient_stamina.connect(_flash_required_stamina_bar)
	
	apple_button_default_distance = mesh_viewer.cam_distance



func _process(delta: float) -> void:
	apple_button_pressed = Input.is_action_pressed("harvest")
	
	var money_text: String = GameManager.get_money().absolute().to_short_string() \
		if GameManager.get_money().is_greater_than_equal_to(BigNumber.new(1000)) \
		else GameManager.get_money().absolute().to_full_string(2)
	
	money_label.text = "$" + money_text if not GameManager.get_money().is_negative() else "-$" + money_text
	apple_label.text = GameManager.get_current_apple().quantity.to_short_string()
	
	
	_handle_stamina_bar()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("sell"): sell()


func harvest() -> void:
	GameManager.harvest_apples(BigNumber.new(1))


func sell() -> void:
	GameManager.sell_apple(BigNumber.new(1))


func _set_apple_button_pressed(new_value: bool) -> void:
	if new_value == apple_button_pressed: return
	
	apple_button_pressed = new_value
	
	_press_apple_button() if apple_button_pressed else _release_apple_button()


func _change_apple_button_mesh(_new_apple_data: AppleData) -> void:
	mesh_viewer.mesh = GameManager.get_current_apple().mesh


func _setup_apple_button_tween() -> void:
	apple_button_default_distance = mesh_viewer.cam_distance
	


func _press_apple_button() -> void:
	apple_button_tween = create_tween()
	apple_button_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	apple_button_tween.tween_property(
		mesh_viewer, 
		"cam_distance", 
		apple_button_default_distance * 1.05, 
		APPLE_BUTTON_TWEEN_TIME)
	
	harvest()


func _release_apple_button() -> void:
	apple_button_tween = create_tween()
	apple_button_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	apple_button_tween.tween_property(
		mesh_viewer,
		"cam_distance", 
		apple_button_default_distance, 
		APPLE_BUTTON_TWEEN_TIME)



func _flash_required_stamina_bar(required_amount: float) -> void:
	if flash_stamina_tween and flash_stamina_tween.is_running(): flash_stamina_tween.kill()
	
	flash_stamina_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	required_stamina_bar.modulate = Color.WHITE
	required_stamina_bar.value = required_amount
	flash_stamina_tween.tween_property(required_stamina_bar, "modulate", Color(1, 1, 1, 0), 1)


func _handle_stamina_bar() -> void:
	var stamina_wait_time_left: float = GameManager.harvest_stamina_wait_timer.time_left
	
	stamina_bar.value = GameManager.get_harvest_stamina()
	stamina_bar.modulate = Color(1, 1, 1, clampf(remap(GameManager.get_harvest_stamina(), 0.95, 1, 1, 0), 0, 1))
	
	stamina_wait_time_label.text = str(stamina_wait_time_left).substr(0, 4) \
		if stamina_wait_time_left > 0.0 else ""
	stamina_wait_time_label.modulate = Color(1, 1, 1, 
		clampf(remap(stamina_wait_time_left, 3, 0, 1, 0), 0, 1))
	
