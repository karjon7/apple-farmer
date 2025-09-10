extends Node

signal apple_discovered(discovered_apple: AppleData)
signal current_apple_changed(changed_to: AppleData)

const APPLES: Array[AppleData] = [
	preload("uid://obqhdpp7447d"),
	preload("uid://bmsaw5ik6gd6g"),
]

var user_data: UserData = UserData.new()


func get_discovered_apples() -> Array:
	return user_data.discovered_apples


func set_current_apple(new_apple_data: AppleData) -> void:
	user_data.current_apple = new_apple_data
	current_apple_changed.emit(new_apple_data)


func get_current_apple() -> AppleData:
	return user_data.current_apple


func get_money() -> BigNumber:
	return user_data.money


func harvest_apples(amount: BigNumber) -> void:
	get_current_apple().quantity.plus_equals(amount)


func sell_apple(amount: BigNumber) -> void:
	var sell_amount: BigNumber = amount if get_current_apple().quantity.is_greater_than(amount) \
		else get_current_apple().quantity
	var money_made: BigNumber = get_current_apple().price.times(sell_amount)
	
	get_current_apple().quantity.minus_equals(sell_amount)
	get_money().plus_equals(money_made)
