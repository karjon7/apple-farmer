extends Control

@onready var apple_label: Label = %AppleLabel
@onready var money_label: Label = %MoneyLabel


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	apple_label.text = SaveManager.get_apples().to_short_string()
	
	var money_text: String = SaveManager.get_money().absolute().to_short_string() \
		if SaveManager.get_money().is_greater_than_equal_to(BigNumber.new(1000)) \
		else SaveManager.get_money().absolute().to_full_string(2)
	
	money_label.text = "$" + money_text if not SaveManager.get_money().is_negative() else "-$" + money_text


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("harvest"): harvest()
	
	if Input.is_action_just_pressed("sell"): sell()


func harvest() -> void:
	GameManager.add_apples(BigNumber.new(1))


func sell() -> void:
	GameManager.sell_apple(BigNumber.new(1))
