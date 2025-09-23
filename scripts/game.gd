extends Control

@onready var apple_label: Label = %AppleLabel
@onready var money_label: Label = %MoneyLabel
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var required_stamina_bar: ProgressBar = %RequiredStamina
@onready var stamina_wait_time_label: Label = %StaminaWaitTimeLabel


func _ready() -> void:
	GameManager.current_apple_changed.connect(_change_apple_button_mesh)
	GameManager.insufficient_stamina.connect(_flash_required_stamina_bar)


func _process(delta: float) -> void:
	var money_text: String = GameManager.get_money().absolute().to_short_string() \
		if GameManager.get_money().is_greater_than_equal_to(BigNumber.new(1000)) \
		else GameManager.get_money().absolute().to_full_string(2)
	
	money_label.text = "$" + money_text if not GameManager.get_money().is_negative() else "-$" + money_text
	apple_label.text = GameManager.get_current_apple().quantity.to_short_string()
	
	
	_handle_stamina_bar()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("harvest"): harvest()
	
	if Input.is_action_just_pressed("sell"): sell()


func harvest() -> void:
	GameManager.harvest_apples(BigNumber.new(1))


func sell() -> void:
	GameManager.sell_apple(BigNumber.new(1))


func _flash_required_stamina_bar(required_amount: float) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	required_stamina_bar.modulate = Color.WHITE
	required_stamina_bar.value = required_amount
	tween.tween_property(required_stamina_bar, "modulate", Color(1, 1, 1, 0), 1)


func _change_apple_button_mesh(_new_apple_data: AppleData) -> void:
	%MeshViewer.mesh = GameManager.get_current_apple().mesh


func _handle_stamina_bar() -> void:
	var stamina_wait_time_left: float = GameManager.harvest_stamina_wait_timer.time_left
	
	stamina_bar.value = GameManager.get_harvest_stamina()
	stamina_bar.modulate = Color(1, 1, 1, clampf(remap(GameManager.get_harvest_stamina(), 0.95, 1, 1, 0), 0, 1))
	
	stamina_wait_time_label.text = str(stamina_wait_time_left).substr(0, 4) \
		if stamina_wait_time_left > 0.0 else ""
	stamina_wait_time_label.modulate = Color(1, 1, 1, 
		clampf(remap(stamina_wait_time_left, 3, 0, 1, 0), 0, 1))
	
