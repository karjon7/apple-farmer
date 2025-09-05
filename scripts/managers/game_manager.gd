extends Node


func add_apples(amount: BigNumber) -> void:
	SaveManager.get_apples().plus_equals(amount)


func sell_apple(amount: BigNumber) -> void:
	var sell_amount: BigNumber = amount
	if SaveManager.get_apples().is_less_than(amount): sell_amount = SaveManager.get_apples()
	
	var money_made: BigNumber = SaveManager.get_apple_price().times(sell_amount)
	
	SaveManager.get_apples().minus_equals(sell_amount)
	add_money(money_made)
	


func add_money(amount: BigNumber) -> void:
	SaveManager.get_money().plus_equals(amount)
