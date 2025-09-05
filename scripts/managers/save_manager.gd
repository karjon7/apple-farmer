extends Node

var user_data: UserData

func _ready() -> void:
	user_data = UserData.new()


func get_apples() -> BigNumber:
	return user_data.apples 


func get_money() -> BigNumber:
	return user_data.money 


func get_apple_price() -> BigNumber:
	return user_data.apple_price
