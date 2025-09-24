extends Node

signal apple_discovered(discovered_apple: AppleData)
signal current_apple_changed(changed_to: AppleData)
signal insufficient_stamina(required_stamina: float)

const APPLES: Array[AppleData] = [
	preload("uid://obqhdpp7447d"),
	preload("uid://bmsaw5ik6gd6g"),
]
const big_to_float_precision: int = 10

var user_data: UserData = UserData.new()
var harvest_stamina_wait_timer: Timer = Timer.new()


func _ready() -> void:
	harvest_stamina_wait_timer.one_shot = true
	add_child(harvest_stamina_wait_timer)


func _process(delta: float) -> void:
	_handle_harvest_stamina(delta)


#USERDATA HELPER FUNCTIONS

func get_apple_inventory() -> Array:
	return user_data.apple_inventory


func set_current_apple(new_apple_data: AppleData) -> void:
	user_data.current_apple = new_apple_data
	current_apple_changed.emit(new_apple_data)


func get_current_apple() -> AppleData:
	return user_data.current_apple


func get_money() -> BigNumber:
	return user_data.money


func get_harvest_stamina() -> float:
	return user_data.harvest_stamina


func get_harvest_stamina_max() -> BigNumber:
	return user_data.harvest_stamina_max


#

func harvest_apples(amount: BigNumber) -> void:
	var increment_amount: BigNumber = BigNumber.big_number_min(user_data.get_apple_inventory_space(), amount)
	var required_stamina_big: BigNumber = get_current_apple().effort.times(
		BigNumber.new(user_data.harvest_stamina_per_apple_effort)
		)
	var required_stamina_float: float = float(
		BigNumber.big_number_min(required_stamina_big, BigNumber.new(1.0)).to_full_string(big_to_float_precision)
		)
	
	
	if get_harvest_stamina() < required_stamina_float: 
		insufficient_stamina.emit(required_stamina_float)
		return
	
	get_current_apple().quantity.plus_equals(increment_amount)
	user_data.harvest_stamina -= required_stamina_float
	harvest_stamina_wait_timer.start(user_data.harvest_stamina_recharge_wait_time)


func sell_apple(amount: BigNumber) -> void:
	var sell_amount: BigNumber = BigNumber.big_number_min(amount, get_current_apple().quantity)
	var money_made: BigNumber = get_current_apple().price.times(sell_amount)
	
	get_current_apple().quantity.minus_equals(sell_amount)
	get_money().plus_equals(money_made)


#HANDLERS

func _handle_harvest_stamina(delta: float) -> void:
	if user_data.harvest_stamina == 1.0: return
	if not harvest_stamina_wait_timer.is_stopped(): return
	
	var add_to_stamina: float = 1 / user_data.harvest_stamina_recharge_time * delta
	
	user_data.harvest_stamina = clampf(user_data.harvest_stamina + add_to_stamina, 0, 1)
