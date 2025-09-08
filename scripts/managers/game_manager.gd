extends Node

var user_data: UserData = UserData.new()


func get_apples() -> BigNumber:
	return user_data.apples


func get_money() -> BigNumber:
	return user_data.money


func harvest_apples(amount: BigNumber) -> void:
	user_data.apples.plus_equals(amount)


func sell_apple(amount: BigNumber) -> void:
	var sell_amount: BigNumber = amount if user_data.apples.is_greater_than(amount) \
		else user_data.apples
	var money_made: BigNumber = user_data.apple_price.times(sell_amount)
	
	user_data.apples.minus_equals(sell_amount)
	add_money(money_made)


func add_money(amount: BigNumber) -> void:
	user_data.money.plus_equals(amount)
