extends Resource
class_name AppleData

signal quantity_updated

@export var name: String = ""
@export_multiline var description: String = ""
@export var starting_price_mantissa: float = 0.0
@export var starting_price_exponent: int = 0
@export var mesh: PackedScene

var quantity: BigNumber = BigNumber.new(0)
var max_quantity: BigNumber = BigNumber.new(100)
var price: BigNumber = BigNumber.new(0) : get = _get_price


func _init() -> void:
	quantity.updated.connect(quantity_updated.emit)


func _get_price() -> BigNumber:
	price = BigNumber.new(starting_price_mantissa, starting_price_exponent)
	
	return price
