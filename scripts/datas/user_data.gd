extends Resource
class_name UserData

var apple_inventory: Array[AppleData] = [ #AKA Discovered Apples
	GameManager.APPLES[0],
	GameManager.APPLES[1],
]
var current_apple: AppleData = apple_inventory[0]
var max_apple_storage: BigNumber = BigNumber.new(100)
var money: BigNumber = BigNumber.new(0)

var harvest_stamina: float = 1.0 #Normalized
var harvest_stamina_recharge_time: float = 60.0 #Time to go from empty - max in secs
var harvest_stamina_recharge_wait_time: float = 10.0 
var harvest_stamina_per_apple_effort: float = 0.1


func get_apple_inventory_space() -> BigNumber:
	var apples_sum: BigNumber = BigNumber.new(0)
	
	for apple_data in apple_inventory:
		apples_sum.plus_equals(apple_data.quantity)
	
	return max_apple_storage.minus(apples_sum)
