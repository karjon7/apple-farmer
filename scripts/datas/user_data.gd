extends Resource
class_name UserData

var discovered_apples: Array[AppleData] = [
	GameManager.APPLES[0],
	GameManager.APPLES[1],
]
var current_apple: AppleData = discovered_apples[0]
var money: BigNumber = BigNumber.new(0)
